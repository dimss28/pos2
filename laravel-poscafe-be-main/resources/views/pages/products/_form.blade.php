@php $isEdit = $product->exists; @endphp
<form action="{{ $isEdit ? route('product.update', $product) : route('product.store') }}" method="POST" enctype="multipart/form-data">
    @csrf
    @if ($isEdit) @method('PUT') @endif
    <div class="row g-3">
        <div class="col-lg-8">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Informasi Produk') }}</h5>
                <x-form-input name="name" label="Nama Produk" :value="$product->name" required />
                <x-form-textarea name="description" label="Deskripsi" :value="$product->description"
                    rows="4" maxlength="1000" :counter="true" />
                <div class="row">
                    <div class="col-md-6">
                        <x-form-input name="price" label="Harga"
                            :value="$product->price ? rupiah($product->price, false) : ''" required icon="dollar-sign" />
                    </div>
                    <div class="col-md-6">
                        <x-form-input name="stock" label="Stok" type="number" :value="$product->stock" required />
                    </div>
                </div>
                <x-form-select name="category_id" label="Kategori"
                    :options="$categories->pluck('name','id')->toArray()" :value="$product->category_id"
                    placeholder="Pilih kategori..." required />
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card-clean mb-3">
                <h5 class="fw-bold mb-3">{{ __('Foto Produk') }}</h5>
                <div class="mb-2 text-center">
                    <img id="preview"
                         src="{{ $product->image_url ?? 'https://placehold.co/300x200?text=Foto' }}"
                         class="img-fluid rounded" style="max-height:200px;object-fit:cover">
                </div>
                <input type="file" name="image" id="imageInput" accept="image/*"
                    class="form-control @error('image') is-invalid @enderror">
                @error('image') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
            </div>
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Status') }}</h5>
                <x-form-toggle name="is_best_seller" label="Best Seller" :checked="(bool) $product->is_best_seller" />
                <div class="d-grid gap-2 mt-3">
                    <button class="btn btn-primary"><i class="fas fa-save me-1"></i>{{ __('messages.save') }}</button>
                    @if (! $isEdit)
                        <button type="submit" name="save_and_new" value="1" class="btn btn-outline-primary">
                            {{ __('messages.save_and_new') }}
                        </button>
                    @endif
                    <a href="{{ route('product.index') }}" class="btn btn-light">{{ __('messages.cancel') }}</a>
                </div>
            </div>
        </div>
    </div>
</form>

@push('scripts')
<script>
    document.getElementById('imageInput')?.addEventListener('change', e => {
        const f = e.target.files[0]; if (!f) return;
        const r = new FileReader();
        r.onload = ev => document.getElementById('preview').src = ev.target.result;
        r.readAsDataURL(f);
    });
    const price = document.querySelector('input[name="price"]');
    price?.addEventListener('input', e => {
        const v = e.target.value.replace(/\D/g, '');
        e.target.value = v ? new Intl.NumberFormat('id-ID').format(v) : '';
    });
</script>
@endpush
