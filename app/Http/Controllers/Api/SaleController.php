<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class SaleController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        if (!$user->shop_id) {
            return response()->json(['message' => 'User is not associated with any shop'], 400);
        }
        
        $sales = Sale::where('shop_id', $user->shop_id)
            ->with(['items.product', 'cashier'])
            ->orderBy('created_at', 'desc')
            ->get();
        return response()->json($sales);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        
        if (!$user->shop_id) {
            return response()->json(['message' => 'User is not associated with any shop'], 400);
        }

        $request->validate([
            'subtotal' => 'required|numeric|min:0',
            'tax' => 'required|numeric|min:0',
            'total' => 'required|numeric|min:0',
            'payment_method' => 'required|in:cash,card,mobile,mixed',
            'cashier_name' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
            'items.*.subtotal' => 'required|numeric|min:0',
        ]);

        // Verify all products belong to the user's shop
        $productIds = collect($request->items)->pluck('product_id');
        $invalidProducts = Product::whereIn('id', $productIds)
            ->where('shop_id', '!=', $user->shop_id)
            ->count();
            
        if ($invalidProducts > 0) {
            return response()->json(['message' => 'Some products do not belong to your shop'], 403);
        }

        DB::beginTransaction();
        
        try {
            $saleData = $request->except('items');
            $saleData['cashier_id'] = $user->id;
            $saleData['shop_id'] = $user->shop_id;
            
            $sale = Sale::create($saleData);
            
            foreach ($request->items as $item) {
                SaleItem::create([
                    'sale_id' => $sale->id,
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'unit_price' => $item['unit_price'],
                    'discount' => $item['discount'] ?? 0,
                    'subtotal' => $item['subtotal'],
                ]);
                
                // Update product stock
                $product = Product::find($item['product_id']);
                $product->decrement('stock_quantity', $item['quantity']);
            }
            
            $sale->update(['status' => 'completed']);
            
            DB::commit();
            
            return response()->json($sale->load(['items.product', 'cashier']), 201);
        } catch (\Exception $e) {
            DB::rollback();
            return response()->json(['message' => 'Failed to create sale'], 500);
        }
    }

    public function show(Sale $sale)
    {
        $user = Auth::user();
        
        // Check if user has access to this sale's shop
        if ($user->shop_id !== $sale->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }
        
        return response()->json($sale->load(['items.product', 'cashier']));
    }

    public function update(Request $request, Sale $sale)
    {
        $user = Auth::user();
        
        // Check if user has access to this sale's shop
        if ($user->shop_id !== $sale->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $request->validate([
            'status' => 'in:pending,completed,cancelled,refunded',
            'notes' => 'string',
        ]);

        $sale->update($request->only(['status', 'notes']));
        return response()->json($sale);
    }

    public function destroy(Sale $sale)
    {
        $user = Auth::user();
        
        // Check if user has access to this sale's shop
        if ($user->shop_id !== $sale->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }
        
        if ($sale->status === 'completed') {
            return response()->json(['message' => 'Cannot delete completed sale'], 422);
        }
        
        $sale->delete();
        return response()->json(['message' => 'Sale deleted successfully']);
    }
}
