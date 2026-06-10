@extends('layouts.app')
@section('title', __('Dashboard'))
@section('page-title', __('Dashboard'))
@section('main')
@php
    $hasRoute = fn ($name) => \Illuminate\Support\Facades\Route::has($name);
@endphp

<div class="mb-3">
    <h1 class="h3 fw-bold mb-1">{{ __('Selamat datang') }}, {{ auth()->user()->name }} 👋</h1>
    <p class="text-muted mb-0">{{ formatDate(now(), 'l, d F Y') }}</p>
</div>

<div class="row g-3">
    <div class="col-md-3">
        <x-stat-card
            label="{{ __('Pendapatan Hari Ini') }}"
            value="{{ rupiah($stats['revenue_today']) }}"
            icon="money-bill-wave" color="success"
            :delta="$stats['revenue_delta']" deltaLabel="vs kemarin" />
    </div>
    <div class="col-md-3">
        <x-stat-card label="{{ __('Pesanan Hari Ini') }}" :value="$stats['orders_today']" icon="receipt" color="primary" />
    </div>
    <div class="col-md-3">
        <x-stat-card label="{{ __('Total Produk') }}" :value="$stats['total_products']" icon="box-open" color="warning"
            :href="$hasRoute('product.index') ? route('product.index') : null" />
    </div>
    <div class="col-md-3">
        <x-stat-card label="{{ __('Kasir Aktif') }}" :value="$stats['active_users']" icon="users" color="info"
            :href="$hasRoute('user.index') ? route('user.index') : null" />
    </div>
</div>

<div class="row g-3 mt-1">
    <div class="col-md-3">
        <div class="card-clean"><div class="text-muted small">{{ __('Pendapatan Minggu Ini') }}</div><div class="h4 fw-bold mb-0">{{ rupiah($quickStats['revenue_week']) }}</div></div>
    </div>
    <div class="col-md-3">
        <div class="card-clean"><div class="text-muted small">{{ __('Pendapatan Bulan Ini') }}</div><div class="h4 fw-bold mb-0">{{ rupiah($quickStats['revenue_month']) }}</div></div>
    </div>
    <div class="col-md-3">
        <div class="card-clean"><div class="text-muted small">{{ __('Rata-rata / Order') }}</div><div class="h4 fw-bold mb-0">{{ rupiah($quickStats['avg_per_order']) }}</div></div>
    </div>
    <div class="col-md-3">
        <div class="card-clean"><div class="text-muted small">{{ __('Item Terjual Hari Ini') }}</div><div class="h4 fw-bold mb-0">{{ $quickStats['items_sold_today'] }}</div></div>
    </div>
</div>

<div class="row g-3 mt-1">
    <div class="col-lg-7">
        <div class="card-clean h-100">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">{{ __('Top 5 Produk') }}</h5>
                @if ($hasRoute('product.index'))
                    <a href="{{ route('product.index') }}" class="small text-decoration-none">{{ __('Lihat semua') }} →</a>
                @endif
            </div>
            @forelse ($topProducts as $i => $item)
                <div class="d-flex align-items-center py-2 {{ $i < $topProducts->count() - 1 ? 'border-bottom' : '' }}">
                    <span class="me-3 fw-bold text-muted">{{ $i + 1 }}</span>
                    <div class="flex-grow-1">
                        <div class="fw-semibold">{{ $item->product->name ?? '-' }}</div>
                        <div class="small text-muted">{{ $item->total_sold }} {{ __('terjual') }}</div>
                    </div>
                    <div class="fw-medium">{{ rupiah($item->product->price ?? 0) }}</div>
                </div>
            @empty
                <x-empty-state icon="chart-bar" title="Belum ada penjualan" />
            @endforelse
        </div>
    </div>
    <div class="col-lg-5">
        <div class="card-clean h-100">
            <h5 class="fw-bold mb-3">{{ __('Pembayaran Hari Ini') }}</h5>
            @if ($paymentBreakdown->isEmpty())
                <x-empty-state icon="credit-card" title="Belum ada transaksi" />
            @else
                <canvas id="paymentChart" height="220"></canvas>
            @endif
        </div>
    </div>
</div>

<div class="card-clean mt-3">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 class="fw-bold mb-0">{{ __('Pesanan Terbaru') }}</h5>
        @if ($hasRoute('order.index'))
            <a href="{{ route('order.index') }}" class="small text-decoration-none">{{ __('Lihat semua') }} →</a>
        @endif
    </div>
    @if ($recentOrders->isEmpty())
        <x-empty-state icon="receipt" title="Belum ada pesanan" />
    @else
        <div class="table-responsive">
            <table class="table table-sm align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th>{{ __('Waktu') }}</th>
                        <th>{{ __('Order') }}</th>
                        <th>{{ __('Kasir') }}</th>
                        <th class="text-end">{{ __('Total') }}</th>
                        <th class="text-center">{{ __('Status') }}</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($recentOrders as $o)
                        <tr>
                            <td>{{ formatDate($o->transaction_time) }}</td>
                            <td><span class="text-primary fw-semibold">{{ $o->order_number ?? '#'.$o->id }}</span></td>
                            <td>{{ $o->kasir->name ?? '-' }}</td>
                            <td class="text-end fw-medium">{{ rupiah($o->total_price) }}</td>
                            <td class="text-center"><x-order-status-badge :status="$o->status" /></td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    @endif
</div>

<div class="card-clean mt-3">
    <h5 class="fw-bold mb-3"><i class="fas fa-exclamation-triangle text-warning me-2"></i>{{ __('Stok Menipis') }}</h5>
    @if ($lowStock->isEmpty())
        <p class="text-muted mb-0">{{ __('Semua stok aman ✓') }}</p>
    @else
        <div class="row">
            @foreach ($lowStock as $p)
                <div class="col-md-6 mb-2 d-flex justify-content-between align-items-center">
                    <span>{{ $p->name }}</span>
                    <span class="badge bg-{{ $p->stock == 0 ? 'danger' : 'warning' }} text-{{ $p->stock == 0 ? 'white' : 'dark' }}">
                        {{ $p->stock }} {{ __('tersisa') }}
                    </span>
                </div>
            @endforeach
        </div>
    @endif
</div>

@push('scripts')
@if (! $paymentBreakdown->isEmpty())
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>
    const pb = @json($paymentBreakdown);
    new Chart(document.getElementById('paymentChart'), {
        type: 'doughnut',
        data: {
            labels: pb.map(r => (r.payment_method || '').toUpperCase()),
            datasets: [{
                data: pb.map(r => Number(r.total)),
                backgroundColor: ['#3B82F6', '#10B981', '#F59E0B', '#EC4899', '#8B5CF6'],
            }],
        },
        options: { plugins: { legend: { position: 'bottom' } } },
    });
</script>
@endif
@endpush
@endsection
