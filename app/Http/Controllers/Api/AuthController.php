<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Google_Client;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Google OAuth Login
     * 
     * Authenticate using Google OAuth ID token.
     * 
     * @group Authentication
     * @bodyParam id_token string required Google ID token. Example: eyJhbGciOiJSUzI1NiIsImtpZCI6...
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "google_id": "123456789",
     *     "role": "owner",
     *     "shop_id": null,
     *     "is_active": true,
     *     "created_at": "2025-08-03T19:44:13.000000Z"
     *   },
     *   "token": "1|laravel_sanctum_token"
     * }
     * @response 401 {"message": "Invalid ID token"}
     */
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

    /**
     * Logout
     * 
     * Revoke the current access token.
     * 
     * @group Authentication
     * @authenticated
     * @response 200 {"message": "Logged out successfully"}
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    }

    /**
     * Get Current User
     * 
     * Get the authenticated user's information.
     * 
     * @group Authentication
     * @authenticated
     * @response 200 {
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "role": "owner",
     *     "shop_id": 1,
     *     "is_active": true,
     *     "created_at": "2025-08-03T19:44:13.000000Z"
     *   }
     * }
     */
    public function user(Request $request)
    {
        return response()->json(['user' => $request->user()]);
    }

    /**
     * Register User
     * 
     * Register a new user with email and password. Default role is 'owner'.
     * 
     * @group Authentication
     * @bodyParam name string required The user's full name. Example: John Doe
     * @bodyParam email string required The user's email address. Example: john@example.com
     * @bodyParam password string required The user's password (minimum 8 characters). Example: password123
     * @bodyParam password_confirmation string required Password confirmation. Example: password123
     * @bodyParam role string optional User role (owner or sales_person). Default: owner. Example: owner
     * @response 201 {
     *   "message": "User registered successfully",
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "role": "owner",
     *     "shop_id": null,
     *     "is_active": true,
     *     "created_at": "2025-08-03T19:44:13.000000Z"
     *   },
     *   "token": "1|laravel_sanctum_token"
     * }
     * @response 422 {"message": "The given data was invalid.", "errors": {"email": ["The email has already been taken."]}}
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'sometimes|in:owner,sales_person',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role ?? 'owner', // Default to owner
            'is_active' => true,
            'last_login_at' => now(),
        ]);

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => 'User registered successfully',
            'user' => $user,
            'token' => $token,
        ], 201);
    }

    /**
     * Login with Email/Password
     * 
     * Authenticate using email and password credentials.
     * 
     * @group Authentication
     * @bodyParam email string required The user's email address. Example: john@example.com
     * @bodyParam password string required The user's password. Example: password123
     * @response 200 {
     *   "message": "Login successful",
     *   "user": {
     *     "id": 1,
     *     "name": "John Doe",
     *     "email": "john@example.com",
     *     "role": "owner",
     *     "shop_id": 1,
     *     "is_active": true,
     *     "last_login_at": "2025-08-03T22:30:15.000000Z"
     *   },
     *   "token": "1|laravel_sanctum_token"
     * }
     * @response 422 {"message": "The given data was invalid.", "errors": {"email": ["The provided credentials are incorrect."]}}
     * @response 403 {"message": "Account is deactivated"}
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user->is_active) {
            return response()->json(['message' => 'Account is deactivated'], 403);
        }

        $user->update(['last_login_at' => now()]);
        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
        ]);
    }
}
