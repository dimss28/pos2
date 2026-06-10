@extends('layouts.app')
@section('title', __('Stok Barang'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Stok Barang') }}"
        subtitle="{{ __('Total Nilai Stok: :val', ['val'=>rupiah($totalValue)]) }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>__('Stok Barang')]]"/>

    <div class="card-clean mb-3">
        <div class="d-flex gap-2">
            @foreach([''=>'Semua','low'=>'Stok Rendah (1-4)','out'=>'Habis (0)'] as $val => $label)
                <a href="{{ request()->fullUrlWithQuery(['stock_filter'=>$val]) }}"
                   class="btn btn-sm {{ request('stock_filter')===$val ? 'btn-primary' : 'btn-outline-secondary' }}">{{ $label }}</a>
            @endforeach
        </div>
    </div>

    <div class="card-clean">
        @if($rows->isEmpty())
            <x-empty-state icon="boxes" title="{{ __('Belum ada data produk') }}"/>
        @else
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr><th>{{ __('Produk') }}</th><th>{{ __('Kategori') }}</th><th class="text-end">{{ __('Stok') }}</th><th class="text-end">{{ __('Terjual') }}</th><th class="text-end">{{ __('Nilai Stok') }}</th><th>{{ __('Terakhir Terjual') }}</th></tr>
                    </thead>
                    <tbody>
                        @foreach($rows as $r)
                        <tr class="{{ $r->stock == 0 ? 'table-danger' : ($r->stock <= 4 ? 'table-warning' : '') }}">
                            <td class="fw-semibold">{{ $r->name }}</td>
                            <td class="text-muted small">{{ $r->category_name }}</td>
                            <td class="text-end">
                                @if($r->stock == 0) <span class="badge bg-danger">Habis</span>
                                @elseif($r->stock <= 4) <span class="badge bg-warning text-dark">{{ $r->stock }}</span>
                                @else {{ $r->stock }}
                                @endif
                            </td>
                            <td class="text-end">{{ number_format($r->sold) }}</td>
                            <td class="text-end fw-medium">{{ rupiah($r->stock * $r->price) }}</td>
                            <td class="text-muted small">{{ $r->last_sold ? formatDate($r->last_sold,'d M Y') : '—' }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                    <tfoot class="fw-bold"><tr><td colspan="4">Total Nilai Stok</td><td class="text-end">{{ rupiah($totalValue) }}</td><td></td></tr></tfoot>
                </table>
            </div>
        @endif
    </div>
</section>
@endsection
