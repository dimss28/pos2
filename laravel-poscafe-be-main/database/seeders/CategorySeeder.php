<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $cats = [
            ['name' => 'Makan', 'icon' => 'utensils', 'color' => '#22C55E'],
            ['name' => 'Ngemil', 'icon' => 'cookie', 'color' => '#F59E0B'],
            ['name' => 'Minum', 'icon' => 'mug-hot', 'color' => '#3B82F6'],
            ['name' => 'Request Sambal', 'icon' => 'fire', 'color' => '#EF4444'],
        ];
        foreach ($cats as $i => $c) {
            Category::updateOrCreate(
                ['name' => $c['name']],
                $c + ['sort_order' => $i, 'is_active' => true]
            );
        }
    }
}
