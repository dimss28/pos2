<?php

namespace Database\Factories;

use App\Models\Order;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Order>
 */
class OrderFactory extends Factory
{
    public function definition(): array
    {
        $items = fake()->numberBetween(1, 5);
        $total = fake()->numberBetween(10000, 200000);

        return [
            'transaction_time' => fake()->dateTimeBetween('-30 days', 'now'),
            'total_price' => $total,
            'subtotal' => $total,
            'total_item' => $items,
            'kasir_id' => User::where('roles', 'kasir')->inRandomOrder()->first()?->id ?? User::factory(),
            'payment_method' => fake()->randomElement(['cash', 'qris', 'transfer']),
            'status' => 'paid',
            'amount_paid' => $total,
            'change_amount' => 0,
        ];
    }
}
