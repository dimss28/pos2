@props(['action', 'from' => null, 'to' => null, 'kasirList' => [], 'showKasir' => false])
<form method="GET" action="{{ $action }}" class="card-clean mb-3">
    <div class="row g-3 align-items-end">
        <div class="col-md-3">
            <label class="form-label">Dari Tanggal</label>
            <input type="date" name="from" value="{{ $from }}" class="form-control">
        </div>
        <div class="col-md-3">
            <label class="form-label">Sampai Tanggal</label>
            <input type="date" name="to" value="{{ $to }}" class="form-control">
        </div>
        @if ($showKasir)
            <div class="col-md-3">
                <label class="form-label">Kasir</label>
                <select name="kasir_id" class="form-select">
                    <option value="">Semua Kasir</option>
                    @foreach ($kasirList as $id => $name)
                        <option value="{{ $id }}" @selected(request('kasir_id') == $id)>{{ $name }}</option>
                    @endforeach
                </select>
            </div>
        @endif
        <div class="col-md-3">
            <button type="submit" class="btn btn-primary w-100"><i class="fas fa-filter me-1"></i>Filter</button>
        </div>
    </div>
</form>
