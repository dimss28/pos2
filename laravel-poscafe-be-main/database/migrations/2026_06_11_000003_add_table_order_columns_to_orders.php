<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE orders MODIFY status VARCHAR(32) NOT NULL DEFAULT 'paid'");

        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('dining_table_id')->nullable()->after('kasir_id')
                ->constrained('dining_tables')->nullOnDelete();
            $table->string('order_source', 20)->default('kasir')->after('dining_table_id');
            $table->string('payment_proof_path')->nullable()->after('notes');
            $table->string('midtrans_order_id', 64)->nullable()->after('payment_proof_path');
            $table->foreignId('confirmed_by_user_id')->nullable()->after('midtrans_order_id')
                ->constrained('users')->nullOnDelete();
            $table->timestamp('confirmed_at')->nullable()->after('confirmed_by_user_id');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropConstrainedForeignId('dining_table_id');
            $table->dropConstrainedForeignId('confirmed_by_user_id');
            $table->dropColumn([
                'order_source',
                'payment_proof_path',
                'midtrans_order_id',
                'confirmed_at',
            ]);
        });

        DB::statement("ALTER TABLE orders MODIFY status ENUM('pending','paid','cancelled','refunded') NOT NULL DEFAULT 'paid'");
    }
};
