<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class Shop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'slug',
        'description',
        'address',
        'phone',
        'email',
        'logo_url',
        'currency',
        'timezone',
        'settings',
        'is_active',
        'owner_id',
    ];

    protected $casts = [
        'settings' => 'array',
        'is_active' => 'boolean',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($shop) {
            if (empty($shop->slug)) {
                $shop->slug = Str::slug($shop->name);
            }
        });
    }

    /**
     * Get the owner of the shop
     */
    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    /**
     * Get all users (team members) of the shop
     */
    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * Get sales persons of the shop
     */
    public function salesPersons(): HasMany
    {
        return $this->hasMany(User::class)->where('role', 'sales_person');
    }

    /**
     * Get all products of the shop
     */
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }

    /**
     * Get all sales of the shop
     */
    public function sales(): HasMany
    {
        return $this->hasMany(Sale::class);
    }
}
