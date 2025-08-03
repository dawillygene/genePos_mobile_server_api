<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if shop_id column exists, if not add it
        if (!Schema::hasColumn('users', 'shop_id')) {
            Schema::table('users', function (Blueprint $table) {
                $table->unsignedBigInteger('shop_id')->nullable()->after('profile_image_url');
                $table->foreign('shop_id', 'fk_users_shop_id')->references('id')->on('shops')->onDelete('set null');
            });
        }
        
        // Update the role enum to include new values
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'manager', 'cashier', 'owner', 'sales_person') DEFAULT 'cashier'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropForeign('fk_users_shop_id');
            $table->dropColumn('shop_id');
        });
        
        // Revert the role enum
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'manager', 'cashier') DEFAULT 'cashier'");
    }
};
