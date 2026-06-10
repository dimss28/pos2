<?php

namespace App\Http\Controllers;

use App\Models\StoreSetting;
use Illuminate\Http\Request;

class StoreSettingController extends Controller
{
    public function edit()
    {
        abort_unless(auth()->user()->isAdmin(), 403);

        return view('pages.store-settings.edit', [
            'transfer' => StoreSetting::transferBank(),
            'midtrans_server_key' => StoreSetting::get('midtrans_server_key', ''),
            'midtrans_is_production' => StoreSetting::get('midtrans_is_production', '0') === '1',
        ]);
    }

    public function update(Request $request)
    {
        abort_unless(auth()->user()->isAdmin(), 403);
        $data = $request->validate([
            'transfer_bank_name' => ['nullable', 'string', 'max:100'],
            'transfer_account_number' => ['nullable', 'string', 'max:50'],
            'transfer_account_holder' => ['nullable', 'string', 'max:100'],
            'midtrans_server_key' => ['nullable', 'string', 'max:255'],
            'midtrans_is_production' => ['nullable', 'boolean'],
        ]);

        StoreSetting::set('transfer_bank_name', $data['transfer_bank_name'] ?? '');
        StoreSetting::set('transfer_account_number', $data['transfer_account_number'] ?? '');
        StoreSetting::set('transfer_account_holder', $data['transfer_account_holder'] ?? '');
        if ($request->filled('midtrans_server_key')) {
            StoreSetting::set('midtrans_server_key', $data['midtrans_server_key']);
        }
        StoreSetting::set('midtrans_is_production', $request->boolean('midtrans_is_production') ? '1' : '0');

        return back()->with('success', __('Pengaturan toko berhasil disimpan.'));
    }
}
