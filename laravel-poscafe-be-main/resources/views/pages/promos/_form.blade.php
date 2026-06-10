@php $isEdit = $promo->exists; @endphp
<form action="{{ $isEdit ? route('promo.update', $promo) : route('promo.store') }}" method="POST">
    @csrf @if($isEdit) @method('PUT') @endif
    <div class="card-clean">
        <h5 class="fw-bold mb-3">{{ __('Informasi Promo') }}</h5>
        <x-form-input name="name" label="Nama Promo" :value="old('name', $promo->name)" required/>
        <div class="row g-3 mb-3">
            <div class="col-md-4">
                <x-form-select name="type" label="Tipe" :options="['percent'=>'Persen','rupiah'=>'Rupiah','b1g1'=>'Beli 1 Gratis 1']" :value="old('type', $promo->type)" required/>
            </div>
            <div class="col-md-4">
                <x-form-input name="value" type="number" label="Nilai" :value="old('value', $promo->value ?? 0)" required help="{{ __('Untuk percent: 1-100. Untuk rupiah: nominal. Untuk b1g1: masukkan 0.') }}"/>
            </div>
            <div class="col-md-4">
                <x-form-input name="min_subtotal" type="number" label="Minimal Belanja" :value="old('min_subtotal', $promo->min_subtotal ?? 0)"/>
            </div>
        </div>
        <x-form-input name="code" label="Kode Voucher (opsional)" :value="old('code', $promo->code)" help="{{ __('Kode akan dipakai customer saat checkout.') }}"/>

        <div class="row g-3 mb-3">
            <div class="col-md-6"><x-form-input name="starts_at" type="datetime-local" label="Mulai" :value="old('starts_at', $promo->starts_at?->format('Y-m-d\TH:i'))"/></div>
            <div class="col-md-6"><x-form-input name="ends_at" type="datetime-local" label="Berakhir" :value="old('ends_at', $promo->ends_at?->format('Y-m-d\TH:i'))"/></div>
        </div>

        <div class="mb-3">
            <x-form-toggle name="active" label="Aktif" :checked="old('active', $promo->active ?? true)"/>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-primary"><i class="fas fa-save me-1"></i>{{ __('Simpan') }}</button>
            <a href="{{ route('promo.index') }}" class="btn btn-light">{{ __('Batal') }}</a>
        </div>
    </div>
</form>
