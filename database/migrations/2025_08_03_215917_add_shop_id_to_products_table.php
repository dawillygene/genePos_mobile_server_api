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
        if (!Schema::hasColumn('products', 'shop_id')) {
            Schema::table('products', function (Blueprint $table) {
                $table->unsignedBigInteger('shop_id')->after('id');
                $table->foreign('shop_id', 'fk_products_shop_id')->references('id')->on('shops')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropForeign('fk_products_shop_id');
            $table->dropColumn('shop_id');
        });
    }
};
