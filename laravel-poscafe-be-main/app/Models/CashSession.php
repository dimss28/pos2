<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CashSession extends Model
{
    use HasFactory;

    const SHIFT_PAGI = 'Pagi';
    const SHIFT_SIANG = 'Siang';
    const SHIFT_MALAM = 'Malam';

    protected $fillable = [
        'user_id', 'shift_label', 'opening_float', 'opening_note', 'opened_at',
        'cash_in', 'cash_out', 'physical_count', 'expected_cash', 'variance', 'closing_note', 'closed_at',
    ];

    protected $casts = [
        'opened_at' => 'datetime',
        'closed_at' => 'datetime',
        'opening_float' => 'integer',
        'cash_in' => 'integer',
        'cash_out' => 'integer',
        'physical_count' => 'integer',
        'expected_cash' => 'integer',
        'variance' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    public function getIsOpenAttribute(): bool
    {
        return is_null($this->closed_at);
    }

    public function getIsBalancedAttribute(): bool
    {
        return $this->variance === 0;
    }

    public function cashRevenue(): int
    {
        return (int) $this->orders()
            ->where('payment_method', 'cash')
            ->where('status', Order::STATUS_PAID)
            ->sum('amount_paid');
    }

    public function revenueByMethod(): array
    {
        return $this->orders()
            ->where('status', Order::STATUS_PAID)
            ->selectRaw('payment_method, SUM(total_price) as total')
            ->groupBy('payment_method')
            ->pluck('total', 'payment_method')->toArray();
    }

    public function scopeOpen($q)
    {
        return $q->whereNull('closed_at');
    }

    public function scopeForUser($q, $userId)
    {
        return $q->where('user_id', $userId);
    }

    public static function currentFor(int $userId): ?self
    {
        return static::open()->forUser($userId)->latest('opened_at')->first();
    }
}
