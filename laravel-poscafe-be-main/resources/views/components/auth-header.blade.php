@props(['title' => null, 'subtitle' => null])
<div class="text-center mb-4">
    <img src="{{ asset('img/logo.svg') }}" style="height:48px" class="mb-3" alt="logo">
    <h3 class="fw-bold mb-1">{{ $title ?? store_name() }}</h3>
    @if ($subtitle) <p class="text-muted small mb-0">{{ $subtitle }}</p> @endif
</div>
