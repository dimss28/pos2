<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'description', 'price', 'stock', 'category', 'category_id', 'image', 'is_best_seller'];

    protected $casts = [
        'price' => 'integer',
        'stock' => 'integer',
        'is_best_seller' => 'boolean',
    ];

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    public static function isBrokenRemoteImage(?string $image): bool
    {
        if (! $image) {
            return false;
        }

        return str_contains($image, 'via.placeholder.com')
            || str_contains($image, 'placeholder.com/');
    }

    public function isLocalImage(): bool
    {
        if (! $this->image) {
            return false;
        }

        return ! str_starts_with($this->image, 'http://')
            && ! str_starts_with($this->image, 'https://');
    }

    public function deleteStoredImage(): void
    {
        if (! $this->isLocalImage()) {
            return;
        }

        \Illuminate\Support\Facades\Storage::disk('public')->delete('products/'.$this->image);
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! $this->image || self::isBrokenRemoteImage($this->image)) {
            return null;
        }
        if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
            return $this->image;
        }

        return asset('storage/products/'.$this->image);
    }
}
