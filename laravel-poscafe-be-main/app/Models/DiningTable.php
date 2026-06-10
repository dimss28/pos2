<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class DiningTable extends Model
{
    use HasFactory;

    protected $fillable = [
        'label',
        'qr_token',
        'is_active',
        'sort_order',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'sort_order' => 'integer',
    ];

    protected static function booted(): void
    {
        static::creating(function (self $table) {
            if (empty($table->qr_token)) {
                $table->qr_token = Str::random(48);
            }
        });
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function publicUrl(): string
    {
        return url('/m/'.$this->qr_token);
    }

    public function qrImageUrl(int $size = 400): string
    {
        return 'https://api.qrserver.com/v1/create-qr-code/?size='.$size.'x'.$size
            .'&data='.urlencode($this->publicUrl());
    }

    public static function findByToken(string $token): ?self
    {
        return self::query()
            ->where('qr_token', $token)
            ->where('is_active', true)
            ->first();
    }
}
