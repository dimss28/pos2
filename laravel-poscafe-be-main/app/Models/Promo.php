<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Promo extends Model
{
    use HasFactory;

    const TYPE_PERCENT = 'percent';
    const TYPE_RUPIAH = 'rupiah';
    const TYPE_B1G1 = 'b1g1';

    const TYPES = [self::TYPE_PERCENT, self::TYPE_RUPIAH, self::TYPE_B1G1];

    protected $fillable = ['name', 'type', 'value', 'code', 'applies_to', 'min_subtotal', 'starts_at', 'ends_at', 'active'];

    protected $casts = [
        'value' => 'integer',
        'min_subtotal' => 'integer',
        'applies_to' => 'array',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'active' => 'boolean',
    ];

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function computeDiscount(int $subtotal, array $items = []): int
    {
        if (! $this->isLive() || $subtotal < $this->min_subtotal) {
            return 0;
        }

        return match ($this->type) {
            self::TYPE_PERCENT => (int) floor($subtotal * $this->value / 100),
            self::TYPE_RUPIAH => min($this->value, $subtotal),
            self::TYPE_B1G1 => $this->computeB1G1Discount($items),
            default => 0,
        };
    }

    private function computeB1G1Discount(array $items): int
    {
        $total = 0;
        foreach ($items as $it) {
            if (($it['quantity'] ?? 0) >= 2) {
                $total += ($it['price'] ?? 0) * intdiv($it['quantity'], 2);
            }
        }

        return $total;
    }

    public function isLive(?\DateTimeInterface $now = null): bool
    {
        $now = $now ?? now();
        if (! $this->active) {
            return false;
        }
        if ($this->starts_at && $now->lt($this->starts_at)) {
            return false;
        }
        if ($this->ends_at && $now->gt($this->ends_at)) {
            return false;
        }

        return true;
    }

    public function typeLabel(): string
    {
        return match ($this->type) {
            self::TYPE_PERCENT => 'Persen',
            self::TYPE_RUPIAH => 'Rupiah',
            self::TYPE_B1G1 => 'Beli 1 Gratis 1',
            default => (string) $this->type,
        };
    }

    public function status(?\DateTimeInterface $now = null): string
    {
        $now = $now ?? now();
        if (! $this->active) {
            return 'inactive';
        }
        if ($this->starts_at && $now->lt($this->starts_at)) {
            return 'scheduled';
        }
        if ($this->ends_at && $now->gt($this->ends_at)) {
            return 'expired';
        }

        return 'live';
    }

    public function scopeActive($q)
    {
        return $q->where('active', true);
    }

    public function scopeLive($q, ?\DateTimeInterface $now = null)
    {
        $now = $now ?? now();

        return $q->where('active', true)
            ->where(fn ($w) => $w->whereNull('starts_at')->orWhere('starts_at', '<=', $now))
            ->where(fn ($w) => $w->whereNull('ends_at')->orWhere('ends_at', '>=', $now));
    }

    public function scopeByCode($q, string $code)
    {
        return $q->whereRaw('UPPER(code) = ?', [strtoupper($code)]);
    }
}
