@php
    $hasRoute = fn ($name) => \Illuminate\Support\Facades\Route::has($name);
@endphp
<aside class="main-sidebar">
    <div class="sidebar-brand">
        <a href="{{ route('home') }}">
            <img src="{{ asset('img/logo.svg') }}" alt="logo">
            <span class="logo-name">{{ config('app.name') }}</span>
        </a>
    </div>
    <ul class="sidebar-menu">
        <li class="menu-header">{{ __('Overview') }}</li>
        <li class="{{ request()->routeIs('home') ? 'active' : '' }}">
            <a href="{{ route('home') }}"><i class="fas fa-chart-line"></i><span>{{ __('Dashboard') }}</span></a>
        </li>

        <li class="menu-header">{{ __('Master Data') }}</li>
        @if ($hasRoute('categories.index'))
            <li class="{{ request()->routeIs('categories.*') ? 'active' : '' }}">
                <a href="{{ route('categories.index') }}"><i class="fas fa-tags"></i><span>{{ __('Kategori') }}</span></a>
            </li>
        @endif
        @if ($hasRoute('product.index'))
            <li class="{{ request()->routeIs('product.*') ? 'active' : '' }}">
                <a href="{{ route('product.index') }}"><i class="fas fa-box-open"></i><span>{{ __('Produk') }}</span></a>
            </li>
        @endif
        @if ($hasRoute('promo.index'))
            <li class="{{ request()->routeIs('promo.*') ? 'active' : '' }}">
                <a href="{{ route('promo.index') }}"><i class="fas fa-percent"></i><span>{{ __('Promo') }}</span></a>
            </li>
        @endif
        @can('viewAny', App\Models\User::class)
            @if ($hasRoute('user.index'))
                <li class="{{ request()->routeIs('user.*') ? 'active' : '' }}">
                    <a href="{{ route('user.index') }}"><i class="fas fa-users"></i><span>{{ __('Pengguna') }}</span></a>
                </li>
            @endif
        @endcan

        @if ($hasRoute('order.index') || $hasRoute('cash-session.index'))
            <li class="menu-header">{{ __('Transaksi') }}</li>
        @endif
        @if ($hasRoute('order.index'))
            <li class="{{ request()->routeIs('order.*') ? 'active' : '' }}">
                <a href="{{ route('order.index') }}"><i class="fas fa-receipt"></i><span>{{ __('Pesanan') }}</span></a>
            </li>
        @endif
        @if ($hasRoute('cash-session.index'))
            <li class="{{ request()->routeIs('cash-session.*') ? 'active' : '' }}">
                <a href="{{ route('cash-session.index') }}"><i class="fas fa-cash-register"></i><span>{{ __('Cash Session') }}</span></a>
            </li>
        @endif

        @can('view-reports')
            @if ($hasRoute('reports.index'))
                <li class="menu-header">{{ __('Laporan') }}</li>
                <li class="{{ request()->routeIs('reports.*') ? 'active' : '' }}">
                    <a href="{{ route('reports.index') }}"><i class="fas fa-chart-bar"></i><span>{{ __('Semua Laporan') }}</span></a>
                </li>
            @endif
        @endcan
    </ul>
</aside>
