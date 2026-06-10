@props(['column'])
@php
    $currentSort = request('sort');
    $currentDir = request('direction', 'asc');
    $isActive = $currentSort === $column;
    $nextDir = $isActive && $currentDir === 'asc' ? 'desc' : 'asc';
    $icon = ! $isActive ? 'sort' : ($currentDir === 'asc' ? 'sort-up' : 'sort-down');
    $url = request()->fullUrlWithQuery(['sort' => $column, 'direction' => $nextDir]);
@endphp
<a href="{{ $url }}" class="text-reset text-decoration-none">
    {{ $slot }} <i class="fas fa-{{ $icon }} small text-muted"></i>
</a>
