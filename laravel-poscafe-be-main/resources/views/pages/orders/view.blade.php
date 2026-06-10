@extends('layouts.app')
@section('title', 'Pesanan ' . $order->order_number)
@section('page-title', $order->order_number)
@section('main')

<x-page-header :title="$order->order_number"
    :subtitle="formatDate($order->transaction_time, 'l, d F Y · H:i')"
    :breadcrumbs="[['label' => 'Pesanan', 'url' => route('order.index')], ['label' => $order->order_number]]">
    <x-slot:actions>
        <span class="badge bg-{{ $order->statusBadgeClass() }} align-self-center">{{ $order->statusLabel() }}</span>
        <a href="{{ route('order.receipt', $order) }}" target="_blank" class="btn btn-outline-secondary"><i class="fas fa-print me-1"></i>{{ __('Cetak Struk') }}</a>
        <a href="{{ route('order.invoice-pdf', $order) }}" class="btn btn-outline-secondary"><i class="fas fa-file-pdf me-1"></i>PDF</a>
        @can('refund', $order)
            <button type="button" class="btn btn-warning"><i class="fas fa-undo me-1"></i>{{ __('Refund') }}</button>
        @endcan
    </x-slot:actions>
</x-page-header>

<div class="row g-3">
    <div class="col-lg-8">
        <div class="card-clean">
            <h5 class="fw-bold mb-3">{{ __('Item Pesanan') }}</h5>
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr>
                            <th>{{ __('Produk') }}</th>
                            <th class="text-end">{{ __('Harga') }}</th>
                            <th class="text-center">{{ __('Qty') }}</th>
                            <th class="text-end">{{ __('Subtotal') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($orderItems as $it)
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        @if ($it->product?->image)
                                            <img src="{{ asset('storage/products/'.$it->product->image) }}" class="rounded me-2" style="width:40px;height:40px;object-fit:cover">
                                        @endif
                                        <div>
                                            <div class="fw-semibold">{{ $it->product?->name ?? '[deleted]' }}</div>
                                            <div class="small text-muted">SKU #{{ $it->product?->id ?? '-' }}</div>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-end">{{ rupiah($it->product?->price ?? 0) }}</td>
                                <td class="text-center">{{ $it->quantity }}</td>
                                <td class="text-end fw-medium">{{ rupiah($it->total_price) }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
        @if ($order->notes)
            <div class="card-clean mt-3">
                <h6 class="fw-bold">{{ __('Catatan') }}</h6>
                <p class="mb-0 text-muted">{{ $order->notes }}</p>
            </div>
        @endif
    </div>
    <div class="col-lg-4">
        <div class="card-clean mb-3">
            <h5 class="fw-bold mb-3">{{ __('Ringkasan') }}</h5>
            <dl class="row mb-0">
                <dt class="col-6 text-muted fw-normal">{{ __('Subtotal') }}</dt>
                <dd class="col-6 text-end">{{ rupiah($order->subtotal) }}</dd>
                @if ($order->discount > 0)
                    <dt class="col-6 text-muted fw-normal">{{ __('Diskon') }}</dt>
                    <dd class="col-6 text-end text-danger">-{{ rupiah($order->discount) }}</dd>
                @endif
                @if ($order->tax > 0)
                    <dt class="col-6 text-muted fw-normal">{{ __('Pajak') }}</dt>
                    <dd class="col-6 text-end">{{ rupiah($order->tax) }}</dd>
                @endif
                <dt class="col-6 fw-bold border-top pt-2 mt-2">{{ __('Total') }}</dt>
                <dd class="col-6 text-end fw-bold border-top pt-2 mt-2 h5">{{ rupiah($order->total_price) }}</dd>
            </dl>
            <hr>
            <dl class="row mb-0">
                <dt class="col-6 text-muted fw-normal">{{ __('Pembayaran') }}</dt>
                <dd class="col-6 text-end">{{ strtoupper($order->payment_method) }}</dd>
                @if ($order->amount_paid > 0)
                    <dt class="col-6 text-muted fw-normal">{{ __('Dibayar') }}</dt>
                    <dd class="col-6 text-end">{{ rupiah($order->amount_paid) }}</dd>
                    <dt class="col-6 text-muted fw-normal">{{ __('Kembalian') }}</dt>
                    <dd class="col-6 text-end">{{ rupiah($order->change_amount) }}</dd>
                @endif
            </dl>
        </div>
        <div class="card-clean">
            <h5 class="fw-bold mb-3">{{ __('Info') }}</h5>
            <dl class="row mb-0">
                <dt class="col-5 text-muted fw-normal">{{ __('Kasir') }}</dt>
                <dd class="col-7">{{ $order->kasir->name ?? '-' }}</dd>
                @if ($order->customer_name)
                    <dt class="col-5 text-muted fw-normal">{{ __('Customer') }}</dt>
                    <dd class="col-7">{{ $order->customer_name }}</dd>
                @endif
                <dt class="col-5 text-muted fw-normal">{{ __('Total Item') }}</dt>
                <dd class="col-7">{{ $order->total_item }}</dd>
            </dl>
        </div>
    </div>
</div>

@endsection
