@props([
    'action', 'from' => null, 'to' => null,
    'kasirList' => [], 'categoryList' => [],
    'showKasir' => false, 'showCategory' => false,
    'showPayment' => false, 'showStatus' => false,
    'exportUrls' => [],
])
@php
    $preset = request('preset');
@endphp
<form method="GET" action="{{ $action }}" class="card-clean mb-3">
    <div class="d-flex flex-wrap gap-2 mb-3">
        @foreach (['today' => 'Hari Ini', 'week' => 'Minggu Ini', 'month' => 'Bulan Ini', 'custom' => 'Custom'] as $k => $label)
            <a href="{{ request()->fullUrlWithQuery(['preset' => $k]) }}"
               class="btn btn-sm {{ $preset === $k ? 'btn-primary' : 'btn-outline-secondary' }}">{{ $label }}</a>
        @endforeach
    </div>
    <div class="row g-3 align-items-end">
        <div class="col-md-2">
            <label class="form-label">Dari</label>
            <input type="date" name="from" value="{{ $from }}" class="form-control">
        </div>
        <div class="col-md-2">
            <label class="form-label">Sampai</label>
            <input type="date" name="to" value="{{ $to }}" class="form-control">
        </div>
        @if ($showKasir)
            <div class="col-md-2">
                <label class="form-label">Kasir</label>
                <select name="kasir_id" class="form-select">
                    <option value="">Semua</option>
                    @foreach ($kasirList as $id => $name)
                        <option value="{{ $id }}" @selected(request('kasir_id') == $id)>{{ $name }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        @if ($showCategory)
            <div class="col-md-2">
                <label class="form-label">Kategori</label>
                <select name="category_id" class="form-select">
                    <option value="">Semua</option>
                    @foreach ($categoryList as $id => $name)
                        <option value="{{ $id }}" @selected(request('category_id') == $id)>{{ $name }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        @if ($showPayment)
            <div class="col-md-2">
                <label class="form-label">Pembayaran</label>
                <select name="payment_method" class="form-select">
                    <option value="">Semua</option>
                    @foreach (['cash' => 'Cash', 'qris' => 'QRIS', 'card' => 'Kartu'] as $k => $v)
                        <option value="{{ $k }}" @selected(request('payment_method') == $k)>{{ $v }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        @if ($showStatus)
            <div class="col-md-2">
                <label class="form-label">Status</label>
                <select name="status" class="form-select">
                    <option value="">Semua</option>
                    @foreach (['paid' => 'Lunas', 'pending' => 'Pending', 'refunded' => 'Refund', 'cancelled' => 'Batal'] as $k => $v)
                        <option value="{{ $k }}" @selected(request('status') == $k)>{{ $v }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        <div class="col-md-2">
            <button type="submit" class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>Terapkan</button>
        </div>
    </div>
    @if (count($exportUrls))
        <div class="d-flex gap-2 mt-3">
            @isset($exportUrls['xlsx']) <a href="{{ $exportUrls['xlsx'] }}" class="btn btn-sm btn-success"><i class="fas fa-file-excel me-1"></i>XLSX</a> @endisset
            @isset($exportUrls['csv']) <a href="{{ $exportUrls['csv'] }}" class="btn btn-sm btn-secondary"><i class="fas fa-file-csv me-1"></i>CSV</a> @endisset
            @isset($exportUrls['pdf']) <a href="{{ $exportUrls['pdf'] }}" class="btn btn-sm btn-danger"><i class="fas fa-file-pdf me-1"></i>PDF</a> @endisset
            <button type="button" onclick="window.print()" class="btn btn-sm btn-outline-secondary"><i class="fas fa-print me-1"></i>Print</button>
        </div>
    @endif
</form>
