@extends('layouts.app')
@section('title', __('Pesanan'))
@section('page-title', __('Pesanan'))
@section('main')

<x-page-header title="{{ __('Pesanan') }}" subtitle="{{ $totalOrders }} transaksi · {{ rupiah($totalRevenue) }}">
    <x-slot:actions>
        <a href="{{ route('order.export', request()->query()) }}" class="btn btn-outline-success"><i class="fas fa-file-excel me-1"></i>{{ __('Export Excel') }}</a>
    </x-slot:actions>
</x-page-header>

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <div class="col-md-3"><input type="text" name="q" value="{{ request('q') }}" placeholder="{{ __('Order # / customer...') }}" class="form-control"></div>
        <div class="col-md-2"><input type="date" name="date_from" value="{{ request('date_from') }}" class="form-control"></div>
        <div class="col-md-2"><input type="date" name="date_to" value="{{ request('date_to') }}" class="form-control"></div>
        <div class="col-md-2">
            <select name="payment_method" class="form-select">
                <option value="">{{ __('Semua Pembayaran') }}</option>
                @foreach ($paymentMethods as $pm)
                    <option value="{{ $pm }}" @selected(request('payment_method') == $pm)>{{ strtoupper($pm) }}</option>
                @endforeach
            </select>
        </div>
        @if ($kasirList->isNotEmpty())
            <div class="col-md-2">
                <select name="kasir_id" class="form-select">
                    <option value="">{{ __('Semua Kasir') }}</option>
                    @foreach ($kasirList as $k)
                        <option value="{{ $k->id }}" @selected(request('kasir_id') == $k->id)>{{ $k->name }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        <div class="col-md-2">
            <select name="status" class="form-select">
                <option value="">{{ __('Semua Status') }}</option>
                @foreach (['pending', 'paid', 'cancelled', 'refunded'] as $s)
                    <option value="{{ $s }}" @selected(request('status') == $s)>{{ ucfirst($s) }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-md-2"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('messages.filter') }}</button></div>
    </form>
</div>

<div class="card-clean">
    @if ($orders->isEmpty())
        <x-empty-state icon="receipt" title="Belum ada pesanan" />
    @else
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th>Order #</th>
                        <th>{{ __('Tanggal') }}</th>
                        <th>{{ __('Kasir') }}</th>
                        <th>{{ __('Customer') }}</th>
                        <th class="text-center">{{ __('Items') }}</th>
                        <th class="text-end">{{ __('Total') }}</th>
                        <th class="text-center">{{ __('Pembayaran') }}</th>
                        <th class="text-center">{{ __('messages.status') }}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($orders as $o)
                        <tr>
                            <td><a href="{{ route('order.show', $o) }}" class="fw-semibold text-primary text-decoration-none">{{ $o->order_number }}</a></td>
                            <td>{{ formatDate($o->transaction_time) }}</td>
                            <td>{{ $o->kasir->name ?? '-' }}</td>
                            <td>{{ $o->customer_name ?? '—' }}</td>
                            <td class="text-center">{{ $o->total_item }}</td>
                            <td class="text-end fw-medium">{{ rupiah($o->total_price) }}</td>
                            <td class="text-center"><span class="badge bg-light text-dark">{{ strtoupper($o->payment_method) }}</span></td>
                            <td class="text-center"><x-order-status-badge :status="$o->status" /></td>
                            <td class="text-end">
                                <a href="{{ route('order.show', $o) }}" class="btn btn-sm btn-light" title="Lihat"><i class="fas fa-eye"></i></a>
                                <a href="{{ route('order.receipt', $o) }}" target="_blank" class="btn btn-sm btn-light" title="Cetak Struk"><i class="fas fa-print"></i></a>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="mt-3">{{ $orders->links() }}</div>
    @endif
</div>

@endsection
