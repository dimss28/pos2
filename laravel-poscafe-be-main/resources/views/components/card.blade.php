@props(['title' => null, 'subtitle' => null, 'noPadding' => false])
<div {{ $attributes->merge(['class' => 'card-clean' . ($noPadding ? ' p-0' : '')]) }}>
    @if ($title || $subtitle || isset($actions))
        <div class="d-flex justify-content-between align-items-start mb-3 {{ $noPadding ? 'p-3 border-bottom' : '' }}">
            <div>
                @if ($title) <h5 class="fw-bold mb-0">{{ $title }}</h5> @endif
                @if ($subtitle) <p class="text-muted small mb-0">{{ $subtitle }}</p> @endif
            </div>
            @if (isset($actions))
                <div>{{ $actions }}</div>
            @endif
        </div>
    @endif
    <div class="{{ $noPadding ? 'p-3' : '' }}">{{ $slot }}</div>
</div>
