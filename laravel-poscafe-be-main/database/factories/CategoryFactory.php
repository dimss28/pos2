<?php

namespace Database\Factories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Category>
 */
class CategoryFactory extends Factory
{
    public function definition(): array
    {
        $name = $this->faker->unique()->randomElement(['Makanan', 'Minuman', 'Snack', 'Dessert', 'Kopi', 'Roti']);

        return [
            'name' => $name,
            'description' => $this->faker->sentence(),
            'icon' => $this->faker->randomElement(['tag', 'cube', 'gift', 'mug-hot', 'utensils']),
            'color' => $this->faker->randomElement(['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899']),
            'is_active' => true,
            'sort_order' => 0,
        ];
    }
}
