@props([
    'name', 'label' => null, 'type' => 'text', 'value' => null,
    'placeholder' => null, 'required' => false, 'readonly' => false,
    'help' => null, 'icon' => null,
])
<div class="mb-3">
    @if ($label)
        <label for="{{ $name }}" class="form-label">
            {{ $label }} @if ($required)<span class="text-danger">*</span>@endif
        </label>
    @endif
    <div class="{{ $icon ? 'input-group' : '' }}">
        @if ($icon)
            <span class="input-group-text"><i class="fas fa-{{ $icon }}"></i></span>
        @endif
        <input type="{{ $type }}"
               id="{{ $name }}"
               name="{{ $name }}"
               value="{{ old($name, $value) }}"
               placeholder="{{ $placeholder }}"
               @if ($required) required @endif
               @if ($readonly) readonly @endif
               {{ $attributes->merge(['class' => 'form-control'.($errors->has($name) ? ' is-invalid' : '')]) }}>
        @error($name) <div class="invalid-feedback">{{ $message }}</div> @enderror
    </div>
    @if ($help) <small class="form-text text-muted">{{ $help }}</small> @endif
</div>
