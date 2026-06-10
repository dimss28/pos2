@props([
    'variant' => 'primary',
    'size' => 'md',
    'icon' => null,
    'href' => null,
    'type' => 'button',
    'loading' => false,
])
@php
    $sizeClass = ['sm' => 'btn-sm', 'md' => '', 'lg' => 'btn-lg'][$size] ?? '';
    $variantClass = $variant === 'ghost' ? 'btn-light' : 'btn-'.$variant;
    $classes = trim("btn $variantClass $sizeClass");
@endphp
@if ($href)
    <a href="{{ $href }}" {{ $attributes->merge(['class' => $classes]) }}>
        @if ($icon)<i class="fas fa-{{ $icon }} {{ trim($slot) !== '' ? 'me-1' : '' }}"></i>@endif
        {{ $slot }}
    </a>
@else
    <button type="{{ $type }}" @if($loading) disabled @endif {{ $attributes->merge(['class' => $classes]) }}>
        @if ($loading)
            <span class="spinner-border spinner-border-sm me-1"></span>
        @elseif ($icon)
            <i class="fas fa-{{ $icon }} {{ trim($slot) !== '' ? 'me-1' : '' }}"></i>
        @endif
        {{ $slot }}
    </button>
@endif
