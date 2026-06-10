<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PromoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('promo')?->id;

        return [
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:percent,rupiah,b1g1'],
            'value' => ['required', 'integer', 'min:0', 'max:100000000'],
            'code' => ['nullable', 'string', 'max:50', 'unique:promos,code,'.$id],
            'min_subtotal' => ['nullable', 'integer', 'min:0'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
            'active' => ['nullable', 'boolean'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($v) {
            if ($this->type === 'percent' && ($this->value < 1 || $this->value > 100)) {
                $v->errors()->add('value', __('Untuk tipe persen, nilai harus 1-100.'));
            }
        });
    }

    protected function prepareForValidation(): void
    {
        $this->merge(['active' => $this->boolean('active', true)]);
    }
}
