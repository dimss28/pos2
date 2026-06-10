@extends('layouts.app')
@section('title', __('Tutup Kasir'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Tutup Kasir') }}"
        subtitle="{{ formatDate($from,'d M Y') }} – {{ formatDate($to,'d M Y') }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>__('Tutup Kasir')]]"/>

    <x-reports-filter-bar
        action="{{ route('reports.close-cashier') }}"
        :from="request('from')" :to="request('to')"
        :exportUrls="[
            'xlsx' => route('reports.export',['type'=>'close-cashier','format'=>'xlsx']+request()->query()),
            'pdf'  => route('reports.export',['type'=>'close-cashier','format'=>'pdf']+request()->query()),
        ]"/>

    <div class="card-clean">
        @if($rows->isEmpty())
            <x-empty-state icon="cash-register" title="{{ __('Belum ada data') }}"/>
        @else
            @php $grouped = $rows->groupBy('kasir_name'); @endphp
            @foreach($grouped as $kasirName => $kasirRows)
            <div class="mb-4">
                <h6 class="fw-bold mb-2 text-primary">{{ $kasirName }}</h6>
                <div class="table-responsive">
                    <table class="table table-sm align-middle">
                        <thead class="text-uppercase small text-muted">
                            <tr><th>{{ __('Metode Pembayaran') }}</th><th class="text-end">{{ __('Transaksi') }}</th><th class="text-end">{{ __('Revenue') }}</th></tr>
                        </thead>
                        <tbody>
                            @foreach($kasirRows as $r)
                            <tr>
                                <td><span class="badge bg-light text-dark">{{ strtoupper($r->payment_method) }}</span></td>
                                <td class="text-end">{{ $r->order_count }}</td>
                                <td class="text-end fw-medium">{{ rupiah($r->revenue) }}</td>
                            </tr>
                            @endforeach
                            <tr class="table-light fw-bold">
                                <td>Total</td>
                                <td class="text-end">{{ $kasirRows->sum('order_count') }}</td>
                                <td class="text-end">{{ rupiah($kasirRows->sum('revenue')) }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            @endforeach
        @endif
    </div>
</section>
@endsection
