<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class ShopController extends Controller
{
    /**
     * Display a listing of shops (only for admin or owner's shops)
     */
    public function index(): JsonResponse
    {
        $user = Auth::user();
        
        if ($user->isOwner()) {
            $shops = $user->ownedShops()->with(['users', 'products', 'sales'])->get();
        } else {
            $shops = Shop::where('id', $user->shop_id)->with(['users', 'products', 'sales'])->get();
        }

        return response()->json($shops);
    }

    /**
     * Store a newly created shop (only owners can create shops)
     */
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user();

        // Only allow owners to create shops
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only owners can create shops'], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'address' => 'nullable|string|max:500',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'currency' => 'nullable|string|size:3',
            'timezone' => 'nullable|string',
            'settings' => 'nullable|array',
        ]);

        $validated['owner_id'] = $user->id;

        $shop = Shop::create($validated);

        // Associate the user with the shop
        $user->update(['shop_id' => $shop->id]);

        return response()->json([
            'message' => 'Shop created successfully',
            'shop' => $shop->load(['owner', 'users'])
        ], 201);
    }

    /**
     * Display the specified shop
     */
    public function show(Shop $shop): JsonResponse
    {
        $user = Auth::user();

        // Check if user has access to this shop
        if ($user->shop_id !== $shop->id && !$user->ownedShops->contains($shop->id)) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        return response()->json($shop->load(['owner', 'users', 'products', 'sales']));
    }

    /**
     * Update the specified shop (only owners)
     */
    public function update(Request $request, Shop $shop): JsonResponse
    {
        $user = Auth::user();

        // Check if user owns this shop
        if ($shop->owner_id !== $user->id) {
            return response()->json(['message' => 'Only shop owners can update shop details'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'address' => 'nullable|string|max:500',
            'phone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'currency' => 'nullable|string|size:3',
            'timezone' => 'nullable|string',
            'settings' => 'nullable|array',
            'is_active' => 'sometimes|boolean',
        ]);

        $shop->update($validated);

        return response()->json([
            'message' => 'Shop updated successfully',
            'shop' => $shop->load(['owner', 'users'])
        ]);
    }

    /**
     * Remove the specified shop (only owners)
     */
    public function destroy(Shop $shop): JsonResponse
    {
        $user = Auth::user();

        // Check if user owns this shop
        if ($shop->owner_id !== $user->id) {
            return response()->json(['message' => 'Only shop owners can delete shops'], 403);
        }

        $shop->delete();

        return response()->json(['message' => 'Shop deleted successfully']);
    }

    /**
     * Get shop statistics
     */
    public function statistics(Shop $shop): JsonResponse
    {
        $user = Auth::user();

        // Check if user has access to this shop
        if ($user->shop_id !== $shop->id && !$user->ownedShops->contains($shop->id)) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        $stats = [
            'total_products' => $shop->products()->count(),
            'active_products' => $shop->products()->where('is_active', true)->count(),
            'low_stock_products' => $shop->products()->where('stock_quantity', '<', 10)->count(),
            'total_sales' => $shop->sales()->count(),
            'total_revenue' => $shop->sales()->where('status', 'completed')->sum('total'),
            'total_team_members' => $shop->users()->count(),
            'active_team_members' => $shop->users()->where('is_active', true)->count(),
        ];

        return response()->json($stats);
    }
}
