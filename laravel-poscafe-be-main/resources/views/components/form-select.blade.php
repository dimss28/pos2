@props(['name', 'label' => null, 'options' => [], 'value' => null, 'placeholder' => null, 'required' => false, 'help' => null])
<div class="mb-3">
    @if ($label)
        <label for="{{ $name }}" class="form-label">
            {{ $label }} @if ($required)<span class="text-danger">*</span>@endif
        </label>
    @endif
    <select id="{{ $name }}" name="{{ $name }}" @if ($required) required @endif
            {{ $attributes->merge(['class' => 'form-select'.($errors->has($name) ? ' is-invalid' : '')]) }}>
        @if ($placeholder)
            <option value="">{{ $placeholder }}</option>
        @endif
        @foreach ($options as $key => $label)
            <option value="{{ $key }}" @selected(old($name, $value) == $key)>{{ $label }}</option>
        @endforeach
    </select>
    @error($name) <div class="invalid-feedback">{{ $message }}</div> @enderror
    @if ($help) <small class="form-text text-muted">{{ $help }}</small> @endif
</div>
