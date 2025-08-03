<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('sale_items', function (Blueprint $table) {
            $table->foreign('sale_id', 'fk_si_sale_id')->references('id')->on('sales')->onDelete('cascade');
            $table->foreign('product_id', 'fk_si_product_id')->references('id')->on('products');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sale_items', function (Blueprint $table) {
            $table->dropForeign('fk_si_sale_id');
            $table->dropForeign('fk_si_product_id');
        });
    }
};
