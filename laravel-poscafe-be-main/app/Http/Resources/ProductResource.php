<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'price' => (int) $this->price,
            'stock' => (int) $this->stock,
            'category' => $this->whenLoaded(
                'category',
                fn () => new CategoryResource($this->getRelation('category'))
            ),
            'category_label' => $this->category,
            'category_id' => $this->category_id,
            'image' => $this->image_url,
            'is_best_seller' => (bool) $this->is_best_seller,
        ];
    }
}
