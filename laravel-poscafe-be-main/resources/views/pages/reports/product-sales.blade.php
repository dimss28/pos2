@extends('layouts.app')
@section('title', __('Penjualan Produk'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Penjualan Produk') }}"
        subtitle="{{ formatDate($from,'d M Y') }} – {{ formatDate($to,'d M Y') }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>__('Penjualan Produk')]]"/>

    <x-reports-filter-bar
        action="{{ route('reports.product-sales') }}"
        :from="request('from')" :to="request('to')"
        :exportUrls="[
            'xlsx' => route('reports.export',['type'=>'product-sales','format'=>'xlsx']+request()->query()),
            'pdf'  => route('reports.export',['type'=>'product-sales','format'=>'pdf']+request()->query()),
        ]"/>

    <div class="card-clean">
        <h5 class="fw-bold mb-3">{{ __('Top Produk') }} <span class="text-muted fw-normal small">Total: {{ rupiah($totalRevenue) }}</span></h5>
        @if($rows->isEmpty())
            <x-empty-state icon="cube" title="{{ __('Belum ada data penjualan') }}"/>
        @else
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr><th>#</th><th>{{ __('Produk') }}</th><th>{{ __('Kategori') }}</th><th class="text-end">{{ __('Qty Terjual') }}</th><th class="text-end">{{ __('Revenue') }}</th><th class="text-end">{{ __('Share') }}</th></tr>
                    </thead>
                    <tbody>
                        @foreach($rows as $i => $r)
                        <tr>
                            <td class="text-muted small">{{ $i+1 }}</td>
                            <td class="fw-semibold">{{ $r->product_name }}</td>
                            <td class="text-muted small">{{ $r->category_name }}</td>
                            <td class="text-end">{{ number_format($r->qty_sold) }}</td>
                            <td class="text-end fw-medium">{{ rupiah($r->revenue) }}</td>
                            <td class="text-end">
                                @php $share = $totalRevenue > 0 ? round($r->revenue/$totalRevenue*100,1) : 0; @endphp
                                <div class="d-flex align-items-center gap-2 justify-content-end">
                                    <div class="progress flex-grow-1" style="height:6px;min-width:60px">
                                        <div class="progress-bar" style="width:{{ $share }}%"></div>
                                    </div>
                                    <span class="small">{{ $share }}%</span>
                                </div>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @endif
    </div>
</section>
@endsection
