@props(['id', 'title' => null, 'size' => 'md', 'static' => false])
@php
    $sizeClass = ['sm' => 'modal-sm', 'lg' => 'modal-lg', 'xl' => 'modal-xl'][$size] ?? '';
@endphp
<div class="modal fade" id="{{ $id }}" tabindex="-1"
     @if ($static) data-bs-backdrop="static" data-bs-keyboard="false" @endif>
    <div class="modal-dialog {{ $sizeClass }}">
        <div class="modal-content">
            @if ($title || isset($header))
                <div class="modal-header">
                    @isset($header){{ $header }}@else<h5 class="modal-title">{{ $title }}</h5>@endisset
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
            @endif
            <div class="modal-body">{{ $slot }}</div>
            @isset($footer)
                <div class="modal-footer">{{ $footer }}</div>
            @endisset
        </div>
    </div>
</div>
