<?php

namespace App\Services;

use App\Models\StoreSetting;
use Illuminate\Support\Facades\Http;

class MidtransService
{
    public function isConfigured(): bool
    {
        return $this->serverKey() !== '';
    }

    public function serverKey(): string
    {
        return (string) (StoreSetting::get('midtrans_server_key')
            ?: config('services.midtrans.server_key', ''));
    }

    public function isProduction(): bool
    {
        $v = StoreSetting::get('midtrans_is_production', '0');

        return $v === '1' || $v === 'true';
    }

    public function baseUrl(): string
    {
        return $this->isProduction()
            ? 'https://api.midtrans.com'
            : 'https://api.sandbox.midtrans.com';
    }

    /**
     * @return array{qr_url: ?string, order_id: string, raw: array}
     */
    public function chargeQris(string $orderId, int $grossAmount): array
    {
        $key = $this->serverKey();
        if ($key === '') {
            throw new \RuntimeException('Server key Midtrans belum diatur.');
        }

        $response = Http::withBasicAuth($key, '')
            ->acceptJson()
            ->connectTimeout(5)
            ->timeout(15)
            ->post($this->baseUrl().'/v2/charge', [
                'payment_type' => 'gopay',
                'transaction_details' => [
                    'order_id' => $orderId,
                    'gross_amount' => $grossAmount,
                ],
            ]);

        if (! $response->successful()) {
            throw new \RuntimeException('Midtrans gagal: '.$response->body());
        }

        $data = $response->json();
        $qrUrl = null;
        foreach ($data['actions'] ?? [] as $action) {
            if (($action['name'] ?? '') === 'generate-qr-code') {
                $qrUrl = $action['url'] ?? null;
                break;
            }
        }
        if (! $qrUrl && ! empty($data['actions'][0]['url'])) {
            $qrUrl = $data['actions'][0]['url'];
        }

        return [
            'qr_url' => $qrUrl,
            'order_id' => $orderId,
            'raw' => $data,
        ];
    }

    public function transactionStatus(string $orderId): ?string
    {
        return $this->transactionStatusBody($orderId)['transaction_status'] ?? null;
    }

    /**
     * @return array<string, mixed>|null
     */
    public function transactionStatusBody(string $orderId): ?array
    {
        $key = $this->serverKey();
        if ($key === '') {
            return null;
        }

        $response = Http::withBasicAuth($key, '')
            ->acceptJson()
            ->connectTimeout(5)
            ->timeout(10)
            ->get($this->baseUrl().'/v2/'.$orderId.'/status');

        if (! $response->successful()) {
            return null;
        }

        return $response->json();
    }
}
