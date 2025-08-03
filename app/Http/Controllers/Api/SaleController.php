<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sale;
use App\Models\SaleItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SaleController extends Controller
{
    public function index()
    {
        $sales = Sale::with(['items.product', 'cashier'])->orderBy('created_at', 'desc')->get();
        return response()->json($sales);
    }

    public function store(Request $request)
    {
        $request->validate([
            'subtotal' => 'required|numeric|min:0',
            'tax' => 'required|numeric|min:0',
            'total' => 'required|numeric|min:0',
            'payment_method' => 'required|in:cash,card,mobile,mixed',
            'cashier_id' => 'required|exists:users,id',
            'cashier_name' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.unit_price' => 'required|numeric|min:0',
            'items.*.subtotal' => 'required|numeric|min:0',
        ]);

        DB::beginTransaction();
        
        try {
            $sale = Sale::create($request->except('items'));
            
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
        return response()->json($sale->load(['items.product', 'cashier']));
    }

    public function update(Request $request, Sale $sale)
    {
        $request->validate([
            'status' => 'in:pending,completed,cancelled,refunded',
            'notes' => 'string',
        ]);

        $sale->update($request->only(['status', 'notes']));
        return response()->json($sale);
    }

    public function destroy(Sale $sale)
    {
        if ($sale->status === 'completed') {
            return response()->json(['message' => 'Cannot delete completed sale'], 422);
        }
        
        $sale->delete();
        return response()->json(['message' => 'Sale deleted successfully']);
    }
}
