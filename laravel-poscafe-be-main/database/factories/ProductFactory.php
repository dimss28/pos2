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
        $base = $this->faker->randomElement([
            'Nasi Goreng', 'Mie Ayam', 'Bakso', 'Es Teh', 'Kopi Susu',
            'Roti Bakar', 'Pisang Goreng', 'Ayam Geprek', 'Soto Ayam', 'Sate Ayam',
        ]);

        return [
            'name' => $base.' '.$this->faker->word(),
            'description' => $this->faker->paragraph(2),
            'price' => $this->faker->numberBetween(5, 50) * 1000,
            'stock' => $this->faker->numberBetween(0, 100),
            'category' => 'food',
            'category_id' => Category::inRandomOrder()->first()?->id ?? Category::factory(),
            'is_best_seller' => $this->faker->boolean(20),
        ];
    }
}
