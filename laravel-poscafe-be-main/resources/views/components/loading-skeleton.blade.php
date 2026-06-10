@props(['rows' => 3, 'height' => 16])
<div>
    @for ($i = 0; $i < $rows; $i++)
        <div class="skeleton-row" style="height:{{ $height }}px"></div>
    @endfor
</div>
<style>
    .skeleton-row {
        background: linear-gradient(90deg, #F3F4F6 25%, #E5E7EB 50%, #F3F4F6 75%);
        background-size: 200% 100%;
        animation: shimmer 1.4s infinite;
        border-radius: 6px;
        margin-bottom: 8px;
    }
    @keyframes shimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
</style>
