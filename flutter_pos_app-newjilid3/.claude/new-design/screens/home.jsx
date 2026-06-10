// HOME / PRODUCT CATALOG VARIATIONS
// Three takes on the home/catalog screen for cashier product input.
// All assume phone portrait. Tablet split layout can be a next pass.
// A — Standard grid with FAB cart
// B — Pill-tab categories + featured strip + compact grid
// C — Compact list view (one-handed, fast add) with sticky bottom cart bar

// ─────────────────────────────────────────────────────────────
// Sample data (placeholder — would come from ProductBloc)
// ─────────────────────────────────────────────────────────────
const CATEGORIES = [
  { id: 'all',     label: 'Semua' },
  { id: 'kopi',    label: 'Kopi' },
  { id: 'snack',   label: 'Snack' },
  { id: 'makanan', label: 'Makanan' },
  { id: 'minuman', label: 'Minuman' },
];

const PRODUCTS = [
  { id: 1,  name: 'Kopi Susu Gula Aren',   cat: 'kopi',   price: 22000, stock: 24, badge: 'best',  hue: 28 },
  { id: 2,  name: 'Americano Panas',        cat: 'kopi',   price: 18000, stock: 18, hue: 18 },
  { id: 3,  name: 'Roti Bakar Coklat',      cat: 'snack',  price: 15000, stock: 6,  badge: 'low',  hue: 36 },
  { id: 4,  name: 'Nasi Goreng Spesial',    cat: 'makanan',price: 28000, stock: 12, hue: 42 },
  { id: 5,  name: 'Es Teh Lemon',           cat: 'minuman',price: 12000, stock: 0,  badge: 'out',  hue: 50 },
  { id: 6,  name: 'Croissant Mentega',      cat: 'snack',  price: 19000, stock: 9,  hue: 45 },
  { id: 7,  name: 'Matcha Latte',           cat: 'kopi',   price: 25000, stock: 22, badge: 'best', hue: 130 },
  { id: 8,  name: 'Pisang Goreng (5pcs)',   cat: 'snack',  price: 14000, stock: 14, hue: 55 },
];

// Tiny placeholder “product image” — solid + initial. No fake illustration.
function ProductImg({ name, hue, size = 88, rounded = R.md, palette, aspectSquare = false }) {
  const initial = name[0];
  const isNum = typeof size === 'number';
  const bg = `oklch(0.92 0.04 ${hue})`;
  const fg = `oklch(0.40 0.10 ${hue})`;
  return (
    <div style={{
      width: size,
      height: isNum ? size : 'auto',
      aspectRatio: !isNum || aspectSquare ? '1 / 1' : undefined,
      borderRadius: rounded,
      background: bg, color: fg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontFamily: TYPE.family, fontWeight: 700,
      fontSize: isNum ? size * 0.42 : 'clamp(28px, 14cqi, 56px)',
      flexShrink: 0,
      position: 'relative', overflow: 'hidden',
      containerType: isNum ? undefined : 'inline-size',
    }}>
      <div style={{
        position: 'absolute', inset: 0,
        backgroundImage: `repeating-linear-gradient(135deg, ${fg}0A 0 2px, transparent 2px 14px)`,
      }}/>
      <span style={{ position: 'relative' }}>{initial}</span>
    </div>
  );
}

function StockBadge({ stock, palette }) {
  const p = palette;
  if (stock === 0) {
    return <Badge bg={p.errorContainer} fg={p.error} label="Habis" />;
  }
  if (stock <= 6) {
    return <Badge bg={p.warningContainer} fg="#92400E" label={`Stok ${stock}`} />;
  }
  return null;
}

function Badge({ bg, fg, label, leading }) {
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 4,
      background: bg, color: fg,
      padding: '4px 8px', borderRadius: R.pill,
      ...t('labelM'), fontSize: 11,
    }}>
      {leading}
      {label}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation A — Standard grid, FAB cart
