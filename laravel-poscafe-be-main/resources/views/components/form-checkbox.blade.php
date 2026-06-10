@props(['name', 'label' => null, 'checked' => false, 'value' => 1])
<div class="form-check mb-3">
    <input class="form-check-input" type="checkbox"
           id="{{ $name }}" name="{{ $name }}" value="{{ $value }}"
           @checked(old($name, $checked))>
    @if ($label)
        <label class="form-check-label" for="{{ $name }}">{{ $label }}</label>
    @endif
</div>
