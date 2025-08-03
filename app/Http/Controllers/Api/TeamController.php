<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class TeamController extends Controller
{
    /**
     * Display team members for the user's shop
     */
    public function index(): JsonResponse
    {
        $user = Auth::user();
        
        if (!$user->shop_id) {
            return response()->json(['message' => 'User is not associated with any shop'], 400);
        }

        $teamMembers = User::where('shop_id', $user->shop_id)
            ->with('shop')
            ->get()
            ->map(function ($member) {
                return [
                    'id' => $member->id,
                    'name' => $member->name,
                    'email' => $member->email,
                    'role' => $member->role,
                    'is_active' => $member->is_active,
                    'created_at' => $member->created_at,
                    'updated_at' => $member->updated_at,
                ];
            });

        return response()->json($teamMembers);
    }

    /**
     * Add a new sales person to the shop (only owners)
     */
    public function store(Request $request): JsonResponse
    {
        $user = Auth::user();

        // Only owners can add team members
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only shop owners can add team members'], 403);
        }

        if (!$user->shop_id) {
            return response()->json(['message' => 'Owner must have a shop first'], 400);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:8',
            'role' => ['required', Rule::in(['sales_person'])], // Only allow sales_person role
        ]);

        $salesPerson = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'shop_id' => $user->shop_id,
            'is_active' => true,
        ]);

        return response()->json([
            'message' => 'Sales person added successfully',
            'user' => [
                'id' => $salesPerson->id,
                'name' => $salesPerson->name,
                'email' => $salesPerson->email,
                'role' => $salesPerson->role,
                'is_active' => $salesPerson->is_active,
                'created_at' => $salesPerson->created_at,
            ]
        ], 201);
    }

    /**
     * Display a specific team member
     */
    public function show(User $user): JsonResponse
    {
        $authUser = Auth::user();

        // Check if the team member belongs to the same shop
        if ($authUser->shop_id !== $user->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'is_active' => $user->is_active,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ]);
    }

    /**
     * Update a team member (only owners can update sales persons)
     */
    public function update(Request $request, User $teamMember): JsonResponse
    {
        $user = Auth::user();

        // Only owners can update team members
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only shop owners can update team members'], 403);
        }

        // Check if the team member belongs to the same shop
        if ($user->shop_id !== $teamMember->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        // Prevent updating another owner
        if ($teamMember->isOwner()) {
            return response()->json(['message' => 'Cannot update another shop owner'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($teamMember->id)],
            'password' => 'sometimes|nullable|string|min:8',
            'is_active' => 'sometimes|boolean',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $teamMember->update($validated);

        return response()->json([
            'message' => 'Team member updated successfully',
            'user' => [
                'id' => $teamMember->id,
                'name' => $teamMember->name,
                'email' => $teamMember->email,
                'role' => $teamMember->role,
                'is_active' => $teamMember->is_active,
                'updated_at' => $teamMember->updated_at,
            ]
        ]);
    }

    /**
     * Remove a team member (only owners)
     */
    public function destroy(User $teamMember): JsonResponse
    {
        $user = Auth::user();

        // Only owners can remove team members
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only shop owners can remove team members'], 403);
        }

        // Check if the team member belongs to the same shop
        if ($user->shop_id !== $teamMember->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        // Prevent deleting another owner or self
        if ($teamMember->isOwner() || $teamMember->id === $user->id) {
            return response()->json(['message' => 'Cannot delete shop owner'], 403);
        }

        $teamMember->delete();

        return response()->json(['message' => 'Team member removed successfully']);
    }

    /**
     * Deactivate/activate a team member
     */
    public function toggleStatus(User $teamMember): JsonResponse
    {
        $user = Auth::user();

        // Only owners can toggle team member status
        if (!$user->isOwner()) {
            return response()->json(['message' => 'Only shop owners can change team member status'], 403);
        }

        // Check if the team member belongs to the same shop
        if ($user->shop_id !== $teamMember->shop_id) {
            return response()->json(['message' => 'Access denied'], 403);
        }

        // Prevent deactivating another owner or self
        if ($teamMember->isOwner() || $teamMember->id === $user->id) {
            return response()->json(['message' => 'Cannot change shop owner status'], 403);
        }

        $teamMember->update(['is_active' => !$teamMember->is_active]);

        $status = $teamMember->is_active ? 'activated' : 'deactivated';

        return response()->json([
            'message' => "Team member {$status} successfully",
            'user' => [
                'id' => $teamMember->id,
                'name' => $teamMember->name,
                'email' => $teamMember->email,
                'role' => $teamMember->role,
                'is_active' => $teamMember->is_active,
                'updated_at' => $teamMember->updated_at,
            ]
        ]);
    }
}
