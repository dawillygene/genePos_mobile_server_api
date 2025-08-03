<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\SaleController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ShopController;
use App\Http\Controllers\Api\TeamController;

Route::post('/auth/google', [AuthController::class, 'googleLogin']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/user', [AuthController::class, 'user']);
    
    Route::apiResource('products', ProductController::class);
    Route::apiResource('sales', SaleController::class);
    
    // Shop management routes
    Route::apiResource('shops', ShopController::class);
    Route::get('/shops/{shop}/statistics', [ShopController::class, 'statistics']);
    
    // Team management routes
    Route::apiResource('team', TeamController::class);
    Route::patch('/team/{user}/toggle-status', [TeamController::class, 'toggleStatus']);
    
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/reports/sales', [DashboardController::class, 'salesReport']);
});
