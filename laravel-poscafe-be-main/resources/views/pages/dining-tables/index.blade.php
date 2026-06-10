@extends('layouts.app')
@section('title', 'Meja')
@section('page-title', 'Meja')
@section('main')
<x-page-header title="Meja" subtitle="{{ $tables->total() }} meja">
    <x-slot:actions>
        @can('create', App\Models\DiningTable::class)
            <a href="{{ route('dining-table.qr-all') }}" class="btn btn-outline-primary"><i class="fas fa-download me-1"></i>Unduh Semua QR</a>
            <a href="{{ route('dining-table.create') }}" class="btn btn-primary"><i class="fas fa-plus me-1"></i>Tambah Meja</a>
        @endcan
    </x-slot:actions>
</x-page-header>

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <div class="col-md-6"><input type="text" name="q" value="{{ request('q') }}" class="form-control" placeholder="Cari nama meja..."></div>
        <div class="col-md-3"><button class="btn btn-primary w-100">Filter</button></div>
    </form>
</div>

<div class="card-clean">
    @if ($tables->isEmpty())
        <x-empty-state icon="chair" title="Belum ada meja" description="Tambahkan meja lalu unduh QR untuk ditempel." actionLabel="Tambah Meja" :actionUrl="route('dining-table.create')" />
    @else
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th>Meja</th>
                        <th>QR</th>
                        <th>Status</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($tables as $t)
                        <tr>
                            <td class="fw-semibold">{{ $t->label }}</td>
                            <td>
                                <img src="{{ $t->qrImageUrl(80) }}" width="48" height="48" alt="QR" class="rounded border">
                            </td>
                            <td>
                                <span class="badge bg-{{ $t->is_active ? 'success' : 'secondary' }}">{{ $t->is_active ? 'Aktif' : 'Nonaktif' }}</span>
                            </td>
                            <td class="text-end">
                                <a href="{{ $t->publicUrl() }}" target="_blank" class="btn btn-sm btn-light" title="Preview"><i class="fas fa-external-link-alt"></i></a>
                                <a href="{{ route('dining-table.qr', $t) }}" class="btn btn-sm btn-light" title="Unduh QR"><i class="fas fa-download"></i></a>
                                @can('update', $t)
                                    <a href="{{ route('dining-table.edit', $t) }}" class="btn btn-sm btn-light"><i class="fas fa-pencil-alt"></i></a>
                                @endcan
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        {{ $tables->links() }}
    @endif
</div>
@endsection
