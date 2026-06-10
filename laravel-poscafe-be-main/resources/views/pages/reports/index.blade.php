@extends('layouts.app')
@section('title', __('Laporan'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Laporan') }}" subtitle="{{ __('Pilih jenis laporan yang ingin Anda lihat') }}"/>
    <div class="row g-3">
        @foreach([
            ['icon'=>'chart-bar',     'color'=>'primary', 'title'=>'Ringkasan',        'desc'=>'Total revenue, orders, items, & performa kasir.',   'route'=>'reports.summary'],
            ['icon'=>'cube',          'color'=>'success', 'title'=>'Penjualan Produk', 'desc'=>'Top produk berdasarkan qty & revenue.',              'route'=>'reports.product-sales'],
            ['icon'=>'cash-register', 'color'=>'warning', 'title'=>'Tutup Kasir',      'desc'=>'Settlement per kasir & breakdown pembayaran.',       'route'=>'reports.close-cashier'],
            ['icon'=>'percent',       'color'=>'info',    'title'=>'Pemakaian Promo',  'desc'=>'Promo terpopuler & total diskon yang diberikan.',    'route'=>'reports.promo-usage'],
            ['icon'=>'chart-line',    'color'=>'primary', 'title'=>'Sales Analytics',  'desc'=>'Peak hour, hari terbaik, & top kategori.',           'route'=>'reports.sales-analytics'],
            ['icon'=>'boxes',         'color'=>'danger',  'title'=>'Stok Barang',      'desc'=>'Stock value, low stock alert, & last sold date.',    'route'=>'reports.inventory'],
        ] as $r)
        <div class="col-md-4">
            <a href="{{ route($r['route']) }}" class="card-clean d-block text-decoration-none text-dark h-100 hover-shadow" style="transition:.2s">
                <div class="d-flex gap-3 align-items-start">
                    <div class="rounded-3 d-flex align-items-center justify-content-center flex-shrink-0"
                         style="width:48px;height:48px;background:rgba(37,99,235,.1);color:#2563EB">
                        <i class="fas fa-{{ $r['icon'] }} fa-lg"></i>
                    </div>
                    <div>
                        <h6 class="fw-bold mb-1">{{ __($r['title']) }}</h6>
                        <p class="text-muted small mb-0">{{ __($r['desc']) }}</p>
                    </div>
                </div>
            </a>
        </div>
        @endforeach
    </div>
</section>
@endsection
