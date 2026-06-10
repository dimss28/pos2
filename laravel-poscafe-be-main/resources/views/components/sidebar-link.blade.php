@props(['route', 'icon', 'show' => true])
@if ($show && \Illuminate\Support\Facades\Route::has($route))
    <li class="{{ request()->routeIs(\Illuminate\Support\Str::before($route, '.').'.*') ? 'active' : '' }}">
        <a href="{{ route($route) }}"><i class="fas fa-{{ $icon }}"></i><span>{{ $slot }}</span></a>
    </li>
@endif
