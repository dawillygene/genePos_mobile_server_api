# Laravel Backend API Setup for GenePos

This guide will help you set up the Laravel backend API for the GenePos point-of-sale system.

## Prerequisites

- PHP 8.1 or higher
- Composer
- MySQL 8.0 or higher
- Node.js and npm (for frontend assets if needed)

## Step 1: Create Laravel Project

```bash
composer create-project laravel/laravel genepos-api
cd genepos-api
```

## Step 2: Install Required Packages

```bash
# Install Laravel Sanctum for API authentication
    composer require laravel/sanctum

# Install Google Sign-in verification
composer require google/apiclient

# Install other useful packages
composer require spatie/laravel-cors
composer require barryvdh/laravel-cors
```

## Step 3: Database Configuration

1. Create a MySQL database named `genepos`

2. Update your `.env` file:
```env
APP_NAME=GenePos-API
APP_ENV=local
APP_KEY=base64:your-app-key-here
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=genepos
DB_USERNAME=venlit
DB_PASSWORD=venlit

# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# CORS Configuration
SANCTUM_STATEFUL_DOMAINS=localhost:3000,127.0.0.1:3000
```

## Step 4: Create Database Migrations

```bash
# Create migrations
php artisan make:migration create_users_table
php artisan make:migration create_products_table
php artisan make:migration create_categories_table
php artisan make:migration create_sales_table
php artisan make:migration create_sale_items_table
```

### Users Migration
```php
<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_users_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('google_id')->unique()->nullable();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password')->nullable();
            $table->string('phone')->nullable();
            $table->enum('role', ['admin', 'manager', 'cashier'])->default('cashier');
            $table->boolean('is_active')->default(true);
            $table->string('profile_image_url')->nullable();
            $table->timestamp('last_login_at')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
```

### Products Migration
```php
<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_products_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 10, 2);
            $table->decimal('cost_price', 10, 2);
            $table->integer('stock_quantity')->default(0);
            $table->string('barcode')->unique()->nullable();
            $table->string('sku')->unique()->nullable();
            $table->string('category');
            $table->string('image_url')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('products');
    }
};
```

### Sales Migration
```php
<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_sales_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sales', function (Blueprint $table) {
            $table->id();
            $table->decimal('subtotal', 10, 2);
            $table->decimal('tax', 10, 2);
            $table->decimal('discount', 10, 2)->default(0);
            $table->decimal('total', 10, 2);
            $table->enum('payment_method', ['cash', 'card', 'mobile', 'mixed']);
            $table->enum('status', ['pending', 'completed', 'cancelled', 'refunded'])->default('pending');
            $table->string('customer_id')->nullable();
            $table->string('customer_name')->nullable();
            $table->string('customer_phone')->nullable();
            $table->foreignId('cashier_id')->constrained('users');
            $table->string('cashier_name');
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sales');
    }
};
```

### Sale Items Migration
```php
<?php
// database/migrations/xxxx_xx_xx_xxxxxx_create_sale_items_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sale_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sale_id')->constrained()->onDelete('cascade');
            $table->foreignId('product_id')->constrained();
            $table->integer('quantity');
            $table->decimal('unit_price', 10, 2);
            $table->decimal('discount', 10, 2)->default(0);
            $table->decimal('subtotal', 10, 2);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sale_items');
    }
};
```

## Step 5: Create Models

```bash
php artisan make:model User
php artisan make:model Product
php artisan make:model Sale
php artisan make:model SaleItem
```

### User Model
```php
<?php
// app/Models/User.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'google_id',
        'name',
        'email',
        'phone',
        'role',
        'is_active',
        'profile_image_url',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function sales()
    {
        return $this->hasMany(Sale::class, 'cashier_id');
    }
}
```

### Product Model
```php
<?php
// app/Models/Product.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'cost_price',
        'stock_quantity',
        'barcode',
        'sku',
        'category',
        'image_url',
        'is_active',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'stock_quantity' => 'integer',
        'is_active' => 'boolean',
    ];

    public function saleItems()
    {
        return $this->hasMany(SaleItem::class);
    }
}
```

### Sale Model
```php
<?php
// app/Models/Sale.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sale extends Model
{
    use HasFactory;

    protected $fillable = [
        'subtotal',
        'tax',
        'discount',
        'total',
        'payment_method',
        'status',
        'customer_id',
        'customer_name',
        'customer_phone',
        'cashier_id',
        'cashier_name',
        'notes',
    ];

    protected $casts = [
        'subtotal' => 'decimal:2',
        'tax' => 'decimal:2',
        'discount' => 'decimal:2',
        'total' => 'decimal:2',
    ];

    public function items()
    {
        return $this->hasMany(SaleItem::class);
    }

    public function cashier()
    {
        return $this->belongsTo(User::class, 'cashier_id');
    }
}
```

### SaleItem Model
```php
<?php
// app/Models/SaleItem.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SaleItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'sale_id',
        'product_id',
        'quantity',
        'unit_price',
        'discount',
        'subtotal',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'unit_price' => 'decimal:2',
        'discount' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
```

## Step 6: Create API Controllers

```bash
php artisan make:controller Api/AuthController
php artisan make:controller Api/ProductController --resource
php artisan make:controller Api/SaleController --resource
php artisan make:controller Api/DashboardController
```

### Auth Controller
```php
<?php
// app/Http/Controllers/Api/AuthController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Google_Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function googleLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        try {
            $client = new Google_Client(['client_id' => config('services.google.client_id')]);
            $payload = $client->verifyIdToken($request->id_token);

            if (!$payload) {
                return response()->json(['message' => 'Invalid ID token'], 401);
            }

            $user = User::updateOrCreate(
                ['google_id' => $payload['sub']],
                [
                    'name' => $payload['name'],
                    'email' => $payload['email'],
                    'profile_image_url' => $payload['picture'] ?? null,
                    'last_login_at' => now(),
                ]
            );

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'user' => $user,
                'token' => $token,
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Authentication failed'], 401);
        }
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    }

    public function user(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }
}
```

## Step 7: API Routes

```php
<?php
// routes/api.php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\SaleController;
use App\Http\Controllers\Api\DashboardController;

Route::post('/auth/google', [AuthController::class, 'googleLogin']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);
    
    Route::apiResource('products', ProductController::class);
    Route::apiResource('sales', SaleController::class);
    
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/reports/sales', [DashboardController::class, 'salesReport']);
});
```

## Step 8: Run Migrations

```bash
php artisan migrate
```

## Step 9: Seed Sample Data

```bash
php artisan make:seeder UserSeeder
php artisan make:seeder ProductSeeder
```

## Step 10: Start the Development Server

```bash
php artisan serve
```

Your Laravel API will be available at `http://localhost:8000`

## Step 11: Configure CORS

Make sure to configure CORS in `config/cors.php` to allow requests from your Flutter app.

## Update Flutter API Base URL

In your Flutter app, update the API base URL in `lib/services/api_service.dart`:

```dart
static const String _baseUrl = 'http://localhost:8000/api'; // For local development
// static const String _baseUrl = 'https://your-domain.com/api'; // For production
```

## Testing the API

You can test the API endpoints using tools like Postman or Insomnia. Make sure to include the Bearer token in the Authorization header for protected routes.

Example:
```
GET http://localhost:8000/api/products
Authorization: Bearer your-api-token-here
```