// ─────────────────────────────────────────────────────────────
function HomeA({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', position: 'relative', minHeight: 0 }}>
      {/* Header */}
      <div style={{ padding: '16px 16px 0' }}>
        <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
          <div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar }}>Selamat siang</div>
            <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 2 }}>Rina · Kasir 1</div>
          </div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar }}>Senin, 24 Mei</div>
        </div>

        {/* search */}
        <div style={{
          marginTop: 18, display: 'flex', alignItems: 'center', gap: 10,
          height: 52, padding: '0 8px 0 16px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <Icon name="search" size={20} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar }}>Cari produk atau scan...</div>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm, background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="qr" size={20}/>
          </div>
        </div>

        {/* categories */}
        <div style={{ display: 'flex', gap: 8, marginTop: 16, overflowX: 'auto', paddingBottom: 4 }}>
          {CATEGORIES.map((c, i) => {
            const active = i === 1;
            return (
              <div key={c.id} style={{
                flexShrink: 0,
                padding: '10px 16px', borderRadius: R.pill,
                background: active ? p.onSurface : 'transparent',
                color: active ? p.surface : p.onSurface,
                border: active ? 'none' : `1.5px solid ${p.outline}`,
                ...t('labelL'),
              }}>
                {c.label}
              </div>
            );
          })}
        </div>
      </div>

      {/* product grid */}
      <div style={{ flex: 1, padding: '16px', overflowY: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 12 }}>
          <div style={{ ...t('titleM'), color: p.onSurface }}>Menu Kopi</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar }}>{PRODUCTS.filter(x=>x.cat==='kopi').length} produk</div>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {PRODUCTS.slice(0, 6).map(prod => (
            <ProductCardA key={prod.id} prod={prod} palette={p}/>
          ))}
        </div>
        <div style={{ height: 160 }}/>
      </div>

      {/* Floating cart pill above bottom nav */}
      <div style={{
        position: 'absolute', bottom: 84, left: 16, right: 16, height: 60,
        background: p.onSurface, color: p.surface, borderRadius: R.lg,
        display: 'flex', alignItems: 'center', padding: '0 8px 0 20px', gap: 12,
        boxShadow: `0 12px 28px ${p.onSurface}55`,
      }}>
        <div style={{
          width: 40, height: 40, borderRadius: R.sm, background: `${p.surface}22`,
          display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative',
        }}>
          <Icon name="cart" size={22} color={p.surface}/>
          <div style={{
            position: 'absolute', top: -4, right: -4, minWidth: 18, height: 18, borderRadius: 9,
            background: p.primary, color: p.onPrimary, padding: '0 5px',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelM'), fontSize: 11,
          }}>3</div>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ ...t('bodyS'), opacity: 0.7 }}>3 item · Meja 4</div>
          <div style={{ ...t('titleM') }}>{rupiah(67000)}</div>
        </div>
        <div style={{
          height: 44, padding: '0 14px', borderRadius: R.md, background: p.primary,
          display: 'flex', alignItems: 'center', gap: 6, color: p.onPrimary,
        }}>
          <span style={{ ...t('labelL') }}>Lihat</span>
          <Icon name="arrow-right" size={18}/>
        </div>
      </div>

      <BottomNav palette={p} active={0}/>
    </div>
  );
}

