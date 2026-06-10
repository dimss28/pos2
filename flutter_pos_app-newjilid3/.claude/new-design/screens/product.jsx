// PRODUCT MANAGEMENT — list, detail modal, add/edit form
// Original: cards with Detail+Edit buttons (no price/stock visible!), bare form
// Redesign: surface price+stock+category up front, single overflow action,
// detail as proper sheet, add form grouped & sticky save.

// ─────────────────────────────────────────────────────────────
// Sample data
// ─────────────────────────────────────────────────────────────
const MP_PRODUCTS = [
  { id: 1, name: 'Pisang Goreng',   cat: 'Snack',    price: 15000, stock: 80,  best: false, hue: 50 },
  { id: 2, name: 'Kentang Goreng',  cat: 'Snack',    price: 18000, stock: 24,  best: true,  hue: 45 },
  { id: 3, name: 'Nasi Goreng',     cat: 'Makanan',  price: 28000, stock: 12,  best: false, hue: 38 },
  { id: 4, name: 'Jus Apel',        cat: 'Minuman',  price: 16000, stock: 5,   best: false, hue: 130 },
  { id: 5, name: 'Kopi Gula Aren',  cat: 'Minuman',  price: 22000, stock: 0,   best: true,  hue: 28 },
];

// ─────────────────────────────────────────────────────────────
// 1) MANAGE PRODUCT — list
// ─────────────────────────────────────────────────────────────
function ManageProductPage({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0, position: 'relative' }}>
      {/* App bar */}
      <div style={{
        padding: '12px 8px 8px',
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: p.onSurface,
        }}>
          <BackArrow color={p.onSurface}/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ ...t('titleL'), color: p.onSurface }}>Kelola Produk</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            48 produk &middot; 3 stok menipis
          </div>
        </div>
      </div>

      {/* Search + filter row */}
      <div style={{ padding: '4px 16px 0', display: 'flex', gap: 8 }}>
        <div style={{
          flex: 1, display: 'flex', alignItems: 'center', gap: 10,
          height: 44, padding: '0 14px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <SearchIconLocal color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar, fontSize: 13 }}>Cari produk...</div>
        </div>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <FilterIconLocal/>
        </div>
      </div>

      {/* Category chips */}
      <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '12px 16px 4px' }}>
        {['Semua', 'Snack', 'Makanan', 'Minuman', 'Kopi'].map((c, i) => {
          const active = i === 0;
          return (
            <div key={c} style={{
              flexShrink: 0, padding: '8px 14px', borderRadius: R.pill,
              background: active ? p.onSurface : 'transparent',
              color: active ? p.surface : p.onSurface,
              border: active ? 'none' : `1.5px solid ${p.outline}`,
              ...t('labelL'), fontSize: 13,
            }}>{c}</div>
          );
        })}
      </div>

      {/* List */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 100px' }}>
        {MP_PRODUCTS.map(prod => <ProductManageTile key={prod.id} prod={prod} palette={p}/>)}
      </div>

      {/* FAB extended */}
      <div style={{
        position: 'absolute', right: 16, bottom: 20,
        height: 52, padding: '0 20px', borderRadius: R.lg,
        background: p.primary, color: p.onPrimary,
        display: 'flex', alignItems: 'center', gap: 8,
        boxShadow: `0 10px 24px ${p.primary}55`,
        ...t('labelL'), fontSize: 14, fontWeight: 700,
      }}>
        <Icon name="plus" size={18} strokeWidth={2.5}/>
        Tambah Produk
      </div>
    </div>
  );
}

function ProductManageTile({ prod, palette }) {
  const p = palette;
  const out = prod.stock === 0;
  const low = prod.stock > 0 && prod.stock <= 6;
  return (
    <div style={{
      display: 'flex', gap: 12, alignItems: 'center', padding: 12,
      background: '#FFF', border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
      marginBottom: 10, opacity: out ? 0.7 : 1,
    }}>
      <ProductImg name={prod.name} hue={prod.hue} size={64} rounded={R.sm} palette={p}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 15, fontWeight: 600 }}>{prod.name}</div>
          {prod.best && (
            <div style={{
              padding: '2px 6px', borderRadius: R.pill,
              background: p.primaryContainer, color: p.onPrimaryContainer,
              ...t('labelM'), fontSize: 10, fontWeight: 700,
            }}>Best</div>
          )}
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 12 }}>
          {prod.cat}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 6 }}>
          <div style={{ ...t('priceM'), color: p.onSurface, fontSize: 15 }}>{rupiah(prod.price)}</div>
          <div style={{ color: p.onSurfaceVar, fontSize: 12 }}>·</div>
          <div style={{
            ...t('labelM'), fontSize: 11,
            color: out ? p.error : low ? '#A66400' : p.success,
          }}>
            {out ? 'Habis' : low ? `Stok ${prod.stock}` : `Stok ${prod.stock}`}
          </div>
        </div>
      </div>
      <div style={{
        width: 36, height: 36, borderRadius: R.sm,
        background: 'transparent', color: p.onSurfaceVar,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        border: `1px solid ${p.outlineSoft}`,
      }}>
        <MoreIcon/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 2) PRODUCT DETAIL — bottom sheet style
