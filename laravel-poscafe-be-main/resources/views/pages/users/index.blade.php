@extends('layouts.app')
@section('title', __('Pengguna'))
@section('page-title', __('Pengguna'))
@section('main')

<x-page-header title="{{ __('Pengguna') }}" subtitle="{{ $users->total() }} pengguna">
    <x-slot:actions>
        @can('create', App\Models\User::class)
            <a href="{{ route('user.create') }}" class="btn btn-primary"><i class="fas fa-user-plus me-1"></i>{{ __('Tambah Pengguna') }}</a>
        @endcan
    </x-slot:actions>
</x-page-header>

<div class="card-clean mb-3">
    <form method="GET" class="row g-2">
        <div class="col-md-6">
            <input type="text" name="q" value="{{ request('q') }}" placeholder="{{ __('Cari nama / email...') }}" class="form-control">
        </div>
        <div class="col-md-3">
            <select name="role" class="form-select">
                <option value="">{{ __('Semua Role') }}</option>
                @foreach (\App\Enums\UserRole::options() as $v => $l)
                    <option value="{{ $v }}" @selected(request('role') === $v)>{{ $l }}</option>
                @endforeach
            </select>
        </div>
        <div class="col-md-3"><button class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>{{ __('messages.filter') }}</button></div>
    </form>
</div>

<div class="card-clean">
    @if ($users->isEmpty())
        <x-empty-state icon="users" title="Belum ada pengguna" />
    @else
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="text-uppercase small text-muted">
                    <tr>
                        <th>{{ __('Pengguna') }}</th>
                        <th>{{ __('Kontak') }}</th>
                        <th>{{ __('Role') }}</th>
                        <th>{{ __('messages.status') }}</th>
                        <th>{{ __('Login Terakhir') }}</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($users as $u)
                        <tr>
                            <td>
                                <div class="d-flex align-items-center">
                                    <img src="{{ $u->avatar_url }}" class="rounded-circle me-2" style="width:40px;height:40px;object-fit:cover">
                                    <div>
                                        <div class="fw-semibold">{{ $u->name }}</div>
                                        <div class="small text-muted">{{ __('Bergabung') }} {{ formatDate($u->created_at, 'd M Y') }}</div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                {{ $u->email }}
                                <div class="small text-muted">{{ $u->phone ?? '—' }}</div>
                            </td>
                            <td><x-role-badge :role="$u->roles" /></td>
                            <td>
                                @if ($u->is_active)
                                    <span class="badge bg-success">{{ __('messages.active') }}</span>
                                @else
                                    <span class="badge bg-secondary">{{ __('messages.inactive') }}</span>
                                @endif
                            </td>
                            <td class="small text-muted">
                                {{ $u->last_login_at ? $u->last_login_at->diffForHumans() : __('Belum pernah') }}
                            </td>
                            <td class="text-end">
                                @can('update', $u)
                                    <a href="{{ route('user.edit', $u) }}" class="btn btn-sm btn-light"><i class="fas fa-pencil-alt"></i></a>
                                @endcan
                                @can('delete', $u)
                                    <button type="button" class="btn btn-sm btn-light text-danger confirm-delete" data-action="{{ route('user.destroy', $u) }}"><i class="fas fa-trash"></i></button>
                                @endcan
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
        <div class="mt-3">{{ $users->links() }}</div>
    @endif
</div>

@endsection
