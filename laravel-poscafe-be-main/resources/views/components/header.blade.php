@php
    $u = auth()->user();
    $initials = collect(explode(' ', $u->name ?? 'U'))->take(2)->map(fn ($w) => mb_substr($w, 0, 1))->implode('');
@endphp
<header class="navbar-top">
    <div class="d-flex align-items-center gap-3">
        <button class="hamburger" type="button"><i class="fas fa-bars"></i></button>
        <span class="nav-title">@yield('page-title', __('Dashboard'))</span>
    </div>
    <div class="user-dropdown">
        <button type="button" class="user-btn">
            <span class="avatar">{{ strtoupper($initials) }}</span>
            <span class="d-none d-sm-inline">{{ $u->name }}</span>
            <i class="fas fa-chevron-down small text-muted"></i>
        </button>
        <ul class="dropdown-menu dropdown-menu-end mt-2" style="right:0">
            <li><a class="dropdown-item" href="{{ route('profile.show') }}"><i class="fas fa-user me-2"></i>{{ __('Profil Saya') }}</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button class="dropdown-item text-danger" type="submit">
                        <i class="fas fa-sign-out-alt me-2"></i>{{ __('Logout') }}
                    </button>
                </form>
            </li>
        </ul>
    </div>
</header>
