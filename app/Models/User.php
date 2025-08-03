<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'email_verified_at',
        'password',
        'google_id',
        'avatar',
        'shop_id',
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

    /**
     * Get the shop that the user belongs to
     */
    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    /**
     * Get the shops owned by this user
     */
    public function ownedShops()
    {
        return $this->hasMany(Shop::class, 'owner_id');
    }

    /**
     * Check if user is shop owner
     */
    public function isOwner(): bool
    {
        return $this->role === 'owner';
    }

    /**
     * Check if user is sales person
     */
    public function isSalesPerson(): bool
    {
        return $this->role === 'sales_person';
    }

    public function sales()
    {
        return $this->hasMany(Sale::class, 'cashier_id');
    }
}
