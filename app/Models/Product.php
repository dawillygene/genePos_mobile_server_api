<?php

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
        'shop_id',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'cost_price' => 'decimal:2',
        'stock_quantity' => 'integer',
        'is_active' => 'boolean',
    ];

    /**
     * Get the shop that owns the product
     */
    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function saleItems()
    {
        return $this->hasMany(SaleItem::class);
    }
}
