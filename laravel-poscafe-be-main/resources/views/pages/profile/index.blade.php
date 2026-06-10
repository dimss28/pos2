@extends('layouts.app')
@section('title', __('Profil Saya'))
@section('page-title', __('Profil Saya'))
@section('main')

<x-page-header title="{{ __('Profil Saya') }}"
    :breadcrumbs="[['label' => 'Profil']]" />

<div class="card-clean mb-4">
    <div class="d-flex align-items-center">
        <img src="{{ $user->avatar_url }}" class="rounded-circle me-3" style="width:80px;height:80px;object-fit:cover">
        <div>
            <h4 class="fw-bold mb-0">{{ $user->name }}</h4>
            <div class="text-muted">{{ $user->email }}</div>
            <div class="mt-1"><x-role-badge :role="$user->roles" /></div>
        </div>
    </div>
</div>

<ul class="nav nav-tabs mb-3" role="tablist">
    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-info" type="button">{{ __('Informasi') }}</button></li>
    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-pwd" type="button">{{ __('Password') }}</button></li>
    <li class="nav-item"><button class="nav-link text-danger" data-bs-toggle="tab" data-bs-target="#tab-del" type="button">{{ __('Hapus Akun') }}</button></li>
</ul>

<div class="tab-content">
    <div class="tab-pane fade show active" id="tab-info">
        <div class="card-clean">
            <form action="{{ route('profile.update') }}" method="POST" enctype="multipart/form-data">
                @csrf @method('PUT')
                <div class="row g-3">
                    <div class="col-md-3 text-center">
                        <img id="prev" src="{{ $user->avatar_url }}" class="rounded-circle mb-2" style="width:128px;height:128px;object-fit:cover">
                        <input type="file" name="avatar" id="av" accept="image/*" class="form-control form-control-sm">
                        @error('avatar') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                    </div>
                    <div class="col-md-9">
                        <x-form-input name="name" label="Nama Lengkap" :value="$user->name" required />
                        <x-form-input name="email" label="Email" type="email" :value="$user->email" required />
                        <x-form-input name="phone" label="No. HP" :value="$user->phone" />
                        <button class="btn btn-primary"><i class="fas fa-save me-1"></i>{{ __('Simpan Perubahan') }}</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="tab-pane fade" id="tab-pwd">
        <div class="card-clean">
            <form action="{{ route('profile.password') }}" method="POST" style="max-width:520px">
                @csrf @method('PUT')
                <x-form-input name="current_password" label="Password Sekarang" type="password" required />
                <x-form-input name="password" label="Password Baru" type="password" required help="Minimal 8 karakter" />
                <x-form-input name="password_confirmation" label="Konfirmasi Password Baru" type="password" required />
                <button class="btn btn-primary"><i class="fas fa-key me-1"></i>{{ __('Ubah Password') }}</button>
            </form>
        </div>
    </div>

    <div class="tab-pane fade" id="tab-del">
        <div class="card-clean border border-danger">
            <h5 class="text-danger fw-bold"><i class="fas fa-exclamation-triangle me-2"></i>{{ __('Hapus Akun Permanen') }}</h5>
            <p class="text-muted">{{ __('Aksi ini akan menghapus akun Anda dan men-anonymize data. Tidak bisa dibatalkan.') }}</p>
            <form action="{{ route('profile.destroy') }}" method="POST" style="max-width:520px"
                  onsubmit="return confirm('Yakin hapus akun?')">
                @csrf @method('DELETE')
                <x-form-input name="confirmation" label="Ketik HAPUS AKUN untuk konfirmasi" required />
                <x-form-input name="password" label="Password Anda" type="password" required />
                <button class="btn btn-danger"><i class="fas fa-trash me-1"></i>{{ __('Hapus Akun Saya') }}</button>
            </form>
        </div>
    </div>
</div>

@push('scripts')
<script>
    document.getElementById('av')?.addEventListener('change', e => {
        const f = e.target.files[0]; if (!f) return;
        const r = new FileReader();
        r.onload = ev => document.getElementById('prev').src = ev.target.result;
        r.readAsDataURL(f);
    });
</script>
@endpush
@endsection
