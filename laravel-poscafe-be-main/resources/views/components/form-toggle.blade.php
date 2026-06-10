@props(['name', 'label' => null, 'checked' => false, 'value' => 1, 'help' => null])
<div class="form-check form-switch mb-3">
    <input class="form-check-input" type="checkbox" role="switch"
           id="{{ $name }}" name="{{ $name }}" value="{{ $value }}"
           @checked(old($name, $checked))>
    @if ($label)
        <label class="form-check-label" for="{{ $name }}">{{ $label }}</label>
    @endif
    @if ($help) <div><small class="form-text text-muted">{{ $help }}</small></div> @endif
</div>
