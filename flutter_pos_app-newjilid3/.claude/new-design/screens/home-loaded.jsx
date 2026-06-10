// HOME — Loaded state (after sync, with products)
// Two artboards: grid view (default) and list view, toggleable.
// Some items have quantity badges to show "in cart" state.

const HL_CATEGORIES = ['Semua', 'Snack', 'Makanan', 'Minuman', 'Kopi'];

const HL_PRODUCTS = [
  { id: 1, name: 'Pisang Goreng',         cat: 'Snack',    price: 15000, stock: 24, qty: 0, hue: 50,  best: false },
  { id: 2, name: 'Kentang Goreng',        cat: 'Snack',    price: 24000, stock: 18, qty: 1, hue: 45,  best: true  },
  { id: 3, name: 'Nasi Goreng Spesial',   cat: 'Makanan',  price: 30000, stock: 12, qty: 3, hue: 38,  best: false },
  { id: 4, name: 'Jus Apel Segar',        cat: 'Minuman',  price: 25000, stock: 22, qty: 0, hue: 130, best: false },
  { id: 5, name: 'Kopi Susu Gula Aren',   cat: 'Kopi',     price: 22000, stock: 30, qty: 0, hue: 28,  best: true  },
  { id: 6, name: 'Matcha Latte',          cat: 'Kopi',     price: 25000, stock: 18, qty: 0, hue: 120, best: false },
];

// ─────────────────────────────────────────────────────────────
// Shell — header + search + chips + toggle, then either grid or list
// ─────────────────────────────────────────────────────────────
function HomeLoaded({ palette, view = 'grid' }) {
  const p = palette;
  const cartCount = HL_PRODUCTS.reduce((s, x) => s + x.qty, 0);
  const cartTotal = HL_PRODUCTS.reduce((s, x) => s + x.qty * x.price, 0);
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0, position: 'relative' }}>
      {/* Header (clean, not colored band) */}
      <div style={{ padding: '16px 16px 0' }}>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
          <div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar }}>Menu Cafe</div>
            <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 2 }}>Sudut Kopi · Bandung</div>
          </div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar }}>{cartCount > 0 ? `${cartCount} di keranjang` : 'Senin, 24 Mei'}</div>
        </div>

        {/* Search */}
        <div style={{
          marginTop: 14, display: 'flex', alignItems: 'center', gap: 10,
          height: 48, padding: '0 8px 0 14px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <Icon name="search" size={18} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar, fontSize: 13 }}>Cari produk atau scan...</div>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm, background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="qr" size={18}/>
          </div>
        </div>

        {/* Chips + view toggle */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 12 }}>
          <div style={{ flex: 1, display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4 }}>
            {HL_CATEGORIES.map((c, i) => {
              const active = i === 0;
              return (
                <div key={c} style={{
                  flexShrink: 0, padding: '8px 14px', borderRadius: R.pill,
                  background: active ? p.onSurface : 'transparent',
                  color: active ? p.surface : p.onSurface,
                  border: active ? 'none' : `1.5px solid ${p.outline}`,
                  ...t('labelL'), fontSize: 12,
                }}>{c}</div>
              );
            })}
          </div>
          <ViewToggle palette={p} view={view}/>
        </div>
      </div>

      {/* Body */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px ' + (cartCount > 0 ? '170px' : '90px') }}>
        {view === 'grid' ? (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {HL_PRODUCTS.map(prod => <ProductCardHL key={prod.id} prod={prod} palette={p}/>)}
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {HL_PRODUCTS.map(prod => <ProductRowHL key={prod.id} prod={prod} palette={p}/>)}
          </div>
        )}
      </div>

      {/* Floating cart bar above bottom nav — only when items added */}
      {cartCount > 0 && (
        <div style={{
          position: 'absolute', bottom: 84, left: 16, right: 16,
          background: p.primary, color: p.onPrimary, borderRadius: R.lg,
          boxShadow: `0 14px 28px ${p.primary}55`,
          padding: '10px 10px 10px 18px',
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm,
            background: `${p.onPrimary}22`, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            position: 'relative', flexShrink: 0,
          }}>
            <Icon name="cart" size={18}/>
            <div style={{
              position: 'absolute', top: -4, right: -4,
              minWidth: 18, height: 18, padding: '0 4px',
              borderRadius: 9, background: p.onSurface, color: p.surface,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              ...t('labelM'), fontSize: 10, fontWeight: 700,
            }}>{cartCount}</div>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyS'), opacity: 0.85, fontSize: 11 }}>{cartCount} item dipilih</div>
            <div style={{ ...t('titleM'), fontWeight: 700, fontSize: 16 }}>{rupiah(cartTotal)}</div>
          </div>
          <div style={{
            height: 40, padding: '0 12px 0 16px', borderRadius: R.md,
            background: p.onPrimary, color: p.primary,
            display: 'flex', alignItems: 'center', gap: 6,
            ...t('labelL'), fontSize: 13, fontWeight: 700,
          }}>
            Bayar
            <Icon name="arrow-right" size={16}/>
          </div>
        </div>
      )}

      <BottomNav palette={p} active={0} cartCount={cartCount}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// View toggle (grid / list)
// ─────────────────────────────────────────────────────────────
function ViewToggle({ palette, view }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', padding: 3,
      background: p.surfaceVariant, borderRadius: R.sm,
      flexShrink: 0,
    }}>
      <ToggleBtn palette={p} active={view === 'grid'}>
        <GridIcon/>
      </ToggleBtn>
      <ToggleBtn palette={p} active={view === 'list'}>
        <ListIcon/>
      </ToggleBtn>
    </div>
  );
}

