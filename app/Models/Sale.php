<?php

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
        'shop_id',
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

    /**
     * Get the shop that owns the sale
     */
    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }
}
