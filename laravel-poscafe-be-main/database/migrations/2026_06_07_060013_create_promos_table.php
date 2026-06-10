<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('promos', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->enum('type', ['percent', 'rupiah', 'b1g1']);
            $table->integer('value')->default(0);
            $table->string('code', 50)->nullable()->unique();
            $table->json('applies_to')->nullable();
            $table->integer('min_subtotal')->default(0);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->boolean('active')->default(true);
            $table->timestamps();
            $table->index(['active', 'starts_at', 'ends_at'], 'promos_window_idx');
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('promo_id')->nullable()->constrained()->nullOnDelete()->after('cash_session_id');
            $table->integer('discount_amount')->default(0)->after('discount');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['promo_id']);
            $table->dropColumn(['promo_id', 'discount_amount']);
        });
        Schema::dropIfExists('promos');
    }
};