// ─────────────────────────────────────────────────────────────
function ProductDetailSheet({ palette }) {
  const p = palette;
  const prod = MP_PRODUCTS[0];
  return (
    <div style={{ flex: 1, position: 'relative', background: '#000', display: 'flex', flexDirection: 'column' }}>
      {/* dim faux background */}
      <div style={{ flex: 1, background: p.surface, opacity: 0.35 }}/>

      {/* Bottom sheet */}
      <div style={{
        background: p.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '12px 20px 20px',
        boxShadow: '0 -16px 40px rgba(0,0,0,0.25)',
      }}>
        {/* drag handle */}
        <div style={{
          width: 40, height: 4, borderRadius: 2,
          background: p.outline, margin: '0 auto 14px',
        }}/>

        {/* Title row */}
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12 }}>
          <ProductImg name={prod.name} hue={prod.hue} size={88} rounded={R.md} palette={p}/>
          <div style={{ flex: 1, minWidth: 0, paddingTop: 4 }}>
            <div style={{ ...t('titleL'), color: p.onSurface, fontSize: 19 }}>{prod.name}</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 4 }}>{prod.cat}</div>
            {prod.best && (
              <div style={{
                display: 'inline-block', marginTop: 8,
                padding: '3px 8px', borderRadius: R.pill,
                background: p.primaryContainer, color: p.onPrimaryContainer,
                ...t('labelM'), fontSize: 10, fontWeight: 700,
              }}>Bestseller</div>
            )}
          </div>
        </div>

        {/* Stats row */}
        <div style={{
          marginTop: 16, padding: '14px 16px',
          background: p.surfaceVariant, borderRadius: R.md,
          display: 'flex', gap: 12,
        }}>
          <StatBlock label="Harga" value={rupiah(prod.price)} palette={p}/>
          <div style={{ width: 1, background: p.outline }}/>
          <StatBlock label="Stok" value={`${prod.stock}`} palette={p}/>
          <div style={{ width: 1, background: p.outline }}/>
          <StatBlock label="Terjual" value="124" palette={p}/>
        </div>

        {/* Action row */}
        <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
          <ActionBtn label="Hapus" palette={p} variant="danger"/>
          <ActionBtn label="Edit Produk" palette={p} variant="primary" full/>
        </div>
      </div>
    </div>
  );
}

function StatBlock({ label, value, palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1 }}>
      <div style={{ ...t('labelM'), color: p.onSurfaceVar, fontSize: 10, textTransform: 'uppercase', letterSpacing: 0.6 }}>{label}</div>
      <div style={{ ...t('titleM'), color: p.onSurface, marginTop: 4, fontSize: 16, fontWeight: 700 }}>{value}</div>
    </div>
  );
}

function ActionBtn({ label, palette, variant, full }) {
  const p = palette;
  const variants = {
    primary: { bg: p.primary, fg: p.onPrimary, border: 'none' },
    danger:  { bg: 'transparent', fg: p.error, border: `1.5px solid ${p.error}55` },
  };
  const v = variants[variant];
  return (
    <div style={{
      flex: full ? 2 : 1,
      height: 48, borderRadius: R.md,
      background: v.bg, color: v.fg, border: v.border,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      ...t('labelL'), fontSize: 14, fontWeight: 700,
    }}>{label}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// 3) ADD/EDIT PRODUCT — form
// ─────────────────────────────────────────────────────────────
function AddProductPage({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      {/* App bar */}
      <div style={{
        padding: '12px 8px 8px',
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: p.onSurface,
        }}>
          <BackArrow color={p.onSurface}/>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ ...t('titleL'), color: p.onSurface }}>Tambah Produk</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Lengkapi info menu baru
          </div>
        </div>
      </div>

      {/* Form */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px' }}>
        {/* Photo picker — featured at top */}
        <SectionLabelAP palette={p}>Foto Produk</SectionLabelAP>
        <div style={{
          height: 160, borderRadius: R.md,
          background: p.surfaceVariant,
          border: `1.5px dashed ${p.outline}`,
          display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', gap: 8,
          color: p.onSurfaceVar,
        }}>
          <CameraIcon/>
          <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>
            Tap untuk pilih foto
          </div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 12 }}>
            PNG / JPG &middot; maks. 2 MB
          </div>
        </div>

        {/* Info section */}
        <SectionLabelAP palette={p}>Informasi</SectionLabelAP>
        <Field palette={p} label="Nama Produk" value="Kopi Susu Gula Aren"/>
        <Field palette={p} label="Harga" value="22.000" prefix="Rp"/>

        <SectionLabelAP palette={p}>Kategori</SectionLabelAP>
        <SelectField palette={p} value="Minuman" placeholder="Pilih kategori"/>

        <SectionLabelAP palette={p}>Stok</SectionLabelAP>
        <StepperField palette={p} value={24}/>

        <SectionLabelAP palette={p}>Tampilan</SectionLabelAP>
        <SwitchRow palette={p} title="Tandai sebagai Bestseller"
                   subtitle="Akan muncul di strip menu favorit"
                   value/>
      </div>

      {/* Sticky save */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
      }}>
        <div style={{
          height: 54, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          Simpan Produk
        </div>
      </div>
    </div>
  );
}

