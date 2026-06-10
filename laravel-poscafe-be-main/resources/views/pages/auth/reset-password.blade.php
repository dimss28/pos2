@extends('layouts.auth')
@section('title', __('Reset Password'))
@section('main')
<div class="d-flex align-items-center justify-content-center" style="min-height:100vh; background:var(--gray-50)">
    <div class="card-clean" style="max-width:420px; width:100%">
        <div class="text-center mb-4">
            <img src="{{ asset('img/logo.svg') }}" style="height:48px" class="mb-3" alt="logo">
            <h3 class="fw-bold">{{ __('Reset Password') }}</h3>
        </div>
        <form method="POST" action="{{ route('password.update') }}">
            @csrf
            <input type="hidden" name="token" value="{{ $request->route('token') }}">
            <div class="mb-3">
                <label class="form-label">{{ __('Email') }}</label>
                <input type="email" name="email" value="{{ old('email', $request->email) }}"
                       class="form-control @error('email') is-invalid @enderror" required>
                @error('email') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="mb-3">
                <label class="form-label">{{ __('Password Baru') }}</label>
                <input type="password" name="password"
                       class="form-control @error('password') is-invalid @enderror" required>
                @error('password') <div class="invalid-feedback">{{ $message }}</div> @enderror
            </div>
            <div class="mb-3">
                <label class="form-label">{{ __('Konfirmasi Password') }}</label>
                <input type="password" name="password_confirmation" class="form-control" required>
            </div>
            <button class="btn btn-primary w-100 btn-lg">{{ __('Reset Password') }}</button>
        </form>
    </div>
</div>
@endsection
