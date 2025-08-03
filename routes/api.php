<?php

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
