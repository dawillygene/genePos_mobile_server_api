<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::where('is_active', true)->get();
        return response()->json($products);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'cost_price' => 'required|numeric|min:0',
            'category' => 'required|string|max:255',
            'stock_quantity' => 'integer|min:0',
            'barcode' => 'string|unique:products,barcode',
            'sku' => 'string|unique:products,sku',
        ]);

        $product = Product::create($request->all());
        return response()->json($product, 201);
    }

    public function show(Product $product)
    {
        return response()->json($product);
    }

    public function update(Request $request, Product $product)
    {
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
        $product->update(['is_active' => false]);
        return response()->json(['message' => 'Product deactivated successfully']);
    }
}
