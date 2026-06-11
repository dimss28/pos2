<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'name' => 'Owner CaK Slamet',
                'email' => 'owner@cakslamet.com',
                'password' => '12345678',
                'roles' => 'owner',
            ],
            [
                'name' => 'Admin CaK Slamet',
                'email' => 'admin@cakslamet.com',
                'password' => '12345678',
                'roles' => 'admin',
            ],
            [
                'name' => 'Kasir CaK Slamet',
                'email' => 'kasir@cakslamet.com',
                'password' => '12345678',
                'roles' => 'kasir',
            ],
        ];

        foreach ($users as $data) {
            User::query()->updateOrCreate(
                ['email' => $data['email']],
                [
                    'name' => $data['name'],
                    'password' => $data['password'],
                    'roles' => $data['roles'],
                    'is_active' => true,
                    'email_verified_at' => now(),
                ]
            );
        }

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
