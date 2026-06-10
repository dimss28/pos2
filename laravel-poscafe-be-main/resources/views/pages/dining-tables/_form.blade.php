<form method="POST" action="{{ $action }}" class="card-clean">
    @csrf
    @if ($method ?? false) @method($method) @endif
    <div class="row g-3">
        <div class="col-md-6">
            <label class="form-label">Nama meja</label>
            <input type="text" name="label" class="form-control" value="{{ old('label', $table->label ?? '') }}" required placeholder="Meja 1">
        </div>
        <div class="col-md-3">
            <label class="form-label">Urutan</label>
            <input type="number" name="sort_order" class="form-control" value="{{ old('sort_order', $table->sort_order ?? 0) }}" min="0">
        </div>
        <div class="col-md-3 d-flex align-items-end">
            <div class="form-check">
                <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" @checked(old('is_active', $table->is_active ?? true))>
                <label class="form-check-label" for="is_active">Aktif</label>
            </div>
        </div>
    </div>
    <div class="mt-4 d-flex gap-2">
        <button class="btn btn-primary">Simpan</button>
        <a href="{{ route('dining-table.index') }}" class="btn btn-light">Batal</a>
    </div>
</form>
