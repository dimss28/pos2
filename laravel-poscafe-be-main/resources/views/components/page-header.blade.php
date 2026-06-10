@props(['title', 'subtitle' => null, 'breadcrumbs' => []])
<div class="d-flex justify-content-between align-items-end mb-4">
    <div>
        <x-breadcrumb :items="$breadcrumbs" />
        <h1 class="h3 fw-bold mb-1">{{ $title }}</h1>
        @if ($subtitle) <p class="text-muted mb-0">{{ $subtitle }}</p> @endif
    </div>
    @if (isset($actions))
        <div class="d-flex gap-2">{{ $actions }}</div>
    @endif
</div>
