<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;

class ClearBrokenProductImages extends Command
{
    protected $signature = 'products:clear-broken-images';

    protected $description = 'Null out dead placeholder.com image URLs in products table';

    public function handle(): int
    {
        $count = Product::query()
            ->where(function ($query) {
                $query->where('image', 'like', '%via.placeholder.com%')
                    ->orWhere('image', 'like', '%placeholder.com/%');
            })
            ->update(['image' => null]);

        $this->info("Cleared {$count} broken product image URL(s).");

        return self::SUCCESS;
    }
}
