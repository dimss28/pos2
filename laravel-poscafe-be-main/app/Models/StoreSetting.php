<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StoreSetting extends Model
{
    public $incrementing = false;

    protected $primaryKey = 'key';

    protected $keyType = 'string';

    protected $fillable = ['key', 'value'];

    public static function get(string $key, ?string $default = null): ?string
    {
        return self::query()->find($key)?->value ?? $default;
    }

    public static function set(string $key, ?string $value): void
    {
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
}
