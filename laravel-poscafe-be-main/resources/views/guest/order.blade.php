<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $table->label }} — {{ config('app.name') }}</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Inter, system-ui, sans-serif; background: #f4f6f8; color: #111; }
        .top { background: #1d4ed8; color: #fff; padding: 16px; position: sticky; top: 0; z-index: 10; }
        .top h1 { margin: 0; font-size: 1.1rem; }
        .top p { margin: 4px 0 0; opacity: .85; font-size: .85rem; }
        .wrap { padding: 12px 12px 100px; max-width: 480px; margin: 0 auto; }
        .cat { font-size: .75rem; font-weight: 700; color: #64748b; margin: 16px 0 8px; text-transform: uppercase; }
        .card { background: #fff; border-radius: 12px; padding: 12px; margin-bottom: 8px; display: flex; gap: 12px; align-items: center; box-shadow: 0 1px 2px rgba(0,0,0,.06); }
        .card img { width: 56px; height: 56px; border-radius: 8px; object-fit: cover; background: #e2e8f0; }
        .card .info { flex: 1; min-width: 0; }
        .card .name { font-weight: 600; font-size: .95rem; }
        .card .price { color: #1d4ed8; font-weight: 700; margin-top: 2px; }
        .qty { display: flex; align-items: center; gap: 8px; }
        .qty button { width: 32px; height: 32px; border: 1px solid #cbd5e1; background: #fff; border-radius: 8px; font-size: 1.1rem; }
        .qty span { min-width: 20px; text-align: center; font-weight: 600; }
        .bar { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; border-top: 1px solid #e2e8f0; padding: 12px 16px; display: flex; gap: 12px; align-items: center; }
        .bar .total { flex: 1; }
        .bar .total small { display: block; color: #64748b; }
        .bar .total strong { font-size: 1.1rem; }
        .btn { border: none; border-radius: 10px; padding: 12px 16px; font-weight: 600; cursor: pointer; }
        .btn-primary { background: #1d4ed8; color: #fff; }
        .btn:disabled { opacity: .5; cursor: not-allowed; }
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.5); z-index: 20; align-items: flex-end; }
        .modal.open { display: flex; }
        .sheet { background: #fff; width: 100%; max-width: 480px; margin: 0 auto; border-radius: 16px 16px 0 0; padding: 20px 16px 24px; max-height: 90vh; overflow-y: auto; }
        .sheet h2 { margin: 0 0 12px; font-size: 1.1rem; }
        label { display: block; font-size: .85rem; font-weight: 600; margin: 12px 0 6px; }
        input, textarea, select { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 1rem; }
        .pay-opt { display: flex; gap: 8px; margin-top: 8px; }
        .pay-opt button { flex: 1; padding: 12px; border: 2px solid #e2e8f0; border-radius: 10px; background: #fff; font-weight: 600; }
        .pay-opt button.active { border-color: #1d4ed8; background: #eff6ff; color: #1d4ed8; }
        .bank { background: #f8fafc; border-radius: 10px; padding: 12px; margin-top: 8px; font-size: .9rem; }
        .qr-box { text-align: center; margin: 16px 0; }
        .qr-box img { max-width: 220px; border-radius: 8px; }
        .msg { padding: 12px; border-radius: 8px; margin-top: 12px; font-size: .9rem; }
        .msg.ok { background: #dcfce7; color: #166534; }
        .msg.err { background: #fee2e2; color: #991b1b; }
        .hidden { display: none !important; }
    </style>
</head>
<body>
<div class="top">
    <h1>{{ $table->label }}</h1>
    <p>Pilih menu & bayar dari HP Anda</p>
</div>

<div class="wrap" id="menuView">
    @foreach ($categories as $category)
        <div class="cat">{{ $category->name }}</div>
        @foreach ($category->products as $product)
            <div class="card" data-id="{{ $product->id }}" data-name="{{ $product->name }}" data-price="{{ $product->price }}">
                @if ($product->image_url)
                    <img src="{{ $product->image_url }}" alt="">
                @else
                    <div style="width:56px;height:56px;border-radius:8px;background:#e2e8f0;display:flex;align-items:center;justify-content:center;font-weight:700;color:#64748b">
                        {{ strtoupper(substr($product->name, 0, 1)) }}
                    </div>
                @endif
                <div class="info">
                    <div class="name">{{ $product->name }}</div>
                    <div class="price">Rp {{ number_format($product->price, 0, ',', '.') }}</div>
                </div>
                <div class="qty">
                    <button type="button" class="minus">−</button>
                    <span class="count">0</span>
                    <button type="button" class="plus">+</button>
                </div>
            </div>
        @endforeach
    @endforeach
</div>

<div class="bar">
    <div class="total">
        <small>Total (<span id="itemCount">0</span> item)</small>
        <strong id="grandTotal">Rp 0</strong>
    </div>
    <button class="btn btn-primary" id="checkoutBtn" disabled>Bayar</button>
</div>

<div class="modal" id="checkoutModal">
    <div class="sheet">
        <h2>Checkout</h2>
        <label>Nama (opsional)</label>
        <input type="text" id="customerName" placeholder="Nama pelanggan">

        <label>Catatan</label>
        <textarea id="notes" rows="2" placeholder="Tanpa es, dll."></textarea>

        <label>Metode bayar</label>
        <div class="pay-opt">
            @if ($midtransReady)
                <button type="button" class="pay-btn active" data-method="qris">QRIS</button>
            @endif
            @if (\App\Models\StoreSetting::isTransferConfigured())
                <button type="button" class="pay-btn {{ $midtransReady ? '' : 'active' }}" data-method="transfer">Transfer</button>
            @endif
        </div>

        <div id="transferBox" class="hidden">
            <div class="bank">
                <strong>Transfer ke:</strong><br>
                {{ $transfer['bank_name'] }}<br>
                {{ $transfer['account_number'] }}<br>
                a.n. {{ $transfer['account_holder'] }}
            </div>
            <label>Bukti transfer (wajib)</label>
            <input type="file" id="proofFile" accept="image/*" capture="environment">
        </div>

        <div id="qrisBox" class="hidden">
            <div class="qr-box">
                <img id="qrImage" src="" alt="QRIS">
                <p>Scan QR dengan e-wallet Anda</p>
            </div>
        </div>

        <div id="checkoutMsg"></div>

        <button class="btn btn-primary" id="submitBtn" style="width:100%;margin-top:16px">Kirim pesanan</button>
        <button class="btn" id="closeModal" style="width:100%;margin-top:8px;background:#e2e8f0">Tutup</button>
    </div>
</div>

<script>
const token = @json($table->qr_token);
const csrf = document.querySelector('meta[name="csrf-token"]').content;
const cart = {};
let paymentMethod = document.querySelector('.pay-btn.active')?.dataset.method || 'transfer';
let currentOrderId = null;
let pollTimer = null;

function formatRp(n) {
    return 'Rp ' + n.toLocaleString('id-ID');
}

function refreshBar() {
    let total = 0, count = 0;
    Object.values(cart).forEach(i => { total += i.price * i.qty; count += i.qty; });
    document.getElementById('grandTotal').textContent = formatRp(total);
    document.getElementById('itemCount').textContent = count;
    document.getElementById('checkoutBtn').disabled = count === 0;
}

document.querySelectorAll('.card').forEach(card => {
    const id = card.dataset.id;
    const minus = card.querySelector('.minus');
    const plus = card.querySelector('.plus');
    const countEl = card.querySelector('.count');
    cart[id] = { id: +id, name: card.dataset.name, price: +card.dataset.price, qty: 0 };

    minus.addEventListener('click', () => {
        if (cart[id].qty > 0) cart[id].qty--;
        countEl.textContent = cart[id].qty;
        refreshBar();
    });
    plus.addEventListener('click', () => {
        cart[id].qty++;
        countEl.textContent = cart[id].qty;
        refreshBar();
    });
});

document.getElementById('checkoutBtn').addEventListener('click', () => {
    document.getElementById('checkoutModal').classList.add('open');
    togglePayBoxes();
});

document.getElementById('closeModal').addEventListener('click', () => {
    document.getElementById('checkoutModal').classList.remove('open');
    if (pollTimer) clearInterval(pollTimer);
});

document.querySelectorAll('.pay-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.pay-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        paymentMethod = btn.dataset.method;
        togglePayBoxes();
    });
});

function togglePayBoxes() {
    document.getElementById('transferBox').classList.toggle('hidden', paymentMethod !== 'transfer');
    document.getElementById('qrisBox').classList.add('hidden');
    document.getElementById('submitBtn').classList.remove('hidden');
    document.getElementById('checkoutMsg').innerHTML = '';
}

document.getElementById('submitBtn').addEventListener('click', async () => {
    const items = Object.values(cart).filter(i => i.qty > 0).map(i => ({
        product_id: i.id, quantity: i.qty
    }));
    if (!items.length) return;

    const fd = new FormData();
    items.forEach((it, idx) => {
        fd.append(`items[${idx}][product_id]`, it.product_id);
        fd.append(`items[${idx}][quantity]`, it.quantity);
    });
    fd.append('payment_method', paymentMethod);
    fd.append('customer_name', document.getElementById('customerName').value);
    fd.append('notes', document.getElementById('notes').value);

    if (paymentMethod === 'transfer') {
        const file = document.getElementById('proofFile').files[0];
        if (!file) {
            showMsg('Upload bukti transfer wajib.', true);
            return;
        }
        fd.append('payment_proof', file);
    }

    document.getElementById('submitBtn').disabled = true;
    try {
        const res = await fetch(`/m/${token}/checkout`, {
            method: 'POST',
            headers: { 'X-CSRF-TOKEN': csrf, 'Accept': 'application/json' },
            body: fd,
        });
        const data = await res.json();
        if (!res.ok) throw new Error(data.message || 'Gagal');

        currentOrderId = data.order_id;

        if (paymentMethod === 'qris' && data.qr_url) {
            document.getElementById('qrImage').src = data.qr_url;
            document.getElementById('qrisBox').classList.remove('hidden');
            document.getElementById('submitBtn').classList.add('hidden');
            showMsg('Scan QR lalu tunggu konfirmasi...', false);
            pollTimer = setInterval(() => pollStatus(), 5000);
        } else {
            showMsg(data.message || 'Pesanan dikirim. Menunggu konfirmasi kasir.', false);
            document.getElementById('submitBtn').classList.add('hidden');
        }
    } catch (e) {
        showMsg(e.message, true);
    } finally {
        document.getElementById('submitBtn').disabled = false;
    }
});

async function pollStatus() {
    if (!currentOrderId) return;
    const res = await fetch(`/m/${token}/orders/${currentOrderId}/status`, {
        headers: { 'Accept': 'application/json' }
    });
    const data = await res.json();
    if (data.status === 'paid') {
        clearInterval(pollTimer);
        showMsg('Pembayaran berhasil! Pesanan sedang disiapkan.', false);
    }
}

function showMsg(text, isErr) {
    const el = document.getElementById('checkoutMsg');
    el.className = 'msg ' + (isErr ? 'err' : 'ok');
    el.textContent = text;
}
</script>
</body>
</html>
