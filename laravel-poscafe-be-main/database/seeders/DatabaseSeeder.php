<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $password = Hash::make('12345678');

        User::factory()->owner()->create([
            'name' => 'Owner POS',
            'email' => 'bahri@fic11.com',
            'password' => $password,
        ]);

        User::factory()->admin()->create([
            'name' => 'Admin POS',
            'email' => 'admin@fic11.com',
            'password' => $password,
        ]);

        User::factory()->create([
            'name' => 'Kasir 1',
            'email' => 'kasir@fic11.com',
            'password' => $password,
            'roles' => 'kasir',
        ]);

        $this->call([
            CategorySeeder::class,
            ProductSeeder::class,
            StoreSetupSeeder::class,
        ]);

        if (app()->environment('local', 'testing')) {
            $this->call(OrderSeeder::class);
        }
    }
}
