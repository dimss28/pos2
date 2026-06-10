@extends('layouts.auth')
@section('title', __('Lupa Password'))
@section('main')
<div class="d-flex align-items-center justify-content-center" style="min-height:100vh; background:var(--gray-50)">
    <div class="card-clean" style="max-width:420px; width:100%">
        <div class="text-center mb-4">
            <img src="{{ asset('img/logo.svg') }}" style="height:48px" class="mb-3" alt="logo">
            <h3 class="fw-bold">{{ __('Lupa Password') }}</h3>
            <p class="text-muted small">{{ __('Masukkan email akun Anda untuk menerima link reset password.') }}</p>
        </div>
        @if (session('status'))
            <div class="alert alert-success">{{ session('status') }}</div>
        @endif
        <form method="POST" action="{{ route('password.email') }}">
            @csrf
            <div class="mb-3">
                <label class="form-label">{{ __('Email') }}</label>
                <input type="email" name="email" value="{{ old('email') }}"
                       class="form-control form-control-lg @error('email') is-invalid @enderror" required>
                @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <button class="btn btn-primary w-100 btn-lg">{{ __('Kirim Link Reset') }}</button>
        </form>
        <p class="text-center mt-3 mb-0">
            <a href="{{ route('login') }}" class="small text-decoration-none">&larr; {{ __('Kembali ke Login') }}</a>
        </p>
    </div>
</div>
@endsection
