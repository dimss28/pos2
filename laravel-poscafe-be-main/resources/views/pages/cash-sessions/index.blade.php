@extends('layouts.app')
@section('title', __('Cash Session'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Cash Session') }}">
        <x-slot:actions>
            @if(! $mySession)
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#openShiftModal"><i class="fas fa-key me-2"></i>{{ __('Buka Shift') }}</button>
            @else
                <a href="{{ route('cash-session.show', $mySession) }}" class="btn btn-success"><i class="fas fa-clock me-2"></i>{{ __('Shift Aktif Anda') }}</a>
            @endif
        </x-slot:actions>
    </x-page-header>

    <div class="row mb-3 g-3">
        <div class="col-md-3"><x-stat-card label="{{ __('Sedang Buka') }}" value="{{ $stats['open_now'] }}" icon="door-open" color="primary"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Tutup Hari Ini') }}" value="{{ $stats['closed_today'] }}" icon="check" color="success"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Variance Hari Ini') }}" value="{{ rupiah($stats['variance_today']) }}" icon="balance-scale" color="warning"/></div>
        <div class="col-md-3"><x-stat-card label="{{ __('Pendapatan Tunai') }}" value="{{ rupiah($stats['cash_revenue_today']) }}" icon="money-bill-wave" color="info"/></div>
    </div>

    <div class="card-clean mb-3">
        <form method="GET" class="row g-2">
            <div class="col-md-3">
                <select name="status" class="form-select">
                    <option value="">{{ __('Semua Status') }}</option>
                    <option value="open" @selected(request('status')==='open')>{{ __('Buka') }}</option>
                    <option value="closed" @selected(request('status')==='closed')>{{ __('Tutup') }}</option>
                </select>
            </div>
            <div class="col-md-3"><input type="date" name="date_from" value="{{ request('date_from') }}" class="form-control"></div>
            <div class="col-md-3"><input type="date" name="date_to" value="{{ request('date_to') }}" class="form-control"></div>
            <div class="col-md-3"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('Filter') }}</button></div>
        </form>
    </div>

    <div class="card-clean">
        @if($sessions->isEmpty())
            <x-empty-state icon="cash-register" title="{{ __('Belum ada shift') }}"/>
        @else
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr><th>{{ __('Kasir') }}</th><th>{{ __('Shift') }}</th><th>{{ __('Buka') }}</th><th>{{ __('Tutup') }}</th><th class="text-end">{{ __('Modal') }}</th><th class="text-end">{{ __('Variance') }}</th><th class="text-center">{{ __('Order') }}</th><th></th></tr>
                    </thead>
                    <tbody>
                        @foreach($sessions as $s)
                            <tr>
                                <td>{{ $s->user->name ?? '-' }}</td>
                                <td><span class="badge bg-light text-dark">{{ $s->shift_label }}</span></td>
                                <td>{{ formatDate($s->opened_at) }}</td>
                                <td>{!! $s->closed_at ? formatDate($s->closed_at) : '<span class="badge bg-warning">Buka</span>' !!}</td>
                                <td class="text-end">{{ rupiah($s->opening_float) }}</td>
                                <td class="text-end">
                                    @if(! is_null($s->variance))
                                        <span class="text-{{ $s->variance === 0 ? 'success' : ($s->variance < 0 ? 'danger' : 'warning') }}">{{ rupiah($s->variance) }}</span>
                                    @else — @endif
                                </td>
                                <td class="text-center">{{ $s->orders_count }}</td>
                                <td class="text-end">
                                    <a href="{{ route('cash-session.show', $s) }}" class="btn btn-sm btn-light" title="Lihat"><i class="fas fa-eye"></i></a>
                                    @if($s->is_open && auth()->user()->isAdmin() && $s->user_id !== auth()->id())
                                        <form action="{{ route('cash-session.force-close', $s) }}" method="POST" class="d-inline">@csrf
                                            <button class="btn btn-sm btn-light text-danger" onclick="return confirm('Force close shift?')">{{ __('Force Close') }}</button>
                                        </form>
                                    @endif
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="mt-3">{{ $sessions->links() }}</div>
        @endif
    </div>

    {{-- Modal buka shift --}}
    <x-modal id="openShiftModal" title="{{ __('Buka Shift') }}">
        <form action="{{ route('cash-session.open') }}" method="POST">@csrf
            <x-form-select name="shift_label" label="Shift" :options="['Pagi'=>'Pagi','Siang'=>'Siang','Malam'=>'Malam']" required/>
            <x-form-input name="opening_float" label="Modal Awal" type="number" required help="Jumlah uang fisik di laci kasir."/>
            <x-form-textarea name="opening_note" label="Catatan" rows="2"/>
            <button class="btn btn-primary w-100">{{ __('Buka Shift') }}</button>
        </form>
    </x-modal>
</section>
@endsection
