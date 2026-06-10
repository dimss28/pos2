@props(['items' => []])
@if (count($items))
    <nav>
        <ol class="breadcrumb mb-2">
            @foreach ($items as $i => $item)
                @if ($i === count($items) - 1)
                    <li class="breadcrumb-item active">{{ $item['label'] }}</li>
                @else
                    <li class="breadcrumb-item"><a href="{{ $item['url'] ?? '#' }}">{{ $item['label'] }}</a></li>
                @endif
            @endforeach
        </ol>
    </nav>
@endif
