<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Product>
 */
class ProductFactory extends Factory
{
    public function definition(): array
    {
        $base = fake()->randomElement([
            'Nasi Goreng', 'Mie Ayam', 'Bakso', 'Es Teh', 'Kopi Susu',
            'Roti Bakar', 'Pisang Goreng', 'Ayam Geprek', 'Soto Ayam', 'Sate Ayam',
        ]);

        return [
            'name' => $base.' '.fake()->word(),
            'description' => fake()->paragraph(2),
            'price' => fake()->numberBetween(5, 50) * 1000,
            'stock' => fake()->numberBetween(0, 100),
            'category' => 'food',
            'category_id' => Category::inRandomOrder()->first()?->id ?? Category::factory(),
            'is_best_seller' => fake()->boolean(20),
        ];
    }
}
