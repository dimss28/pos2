<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\StoreSetting;
use App\Services\MidtransService;

class PaymentSettingsController extends Controller
{
    public function show()
    {
        $midtrans = app(MidtransService::class);

        return ApiResponse::success([
            'qris_enabled' => StoreSetting::isQrisEnabled(),
            'midtrans_configured' => $midtrans->isConfigured(),
            'midtrans_environment' => $midtrans->isProduction() ? 'production' : 'sandbox',
            'transfer_configured' => StoreSetting::isTransferConfigured(),
        ]);
    }
}
