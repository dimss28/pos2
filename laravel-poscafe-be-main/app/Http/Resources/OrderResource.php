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
            'kasir_id' => $this->kasir_id,
            'kasir' => new UserResource($this->whenLoaded('kasir')),
            'order_source' => $this->order_source,
            'dining_table_id' => $this->dining_table_id,
            'dining_table' => $this->whenLoaded('diningTable', fn () => [
                'id' => $this->diningTable->id,
                'label' => $this->diningTable->label,
            ]),
            'payment_proof_url' => $this->paymentProofUrl(),
            'status_label' => $this->statusLabel(),
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
            'customer_whatsapp' => $this->customer_whatsapp,
            'notes' => $this->notes,
            'order_items' => OrderItemResource::collection($this->whenLoaded('orderItems')),
        ];
    }
}
