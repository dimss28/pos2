@php $isEdit = $user->exists; @endphp
<form action="{{ $isEdit ? route('user.update', $user) : route('user.store') }}" method="POST" enctype="multipart/form-data">
    @csrf
    @if ($isEdit) @method('PUT') @endif
    <div class="row g-3">
        <div class="col-lg-8">
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Informasi') }}</h5>
                <x-form-input name="name" label="Nama Lengkap" :value="$user->name" required />
                <x-form-input name="email" label="Email" type="email" :value="$user->email" required />
                <x-form-input name="phone" label="No. HP" :value="$user->phone" />

                <h6 class="fw-bold mt-4 mb-3">
                    {{ __('Password') }}
                    @if ($isEdit) <small class="text-muted fw-normal">({{ __('Kosongkan jika tidak diubah') }})</small> @endif
                </h6>
                <x-form-input name="password" label="Password" type="password" :required="!$isEdit" />
                <x-form-input name="password_confirmation" label="Konfirmasi Password" type="password" :required="!$isEdit" />
            </div>
        </div>
        <div class="col-lg-4">
            <div class="card-clean mb-3 text-center">
                <h5 class="fw-bold mb-3">{{ __('Foto') }}</h5>
                <img id="avPrev" src="{{ $user->avatar_url }}" class="rounded-circle mb-2"
                     style="width:120px;height:120px;object-fit:cover">
                <input type="file" name="avatar" id="avInput" accept="image/*"
                    class="form-control @error('avatar') is-invalid @enderror">
                @error('avatar') <div class="invalid-feedback d-block">{{ $message }}</div> @enderror
            </div>
            <div class="card-clean">
                <h5 class="fw-bold mb-3">{{ __('Role & Status') }}</h5>
                <x-form-select name="roles" label="Role" :options="\App\Enums\UserRole::options()" :value="$user->roles" required />
                <x-form-toggle name="is_active" label="Akun Aktif" :checked="(bool) ($user->is_active ?? true)" />
                <div class="d-grid gap-2 mt-3">
                    <button class="btn btn-primary"><i class="fas fa-save me-1"></i>{{ __('messages.save') }}</button>
                    <a href="{{ route('user.index') }}" class="btn btn-light">{{ __('messages.cancel') }}</a>
                </div>
            </div>
        </div>
    </div>
</form>

@push('scripts')
<script>
    document.getElementById('avInput')?.addEventListener('change', e => {
        const f = e.target.files[0]; if (!f) return;
        const r = new FileReader();
        r.onload = ev => document.getElementById('avPrev').src = ev.target.result;
        r.readAsDataURL(f);
    });
</script>
@endpush
