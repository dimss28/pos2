@extends('layouts.app')
@section('title', __('Produk'))
@section('page-title', __('Produk'))
@section('main')
@php $catMap = $categories->keyBy('id'); @endphp

<x-page-header title="{{ __('Produk') }}" subtitle="{{ $products->total() }} produk">
    <x-slot:actions>
        @can('create', App\Models\Product::class)
            <a href="{{ route('product.create') }}" class="btn btn-primary"><i class="fas fa-plus me-1"></i>{{ __('Tambah Produk') }}</a>
        @endcan
    </x-slot:actions>
</x-page-header>

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <div class="col-md-4">
            <input type="text" name="q" value="{{ request('q') }}" placeholder="{{ __('Cari nama produk...') }}" class="form-control">
        </div>
        <div class="col-md-3">
            <select name="category_id" class="form-select">
                <option value="">{{ __('Semua Kategori') }}</option>
                @foreach ($categories as $c)
                    <option value="{{ $c->id }}" @selected(request('category_id') == $c->id)>{{ $c->name }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-md-3">
            <select name="stock_filter" class="form-select">
                <option value="">{{ __('Semua Stok') }}</option>
                <option value="low" @selected(request('stock_filter') === 'low')>{{ __('Stok Menipis (<5)') }}</option>
                <option value="out" @selected(request('stock_filter') === 'out')>{{ __('Stok Habis') }}</option>
            </select>
        </div>
        <div class="col-md-2"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('messages.filter') }}</button></div>
    </form>
</div>

<form id="bulk-form" method="POST" action="{{ route('product.bulk-destroy') }}">@csrf @method('DELETE')</form>

<div id="bulk-toolbar" class="card-clean mb-3 d-none d-flex justify-content-between align-items-center">
    <span><strong id="selected-count">0</strong> {{ __('produk terpilih') }}</span>
    <button type="button" class="btn btn-sm btn-danger" onclick="bulkDel()"><i class="fas fa-trash me-1"></i>{{ __('messages.delete') }}</button>
</div>

<div class="card-clean">
    @if ($products->isEmpty())
        <x-empty-state icon="box-open" title="Belum ada produk"
            description="Tambahkan produk pertama untuk mulai berjualan."
            actionLabel="Tambah Produk" :actionUrl="route('product.create')" />
    @else
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th style="width:30px"><input type="checkbox" id="select-all" class="form-check-input"></th>
                        <th>{{ __('Produk') }}</th>
                        <th>{{ __('Kategori') }}</th>
                        <th class="text-end"><x-sort-link column="price">{{ __('Harga') }}</x-sort-link></th>
                        <th class="text-center"><x-sort-link column="stock">{{ __('Stok') }}</x-sort-link></th>
                        <th class="text-center">{{ __('Best Seller') }}</th>
                        <th class="text-center">{{ __('Aksi') }}</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($products as $p)
                        <tr>
                            <td><input type="checkbox" name="ids[]" form="bulk-form" value="{{ $p->id }}" class="form-check-input row-select"></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    @if ($p->image_url)
                                        <img src="{{ $p->image_url }}" class="rounded me-2" style="width:48px;height:48px;object-fit:cover">
                                    @else
                                        <div class="rounded bg-light me-2 d-flex align-items-center justify-content-center" style="width:48px;height:48px"><i class="fas fa-image text-muted"></i></div>
                                    @endif
                                    <div>
                                        <div class="fw-semibold">{{ $p->name }}</div>
                                        <div class="small text-muted">#{{ $p->id }}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                @if ($cat = $catMap->get($p->category_id))
                                    <span class="badge bg-light text-dark">{{ $cat->name }}</span>
                                @endif
                            </td>
                            <td class="text-end fw-medium">{{ rupiah($p->price) }}</td>
                            <td class="text-center">
                                @if ($p->stock == 0)
                                    <span class="badge bg-danger">{{ __('Habis') }}</span>
                                @elseif ($p->stock < 5)
                                    <span class="badge bg-warning text-dark">{{ $p->stock }}</span>
                                @else
                                    <span>{{ $p->stock }}</span>
                                @endif
                            </td>
                            <td class="text-center">
                                @if ($p->is_best_seller) <i class="fas fa-star text-warning"></i> @endif
                            </td>
                            <td class="text-center">
                                @can('update', $p)
                                    <a href="{{ route('product.edit', $p) }}" class="btn btn-sm btn-light"><i class="fas fa-pencil-alt"></i></a>
                                @endcan
                                @can('delete', $p)
                                    <button type="button" class="btn btn-sm btn-light text-danger confirm-delete" data-action="{{ route('product.destroy', $p) }}"><i class="fas fa-trash"></i></button>
                                @endcan
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="mt-3 d-flex justify-content-between align-items-center">
            <small class="text-muted">{{ __('messages.showing', ['from' => $products->firstItem(), 'to' => $products->lastItem(), 'total' => $products->total()]) }}</small>
            {{ $products->links() }}
        </div>
    @endif
</div>

@push('scripts')
<script>
    const sa = document.getElementById('select-all');
    const tb = document.getElementById('bulk-toolbar');
    const sc = document.getElementById('selected-count');
    function upd() {
        const n = document.querySelectorAll('.row-select:checked').length;
        tb.classList.toggle('d-none', n === 0);
        sc.textContent = n;
    }
    sa?.addEventListener('change', () => {
        document.querySelectorAll('.row-select').forEach(c => c.checked = sa.checked);
        upd();
    });
    document.querySelectorAll('.row-select').forEach(c => c.addEventListener('change', upd));
    function bulkDel() {
        if (!confirm('Hapus produk terpilih?')) return;
        document.getElementById('bulk-form').submit();
    }
</script>
@endpush
@endsection
