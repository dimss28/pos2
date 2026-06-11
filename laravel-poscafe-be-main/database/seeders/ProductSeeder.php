<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $menu = [
            'Minuman' => [
                ['name' => 'Kopi Susu', 'price' => 18000, 'stock' => 99, 'is_best_seller' => true],
                ['name' => 'Espresso', 'price' => 15000, 'stock' => 99],
                ['name' => 'Cappuccino', 'price' => 22000, 'stock' => 99],
                ['name' => 'Latte', 'price' => 23000, 'stock' => 99],
                ['name' => 'Americano', 'price' => 17000, 'stock' => 99],
                ['name' => 'Teh Tarik', 'price' => 12000, 'stock' => 99],
                ['name' => 'Es Teh Manis', 'price' => 8000, 'stock' => 99],
                ['name' => 'Matcha Latte', 'price' => 25000, 'stock' => 99, 'is_best_seller' => true],
                ['name' => 'Cokelat Panas', 'price' => 20000, 'stock' => 99],
            ],
            'Makanan' => [
                ['name' => 'Nasi Goreng Spesial', 'price' => 28000, 'stock' => 50, 'is_best_seller' => true],
                ['name' => 'Mie Goreng', 'price' => 25000, 'stock' => 50],
                ['name' => 'Ayam Geprek', 'price' => 27000, 'stock' => 50],
                ['name' => 'Roti Bakar Cokelat', 'price' => 18000, 'stock' => 40],
                ['name' => 'Roti Bakar Keju', 'price' => 20000, 'stock' => 40],
            ],
            'Snack' => [
                ['name' => 'Kentang Goreng', 'price' => 15000, 'stock' => 60],
                ['name' => 'Pisang Goreng', 'price' => 12000, 'stock' => 60],
                ['name' => 'Singkong Goreng', 'price' => 10000, 'stock' => 60],
            ],
            'Dessert' => [
                ['name' => 'Pudding Caramel', 'price' => 16000, 'stock' => 30],
                ['name' => 'Brownies', 'price' => 18000, 'stock' => 30, 'is_best_seller' => true],
                ['name' => 'Es Krim Vanilla', 'price' => 14000, 'stock' => 30],
            ],
        ];

        foreach ($menu as $categoryName => $items) {
            $category = Category::where('name', $categoryName)->first();
            if (! $category) {
                continue;
            }

            foreach ($items as $item) {
                Product::updateOrCreate(
                    ['name' => $item['name']],
                    [
                        'description' => null,
                        'price' => $item['price'],
                        'stock' => $item['stock'],
                        'category' => strtolower($categoryName),
                        'category_id' => $category->id,
                        'is_best_seller' => $item['is_best_seller'] ?? false,
                    ]
                );
            }
        }
    }
}
