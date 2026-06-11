<?php

namespace Database\Seeders;

use App\Models\DiningTable;
use App\Models\StoreSetting;
use Illuminate\Database\Seeder;

class StoreSetupSeeder extends Seeder
{
    public function run(): void
    {
        StoreSetting::set('store_name', 'BEBEK GORENG CaK SLAMET');
        StoreSetting::set('store_tagline', 'Enak, Gurih, Nagih!');
        StoreSetting::set('store_address', '');
        StoreSetting::set('transfer_bank_name', '');
        StoreSetting::set('transfer_account_number', '');
        StoreSetting::set('transfer_account_holder', '');
        StoreSetting::set('midtrans_enabled', '0');

        for ($i = 1; $i <= 5; $i++) {
            DiningTable::firstOrCreate(
                ['label' => "Meja $i"],
                ['is_active' => true, 'sort_order' => $i]
            );
        }
    }
}
