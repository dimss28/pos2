<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    const SOURCE_KASIR = 'kasir';
    const SOURCE_TABLE_QR = 'table_qr';

    const STATUS_PENDING = 'pending';
    const STATUS_AWAITING_PAYMENT = 'awaiting_payment';
    const STATUS_AWAITING_CONFIRMATION = 'awaiting_confirmation';
    const STATUS_PAID = 'paid';
    const STATUS_PREPARING = 'preparing';
    const STATUS_READY = 'ready';
    const STATUS_COMPLETED = 'completed';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_REFUNDED = 'refunded';

    protected $fillable = [
        'order_number', 'transaction_time', 'total_price', 'total_item', 'kasir_id', 'dining_table_id', 'order_source',
        'cash_session_id', 'promo_id', 'payment_method', 'status', 'subtotal', 'discount', 'discount_amount', 'tax',
        'amount_paid', 'change_amount', 'customer_name', 'customer_whatsapp', 'notes', 'payment_proof_path', 'midtrans_order_id',
        'confirmed_by_user_id', 'confirmed_at', 'refunded_at', 'refund_reason', 'refund_note', 'refund_amount',
        'refunded_by_user_id',
    ];

    protected $casts = [
        'transaction_time' => 'datetime',
        'confirmed_at' => 'datetime',
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

    public function diningTable()
    {
        return $this->belongsTo(DiningTable::class);
    }

    public function confirmedBy()
    {
        return $this->belongsTo(User::class, 'confirmed_by_user_id');
    }

    public function isTableOrder(): bool
    {
        return $this->order_source === self::SOURCE_TABLE_QR;
    }

    public function paymentProofUrl(): ?string
    {
        if (! $this->payment_proof_path) {
            return null;
        }

        return asset('storage/'.$this->payment_proof_path);
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
                $order->status = $order->order_source === self::SOURCE_TABLE_QR
                    ? self::STATUS_AWAITING_PAYMENT
                    : self::STATUS_PAID;
            }
            if (empty($order->order_source)) {
                $order->order_source = self::SOURCE_KASIR;
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
            self::STATUS_PAID => 'Pesanan masuk',
            self::STATUS_PENDING, self::STATUS_AWAITING_PAYMENT => 'Menunggu bayar',
            self::STATUS_AWAITING_CONFIRMATION => 'Menunggu lunas',
            self::STATUS_PREPARING => 'Diproses',
            self::STATUS_READY => 'Siap disajikan',
            self::STATUS_COMPLETED => 'Selesai',
            self::STATUS_CANCELLED => 'Dibatalkan',
            self::STATUS_REFUNDED => 'Refund',
            default => (string) $this->status,
        };
    }

    public function statusBadgeClass(): string
    {
        return match ($this->status) {
            self::STATUS_PAID, self::STATUS_COMPLETED => 'success',
            self::STATUS_PREPARING, self::STATUS_READY => 'primary',
            self::STATUS_PENDING, self::STATUS_AWAITING_PAYMENT, self::STATUS_AWAITING_CONFIRMATION => 'warning',
            self::STATUS_CANCELLED => 'danger',
            self::STATUS_REFUNDED => 'info',
            default => 'secondary',
        };
    }
}
