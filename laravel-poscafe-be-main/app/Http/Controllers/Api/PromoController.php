<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PromoResource;
use App\Http\Responses\ApiResponse;
use App\Models\Promo;
use Illuminate\Http\Request;

class PromoController extends Controller
{
    public function index()
    {
        $promos = Promo::live()->orderBy('name')->get();

        return ApiResponse::success(PromoResource::collection($promos));
    }

    public function show(Promo $promo)
    {
        return ApiResponse::success(new PromoResource($promo));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'type' => ['required', 'in:percent,rupiah,b1g1'],
            'value' => ['required', 'integer', 'min:0'],
            'code' => ['nullable', 'string', 'max:50', 'unique:promos,code'],
            'min_subtotal' => ['nullable', 'integer', 'min:0'],
        ]);
        if (! empty($data['code'])) {
            $data['code'] = strtoupper($data['code']);
        }
        $promo = Promo::create($data);

        return ApiResponse::success(new PromoResource($promo), 'Promo dibuat.', 201);
    }

    public function update(Request $request, Promo $promo)
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'value' => ['sometimes', 'integer', 'min:0'],
            'active' => ['sometimes', 'boolean'],
        ]);
        $promo->update($data);

        return ApiResponse::success(new PromoResource($promo));
    }

    public function destroy(Promo $promo)
    {
        if ($promo->orders()->exists()) {
            return ApiResponse::error('Promo sudah dipakai.', 422);
        }
        $promo->delete();

        return ApiResponse::success(null, 'Promo dihapus.');
    }

    public function toggle(Promo $promo)
    {
        $promo->update(['active' => ! $promo->active]);

        return ApiResponse::success(new PromoResource($promo));
    }

    public function apply(Request $request)
    {
        $request->validate([
            'code' => ['required', 'string'],
            'subtotal' => ['required', 'integer', 'min:0'],
            'items' => ['nullable', 'array'],
        ]);
        $promo = Promo::byCode($request->code)->first();
        if (! $promo) {
            return ApiResponse::error('Kode promo tidak ditemukan.', 404);
        }
        if (! $promo->isLive()) {
            return ApiResponse::error('Promo tidak aktif atau sudah berakhir.', 422);
        }
        if ($request->subtotal < $promo->min_subtotal) {
            return ApiResponse::error(__('Minimum belanja Rp :min', ['min' => number_format($promo->min_subtotal, 0, ',', '.')]), 422);
        }
        $discount = $promo->computeDiscount((int) $request->subtotal, $request->items ?? []);

        return ApiResponse::success([
            'promo' => new PromoResource($promo),
            'discount' => $discount,
        ], 'Promo berhasil diterapkan.');
    }
}
