<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\StoreSetting;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class QrisPaymentController extends Controller
{
    public function charge(Request $request)
    {
        if (! StoreSetting::isQrisEnabled()) {
            return ApiResponse::error('QRIS belum diaktifkan. Atur di Pengaturan Toko (web admin).', 422);
        }

        $data = $request->validate([
            'gross_amount' => ['required', 'integer', 'min:1'],
            'order_id' => ['nullable', 'string', 'max:64'],
        ]);

        $orderId = $data['order_id']
            ?? 'KSR-'.$request->user()->id.'-'.now()->format('YmdHis').'-'.Str::upper(Str::random(4));

        try {
            $charge = app(MidtransService::class)->chargeQris($orderId, $data['gross_amount']);
        } catch (\Throwable $e) {
            return ApiResponse::error($e->getMessage(), 502);
        }

        return ApiResponse::success([
            'order_id' => $charge['order_id'],
            'qr_url' => $charge['qr_url'],
            'midtrans' => $charge['raw'],
        ]);
    }

    public function status(string $orderId)
    {
        if (! StoreSetting::isQrisEnabled()) {
            return ApiResponse::error('QRIS belum diaktifkan.', 422);
        }

        try {
            $body = app(MidtransService::class)->transactionStatusBody($orderId);
        } catch (\Throwable $e) {
            return ApiResponse::error($e->getMessage(), 502);
        }

        if ($body === null) {
            return ApiResponse::error('Status pembayaran tidak ditemukan.', 404);
        }

        return ApiResponse::success($body);
    }
}
