@props(['role'])
@php
    $map = [
        'owner' => ['bg-danger', 'Owner'],
        'admin' => ['bg-primary', 'Admin'],
        'kasir' => ['bg-info text-dark', 'Kasir'],
    ];
    [$class, $label] = $map[$role] ?? ['bg-secondary', ucfirst($role ?? '-')];
@endphp
<span class="badge {{ $class }}">{{ $label }}</span>
