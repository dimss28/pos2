@extends('layouts.app')
@section('title', 'Edit Meja')
@section('page-title', 'Edit Meja')
@section('main')
<x-page-header title="Edit {{ $table->label }}" :breadcrumbs="[['label' => 'Meja', 'url' => route('dining-table.index')], ['label' => 'Edit']]" />
@include('pages.dining-tables._form', ['action' => route('dining-table.update', $table), 'method' => 'PUT', 'table' => $table])

<div class="card-clean mt-3">
    <h6 class="fw-bold">QR Code</h6>
    <p class="small text-muted">URL: <a href="{{ $table->publicUrl() }}" target="_blank">{{ $table->publicUrl() }}</a></p>
    <img src="{{ $table->qrImageUrl(200) }}" alt="QR" class="border rounded mb-3">
    <div class="d-flex gap-2 flex-wrap">
        <a href="{{ route('dining-table.qr', $table) }}" class="btn btn-outline-primary btn-sm"><i class="fas fa-download me-1"></i>Unduh QR</a>
        <form method="POST" action="{{ route('dining-table.regenerate', $table) }}" onsubmit="return confirm('Token QR akan berubah. Sticker lama tidak valid.')">
            @csrf
            <button class="btn btn-outline-warning btn-sm">Generate ulang token</button>
        </form>
        @can('delete', $table)
            <form method="POST" action="{{ route('dining-table.destroy', $table) }}" onsubmit="return confirm('Hapus meja ini?')">
                @csrf @method('DELETE')
                <button class="btn btn-outline-danger btn-sm">Hapus</button>
            </form>
        @endcan
    </div>
</div>
@endsection
