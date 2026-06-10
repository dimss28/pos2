<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class ApiOrderStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
            'items.*.total_price' => ['required', 'integer', 'min:0'],
            'subtotal' => ['required', 'integer', 'min:0'],
            'tax' => ['nullable', 'integer', 'min:0'],
            'amount_paid' => ['required', 'integer', 'min:0'],
            'payment_method' => ['required', 'in:cash,qris,transfer'],
            'transaction_time' => ['nullable', 'date'],
            'promo_id' => ['nullable', 'exists:promos,id'],
            'promo_code' => ['nullable', 'string'],
            'customer_name' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string', 'max:500'],
        ];
    }
}
