@props(['label', 'value', 'icon', 'color' => 'primary', 'delta' => null, 'deltaLabel' => null, 'href' => null])
@php $tag = $href ? 'a' : 'div'; @endphp
<{{ $tag }} @if ($href) href="{{ $href }}" @endif class="card-clean d-block text-decoration-none text-reset">
    <div class="d-flex">
        <div class="me-3 rounded p-3 bg-{{ $color }}-100 text-{{ $color }}-600 align-self-start">
            <i class="fas fa-{{ $icon }} fa-2x"></i>
        </div>
        <div>
            <div class="text-muted text-uppercase small fw-semibold">{{ $label }}</div>
            <div class="h3 fw-bold mb-0">{{ $value }}</div>
            @if ($delta !== null)
                <div class="small {{ $delta >= 0 ? 'text-success' : 'text-danger' }}">
                    <i class="fas fa-arrow-{{ $delta >= 0 ? 'up' : 'down' }}"></i>
                    {{ abs($delta) }}% {{ $deltaLabel ?? __('vs kemarin') }}
                </div>
            @endif
        </div>
    </div>
</{{ $tag }}>
