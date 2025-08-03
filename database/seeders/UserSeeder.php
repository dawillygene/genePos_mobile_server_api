<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@genepos.com',
            'role' => 'admin',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Manager User',
            'email' => 'manager@genepos.com',
            'role' => 'manager',
            'is_active' => true,
        ]);

        User::create([
            'name' => 'Cashier User',
            'email' => 'cashier@genepos.com',
            'role' => 'cashier',
            'is_active' => true,
        ]);
    }
}
