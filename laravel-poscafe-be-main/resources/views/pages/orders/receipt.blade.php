<!DOCTYPE html><html><head>
<title>Struk #{{ $order->order_number }}</title>
<style>
@page { size: 80mm auto; margin: 5mm; }
body { width: 70mm; font-family: monospace; font-size: 11px; padding: 5px; }
.center { text-align: center; }
.right { text-align: right; }
hr { border: none; border-top: 1px dashed #000; }
table { width: 100%; }
@media print { .no-print { display: none; } }
</style>
</head><body onload="window.print()">
<div class="center">
    <strong>{{ store_name() }}</strong><br>
    Jl. Contoh No. 1, Jakarta
</div>
<hr>
<div>{{ $order->order_number }}</div>
<div>{{ formatDate($order->transaction_time, 'd/m/Y H:i') }}</div>
<div>Kasir: {{ $order->kasir->name ?? '-' }}</div>
@if($order->customer_name)<div>Customer: {{ $order->customer_name }}</div>@endif
<hr>
@foreach($orderItems as $it)
<div>
    {{ $it->product->name ?? '-' }}<br>
    {{ $it->quantity }} x {{ rupiah($it->product->price ?? 0, false) }} = {{ rupiah($it->total_price, false) }}
</div>
@endforeach
<hr>
<table>
    <tr><td>Subtotal</td><td class="right">{{ rupiah($order->subtotal, false) }}</td></tr>
    @if($order->discount > 0)<tr><td>Diskon</td><td class="right">-{{ rupiah($order->discount, false) }}</td></tr>@endif
    @if($order->tax > 0)<tr><td>Pajak</td><td class="right">{{ rupiah($order->tax, false) }}</td></tr>@endif
    <tr><td><strong>Total</strong></td><td class="right"><strong>{{ rupiah($order->total_price, false) }}</strong></td></tr>
    <tr><td>Bayar ({{ strtoupper($order->payment_method) }})</td><td class="right">{{ rupiah($order->amount_paid, false) }}</td></tr>
    <tr><td>Kembali</td><td class="right">{{ rupiah($order->change_amount, false) }}</td></tr>
</table>
<hr>
<div class="center">Terima kasih atas kunjungan Anda</div>
<button class="no-print" onclick="window.print()">Cetak</button>
</body></html>
