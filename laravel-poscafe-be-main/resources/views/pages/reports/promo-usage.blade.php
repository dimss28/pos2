@extends('layouts.app')
@section('title', __('Pemakaian Promo'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Pemakaian Promo') }}"
        subtitle="{{ formatDate($from,'d M Y') }} – {{ formatDate($to,'d M Y') }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>__('Pemakaian Promo')]]"/>

    <x-reports-filter-bar
        action="{{ route('reports.promo-usage') }}"
        :from="request('from')" :to="request('to')"/>

    <div class="card-clean">
        @if($rows->isEmpty())
            <x-empty-state icon="percent" title="{{ __('Belum ada data promo') }}"/>
        @else
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr><th>{{ __('Nama Promo') }}</th><th>{{ __('Kode') }}</th><th>{{ __('Tipe') }}</th><th class="text-end">{{ __('Dipakai') }}</th><th class="text-end">{{ __('Total Diskon') }}</th></tr>
                    </thead>
                    <tbody>
                        @foreach($rows as $r)
                        <tr>
                            <td class="fw-semibold">{{ $r->name }}</td>
                            <td>@if($r->code)<code>{{ $r->code }}</code>@else <span class="text-muted">—</span>@endif</td>
                            <td>{{ ucfirst($r->type) }}</td>
                            <td class="text-end">{{ $r->usage_count }}x</td>
                            <td class="text-end fw-medium text-danger">{{ rupiah($r->total_discount) }}</td>
                        </tr>
                        @endforeach
                        <tr class="table-light fw-bold">
                            <td colspan="3">Total</td>
                            <td class="text-end">{{ $rows->sum('usage_count') }}x</td>
                            <td class="text-end text-danger">{{ rupiah($rows->sum('total_discount')) }}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        @endif
    </div>
</section>
@endsection
