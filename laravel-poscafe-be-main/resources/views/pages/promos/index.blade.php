@extends('layouts.app')
@section('title', __('Promo'))
@section('main')
<section class="section">
    <x-page-header title="{{ __('Promo') }}">
        <x-slot:actions>
            @can('create', App\Models\Promo::class)
                <a href="{{ route('promo.create') }}" class="btn btn-primary"><i class="fas fa-plus me-2"></i>{{ __('Tambah Promo') }}</a>
            @endcan
        </x-slot:actions>
    </x-page-header>

    <div class="card-clean mb-3">
        <form method="GET" class="row g-2">
            <div class="col-md-5"><input type="text" name="q" value="{{ request('q') }}" placeholder="{{ __('Cari nama promo...') }}" class="form-control"></div>
            <div class="col-md-3">
                <select name="status" class="form-select">
                    <option value="">{{ __('Semua Status') }}</option>
                    <option value="live" @selected(request('status')==='live')>{{ __('Live') }}</option>
                    <option value="scheduled" @selected(request('status')==='scheduled')>{{ __('Terjadwal') }}</option>
                    <option value="expired" @selected(request('status')==='expired')>{{ __('Kadaluarsa') }}</option>
                    <option value="inactive" @selected(request('status')==='inactive')>{{ __('Nonaktif') }}</option>
                </select>
            </div>
            <div class="col-md-2"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('Filter') }}</button></div>
            <div class="col-md-2"><a href="{{ route('promo.index') }}" class="btn btn-light w-100">{{ __('Reset') }}</a></div>
        </form>
    </div>

    <div class="card-clean">
        @if($promos->isEmpty())
            <x-empty-state icon="percent" title="{{ __('Belum ada promo') }}"/>
        @else
            <div class="table-responsive">
                <table class="table align-middle">
                    <thead class="text-uppercase small text-muted">
                        <tr><th>{{ __('Nama') }}</th><th>{{ __('Kode') }}</th><th>{{ __('Tipe') }}</th><th class="text-end">{{ __('Nilai') }}</th><th>{{ __('Periode') }}</th><th class="text-center">{{ __('Status') }}</th><th class="text-center">{{ __('Pakai') }}</th><th></th></tr>
                    </thead>
                    <tbody>
                        @foreach($promos as $p)
                            <tr>
                                <td><strong>{{ $p->name }}</strong></td>
                                <td>@if($p->code)<code>{{ $p->code }}</code>@else — @endif</td>
                                <td>{{ $p->typeLabel() }}</td>
                                <td class="text-end">
                                    @if($p->type === 'percent') {{ $p->value }}%
                                    @elseif($p->type === 'rupiah') {{ rupiah($p->value) }}
                                    @else B1G1
                                    @endif
                                </td>
                                <td class="small text-muted">
                                    {{ $p->starts_at ? formatDate($p->starts_at, 'd M Y') : '—' }} →
                                    {{ $p->ends_at ? formatDate($p->ends_at, 'd M Y') : __('Tanpa batas') }}
                                </td>
                                <td class="text-center">
                                    @php $st = $p->status(); @endphp
                                    @if($st === 'live')<span class="badge bg-success">{{ __('Live') }}</span>
                                    @elseif($st === 'scheduled')<span class="badge bg-info">{{ __('Terjadwal') }}</span>
                                    @elseif($st === 'expired')<span class="badge bg-secondary">{{ __('Kadaluarsa') }}</span>
                                    @else<span class="badge bg-dark">{{ __('Nonaktif') }}</span>
                                    @endif
                                </td>
                                <td class="text-center">{{ $p->orders_count }}</td>
                                <td class="text-end">
                                    <form action="{{ route('promo.toggle', $p) }}" method="POST" class="d-inline">@csrf
                                        <button class="btn btn-sm btn-light" title="Toggle Active/Inactive"><i class="fas fa-power-off"></i></button>
                                    </form>
                                    @can('update', $p)<a href="{{ route('promo.edit', $p) }}" class="btn btn-sm btn-light" title="Edit"><i class="fas fa-pencil-alt"></i></a>@endcan
                                    @can('delete', $p)<button type="button" class="btn btn-sm btn-light text-danger confirm-delete" data-action="{{ route('promo.destroy', $p) }}" title="Hapus"><i class="fas fa-trash"></i></button>@endcan
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="mt-3">{{ $promos->links() }}</div>
        @endif
    </div>
</section>
@endsection
