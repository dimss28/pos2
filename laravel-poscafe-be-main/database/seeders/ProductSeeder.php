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
            'Makan' => [
                ['name' => 'BEBEK GORENG SLAMET', 'price' => 30000, 'is_best_seller' => true],
                ['name' => 'BEBEK GORENG GALAK', 'price' => 30000, 'is_best_seller' => true],
                ['name' => 'AYAM KAMPUNG GORENG', 'price' => 30000],
                ['name' => 'IKAN PATIN GORENG', 'price' => 30000],
                ['name' => 'IKAN NILA GORENG', 'price' => 30000],
                ['name' => 'UDANG GORENG TEPUNG', 'price' => 25000],
                ['name' => 'CUMI GORENG TEPUNG', 'price' => 25000],
                ['name' => 'AYAM RAS GORENG', 'price' => 20000],
                ['name' => 'IKAN LELE GORENG', 'price' => 20000],
                ['name' => 'TELOR SAMBEL PENYET', 'price' => 15000],
                ['name' => 'GEGACOK TERONG', 'price' => 15000],
                ['name' => 'CAH KANGKUNG', 'price' => 10000],
                ['name' => 'PETE GORENG', 'price' => 7000],
                ['name' => 'NASI', 'price' => 5000],
            ],
            'Ngemil' => [
                ['name' => 'KENTANG GORENG', 'price' => 12000],
                ['name' => 'SOSIS GORENG', 'price' => 12000],
                ['name' => 'NUGGET GORENG', 'price' => 12000],
                ['name' => 'PEMPEK PALEMBANG', 'price' => 20000],
            ],
            'Minum' => [
                ['name' => 'ES KUNIR ASEM', 'price' => 10000],
                ['name' => 'ES BERAS KENCUR', 'price' => 10000],
                ['name' => 'ES JERUK', 'price' => 10000],
                ['name' => 'SQUASH LEMONADE', 'price' => 12000],
                ['name' => 'ES SODA GEMBIRA', 'price' => 15000],
                ['name' => 'ES MILO', 'price' => 10000],
                ['name' => 'ES SUSU', 'price' => 8000],
                ['name' => 'ES LIMUS/SYRUP', 'price' => 8000],
                ['name' => 'ES TEH', 'price' => 5000],
                ['name' => 'AIR MINERAL', 'price' => 5000],
            ],
            'Request Sambal' => [
                ['name' => 'SAMBAL LUCUNG', 'price' => 5000],
                ['name' => 'SAMBAL BAWANG', 'price' => 5000],
                ['name' => 'SAMBAL MENTAH', 'price' => 5000],
                ['name' => 'SAMBAL MANGGA', 'price' => 5000],
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
                        'stock' => 99,
                        'category' => strtolower(str_replace(' ', '_', $categoryName)),
                        'category_id' => $category->id,
                        'is_best_seller' => $item['is_best_seller'] ?? false,
                    ]
                );
            }
        }
    }
}
