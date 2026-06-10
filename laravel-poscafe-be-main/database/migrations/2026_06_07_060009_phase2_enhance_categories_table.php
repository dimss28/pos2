<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->string('slug')->nullable()->unique()->after('name');
            $table->string('description', 500)->nullable()->after('slug');
            $table->string('icon', 50)->default('tag')->after('description');
            $table->string('color', 7)->default('#3B82F6')->after('icon');
            $table->unsignedInteger('sort_order')->default(0)->after('color');
            $table->boolean('is_active')->default(true)->after('sort_order');
        });
    }

    public function down(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->dropUnique(['slug']);
            $table->dropColumn(['slug', 'description', 'icon', 'color', 'sort_order', 'is_active']);
        });
    }
};
