@props(['icon' => 'inbox', 'title' => 'Belum ada data', 'description' => null, 'actionLabel' => null, 'actionUrl' => null])
<div class="text-center py-5">
    <i class="fas fa-{{ $icon }} fa-3x text-muted mb-3"></i>
    <h5 class="fw-bold">{{ $title }}</h5>
    @if ($description) <p class="text-muted">{{ $description }}</p> @endif
    @if ($actionLabel && $actionUrl)
        <a href="{{ $actionUrl }}" class="btn btn-primary"><i class="fas fa-plus me-1"></i>{{ $actionLabel }}</a>
    @endif
</div>
