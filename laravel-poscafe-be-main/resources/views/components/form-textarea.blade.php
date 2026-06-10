@props(['name', 'label' => null, 'value' => null, 'placeholder' => null, 'rows' => 3, 'required' => false, 'maxlength' => null, 'counter' => false, 'help' => null])
<div class="mb-3">
    @if ($label)
        <label for="{{ $name }}" class="form-label">
            {{ $label }} @if ($required)<span class="text-danger">*</span>@endif
        </label>
    @endif
    <textarea id="{{ $name }}" name="{{ $name }}" rows="{{ $rows }}"
              @if ($required) required @endif
              @if ($maxlength) maxlength="{{ $maxlength }}" @endif
              placeholder="{{ $placeholder }}"
              {{ $attributes->merge(['class' => 'form-control'.($errors->has($name) ? ' is-invalid' : '')]) }}>{{ old($name, $value) }}</textarea>
    @error($name) <div class="invalid-feedback">{{ $message }}</div> @enderror
    <div class="d-flex justify-content-between">
        @if ($help) <small class="form-text text-muted">{{ $help }}</small> @else <span></span> @endif
        @if ($counter && $maxlength)
            <small class="form-text text-muted" id="{{ $name }}-counter">0/{{ $maxlength }}</small>
            <script>
                (() => {
                    const el = document.getElementById('{{ $name }}');
                    const c = document.getElementById('{{ $name }}-counter');
                    const update = () => c.textContent = `${el.value.length}/{{ $maxlength }}`;
                    el.addEventListener('input', update); update();
                })();
            </script>
        @endif
    </div>
</div>
