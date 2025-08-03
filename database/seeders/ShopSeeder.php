<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Shop;
use App\Models\Product;
use App\Models\Sale;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class ShopSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create shop owners
        $owner1 = User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => Hash::make('password'),
            'role' => 'owner',
            'is_active' => true,
        ]);

        $owner2 = User::create([
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'password' => Hash::make('password'),
            'role' => 'owner',
            'is_active' => true,
        ]);

        // Create shops
        $shop1 = Shop::create([
            'name' => 'Tech Store',
            'slug' => 'tech-store',
            'description' => 'Electronics and gadgets store',
            'address' => '123 Tech Street, Silicon Valley',
            'phone' => '+1-555-0101',
            'email' => 'tech@store.com',
            'currency' => 'USD',
            'timezone' => 'America/Los_Angeles',
            'owner_id' => $owner1->id,
        ]);

        $shop2 = Shop::create([
            'name' => 'Fashion Boutique',
            'slug' => 'fashion-boutique',
            'description' => 'Trendy clothing and accessories',
            'address' => '456 Fashion Ave, New York',
            'phone' => '+1-555-0202',
            'email' => 'hello@fashionboutique.com',
            'currency' => 'USD',
            'timezone' => 'America/New_York',
            'owner_id' => $owner2->id,
        ]);

        // Associate owners with their shops
        $owner1->update(['shop_id' => $shop1->id]);
        $owner2->update(['shop_id' => $shop2->id]);

        // Create sales persons for each shop
        $salesPerson1 = User::create([
            'name' => 'Mike Johnson',
            'email' => 'mike@techstore.com',
            'password' => Hash::make('password'),
            'role' => 'sales_person',
            'shop_id' => $shop1->id,
            'is_active' => true,
        ]);

        $salesPerson2 = User::create([
            'name' => 'Sarah Wilson',
            'email' => 'sarah@fashionboutique.com',
            'password' => Hash::make('password'),
            'role' => 'sales_person',
            'shop_id' => $shop2->id,
            'is_active' => true,
        ]);

        // Create products for each shop
        $techProducts = [
            ['name' => 'iPhone 15', 'price' => 999.00, 'cost_price' => 750.00, 'category' => 'Smartphones', 'stock_quantity' => 50],
            ['name' => 'MacBook Pro', 'price' => 2499.00, 'cost_price' => 2000.00, 'category' => 'Laptops', 'stock_quantity' => 20],
            ['name' => 'AirPods Pro', 'price' => 249.00, 'cost_price' => 180.00, 'category' => 'Audio', 'stock_quantity' => 100],
            ['name' => 'iPad Air', 'price' => 599.00, 'cost_price' => 450.00, 'category' => 'Tablets', 'stock_quantity' => 30],
        ];

        foreach ($techProducts as $productData) {
            Product::create([
                'name' => $productData['name'],
                'description' => 'High-quality ' . $productData['name'],
                'price' => $productData['price'],
                'cost_price' => $productData['cost_price'],
                'category' => $productData['category'],
                'stock_quantity' => $productData['stock_quantity'],
                'barcode' => 'TECH' . rand(100000, 999999),
                'sku' => 'TECH-' . strtoupper(str_replace(' ', '-', $productData['name'])),
                'shop_id' => $shop1->id,
            ]);
        }

        $fashionProducts = [
            ['name' => 'Designer Dress', 'price' => 199.00, 'cost_price' => 120.00, 'category' => 'Dresses', 'stock_quantity' => 25],
            ['name' => 'Leather Handbag', 'price' => 299.00, 'cost_price' => 180.00, 'category' => 'Accessories', 'stock_quantity' => 15],
            ['name' => 'Casual Jeans', 'price' => 89.00, 'cost_price' => 50.00, 'category' => 'Pants', 'stock_quantity' => 40],
            ['name' => 'Silk Scarf', 'price' => 79.00, 'cost_price' => 35.00, 'category' => 'Accessories', 'stock_quantity' => 60],
        ];

        foreach ($fashionProducts as $productData) {
            Product::create([
                'name' => $productData['name'],
                'description' => 'Stylish ' . $productData['name'],
                'price' => $productData['price'],
                'cost_price' => $productData['cost_price'],
                'category' => $productData['category'],
                'stock_quantity' => $productData['stock_quantity'],
                'barcode' => 'FASH' . rand(100000, 999999),
                'sku' => 'FASH-' . strtoupper(str_replace(' ', '-', $productData['name'])),
                'shop_id' => $shop2->id,
            ]);
        }

        $this->command->info('Shop system seeded successfully!');
        $this->command->info('Owners created: john@example.com, jane@example.com');
        $this->command->info('Sales persons created: mike@techstore.com, sarah@fashionboutique.com');
        $this->command->info('All passwords: password');
    }
}
