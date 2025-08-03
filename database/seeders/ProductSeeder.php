<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $products = [
            [
                'name' => 'Coca Cola 500ml',
                'description' => 'Refreshing cola drink',
                'price' => 2.50,
                'cost_price' => 1.50,
                'stock_quantity' => 100,
                'barcode' => '1234567890123',
                'sku' => 'COKE-500ML',
                'category' => 'Beverages',
                'is_active' => true,
            ],
            [
                'name' => 'Bread Loaf',
                'description' => 'Fresh white bread',
                'price' => 3.00,
                'cost_price' => 1.80,
                'stock_quantity' => 50,
                'barcode' => '2345678901234',
                'sku' => 'BREAD-WHITE',
                'category' => 'Bakery',
                'is_active' => true,
            ],
            [
                'name' => 'Milk 1L',
                'description' => 'Fresh whole milk',
                'price' => 4.50,
                'cost_price' => 3.00,
                'stock_quantity' => 75,
                'barcode' => '3456789012345',
                'sku' => 'MILK-1L',
                'category' => 'Dairy',
                'is_active' => true,
            ],
            [
                'name' => 'Bananas (per kg)',
                'description' => 'Fresh ripe bananas',
                'price' => 3.99,
                'cost_price' => 2.50,
                'stock_quantity' => 30,
                'barcode' => '4567890123456',
                'sku' => 'BANANA-KG',
                'category' => 'Fruits',
                'is_active' => true,
            ],
            [
                'name' => 'Rice 2kg',
                'description' => 'Premium jasmine rice',
                'price' => 8.99,
                'cost_price' => 6.00,
                'stock_quantity' => 25,
                'barcode' => '5678901234567',
                'sku' => 'RICE-2KG',
                'category' => 'Grains',
                'is_active' => true,
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
