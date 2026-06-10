@extends('layouts.app')
@section('title', __('Kategori'))
@section('page-title', __('Kategori'))
@section('main')

<x-page-header title="{{ __('Kategori') }}" subtitle="{{ $categories->total() }} kategori">
    <x-slot:actions>
        <a href="{{ route('categories.index', ['view' => 'grid']) }}" class="btn btn-sm btn-{{ $view === 'grid' ? 'primary' : 'outline-secondary' }}"><i class="fas fa-th"></i></a>
        <a href="{{ route('categories.index', ['view' => 'list']) }}" class="btn btn-sm btn-{{ $view === 'list' ? 'primary' : 'outline-secondary' }}"><i class="fas fa-list"></i></a>
        @can('create', App\Models\Category::class)
            <a href="{{ route('categories.create') }}" class="btn btn-primary"><i class="fas fa-plus me-1"></i>{{ __('Tambah Kategori') }}</a>
        @endcan
    </x-slot:actions>
</x-page-header>

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <input type="hidden" name="view" value="{{ $view }}">
        <div class="col-md-6">
            <input type="text" name="q" value="{{ request('q') }}" placeholder="{{ __('Cari nama kategori...') }}" class="form-control">
        </div>
        <div class="col-md-3"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('messages.filter') }}</button></div>
        <div class="col-md-3"><a href="{{ route('categories.index') }}" class="btn btn-light w-100">{{ __('messages.reset') }}</a></div>
    </form>
</div>

@if ($categories->isEmpty())
    <x-empty-state icon="tags" title="Belum ada kategori"
        description="Tambahkan kategori untuk mengelompokkan produk."
        actionLabel="Tambah Kategori" :actionUrl="route('categories.create')" />
@elseif ($view === 'grid')
    <div class="row g-3">
        @foreach ($categories as $cat)
            <div class="col-md-3">
                <div class="card-clean h-100 position-relative">
                    <div class="rounded-3 d-flex align-items-center justify-content-center mb-3"
                         style="width:48px;height:48px;background:{{ $cat->color }}22;color:{{ $cat->color }}">
                        <i class="fas fa-{{ $cat->icon ?: 'tag' }} fa-lg"></i>
                    </div>
                    <h6 class="fw-bold mb-1">{{ $cat->name }}</h6>
                    <p class="small text-muted mb-2">{{ $cat->products_count }} {{ __('produk') }}</p>
                    @if (! $cat->is_active)
                        <span class="badge bg-secondary">{{ __('messages.inactive') }}</span>
                    @endif
                    <div class="position-absolute top-0 end-0 p-2 d-flex gap-1">
                        @can('update', $cat)
                            <a href="{{ route('categories.edit', $cat) }}" class="btn btn-sm btn-light"><i class="fas fa-pencil-alt"></i></a>
                        @endcan
                        @can('delete', $cat)
                            <button type="button" class="btn btn-sm btn-light text-danger confirm-delete" data-action="{{ route('categories.destroy', $cat) }}"><i class="fas fa-trash"></i></button>
                        @endcan
                    </div>
                </div>
            </div>
        @endforeach
    </div>
@else
    <div class="card-clean">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th></th>
                        <th>{{ __('Nama') }}</th>
                        <th>{{ __('Produk') }}</th>
                        <th>{{ __('messages.status') }}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($categories as $cat)
                        <tr>
                            <td>
                                <span class="rounded-3 d-inline-flex align-items-center justify-content-center"
                                      style="width:36px;height:36px;background:{{ $cat->color }}22;color:{{ $cat->color }}">
                                    <i class="fas fa-{{ $cat->icon ?: 'tag' }}"></i>
                                </span>
                            </td>
                            <td>
                                <strong>{{ $cat->name }}</strong>
                                <div class="small text-muted">{{ $cat->slug }}</div>
                            </td>
                            <td>{{ $cat->products_count }}</td>
                            <td>
                                @if ($cat->is_active)
                                    <span class="badge bg-success">{{ __('messages.active') }}</span>
                                @else
                                    <span class="badge bg-secondary">{{ __('messages.inactive') }}</span>
                                @endif
                            </td>
                            <td class="text-end">
                                @can('update', $cat)
                                    <a href="{{ route('categories.edit', $cat) }}" class="btn btn-sm btn-light"><i class="fas fa-pencil-alt"></i></a>
                                @endcan
                                @can('delete', $cat)
                                    <button type="button" class="btn btn-sm btn-light text-danger confirm-delete" data-action="{{ route('categories.destroy', $cat) }}"><i class="fas fa-trash"></i></button>
                                @endcan
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
@endif

<div class="mt-3">{{ $categories->links() }}</div>

@endsection
