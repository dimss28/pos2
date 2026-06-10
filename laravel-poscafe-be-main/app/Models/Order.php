<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    const STATUS_PENDING = 'pending';
    const STATUS_PAID = 'paid';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_REFUNDED = 'refunded';

    protected $fillable = [
        'order_number', 'transaction_time', 'total_price', 'total_item', 'kasir_id', 'cash_session_id', 'promo_id',
        'payment_method', 'status', 'subtotal', 'discount', 'discount_amount', 'tax', 'amount_paid', 'change_amount',
        'customer_name', 'notes', 'refunded_at', 'refund_reason', 'refund_note', 'refund_amount', 'refunded_by_user_id',
    ];

    protected $casts = [
        'transaction_time' => 'datetime',
        'refunded_at' => 'datetime',
        'total_price' => 'decimal:2',
        'subtotal' => 'decimal:2',
        'discount' => 'decimal:2',
        'tax' => 'decimal:2',
        'amount_paid' => 'decimal:2',
        'change_amount' => 'decimal:2',
        'refund_amount' => 'decimal:2',
    ];

    public function kasir()
    {
        return $this->belongsTo(User::class, 'kasir_id');
    }

    public function cashSession()
    {
        return $this->belongsTo(CashSession::class);
    }

    public function promo()
    {
        return $this->belongsTo(Promo::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    protected static function booted(): void
    {
        static::creating(function (self $order) {
            if (empty($order->order_number)) {
                $order->order_number = self::generateOrderNumber();
            }
            if (empty($order->status)) {
                $order->status = self::STATUS_PAID;
            }
            if (empty($order->cash_session_id) && $order->kasir_id) {
                $current = CashSession::currentFor($order->kasir_id);
                if ($current) {
                    $order->cash_session_id = $current->id;
                }
            }
        });
    }

    public static function generateOrderNumber(): string
    {
        $count = self::whereDate('created_at', today())->count() + 1;

        return 'INV-'.now()->format('Ymd').'-'.str_pad((string) $count, 4, '0', STR_PAD_LEFT);
    }

    public function statusLabel(): string
    {
        return match ($this->status) {
            self::STATUS_PAID => 'Lunas',
            self::STATUS_PENDING => 'Menunggu',
            self::STATUS_CANCELLED => 'Dibatalkan',
            self::STATUS_REFUNDED => 'Refund',
            default => (string) $this->status,
        };
    }

    public function statusBadgeClass(): string
    {
        return match ($this->status) {
            self::STATUS_PAID => 'success',
            self::STATUS_PENDING => 'warning',
            self::STATUS_CANCELLED => 'danger',
            self::STATUS_REFUNDED => 'info',
            default => 'secondary',
        };
    }
}
