@php $isEdit = isset($category) && $category->exists; @endphp
<form action="{{ $isEdit ? route('categories.update', $category) : route('categories.store') }}" method="POST">
    @csrf
    @if ($isEdit) @method('PUT') @endif
    <div class="row g-3">
        <div class="col-lg-8">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Informasi Kategori') }}</h5>
                <x-form-input name="name" label="Nama Kategori" :value="$category->name" required />
                <x-form-textarea name="description" label="Deskripsi" :value="$category->description"
                    rows="3" maxlength="500" :counter="true" />
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Tampilan') }}</h5>

                <div class="mb-3">
                    <label class="form-label">{{ __('Icon') }}</label>
                    <div class="d-flex flex-wrap gap-2">
                        @foreach (['tag','cube','gift','mug-hot','utensils','cookie','star','bolt'] as $ic)
                            <button type="button" class="btn btn-sm btn-outline-secondary icon-pick" data-icon="{{ $ic }}">
                                <i class="fas fa-{{ $ic }}"></i>
                            </button>
                        @endforeach
                    </div>
                    <input type="hidden" name="icon" id="icon-input" value="{{ old('icon', $category->icon ?? 'tag') }}">
                    <small class="text-muted">Dipilih: <code id="icon-preview">{{ old('icon', $category->icon ?? 'tag') }}</code></small>
                </div>

                <div class="mb-3">
                    <label class="form-label">{{ __('Warna') }}</label>
                    <div class="d-flex gap-2">
                        @foreach (['#3B82F6','#10B981','#F59E0B','#EF4444','#8B5CF6','#EC4899'] as $col)
                            <button type="button" class="color-pick rounded-circle border" data-color="{{ $col }}"
                                style="width:32px;height:32px;background:{{ $col }};cursor:pointer"></button>
                        @endforeach
                    </div>
                    <input type="hidden" name="color" id="color-input" value="{{ old('color', $category->color ?? '#3B82F6') }}">
                    <small class="text-muted">Dipilih: <code id="color-preview">{{ old('color', $category->color ?? '#3B82F6') }}</code></small>
                </div>

                <x-form-toggle name="is_active" label="Aktif" :checked="old('is_active', $category->is_active ?? true)" />

                <div class="d-grid gap-2 mt-3">
                    <button class="btn btn-primary"><i class="fas fa-save me-1"></i>{{ __('messages.save') }}</button>
                    <a href="{{ route('categories.index') }}" class="btn btn-light">{{ __('messages.cancel') }}</a>
                </div>
            </div>
        </div>
    </div>
</form>
<script>
    document.querySelectorAll('.icon-pick').forEach(b => b.addEventListener('click', () => {
        const v = b.dataset.icon;
        document.getElementById('icon-input').value = v;
        document.getElementById('icon-preview').textContent = v;
    }));
    document.querySelectorAll('.color-pick').forEach(b => b.addEventListener('click', () => {
        const v = b.dataset.color;
        document.getElementById('color-input').value = v;
        document.getElementById('color-preview').textContent = v;
    }));
</script>
