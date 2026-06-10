<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $table->label }} — {{ config('app.name') }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #B8743D;
            --primary-dark: #8A5527;
            --primary-container: #F8E6D0;
            --on-primary-container: #4A2810;
            --surface: #FBF6EE;
            --surface-variant: #EFE4D2;
            --outline-soft: #EBDFCB;
            --on-surface: #241B12;
            --on-surface-var: #6E5E48;
            --success: #5A7A3A;
            --success-container: #E3EFD0;
            --warning: #B87A1E;
            --warning-container: #F8E6C2;
            --error: #A8392E;
            --error-container: #F5D7D3;
            --white: #fff;
            --radius-sm: 8px;
            --radius-md: 12px;
            --shadow: 0 2px 8px rgba(36, 27, 18, .08);
            --safe-bottom: env(safe-area-inset-bottom, 0px);
        }
        * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
        body {
            margin: 0;
            font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
            background: var(--surface);
            color: var(--on-surface);
            min-height: 100dvh;
            padding-bottom: var(--safe-bottom);
        }

        /* ── header ── */
        .header {
            padding: 14px 16px 0;
            position: sticky;
            top: 0;
            z-index: 10;
            background: var(--surface);
        }
        .header-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }
        .store-name {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--on-surface);
            line-height: 1.2;
        }
        .table-badge {
            flex-shrink: 0;
            background: var(--primary-container);
            color: var(--primary-dark);
            font-size: .75rem;
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 999px;
            letter-spacing: .02em;
        }
        .header-sub {
            margin-top: 4px;
            font-size: .8rem;
            color: var(--on-surface-var);
        }

        /* ── search ── */
        .search-wrap {
            padding: 14px 16px 0;
        }
        .search-box {
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--surface-variant);
            border-radius: var(--radius-md);
            padding: 0 14px;
            height: 48px;
        }
        .search-box svg { flex-shrink: 0; color: var(--on-surface-var); }
        .search-box input {
            flex: 1;
            border: none;
            background: transparent;
            font: inherit;
            font-size: .95rem;
            color: var(--on-surface);
            outline: none;
        }
        .search-box input::placeholder { color: var(--on-surface-var); }

        /* ── category chips ── */
        .chips {
            display: flex;
            gap: 8px;
            padding: 12px 16px 0;
            overflow-x: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        .chips::-webkit-scrollbar { display: none; }
        .chip {
            flex-shrink: 0;
            border: none;
            border-radius: 999px;
            padding: 8px 16px;
            font: inherit;
            font-size: .82rem;
            font-weight: 600;
            cursor: pointer;
            background: var(--surface-variant);
            color: var(--on-surface-var);
            transition: background .15s, color .15s;
        }
        .chip.active {
            background: var(--primary);
            color: var(--white);
        }

        /* ── product grid ── */
        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            padding: 12px 16px calc(120px + var(--safe-bottom));
            max-width: 520px;
            margin: 0 auto;
        }
        .product {
            background: var(--white);
            border-radius: var(--radius-md);
            border: 1px solid var(--outline-soft);
            padding: 10px;
            display: flex;
            flex-direction: column;
            transition: border-color .15s, box-shadow .15s;
        }
        .product.in-cart {
            border-color: rgba(184, 116, 61, .55);
            border-width: 1.5px;
            box-shadow: var(--shadow);
        }
        .product.hidden { display: none; }
        .product-img-wrap {
            position: relative;
            aspect-ratio: 1;
            border-radius: var(--radius-sm);
            overflow: hidden;
            margin-bottom: 8px;
        }
        .product-img-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .product-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            font-weight: 700;
        }
        .qty-badge {
            position: absolute;
            top: -6px;
            right: -6px;
            background: var(--primary);
            color: var(--white);
            font-size: .7rem;
            font-weight: 700;
            min-width: 22px;
            height: 22px;
            border-radius: 999px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid var(--surface);
        }
        .product-name {
            font-size: .82rem;
            font-weight: 600;
            line-height: 1.3;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .product-cat {
            font-size: .7rem;
            color: var(--on-surface-var);
            margin-top: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .product-foot {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 6px;
            margin-top: auto;
            padding-top: 8px;
        }
        .product-price {
            font-size: .88rem;
            font-weight: 700;
            color: var(--on-surface);
        }
        .btn-add {
            width: 32px;
            height: 32px;
            border: none;
            border-radius: var(--radius-sm);
            background: var(--primary);
            color: var(--white);
            font-size: 1.2rem;
            line-height: 1;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stepper {
            display: flex;
            align-items: center;
            background: var(--primary-container);
            border-radius: var(--radius-sm);
            height: 32px;
            padding: 0 3px;
        }
        .stepper button {
            width: 28px;
            height: 28px;
            border: none;
            background: transparent;
            color: var(--primary);
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .stepper button:disabled { opacity: .35; cursor: not-allowed; }
        .stepper span {
            min-width: 22px;
            text-align: center;
            font-size: .82rem;
            font-weight: 700;
            color: var(--on-primary-container);
        }

        /* ── floating cart bar ── */
        .cart-bar {
            position: fixed;
            bottom: calc(12px + var(--safe-bottom));
            left: 16px;
            right: 16px;
            max-width: 488px;
            margin: 0 auto;
            background: var(--on-surface);
            color: var(--white);
            border-radius: var(--radius-md);
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 4px 20px rgba(36, 27, 18, .25);
            z-index: 15;
            transform: translateY(120%);
            opacity: 0;
            transition: transform .25s, opacity .25s;
        }
        .cart-bar.visible { transform: translateY(0); opacity: 1; }
        .cart-bar-info { flex: 1; min-width: 0; }
        .cart-bar-info small {
            display: block;
            font-size: .72rem;
            opacity: .75;
        }
        .cart-bar-info strong { font-size: 1rem; }
        .btn-checkout {
            border: none;
            border-radius: var(--radius-sm);
            background: var(--primary);
            color: var(--white);
            font: inherit;
            font-weight: 700;
            font-size: .88rem;
            padding: 10px 18px;
            cursor: pointer;
            white-space: nowrap;
        }

        /* ── empty state ── */
        .empty {
            grid-column: 1 / -1;
            text-align: center;
            padding: 48px 16px;
            color: var(--on-surface-var);
        }
        .empty-icon {
            width: 72px;
            height: 72px;
            background: var(--primary-container);
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            font-size: 2rem;
        }

        /* ── modal / sheet ── */
        .modal {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(36, 27, 18, .45);
            z-index: 30;
            align-items: flex-end;
        }
        .modal.open { display: flex; }
        .sheet {
            background: var(--white);
            width: 100%;
            max-width: 520px;
            margin: 0 auto;
            border-radius: 20px 20px 0 0;
            padding: 8px 20px calc(24px + var(--safe-bottom));
            max-height: 92dvh;
            overflow-y: auto;
        }
        .sheet-handle {
            width: 40px;
            height: 4px;
            background: var(--outline-soft);
            border-radius: 999px;
            margin: 8px auto 16px;
        }
        .sheet h2 {
            margin: 0 0 4px;
            font-size: 1.15rem;
            font-weight: 700;
        }
        .sheet-sub {
            font-size: .82rem;
            color: var(--on-surface-var);
            margin-bottom: 16px;
        }
        .order-summary {
            background: var(--surface);
            border-radius: var(--radius-md);
            border: 1px solid var(--outline-soft);
            padding: 12px;
            margin-bottom: 16px;
            max-height: 160px;
            overflow-y: auto;
        }
        .order-line {
            display: flex;
            justify-content: space-between;
            font-size: .85rem;
            padding: 4px 0;
        }
        .order-line .qty { color: var(--on-surface-var); margin-right: 6px; }
        .order-total {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            font-size: .95rem;
            padding-top: 8px;
            margin-top: 4px;
            border-top: 1px solid var(--outline-soft);
        }
        .field { margin-bottom: 12px; }
        .field label {
            display: block;
            font-size: .78rem;
            font-weight: 600;
            color: var(--on-surface-var);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .field label .req { color: var(--error); }
        .field input, .field textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid var(--outline-soft);
            border-radius: var(--radius-sm);
            font: inherit;
            font-size: .95rem;
            color: var(--on-surface);
            background: var(--white);
        }
        .field input:focus, .field textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(184, 116, 61, .15);
        }
        .field-hint {
            font-size: .75rem;
            color: var(--on-surface-var);
            margin-top: 4px;
        }
        .pay-opt { display: flex; gap: 8px; margin-top: 4px; }
        .pay-btn {
            flex: 1;
            padding: 12px;
            border: 2px solid var(--outline-soft);
            border-radius: var(--radius-md);
            background: var(--white);
            font: inherit;
            font-weight: 600;
            font-size: .88rem;
            cursor: pointer;
            color: var(--on-surface-var);
        }
        .pay-btn.active {
            border-color: var(--primary);
            background: var(--primary-container);
            color: var(--primary-dark);
        }
        .bank {
            background: var(--surface);
            border: 1px solid var(--outline-soft);
            border-radius: var(--radius-md);
            padding: 14px;
            margin-top: 8px;
            font-size: .88rem;
            line-height: 1.6;
        }
        .bank strong { color: var(--primary-dark); }
        .file-upload {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 14px;
            border: 1.5px dashed var(--outline-soft);
            border-radius: var(--radius-sm);
            cursor: pointer;
            background: var(--surface);
            transition: border-color .15s;
        }
        .file-upload:hover { border-color: var(--primary); }
        .file-upload input { display: none; }
        .file-upload-icon {
            width: 36px;
            height: 36px;
            background: var(--primary-container);
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
        }
        .file-upload-text { font-size: .85rem; }
        .file-upload-text strong { display: block; font-size: .88rem; }
        .file-upload-text span { color: var(--on-surface-var); font-size: .78rem; }
        .qr-box { text-align: center; margin: 16px 0; }
        .qr-box img { max-width: 220px; border-radius: var(--radius-sm); border: 1px solid var(--outline-soft); }
        .qr-box p { font-size: .85rem; color: var(--on-surface-var); margin-top: 8px; }
        .msg {
            padding: 12px 14px;
            border-radius: var(--radius-sm);
            margin-top: 12px;
            font-size: .88rem;
            line-height: 1.4;
        }
        .msg.ok { background: var(--success-container); color: var(--success); }
        .msg.err { background: var(--error-container); color: var(--error); }
        .btn-primary {
            width: 100%;
            border: none;
            border-radius: var(--radius-md);
            background: var(--primary);
            color: var(--white);
            font: inherit;
            font-weight: 700;
            font-size: .95rem;
            padding: 14px;
            cursor: pointer;
            margin-top: 16px;
        }
        .btn-primary:disabled { opacity: .5; cursor: not-allowed; }
        .btn-secondary {
            width: 100%;
            border: none;
            border-radius: var(--radius-md);
            background: var(--surface-variant);
            color: var(--on-surface);
            font: inherit;
            font-weight: 600;
            font-size: .9rem;
            padding: 12px;
            cursor: pointer;
            margin-top: 8px;
        }
        .hidden { display: none !important; }
    </style>
</head>
<body>

<header class="header">
    <div class="header-top">
        <div class="store-name">{{ config('app.name') }}</div>
        <div class="table-badge">{{ $table->label }}</div>
    </div>
    <div class="header-sub">Pilih menu & bayar dari HP Anda</div>
</header>

<div class="search-wrap">
    <div class="search-box">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
        <input type="search" id="searchInput" placeholder="Cari menu..." autocomplete="off">
    </div>
</div>

<div class="chips" id="categoryChips">
    <button type="button" class="chip active" data-cat="all">Semua</button>
    @foreach ($categories as $category)
        <button type="button" class="chip" data-cat="{{ $category->id }}">{{ $category->name }}</button>
    @endforeach
</div>

<div class="grid" id="productGrid">
    @php $hasProducts = false; @endphp
    @foreach ($categories as $category)
        @foreach ($category->products as $product)
            @php
                $hasProducts = true;
                $hue = ($product->id * 47) % 360;
            @endphp
            <article class="product"
                     data-id="{{ $product->id }}"
                     data-name="{{ $product->name }}"
                     data-price="{{ $product->price }}"
                     data-cat="{{ $category->id }}"
                     data-cat-name="{{ $category->name }}">
                <div class="product-img-wrap">
                    @if ($product->image_url)
                        <img src="{{ $product->image_url }}" alt="{{ $product->name }}" loading="lazy">
                    @else
                        <div class="product-placeholder" style="background:hsl({{ $hue }},35%,88%);color:hsl({{ $hue }},45%,32%)">
                            {{ strtoupper(substr($product->name, 0, 1)) }}
                        </div>
                    @endif
                    <div class="qty-badge hidden" data-badge></div>
                </div>
                <div class="product-name">{{ $product->name }}</div>
                <div class="product-cat">{{ $category->name }}</div>
                <div class="product-foot">
                    <div class="product-price">Rp {{ number_format($product->price, 0, ',', '.') }}</div>
                    <button type="button" class="btn-add" data-add>+</button>
                    <div class="stepper hidden" data-stepper>
                        <button type="button" data-minus>−</button>
                        <span data-count>0</span>
                        <button type="button" data-plus>+</button>
                    </div>
                </div>
            </article>
        @endforeach
    @endforeach
    @unless ($hasProducts)
        <div class="empty">
            <div class="empty-icon">☕</div>
            <p>Menu belum tersedia.<br>Silakan hubungi kasir.</p>
        </div>
    @endunless
</div>

<div class="cart-bar" id="cartBar">
    <div class="cart-bar-info">
        <small><span id="itemCount">0</span> item di keranjang</small>
        <strong id="grandTotal">Rp 0</strong>
    </div>
    <button type="button" class="btn-checkout" id="checkoutBtn">Bayar</button>
</div>

<div class="modal" id="checkoutModal">
    <div class="sheet">
        <div class="sheet-handle"></div>
        <h2>Checkout</h2>
        <p class="sheet-sub">{{ $table->label }} · {{ config('app.name') }}</p>

        <div class="order-summary" id="orderSummary"></div>

        <div class="field">
            <label>No. WhatsApp <span class="req">*</span></label>
            <input type="tel" id="customerWhatsapp" placeholder="08xxxxxxxxxx" inputmode="numeric" autocomplete="tel" required>
            <div class="field-hint">Wajib diisi agar kasir bisa menghubungi Anda</div>
        </div>

        <div class="field">
            <label>Nama (opsional)</label>
            <input type="text" id="customerName" placeholder="Nama pelanggan" maxlength="100">
        </div>

        <div class="field">
            <label>Catatan</label>
            <textarea id="notes" rows="2" placeholder="Tanpa es, kurang manis, dll."></textarea>
        </div>

        <div class="field">
            <label>Metode bayar</label>
            <div class="pay-opt">
                @if ($midtransReady)
                    <button type="button" class="pay-btn active" data-method="qris">QRIS</button>
                @endif
                @if (\App\Models\StoreSetting::isTransferConfigured())
                    <button type="button" class="pay-btn {{ $midtransReady ? '' : 'active' }}" data-method="transfer">Transfer</button>
                @endif
            </div>
        </div>

        <div id="transferBox" class="hidden">
            <div class="bank">
                <strong>Transfer ke:</strong><br>
                {{ $transfer['bank_name'] }}<br>
                No. Rek: <strong>{{ $transfer['account_number'] }}</strong><br>
                a.n. {{ $transfer['account_holder'] }}
            </div>
            <div class="field" style="margin-top:12px">
                <label>Bukti transfer <span class="req">*</span></label>
                <label class="file-upload" for="proofFile">
                    <div class="file-upload-icon">📎</div>
                    <div class="file-upload-text">
                        <strong id="proofLabel">Pilih foto bukti</strong>
                        <span>Upload dari galeri atau file</span>
                    </div>
                    <input type="file" id="proofFile" accept="image/*">
                </label>
            </div>
        </div>

        <div id="qrisBox" class="hidden">
            <div class="qr-box">
                <img id="qrImage" src="" alt="QRIS">
                <p>Scan QR dengan e-wallet Anda</p>
            </div>
        </div>

        <div id="checkoutMsg"></div>

        <button type="button" class="btn-primary" id="submitBtn">Kirim pesanan</button>
        <button type="button" class="btn-secondary" id="closeModal">Tutup</button>
    </div>
</div>

<script>
const token = @json($table->qr_token);
const csrf = document.querySelector('meta[name="csrf-token"]').content;
const cart = {};
let paymentMethod = document.querySelector('.pay-btn.active')?.dataset.method || 'transfer';
let currentOrderId = null;
let pollTimer = null;
let activeCategory = 'all';

function formatRp(n) {
    return 'Rp ' + n.toLocaleString('id-ID');
}

function refreshBar() {
    let total = 0, count = 0;
    Object.values(cart).forEach(i => { total += i.price * i.qty; count += i.qty; });
    document.getElementById('grandTotal').textContent = formatRp(total);
    document.getElementById('itemCount').textContent = count;
    document.getElementById('cartBar').classList.toggle('visible', count > 0);
}

function updateProductUI(card, qty) {
    const inCart = qty > 0;
    card.classList.toggle('in-cart', inCart);
    const badge = card.querySelector('[data-badge]');
    const addBtn = card.querySelector('[data-add]');
    const stepper = card.querySelector('[data-stepper]');
    const countEl = card.querySelector('[data-count]');
    if (inCart) {
        badge.textContent = qty;
        badge.classList.remove('hidden');
        addBtn.classList.add('hidden');
        stepper.classList.remove('hidden');
        countEl.textContent = qty;
    } else {
        badge.classList.add('hidden');
        addBtn.classList.remove('hidden');
        stepper.classList.add('hidden');
        countEl.textContent = '0';
    }
}

function refreshSummary() {
    const el = document.getElementById('orderSummary');
    const items = Object.values(cart).filter(i => i.qty > 0);
    let total = 0;
    let html = '';
    items.forEach(i => {
        const sub = i.price * i.qty;
        total += sub;
        html += `<div class="order-line"><span><span class="qty">${i.qty}x</span>${i.name}</span><span>${formatRp(sub)}</span></div>`;
    });
    html += `<div class="order-total"><span>Total</span><span>${formatRp(total)}</span></div>`;
    el.innerHTML = html;
}

function isValidWa(val) {
    return /^(\+?62|0)8[1-9][0-9]{7,11}$/.test(val.trim());
}

document.querySelectorAll('.product').forEach(card => {
    const id = card.dataset.id;
    cart[id] = { id: +id, name: card.dataset.name, price: +card.dataset.price, qty: 0 };

    const add = () => {
        cart[id].qty++;
        updateProductUI(card, cart[id].qty);
        refreshBar();
    };
    const minus = () => {
        if (cart[id].qty > 0) cart[id].qty--;
        updateProductUI(card, cart[id].qty);
        refreshBar();
    };

    card.querySelector('[data-add]').addEventListener('click', e => { e.stopPropagation(); add(); });
    card.querySelector('[data-plus]').addEventListener('click', e => { e.stopPropagation(); add(); });
    card.querySelector('[data-minus]').addEventListener('click', e => { e.stopPropagation(); minus(); });
    card.addEventListener('click', () => { if (cart[id].qty === 0) add(); });
});

document.getElementById('categoryChips').addEventListener('click', e => {
    const chip = e.target.closest('.chip');
    if (!chip) return;
    activeCategory = chip.dataset.cat;
    document.querySelectorAll('.chip').forEach(c => c.classList.toggle('active', c === chip));
    filterProducts();
});

document.getElementById('searchInput').addEventListener('input', filterProducts);

function filterProducts() {
    const q = document.getElementById('searchInput').value.trim().toLowerCase();
    document.querySelectorAll('.product').forEach(card => {
        const matchCat = activeCategory === 'all' || card.dataset.cat === activeCategory;
        const matchSearch = !q || card.dataset.name.toLowerCase().includes(q);
        card.classList.toggle('hidden', !(matchCat && matchSearch));
    });
}

document.getElementById('checkoutBtn').addEventListener('click', () => {
    refreshSummary();
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

document.getElementById('proofFile').addEventListener('change', e => {
    const f = e.target.files[0];
    document.getElementById('proofLabel').textContent = f ? f.name : 'Pilih foto bukti';
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

    const wa = document.getElementById('customerWhatsapp').value.trim();
    if (!wa) {
        showMsg('No. WhatsApp wajib diisi.', true);
        document.getElementById('customerWhatsapp').focus();
        return;
    }
    if (!isValidWa(wa)) {
        showMsg('Format WhatsApp tidak valid. Contoh: 08123456789', true);
        document.getElementById('customerWhatsapp').focus();
        return;
    }

    const fd = new FormData();
    items.forEach((it, idx) => {
        fd.append(`items[${idx}][product_id]`, it.product_id);
        fd.append(`items[${idx}][quantity]`, it.quantity);
    });
    fd.append('payment_method', paymentMethod);
    fd.append('customer_whatsapp', wa);
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
        if (!res.ok) throw new Error(data.message || Object.values(data.errors || {}).flat().join(' ') || 'Gagal');

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
        showMsg('Pembayaran berhasil! Pesanan menunggu diproses kasir.', false);
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
