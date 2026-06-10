<!DOCTYPE html><html><head><meta charset="UTF-8">
<title>Invoice {{ $order->order_number }}</title>
<style>
body { font-family: sans-serif; font-size: 12px; color: #333; }
.header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
.h1 { font-size: 24px; font-weight: bold; }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 8px; border-bottom: 1px solid #eee; text-align: left; }
.right { text-align: right; }
.summary { margin-top: 20px; }
.total-row { font-size: 16px; font-weight: bold; border-top: 2px solid #333; }
</style>
</head><body>
<div class="header">
    <div>
        <div class="h1">{{ config('app.name') }}</div>
        <div>Invoice</div>
    </div>
    <div class="right">
        <div><strong>{{ $order->order_number }}</strong></div>
        <div>{{ formatDate($order->transaction_time, 'd F Y H:i') }}</div>
        <div>Kasir: {{ $order->kasir->name ?? '-' }}</div>
    </div>
</div>

@if($order->customer_name)<p>Kepada: <strong>{{ $order->customer_name }}</strong></p>@endif

<table>
    <thead><tr><th>Produk</th><th class="right">Harga</th><th class="right">Qty</th><th class="right">Subtotal</th></tr></thead>
    <tbody>
        @foreach($orderItems as $it)
            <tr>
                <td>{{ $it->product->name ?? '-' }}</td>
                <td class="right">{{ rupiah($it->product->price ?? 0) }}</td>
                <td class="right">{{ $it->quantity }}</td>
                <td class="right">{{ rupiah($it->total_price) }}</td>
            </tr>
        @endforeach
    </tbody>
</table>

<table class="summary" style="width: 40%; margin-left: auto;">
    <tr><td>Subtotal</td><td class="right">{{ rupiah($order->subtotal) }}</td></tr>
    @if($order->discount > 0)<tr><td>Diskon</td><td class="right">-{{ rupiah($order->discount) }}</td></tr>@endif
    @if($order->tax > 0)<tr><td>Pajak</td><td class="right">{{ rupiah($order->tax) }}</td></tr>@endif
    <tr class="total-row"><td>Total</td><td class="right">{{ rupiah($order->total_price) }}</td></tr>
</table>

<p style="margin-top: 50px;">Terima kasih atas pembelian Anda.</p>
</body></html>
