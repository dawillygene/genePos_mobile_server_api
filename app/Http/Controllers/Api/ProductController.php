<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProductController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        if (!$user->shop_id) {
            return response()->json(['message' => 'User is not associated with any shop'], 400);
        }
        
        $products = Product::where('shop_id', $user->shop_id)
            ->where('is_active', true)
            ->get();
        return response()->json($products);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        
        if (!$user->shop_id) {
            return response()->json(['message' => 'User is not associated with any shop'], 400);
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'required|numeric|min:0',
            'category' => 'required|string|max:255',
            'stock_quantity' => 'integer|min:0',
            'barcode' => 'string|unique:products,barcode',
            'sku' => 'string|unique:products,sku',
        ]);

        $productData = $request->all();
        $productData['shop_id'] = $user->shop_id;

        $product = Product::create($productData);
        return response()->json($product, 201);
    }

    public function show(Product $product)
    {
        $user = Auth::user();
        
        // Check if user has access to this product's shop
        if ($user->shop_id !== $product->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }
        
        return response()->json($product);
    }

    public function update(Request $request, Product $product)
    {
        $user = Auth::user();
        
        // Check if user has access to this product's shop
        if ($user->shop_id !== $product->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $request->validate([
            'name' => 'string|max:255',
            'price' => 'numeric|min:0',
            'cost_price' => 'numeric|min:0',
            'category' => 'string|max:255',
            'stock_quantity' => 'integer|min:0',
            'barcode' => 'string|unique:products,barcode,' . $product->id,
            'sku' => 'string|unique:products,sku,' . $product->id,
        ]);

        $product->update($request->all());
        return response()->json($product);
    }

    public function destroy(Product $product)
    {
        $user = Auth::user();
        
        // Check if user has access to this product's shop
        if ($user->shop_id !== $product->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }
        
        $product->update(['is_active' => false]);
        return response()->json(['message' => 'Product deactivated successfully']);
    }
}
