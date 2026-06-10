@extends('layouts.app')
@section('title', 'Pengaturan Toko')
@section('page-title', 'Pengaturan Toko')
@section('main')
<x-page-header title="Pengaturan Toko" subtitle="Rekening transfer & QRIS (kasir + pelanggan meja)" />

<form method="POST" action="{{ route('store-settings.update') }}" class="card-clean">
    @csrf @method('PUT')
    <h6 class="fw-bold mb-3">Rekening Transfer</h6>
    <div class="row g-3">
        <div class="col-md-4">
            <label class="form-label">Nama bank</label>
            <input type="text" name="transfer_bank_name" class="form-control" value="{{ old('transfer_bank_name', $transfer['bank_name']) }}" placeholder="BCA">
        </div>
        <div class="col-md-4">
            <label class="form-label">No. rekening</label>
            <input type="text" name="transfer_account_number" class="form-control" value="{{ old('transfer_account_number', $transfer['account_number']) }}">
        </div>
        <div class="col-md-4">
            <label class="form-label">Atas nama</label>
            <input type="text" name="transfer_account_holder" class="form-control" value="{{ old('transfer_account_holder', $transfer['account_holder']) }}">
        </div>
    </div>

    <hr class="my-4">
    <h6 class="fw-bold mb-3">QRIS (Midtrans) — Kasir & Pelanggan Meja</h6>
    <p class="small text-muted">Satu pengaturan untuk app kasir dan order scan meja. Sandbox key diawali <code>SB-Mid-server-</code>.</p>
    <div class="mb-3">
        <div class="form-check form-switch">
            <input class="form-check-input" type="checkbox" name="midtrans_enabled" value="1" id="qris_on" @checked(old('midtrans_enabled', $midtrans_enabled))>
            <label class="form-check-label" for="qris_on"><strong>Aktifkan QRIS</strong> (kasir + pelanggan)</label>
        </div>
    </div>
    <div class="row g-3">
        <div class="col-md-8">
            <label class="form-label">Server Key</label>
            <input type="password" name="midtrans_server_key" class="form-control" placeholder="Kosongkan jika tidak ingin mengubah">
        </div>
        <div class="col-md-4 d-flex align-items-end">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" name="midtrans_is_production" value="1" id="prod" @checked(old('midtrans_is_production', $midtrans_is_production))>
                <label class="form-check-label" for="prod">Production (transaksi asli)</label>
            </div>
        </div>
    </div>

    <div class="mt-4">
        <button class="btn btn-primary">Simpan</button>
    </div>
</form>
@endsection