function ToggleBtn({ palette, active, children }) {
  const p = palette;
  return (
    <div style={{
      width: 32, height: 32, borderRadius: 6,
      background: active ? '#FFF' : 'transparent',
      color: active ? p.onSurface : p.onSurfaceVar,
      boxShadow: active ? `0 1px 3px ${p.onSurface}1A` : 'none',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Grid card
// ─────────────────────────────────────────────────────────────
function ProductCardHL({ prod, palette }) {
  const p = palette;
  const inCart = prod.qty > 0;
  return (
    <div style={{
      background: '#FFF', border: `1px solid ${inCart ? p.primary + '55' : p.outlineSoft}`,
      borderRadius: R.md, padding: 10, position: 'relative',
      boxShadow: inCart ? `0 0 0 1.5px ${p.primary}55` : 'none',
    }}>
      <div style={{ position: 'relative' }}>
        <ProductImg name={prod.name} hue={prod.hue} size="100%" rounded={R.sm} palette={p}/>
        {/* qty badge */}
        {inCart && (
          <div style={{
            position: 'absolute', top: -6, right: -6,
            minWidth: 26, height: 26, padding: '0 6px',
            borderRadius: 13, background: p.primary, color: p.onPrimary,
            border: `2.5px solid ${p.surface}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelL'), fontSize: 12, fontWeight: 700,
          }}>{prod.qty}</div>
        )}
        {/* best ribbon */}
        {prod.best && (
          <div style={{
            position: 'absolute', top: 6, left: 6,
            padding: '2px 7px', borderRadius: R.pill,
            background: `${p.onSurface}D9`, color: p.surface,
            ...t('labelM'), fontSize: 10, fontWeight: 700,
            letterSpacing: 0.4,
          }}>BEST</div>
        )}
      </div>
      <div style={{
        marginTop: 10, ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 600,
        display: '-webkit-box', WebkitLineClamp: 1, WebkitBoxOrient: 'vertical', overflow: 'hidden',
      }}>{prod.name}</div>
      <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>{prod.cat}</div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
        <div style={{ ...t('priceM'), color: p.onSurface, fontSize: 15 }}>{rupiah(prod.price)}</div>
        {inCart ? (
          <Stepper palette={p} qty={prod.qty} size="sm"/>
        ) : (
          <div style={{
            width: 32, height: 32, borderRadius: R.sm,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="plus" size={18} strokeWidth={2.5}/>
          </div>
        )}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// List row
// ─────────────────────────────────────────────────────────────
function ProductRowHL({ prod, palette }) {
  const p = palette;
  const inCart = prod.qty > 0;
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'center', padding: 10,
      background: '#FFF',
      border: `1px solid ${inCart ? p.primary + '55' : p.outlineSoft}`,
      borderRadius: R.md,
      boxShadow: inCart ? `0 0 0 1.5px ${p.primary}33` : 'none',
    }}>
      <div style={{ position: 'relative' }}>
        <ProductImg name={prod.name} hue={prod.hue} size={68} rounded={R.sm} palette={p}/>
        {inCart && (
          <div style={{
            position: 'absolute', top: -6, right: -6,
            minWidth: 24, height: 24, padding: '0 6px',
            borderRadius: 12, background: p.primary, color: p.onPrimary,
            border: `2.5px solid ${p.surface}`,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelL'), fontSize: 11, fontWeight: 700,
          }}>{prod.qty}</div>
        )}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>{prod.name}</div>
          {prod.best && (
            <div style={{
              padding: '2px 6px', borderRadius: R.pill,
              background: `${p.onSurface}D9`, color: p.surface,
              ...t('labelM'), fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
            }}>BEST</div>
          )}
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
          {prod.cat} &middot; stok {prod.stock}
        </div>
        <div style={{ ...t('priceM'), color: p.onSurface, fontSize: 15, marginTop: 4 }}>
          {rupiah(prod.price)}
        </div>
      </div>
      {inCart ? (
        <Stepper palette={p} qty={prod.qty}/>
      ) : (
        <div style={{
          width: 40, height: 40, borderRadius: R.sm,
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={20} strokeWidth={2.5}/>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Stepper
// ─────────────────────────────────────────────────────────────
function Stepper({ palette, qty, size }) {
  const p = palette;
  const sm = size === 'sm';
  const h = sm ? 32 : 40;
  const btn = sm ? 28 : 36;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', height: h,
      background: p.primaryContainer, color: p.onPrimaryContainer,
      borderRadius: R.sm, padding: '0 3px',
    }}>
      <div style={{ width: btn, height: btn, display: 'flex', alignItems: 'center', justifyContent: 'center', color: p.primary }}>
        <Icon name="minus" size={sm ? 16 : 18} strokeWidth={2.5}/>
      </div>
      <div style={{ minWidth: sm ? 16 : 20, textAlign: 'center', ...t('labelL'), color: p.onPrimaryContainer, fontSize: sm ? 13 : 14, fontWeight: 700 }}>
        {qty}
      </div>
      <div style={{ width: btn, height: btn, display: 'flex', alignItems: 'center', justifyContent: 'center', color: p.primary }}>
        <Icon name="plus" size={sm ? 16 : 18} strokeWidth={2.5}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons
// ─────────────────────────────────────────────────────────────
function GridIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/>
      <rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>
    </svg>
  );
}
function ListIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/>
    </svg>
  );
}

Object.assign(window, { HomeLoaded });
