<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CashSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user' => new UserResource($this->whenLoaded('user')),
            'shift_label' => $this->shift_label,
            'opening_float' => (int) $this->opening_float,
            'opened_at' => $this->opened_at?->toIso8601String(),
            'cash_in' => (int) $this->cash_in,
            'cash_out' => (int) $this->cash_out,
            'physical_count' => $this->physical_count,
            'expected_cash' => $this->expected_cash,
            'variance' => $this->variance,
            'closed_at' => $this->closed_at?->toIso8601String(),
            'is_open' => is_null($this->closed_at),
        ];
    }
}
