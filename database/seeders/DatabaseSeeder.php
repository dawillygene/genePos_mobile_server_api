<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            ShopSeeder::class, // Creates shops, owners, sales persons, and shop-specific products
            // Additional seeders can be added here if needed
        ]);
    }
}
