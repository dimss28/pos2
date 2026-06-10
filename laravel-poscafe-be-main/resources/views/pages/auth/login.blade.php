@extends('layouts.auth')
@section('title', __('Masuk'))
@section('main')
<div class="d-flex" style="min-height:100vh">
    <div class="col-lg-6 d-flex align-items-center justify-content-center p-4 p-md-5 bg-white">
        <div style="max-width:420px;width:100%">
            <div class="text-center mb-4">
                <img src="{{ asset('img/logo.svg') }}" style="height:56px" class="mb-3" alt="logo">
                <h2 class="h3 fw-bold">{{ config('app.name') }}</h2>
                <p class="text-muted">{{ __('Masuk untuk melanjutkan ke panel admin') }}</p>
            </div>

            @if (session('status'))
                <div class="alert alert-success">{{ session('status') }}</div>
            @endif

            <form method="POST" action="{{ route('login') }}">
                @csrf
                <div class="mb-3">
                    <label class="form-label">{{ __('Email') }}</label>
                    <input type="email" name="email" value="{{ old('email') }}"
                           class="form-control form-control-lg @error('email') is-invalid @enderror"
                           autofocus required>
                    @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
                </div>
                <div class="mb-3">
                    <div class="d-flex justify-content-between">
                        <label class="form-label">{{ __('Password') }}</label>
                        <a href="{{ route('password.request') }}" class="small text-decoration-none">{{ __('Lupa password?') }}</a>
                    </div>
                    <div class="input-group input-group-lg">
                        <input type="password" name="password" id="password"
                               class="form-control @error('password') is-invalid @enderror" required>
                        <button type="button" class="btn btn-outline-secondary" onclick="togglePwd('password')">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                    @error('password') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
                </div>
                <div class="form-check mb-3">
                    <input class="form-check-input" type="checkbox" name="remember" id="remember">
                    <label class="form-check-label" for="remember">{{ __('Ingat saya') }}</label>
                </div>
                <button class="btn btn-primary w-100 btn-lg">{{ __('Masuk') }}</button>
            </form>

            @if (\Illuminate\Support\Facades\Route::has('register'))
                <p class="text-center text-muted mt-4 mb-0">
                    {{ __('Belum punya akun?') }} <a href="{{ route('register') }}" class="text-decoration-none">{{ __('Daftar') }}</a>
                </p>
            @endif
        </div>
    </div>
    <div class="col-lg-6 d-none d-lg-flex align-items-center justify-content-center text-white p-5"
         style="background:linear-gradient(135deg,#2563EB,#1D4ED8)">
        <div class="text-center" style="max-width:420px">
            <i class="fas fa-mug-hot fa-4x mb-4 opacity-75"></i>
            <h3 class="fw-bold">{{ __('Kelola Bisnis Cafe Anda dengan Mudah') }}</h3>
            <p class="opacity-75">{{ __('Dashboard, produk, transaksi, dan laporan POS — semua dalam satu tempat.') }}</p>
        </div>
    </div>
</div>
@endsection
