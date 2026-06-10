@props(['status'])
@php
    $map = [
        'pending' => ['bg-warning text-dark', 'Pending'],
        'paid' => ['bg-success', 'Lunas'],
        'cancelled' => ['bg-danger', 'Batal'],
        'refunded' => ['bg-info text-dark', 'Refund'],
    ];
    [$class, $label] = $map[$status] ?? ['bg-secondary', ucfirst($status)];
@endphp
<span class="badge {{ $class }}">{{ $label }}</span>
