<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'transaction_time' => $this->transaction_time?->toIso8601String(),
            'kasir' => new UserResource($this->whenLoaded('kasir')),
            'cash_session_id' => $this->cash_session_id,
            'promo_id' => $this->promo_id,
            'payment_method' => $this->payment_method,
            'status' => $this->status,
            'subtotal' => (int) $this->subtotal,
            'discount' => (int) $this->discount,
            'discount_amount' => (int) $this->discount_amount,
            'tax' => (int) $this->tax,
            'total_price' => (int) $this->total_price,
            'amount_paid' => (int) $this->amount_paid,
            'change_amount' => (int) $this->change_amount,
            'total_item' => $this->total_item,
            'customer_name' => $this->customer_name,
            'notes' => $this->notes,
            'order_items' => OrderItemResource::collection($this->whenLoaded('orderItems')),
        ];
    }
}