function SectionLabelAP({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function Field({ palette, label, value, prefix }) {
  const p = palette;
  return (
    <div style={{ marginBottom: 10 }}>
      <div style={{
        height: 52, borderRadius: R.md,
        border: `1.5px solid ${p.outline}`,
        background: '#FFF',
        display: 'flex', alignItems: 'center', padding: '0 14px', gap: 6,
      }}>
        {prefix && (
          <div style={{ ...t('bodyL'), color: p.onSurfaceVar, fontSize: 15 }}>{prefix}</div>
        )}
        <div style={{ flex: 1, ...t('bodyL'), color: p.onSurface, fontSize: 15 }}>{value}</div>
      </div>
    </div>
  );
}

function SelectField({ palette, value, placeholder }) {
  const p = palette;
  return (
    <div style={{
      height: 52, borderRadius: R.md,
      border: `1.5px solid ${p.outline}`,
      background: '#FFF',
      display: 'flex', alignItems: 'center', padding: '0 14px', gap: 6,
    }}>
      <div style={{ flex: 1, ...t('bodyL'), color: value ? p.onSurface : p.onSurfaceVar, fontSize: 15 }}>
        {value || placeholder}
      </div>
      <div style={{ color: p.onSurfaceVar }}>
        <Icon name="chev-down" size={18}/>
      </div>
    </div>
  );
}

function StepperField({ palette, value }) {
  const p = palette;
  return (
    <div style={{
      height: 52, borderRadius: R.md,
      border: `1.5px solid ${p.outline}`,
      background: '#FFF',
      display: 'flex', alignItems: 'center', padding: '4px 6px',
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: R.sm,
        background: p.surfaceVariant, color: p.onSurface,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon name="minus" size={18} strokeWidth={2.5}/>
      </div>
      <div style={{ flex: 1, textAlign: 'center', ...t('titleM'), color: p.onSurface, fontSize: 18 }}>
        {value}
      </div>
      <div style={{
        width: 40, height: 40, borderRadius: R.sm,
        background: p.primary, color: p.onPrimary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <Icon name="plus" size={18} strokeWidth={2.5}/>
      </div>
    </div>
  );
}

function SwitchRow({ palette, title, subtitle, value }) {
  const p = palette;
  return (
    <div style={{
      padding: '14px 14px', borderRadius: R.md,
      border: `1px solid ${p.outlineSoft}`, background: '#FFF',
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      <div style={{ flex: 1 }}>
        <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>{title}</div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 12 }}>{subtitle}</div>
      </div>
      <div style={{
        width: 44, height: 24, borderRadius: 12,
        background: value ? p.primary : p.outline,
        position: 'relative', flexShrink: 0,
      }}>
        <div style={{
          position: 'absolute', top: 2, left: value ? 22 : 2,
          width: 20, height: 20, borderRadius: '50%',
          background: '#FFF', transition: 'left .15s',
        }}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons local
// ─────────────────────────────────────────────────────────────
function SearchIconLocal({ color }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke={color || 'currentColor'} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>
    </svg>
  );
}
function FilterIconLocal() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 5h18M6 12h12M10 19h4"/>
    </svg>
  );
}
function MoreIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
      <circle cx="12" cy="6"  r="1.8"/>
      <circle cx="12" cy="12" r="1.8"/>
      <circle cx="12" cy="18" r="1.8"/>
    </svg>
  );
}
function CameraIcon() {
  return (
    <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 9a2 2 0 0 1 2-2h2l2-2h6l2 2h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
      <circle cx="12" cy="13" r="3.5"/>
    </svg>
  );
}
function BackArrow({ color }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
         stroke={color} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 12H5M12 19l-7-7 7-7"/>
    </svg>
  );
}

Object.assign(window, { ManageProductPage, ProductDetailSheet, AddProductPage });
