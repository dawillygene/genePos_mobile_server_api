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
        if (!Schema::hasColumn('sales', 'shop_id')) {
            Schema::table('sales', function (Blueprint $table) {
                $table->unsignedBigInteger('shop_id')->after('id');
                $table->foreign('shop_id', 'fk_sales_shop_id')->references('id')->on('shops')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('sales', function (Blueprint $table) {
            $table->dropForeign('fk_sales_shop_id');
            $table->dropColumn('shop_id');
        });
    }
};
