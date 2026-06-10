@extends('layouts.app')
@section('title', __('Sales Analytics'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Sales Analytics') }}"
        subtitle="{{ formatDate($from,'d M Y') }} – {{ formatDate($to,'d M Y') }}"
        :breadcrumbs="[['label'=>__('Laporan'),'url'=>route('reports.index')],['label'=>'Sales Analytics']]"/>

    <x-reports-filter-bar
        action="{{ route('reports.sales-analytics') }}"
        :from="request('from')" :to="request('to')"/>

    @php
        $days = ['','Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    @endphp

    <div class="row g-3 mb-3">
        <div class="col-md-6">
            <div class="card-clean">
                <h6 class="fw-bold mb-1">⏰ {{ __('Peak Hour') }}</h6>
                <div class="h2 fw-bold text-primary">{{ $peakHour !== null ? $peakHour.':00' : '—' }}</div>
                <p class="text-muted small mb-0">{{ __('Jam dengan transaksi tertinggi') }}</p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card-clean">
                <h6 class="fw-bold mb-1">📅 {{ __('Hari Terbaik') }}</h6>
                <div class="h2 fw-bold text-success">{{ $bestDay ? $days[$bestDay] : '—' }}</div>
                <p class="text-muted small mb-0">{{ __('Hari dengan revenue tertinggi') }}</p>
            </div>
        </div>
    </div>

    <div class="row g-3">
        <div class="col-lg-6">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Distribusi Per Jam') }}</h5>
                <canvas id="hourlyChart" height="200"></canvas>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Top Kategori') }}</h5>
                @if($topCategories->isEmpty())
                    <p class="text-muted text-center py-3">Belum ada data</p>
                @else
                    <canvas id="catChart" height="200"></canvas>
                @endif
            </div>
        </div>
    </div>
</section>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
const hourly = @json($hourly);
new Chart(document.getElementById('hourlyChart'), {
    type: 'bar',
    data: {
        labels: hourly.map(r => r.hour+':00'),
        datasets: [{ label: 'Transaksi', data: hourly.map(r => r.count), backgroundColor:'rgba(37,99,235,.7)' }]
    },
    options: { plugins:{ legend:{ display:false } }, scales:{ y:{ beginAtZero:true } } }
});
const cats = @json($topCategories);
if (cats.length && document.getElementById('catChart')) {
    new Chart(document.getElementById('catChart'), {
        type: 'bar',
        data: {
            labels: cats.map(r => r.cat),
            datasets: [{ data: cats.map(r => r.revenue), backgroundColor:['#2563EB','#10B981','#F59E0B','#EC4899','#8B5CF6'] }]
        },
        options: { indexAxis:'y', plugins:{ legend:{ display:false } } }
    });
}
</script>
@endpush
