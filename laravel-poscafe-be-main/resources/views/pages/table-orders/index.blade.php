@extends('layouts.app')
@section('title', 'Pesanan Meja')
@section('page-title', 'Pesanan Meja')
@section('main')
<x-page-header title="Pesanan Meja" subtitle="Order dari scan QR pelanggan" />

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <div class="col-md-4">
            <select name="status" class="form-select">
                <option value="">Semua aktif</option>
                @foreach (['awaiting_confirmation','awaiting_payment','paid','preparing','ready'] as $s)
                    <option value="{{ $s }}" @selected(request('status') === $s)>{{ $s }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-md-2"><button class="btn btn-primary w-100">Filter</button></div>
    </form>
</div>

<div class="card-clean">
    @if ($orders->isEmpty())
        <x-empty-state icon="concierge-bell" title="Belum ada pesanan meja" description="Pesanan muncul setelah pelanggan scan QR dan checkout." />
    @else
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th>Waktu</th>
                        <th>Meja</th>
                        <th>Total</th>
                        <th>Bayar</th>
                        <th>Status</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($orders as $o)
                        <tr>
                            <td class="small">{{ $o->transaction_time?->format('d/m H:i') }}</td>
                            <td class="fw-semibold">{{ $o->diningTable?->label ?? '—' }}</td>
                            <td>Rp {{ number_format($o->total_price, 0, ',', '.') }}</td>
                            <td><span class="badge bg-light text-dark">{{ strtoupper($o->payment_method) }}</span></td>
                            <td><span class="badge bg-{{ $o->statusBadgeClass() }}">{{ $o->statusLabel() }}</span></td>
                            <td class="text-end"><a href="{{ route('table-order.show', $o) }}" class="btn btn-sm btn-primary">Detail</a></td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        {{ $orders->links() }}
    @endif
</div>
@endsection
