<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::factory()->owner()->create([
            'name' => 'POS Owner',
            'email' => 'owner@pos.com',
            'password' => Hash::make('12345678'),
        ]);

        User::factory()->admin()->count(2)->create();
        User::factory()->count(5)->create();

        $this->call([
            CategorySeeder::class,
            ProductSeeder::class,
        ]);

        if (app()->environment('local', 'testing')) {
            $this->call(OrderSeeder::class);
        }
    }
}
