<?php

namespace Database\Seeders;

use App\Models\Order;
use App\Models\Product;
use Illuminate\Database\Seeder;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        Order::factory()->count(50)->create()->each(function (Order $order) {
            $itemCount = rand(1, 4);
            $total = 0;
            for ($i = 0; $i < $itemCount; $i++) {
                $product = Product::inRandomOrder()->first();
                $qty = rand(1, 3);
                $sub = $product->price * $qty;
                $order->orderItems()->create([
                    'product_id' => $product->id,
                    'quantity' => $qty,
                    'total_price' => $sub,
                ]);
                $total += $sub;
            }
            $order->update([
                'total_price' => $total,
                'subtotal' => $total,
                'amount_paid' => $total,
                'total_item' => $itemCount,
            ]);
        });
    }
}
