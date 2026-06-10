<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $cats = [
            ['name' => 'Makanan', 'icon' => 'utensils', 'color' => '#F59E0B'],
            ['name' => 'Minuman', 'icon' => 'mug-hot', 'color' => '#3B82F6'],
            ['name' => 'Snack',   'icon' => 'cookie',  'color' => '#10B981'],
            ['name' => 'Dessert', 'icon' => 'ice-cream', 'color' => '#EC4899'],
        ];
        foreach ($cats as $i => $c) {
            Category::firstOrCreate(['name' => $c['name']], $c + ['sort_order' => $i, 'is_active' => true]);
        }
    }
}