function ProductCardA({ prod, palette }) {
  const p = palette;
  const out = prod.stock === 0;
  return (
    <div style={{
      background: '#FFF', border: `1px solid ${p.outlineSoft}`,
      borderRadius: R.md, padding: 10, position: 'relative',
      opacity: out ? 0.55 : 1,
    }}>
      <div style={{ position: 'relative' }}>
        <ProductImg name={prod.name} hue={prod.hue} size="100%" rounded={R.sm} palette={p}/>
        <div style={{ position: 'absolute', top: 6, right: 6 }}>
          <StockBadge stock={prod.stock} palette={p}/>
        </div>
      </div>
      <div style={{ marginTop: 10, ...t('bodyM'), color: p.onSurface,
                    display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden', minHeight: 40 }}>
        {prod.name}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 6 }}>
        <div style={{ ...t('priceM'), color: p.onSurface }}>{rupiah(prod.price)}</div>
        <div style={{
          width: 32, height: 32, borderRadius: R.sm, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={18} strokeWidth={2.5}/>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation B — Featured strip + tighter grid
// ─────────────────────────────────────────────────────────────
function HomeB({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column' }}>
      {/* colored header */}
      <div style={{ background: p.onSurface, color: p.surface, padding: '16px 20px 24px',
                    borderBottomLeftRadius: 28, borderBottomRightRadius: 28 }}>
        <div>
          <div style={{ ...t('bodyS'), opacity: 0.6 }}>Warung Bu Rina · Senin, 24 Mei</div>
          <div style={{ ...t('titleM'), fontWeight: 600, marginTop: 2 }}>Apa yang dipesan?</div>
        </div>

        {/* search inside header */}
        <div style={{
          marginTop: 16, display: 'flex', alignItems: 'center', gap: 10,
          height: 52, padding: '0 6px 0 16px',
          background: p.surface, color: p.onSurface, borderRadius: R.md,
        }}>
          <Icon name="search" size={20} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar }}>Cari produk...</div>
          <div style={{
            width: 40, height: 40, borderRadius: R.sm, background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="qr" size={20}/>
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 16px 160px' }}>
        {/* category pills */}
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4, marginBottom: 20 }}>
          {CATEGORIES.map((c, i) => {
            const active = i === 0;
            return (
              <div key={c.id} style={{
                flexShrink: 0, padding: '10px 18px', borderRadius: R.pill,
                background: active ? p.primary : p.surfaceVariant,
                color: active ? p.onPrimary : p.onSurface,
                ...t('labelL'),
              }}>
                {c.label}
              </div>
            );
          })}
        </div>

        {/* featured strip */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div style={{ ...t('titleM'), color: p.onSurface }}>Bestseller</div>
          <div style={{ ...t('labelL'), color: p.primary }}>Lihat semua</div>
        </div>
        <div style={{ display: 'flex', gap: 12, overflowX: 'auto', padding: '12px 0 4px' }}>
          {PRODUCTS.filter(x => x.badge === 'best').map(prod => (
            <FeaturedCardB key={prod.id} prod={prod} palette={p}/>
          ))}
        </div>

        {/* all products list */}
        <div style={{ ...t('titleM'), color: p.onSurface, marginTop: 20, marginBottom: 12 }}>Semua Produk</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {PRODUCTS.slice(2, 7).map(prod => <ProductRowB key={prod.id} prod={prod} palette={p}/>)}
        </div>
      </div>

      {/* bottom nav */}
      <BottomNav palette={p} active={0}/>
    </div>
  );
}

function FeaturedCardB({ prod, palette }) {
  const p = palette;
  return (
    <div style={{
      width: 180, flexShrink: 0,
      background: '#FFF', border: `1px solid ${p.outlineSoft}`,
      borderRadius: R.md, padding: 10,
    }}>
      <ProductImg name={prod.name} hue={prod.hue} size={160} rounded={R.sm} palette={p}/>
      <div style={{ marginTop: 10, ...t('bodyM'), color: p.onSurface,
                    display: '-webkit-box', WebkitLineClamp: 1, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
        {prod.name}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 4 }}>
        <div style={{ ...t('priceM'), color: p.primary }}>{rupiah(prod.price)}</div>
        <div style={{
          width: 28, height: 28, borderRadius: 14, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={16} strokeWidth={2.5}/>
        </div>
      </div>
    </div>
  );
}

function ProductRowB({ prod, palette }) {
  const p = palette;
  const out = prod.stock === 0;
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'center', padding: 10,
      background: '#FFF', border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
      opacity: out ? 0.55 : 1,
    }}>
      <ProductImg name={prod.name} hue={prod.hue} size={60} rounded={R.sm} palette={p}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...t('bodyM'), color: p.onSurface, fontWeight: 600 }}>{prod.name}</div>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginTop: 4 }}>
          <div style={{ ...t('priceM'), fontSize: 15, color: p.onSurface }}>{rupiah(prod.price)}</div>
          <StockBadge stock={prod.stock} palette={p}/>
        </div>
      </div>
      <div style={{
        width: 40, height: 40, borderRadius: R.sm, background: p.primaryContainer, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon name="plus" size={20} strokeWidth={2.5}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation C — Dense list, quick-add, sticky cart bar
// ─────────────────────────────────────────────────────────────
function HomeC({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', position: 'relative', minHeight: 0 }}>
      {/* Top sticky */}
      <div style={{ padding: '16px 16px 8px', background: p.surface, position: 'sticky', top: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ ...t('titleL'), color: p.onSurface }}>Katalog</div>
          <div style={{
            ...t('labelM'), color: p.onSurfaceVar,
            padding: '4px 8px', background: p.surfaceVariant, borderRadius: R.pill,
          }}>148 produk</div>
          <div style={{ flex: 1 }}/>
          <div style={{
            width: 40, height: 40, borderRadius: R.sm, background: p.surfaceVariant,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="filter" size={20} color={p.onSurface}/>
          </div>
        </div>

        {/* search row */}
        <div style={{ marginTop: 12, display: 'flex', gap: 8 }}>
          <div style={{
            flex: 1, display: 'flex', alignItems: 'center', gap: 10,
            height: 48, padding: '0 14px',
            background: '#FFF', border: `1.5px solid ${p.outline}`, borderRadius: R.md,
          }}>
            <Icon name="search" size={20} color={p.onSurfaceVar}/>
            <div style={{ flex: 1, ...t('bodyM'), color: p.onSurface }}>kopi susu</div>
            <div style={{ ...t('labelM'), color: p.onSurfaceVar }}>×</div>
          </div>
          <div style={{
            width: 48, height: 48, borderRadius: R.md, background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="qr" size={22}/>
          </div>
        </div>

        {/* tab-style categories */}
        <div style={{
          marginTop: 12, display: 'flex', gap: 0,
          borderBottom: `1px solid ${p.outlineSoft}`,
        }}>
          {CATEGORIES.slice(0, 5).map((c, i) => {
            const active = i === 1;
            return (
              <div key={c.id} style={{
                padding: '10px 0', marginRight: 18,
                ...t('labelL'),
                color: active ? p.primary : p.onSurfaceVar,
                borderBottom: active ? `2.5px solid ${p.primary}` : '2.5px solid transparent',
                marginBottom: -1,
              }}>
                {c.label}
              </div>
            );
          })}
        </div>
      </div>

      {/* dense list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 180px' }}>
        {PRODUCTS.map(prod => <ProductRowC key={prod.id} prod={prod} palette={p}/>)}
      </div>

      {/* sticky cart bar above bottom nav */}
      <div style={{
        position: 'absolute', bottom: 84, left: 16, right: 16,
        background: p.primary, color: p.onPrimary, borderRadius: R.lg,
        boxShadow: `0 14px 28px ${p.primary}55`, padding: '10px 10px 10px 20px',
        display: 'flex', alignItems: 'center', gap: 12,
      }}>
        <div style={{
          display: 'flex', marginLeft: -4,
        }}>
          {[28, 36, 130].map((h, i) => (
            <div key={i} style={{
              width: 32, height: 32, borderRadius: '50%',
              background: `oklch(0.92 0.04 ${h})`,
              border: `2px solid ${p.primary}`, marginLeft: i ? -8 : 0,
              color: `oklch(0.40 0.10 ${h})`, fontSize: 12, fontWeight: 700,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{['K','R','M'][i]}</div>
          ))}
        </div>
        <div style={{ flex: 1, marginLeft: 4 }}>
          <div style={{ ...t('bodyS'), opacity: 0.8 }}>3 item dipilih</div>
          <div style={{ ...t('titleM'), fontWeight: 700 }}>{rupiah(67000)}</div>
        </div>
        <div style={{
          height: 42, padding: '0 14px 0 18px', borderRadius: R.md,
          background: p.onPrimary, color: p.primary,
          display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <span style={{ ...t('labelL') }}>Bayar</span>
          <Icon name="arrow-right" size={18}/>
        </div>
      </div>

      <BottomNav palette={p} active={0}/>
    </div>
  );
}

function ProductRowC({ prod, palette }) {
  const p = palette;
  const out = prod.stock === 0;
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'center', padding: '10px 0',
      borderBottom: `1px solid ${p.outlineSoft}`,
      opacity: out ? 0.5 : 1,
    }}>
      <ProductImg name={prod.name} hue={prod.hue} size={56} rounded={R.sm} palette={p}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
          <div style={{ ...t('bodyM'), color: p.onSurface, fontWeight: 600 }}>{prod.name}</div>
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 4 }}>
          <div style={{ ...t('priceM'), fontSize: 16, color: p.onSurface }}>{rupiah(prod.price)}</div>
          {prod.stock <= 6 && prod.stock > 0 && (
            <span style={{ ...t('labelM'), color: p.warning }}>· stok {prod.stock}</span>
          )}
          {out && <span style={{ ...t('labelM'), color: p.error }}>· habis</span>}
        </div>
      </div>
      {prod.id === 2 ? (
        // already added — qty stepper
        <div style={{
          display: 'flex', alignItems: 'center', height: 40,
          background: p.primaryContainer, color: p.primary,
          borderRadius: R.md, padding: '0 4px',
        }}>
          <div style={{ width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="minus" size={18} strokeWidth={2.5}/>
          </div>
          <div style={{ ...t('labelL'), minWidth: 18, textAlign: 'center', color: p.onPrimaryContainer }}>2</div>
          <div style={{ width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="plus" size={18} strokeWidth={2.5}/>
          </div>
        </div>
      ) : (
        <div style={{
          width: 40, height: 40, borderRadius: R.sm,
          border: `1.5px solid ${out ? p.outline : p.primary}`,
          color: out ? p.onSurfaceVar : p.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="plus" size={20} strokeWidth={2.5}/>
        </div>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Bottom nav (Material 3 NavigationBar)
// ─────────────────────────────────────────────────────────────
function BottomNav({ palette, active = 0, cartCount = 0 }) {
  const p = palette;
  const tabs = [
    { i: 'home',    label: 'Home',    badge: 0 },
    { i: 'cart',    label: 'Order',   badge: cartCount },
    { i: 'receipt', label: 'Riwayat', badge: 0 },
    { i: 'settings',label: 'Setting', badge: 0 },
  ];
  return (
    <div style={{
      display: 'flex', background: p.surface,
      borderTop: `1px solid ${p.outlineSoft}`,
      padding: '10px 8px 14px',
      flexShrink: 0,
    }}>
      {tabs.map((tab, i) => {
        const a = i === active;
        return (
          <div key={tab.label} style={{
            flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
          }}>
            <div style={{
              padding: '4px 16px', borderRadius: R.pill,
              background: a ? p.primaryContainer : 'transparent',
              color: a ? p.onPrimaryContainer : p.onSurface,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              position: 'relative',
            }}>
              <Icon name={tab.i} size={22}/>
              {tab.badge > 0 && (
                <div style={{
                  position: 'absolute', top: 0, right: 6,
                  minWidth: 16, height: 16, padding: '0 4px',
                  borderRadius: 8, background: p.error, color: '#FFF',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  ...t('labelM'), fontSize: 9, fontWeight: 700,
                  border: `1.5px solid ${p.surface}`,
                }}>{tab.badge}</div>
              )}
            </div>
            <div style={{
              ...t('labelM'), fontSize: 11,
              color: a ? p.onSurface : p.onSurfaceVar,
              fontWeight: a ? 700 : 500,
              lineHeight: '14px',
            }}>{tab.label}</div>
          </div>
        );
      })}
    </div>
  );
}

Object.assign(window, { HomeA, HomeB, HomeC, BottomNav, ProductImg });
