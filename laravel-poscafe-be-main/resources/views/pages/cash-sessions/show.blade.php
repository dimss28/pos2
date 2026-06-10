@extends('layouts.app')
@section('title', __('Shift :id', ['id' => $cashSession->id]))
@section('main')
<section class="section">
    <x-page-header
        title="{{ __('Shift :label - :kasir', ['label' => $cashSession->shift_label, 'kasir' => $cashSession->user->name]) }}"
        subtitle="{{ __('Dibuka :time', ['time' => formatDate($cashSession->opened_at)]) }}"
        :breadcrumbs="[['label'=>__('Cash Session'),'url'=>route('cash-session.index')], ['label'=>$cashSession->shift_label]]"/>

    <div class="row g-3">
        <div class="col-lg-7">
            <div class="card-clean mb-3">
                <h5 class="fw-bold mb-3">{{ __('Pendapatan per Metode') }}</h5>
                <div class="table-responsive">
                    <table class="table">
                        <tbody>
                            @foreach($revenueByMethod as $method => $total)
                                <tr>
                                    <td>{{ strtoupper($method) }}</td>
                                    <td class="text-end fw-medium">{{ rupiah($total) }}</td>
                                </tr>
                            @endforeach
                            @if(empty($revenueByMethod))
                                <tr>
                                    <td colspan="2" class="text-center text-muted py-3">{{ __('Belum ada pendapatan') }}</td>
                                </tr>
                            @endif
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __(':n Pesanan di Shift Ini', ['n' => $orders->count()]) }}</h5>
                <div class="table-responsive">
                    <table class="table align-middle">
                        <tbody>
                            @foreach($orders as $o)
                                <tr>
                                    <td><a href="{{ route('order.show', $o) }}" class="text-primary text-decoration-none fw-semibold">{{ $o->order_number }}</a></td>
                                    <td>{{ formatDate($o->transaction_time, 'H:i') }}</td>
                                    <td class="text-end fw-medium">{{ rupiah($o->total_price) }}</td>
                                </tr>
                            @endforeach
                            @if($orders->isEmpty())
                                <tr>
                                    <td colspan="3" class="text-center text-muted py-3">{{ __('Belum ada transaksi') }}</td>
                                </tr>
                            @endif
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-lg-5">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ $cashSession->is_open ? __('Tutup Shift') : __('Ringkasan Tutup') }}</h5>
                <dl class="row">
                    <dt class="col-7 text-muted fw-normal">{{ __('Modal Awal') }}</dt>
                    <dd class="col-5 text-end">{{ rupiah($cashSession->opening_float) }}</dd>
                    <dt class="col-7 text-muted fw-normal">{{ __('+ Pendapatan Tunai') }}</dt>
                    <dd class="col-5 text-end">{{ rupiah($cashRevenue) }}</dd>
                    <dt class="col-7 text-muted fw-normal">{{ __('+ Cash In') }}</dt>
                    <dd class="col-5 text-end">{{ rupiah($cashSession->cash_in) }}</dd>
                    <dt class="col-7 text-muted fw-normal">{{ __('- Cash Out') }}</dt>
                    <dd class="col-5 text-end">-{{ rupiah($cashSession->cash_out) }}</dd>
                    <dt class="col-7 fw-bold border-top pt-2 mt-2">{{ __('Expected') }}</dt>
                    <dd class="col-5 text-end fw-bold border-top pt-2 mt-2 h5">{{ rupiah($expectedCash) }}</dd>
                </dl>

                @if($cashSession->is_open && ($cashSession->user_id === auth()->id() || auth()->user()->isAdmin()))
                    <hr>
                    <form action="{{ route('cash-session.close', $cashSession) }}" method="POST">@csrf
                        <x-form-input name="cash_in" type="number" label="Cash In Tambahan" value="0"/>
                        <x-form-input name="cash_out" type="number" label="Cash Out Tambahan" value="0"/>
                        <x-form-input name="physical_count" type="number" label="Hitung Fisik" required help="Jumlah uang tunai aktual di laci."/>
                        <x-form-textarea name="closing_note" label="Catatan" rows="2"/>
                        <button class="btn btn-danger w-100 mt-3"><i class="fas fa-lock me-2"></i>{{ __('Tutup Shift') }}</button>
                    </form>
                @else
                    <dl class="row mt-3">
                        <dt class="col-7 text-muted fw-normal">{{ __('Hitung Fisik') }}</dt>
                        <dd class="col-5 text-end">{{ rupiah($cashSession->physical_count) }}</dd>
                        <dt class="col-7 fw-bold">{{ __('Variance') }}</dt>
                        <dd class="col-5 text-end fw-bold text-{{ $cashSession->variance === 0 ? 'success' : 'danger' }}">{{ rupiah($cashSession->variance) }}</dd>
                    </dl>
                    @if($cashSession->closing_note)
                        <div class="mt-3 p-3 bg-light rounded">
                            <span class="text-muted small d-block mb-1">{{ __('Catatan Penutupan:') }}</span>
                            <p class="mb-0 small text-muted">{{ $cashSession->closing_note }}</p>
                        </div>
                    @endif
                @endif
            </div>
        </div>
    </div>
</section>
@endsection
