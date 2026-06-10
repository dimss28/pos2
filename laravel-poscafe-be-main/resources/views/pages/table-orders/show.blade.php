@extends('layouts.app')
@section('title', 'Pesanan Meja')
@section('page-title', 'Pesanan Meja')
@section('main')
<x-page-header :title="$order->diningTable?->label ?? 'Pesanan Meja'" :subtitle="$order->order_number">
    <x-slot:actions>
        <a href="{{ route('table-order.index') }}" class="btn btn-light">Kembali</a>
    </x-slot:actions>
</x-page-header>

<div class="row g-3">
    <div class="col-lg-8">
        <div class="card-clean">
            <div class="d-flex justify-content-between mb-3">
                <span class="badge bg-{{ $order->statusBadgeClass() }} fs-6">{{ $order->statusLabel() }}</span>
                <span class="text-muted small">{{ $order->transaction_time?->format('d M Y H:i') }}</span>
            </div>
            <table class="table">
                <thead><tr><th>Item</th><th class="text-center">Qty</th><th class="text-end">Subtotal</th></tr></thead>
                <tbody>
                    @foreach ($order->orderItems as $item)
                        <tr>
                            <td>{{ $item->product?->name ?? 'Produk #'.$item->product_id }}</td>
                            <td class="text-center">{{ $item->quantity }}</td>
                            <td class="text-end">Rp {{ number_format($item->total_price, 0, ',', '.') }}</td>
                        </tr>
                    @endforeach
                </tbody>
                <tfoot>
                    <tr><th colspan="2">Total</th><th class="text-end">Rp {{ number_format($order->total_price, 0, ',', '.') }}</th></tr>
                </tfoot>
            </table>
            @if ($order->notes)
                <p class="small text-muted mb-0"><strong>Catatan:</strong> {{ $order->notes }}</p>
            @endif
        </div>
    </div>
    <div class="col-lg-4">
        <div class="card-clean mb-3">
            <h6 class="fw-bold">Pembayaran</h6>
            <p class="mb-1">Metode: <strong>{{ strtoupper($order->payment_method) }}</strong></p>
            @if ($order->payment_proof_url)
                <p class="small text-muted">Bukti transfer:</p>
                <a href="{{ $order->payment_proof_url }}" target="_blank">
                    <img src="{{ $order->payment_proof_url }}" class="img-fluid rounded border" alt="Bukti">
                </a>
            @endif
        </div>

        @if ($order->status === App\Models\Order::STATUS_AWAITING_CONFIRMATION)
            <div class="card-clean mb-3 border-warning">
                <h6 class="fw-bold">Konfirmasi Transfer</h6>
                <p class="small text-muted">Cek rekening, lalu terima atau tolak.</p>
                <form method="POST" action="{{ route('table-order.confirm', $order) }}" class="d-inline">@csrf<button class="btn btn-success w-100 mb-2">Terima pembayaran</button></form>
                <form method="POST" action="{{ route('table-order.reject', $order) }}" onsubmit="return confirm('Tolak pesanan ini?')">@csrf<button class="btn btn-outline-danger w-100">Tolak</button></form>
            </div>
        @endif

        @if (in_array($order->status, [App\Models\Order::STATUS_PAID, App\Models\Order::STATUS_PREPARING, App\Models\Order::STATUS_READY], true))
            <div class="card-clean">
                <h6 class="fw-bold">Proses pesanan</h6>
                @if ($order->status === App\Models\Order::STATUS_PAID)
                    <form method="POST" action="{{ route('table-order.status', $order) }}">@csrf<input type="hidden" name="status" value="preparing"><button class="btn btn-primary w-100 mb-2">Mulai siapkan</button></form>
                @elseif ($order->status === App\Models\Order::STATUS_PREPARING)
                    <form method="POST" action="{{ route('table-order.status', $order) }}">@csrf<input type="hidden" name="status" value="ready"><button class="btn btn-primary w-100 mb-2">Siap disajikan</button></form>
                @elseif ($order->status === App\Models\Order::STATUS_READY)
                    <form method="POST" action="{{ route('table-order.status', $order) }}">@csrf<input type="hidden" name="status" value="completed"><button class="btn btn-success w-100">Selesai</button></form>
                @endif
            </div>
        @endif
    </div>
</div>
@endsection
