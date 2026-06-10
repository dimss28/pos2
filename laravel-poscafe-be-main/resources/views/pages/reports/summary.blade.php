@extends('layouts.app')
@section('title', __('Ringkasan Penjualan'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Ringkasan Penjualan') }}"
        subtitle="{{ formatDate($from,'d M Y') }} – {{ formatDate($to,'d M Y') }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>__('Ringkasan')]]"/>

    <x-reports-filter-bar
        action="{{ route('reports.summary') }}"
        :from="request('from')" :to="request('to')"
        :exportUrls="[
            'xlsx' => route('reports.export',['type'=>'summary','format'=>'xlsx']+request()->query()),
            'pdf'  => route('reports.export',['type'=>'summary','format'=>'pdf']+request()->query()),
        ]"/>

    <div class="row g-3 mb-3">
        <div class="col-md-3"><x-stat-card label="{{ __('Total Pendapatan') }}"  value="{{ rupiah($stats['total_revenue']) }}" icon="money-bill-wave" color="success"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Total Transaksi') }}"   value="{{ $stats['total_orders'] }}"         icon="receipt"         color="primary"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Item Terjual') }}"       value="{{ $stats['total_items'] }}"          icon="cube"            color="warning"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Rata-rata / Trx') }}"   value="{{ rupiah($stats['avg_per_order']) }}" icon="chart-bar"       color="info"/></div>
    </div>

    <div class="card-clean mb-3">
        <h5 class="fw-bold mb-3">{{ __('Pendapatan Harian') }}</h5>
        <canvas id="dailyChart" height="80"></canvas>
    </div>

    <div class="row g-3">
        <div class="col-lg-6">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Performa Kasir') }}</h5>
                <div class="table-responsive">
                    <table class="table">
                        <thead><tr><th>{{ __('Kasir') }}</th><th class="text-end">{{ __('Trx') }}</th><th class="text-end">{{ __('Revenue') }}</th></tr></thead>
                        <tbody>
                            @forelse($perKasir as $k)
                                <tr><td>{{ $k->kasir_name }}</td><td class="text-end">{{ $k->order_count }}</td><td class="text-end fw-medium">{{ rupiah($k->revenue) }}</td></tr>
                            @empty
                                <tr><td colspan="3" class="text-center text-muted py-3">Belum ada data</td></tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Breakdown Pembayaran') }}</h5>
                <canvas id="paymentChart" height="200"></canvas>
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
const daily = @json($daily);
new Chart(document.getElementById('dailyChart'), {
    type: 'line',
    data: {
        labels: daily.map(r => r.date),
        datasets: [{ label: 'Revenue', data: daily.map(r => r.total), borderColor:'#2563EB', backgroundColor:'rgba(37,99,235,.1)', tension:0.3, fill:true }]
    },
    options: { plugins:{ legend:{ display:false } }, scales:{ y:{ beginAtZero:true } } }
});
const pb = @json($paymentBreakdown);
new Chart(document.getElementById('paymentChart'), {
    type: 'doughnut',
    data: {
        labels: pb.map(r => r.payment_method.toUpperCase()),
        datasets: [{ data: pb.map(r => r.total), backgroundColor:['#3B82F6','#10B981','#F59E0B','#EC4899','#8B5CF6'] }]
    },
    options: { plugins:{ legend:{ position:'bottom' } } }
});
</script>
@endpush
