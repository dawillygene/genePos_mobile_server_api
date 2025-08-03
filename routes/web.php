<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'GenePos API is running!',
        'status' => 'success',
        'version' => '1.0.0',
        'timestamp' => now()->toISOString(),
        'environment' => app()->environment()
    ]);
});

Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'database' => 'connected',
        'timestamp' => now()->toISOString()
    ]);
});

Route::get('/welcome', function () {
    return view('welcome');
});
