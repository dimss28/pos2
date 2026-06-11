<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class StoreSetting extends Model
{
    public $incrementing = false;

    protected $primaryKey = 'key';

    protected $keyType = 'string';

    protected $fillable = ['key', 'value'];

    public static function get(string $key, ?string $default = null): ?string
    {
        try {
            if (! Schema::hasTable('store_settings')) {
                return $default;
            }

            return self::query()->find($key)?->value ?? $default;
        } catch (\Throwable) {
            return $default;
        }
    }

    public static function set(string $key, ?string $value): void
    {
        if (! Schema::hasTable('store_settings')) {
            return;
        }

        self::query()->updateOrCreate(['key' => $key], ['value' => $value]);
    }

    public static function transferBank(): array
    {
        return [
            'bank_name' => self::get('transfer_bank_name', ''),
            'account_number' => self::get('transfer_account_number', ''),
            'account_holder' => self::get('transfer_account_holder', ''),
        ];
    }

    public static function isTransferConfigured(): bool
    {
        $t = self::transferBank();

        return $t['bank_name'] !== '' && $t['account_number'] !== '' && $t['account_holder'] !== '';
    }

    public static function isQrisEnabled(): bool
    {
        if (self::get('midtrans_enabled', '0') !== '1') {
            return false;
        }

        return app(\App\Services\MidtransService::class)->isConfigured();
    }
}
