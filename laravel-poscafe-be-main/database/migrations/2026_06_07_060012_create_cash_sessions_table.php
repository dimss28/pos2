<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cash_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('shift_label', 20);
            $table->integer('opening_float')->default(0);
            $table->text('opening_note')->nullable();
            $table->timestamp('opened_at');
            $table->integer('cash_in')->default(0);
            $table->integer('cash_out')->default(0);
            $table->integer('physical_count')->nullable();
            $table->integer('expected_cash')->nullable();
            $table->integer('variance')->nullable();
            $table->text('closing_note')->nullable();
            $table->timestamp('closed_at')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'closed_at'], 'cash_sessions_user_open_idx');
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->foreignId('cash_session_id')->nullable()->constrained()->nullOnDelete()->after('kasir_id');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropForeign(['cash_session_id']);
            $table->dropColumn('cash_session_id');
        });
        Schema::dropIfExists('cash_sessions');
    }
};
