<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE users MODIFY roles VARCHAR(20) NOT NULL DEFAULT 'kasir'");
        DB::table('users')->whereIn('roles', ['user', 'staff'])->update(['roles' => 'kasir']);
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE users MODIFY roles ENUM('admin','staff','user') NOT NULL DEFAULT 'user'");
    }
};
