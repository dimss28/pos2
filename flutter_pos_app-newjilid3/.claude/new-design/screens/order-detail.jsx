// ORDER DETAIL — Cart / Checkout with items
// Original issues: cramped item layout (price overflow), tiny payment cards,
// no subtotal/tax breakdown, save-draft hidden, no table/customer label.
// Redesign: proper line items, summary breakdown, prominent payment picker,
// total + bayar in one sticky CTA.

const OD_ITEMS = [
  { id: 1, name: 'Nasi Goreng Spesial', price: 30000, qty: 3, note: '',                  hue: 38 },
  { id: 2, name: 'Kentang Goreng',      price: 24000, qty: 1, note: 'less salt',         hue: 45 },
];

const OD_TAX_PCT = 0.10;

function OrderDetailPage({ palette }) {
  const p = palette;
  const subtotal = OD_ITEMS.reduce((s, x) => s + x.price * x.qty, 0);
  const tax = Math.round(subtotal * OD_TAX_PCT);
  const total = subtotal + tax;

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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Detail Order</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            #ORD-1248 &middot; Meja 4
          </div>
        </div>
        <div style={{
          padding: '8px 12px', borderRadius: R.sm,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', gap: 6,
          ...t('labelL'), fontSize: 12,
        }}>
          <SaveIcon/>
          Draft
        </div>
      </div>

      {/* Body — items + summary + payment, scrollable */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 16px' }}>
        {/* Items list */}
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`, overflow: 'hidden',
        }}>
          {OD_ITEMS.map((it, i) => (
            <OrderItemRow key={it.id} item={it} palette={p} last={i === OD_ITEMS.length - 1}/>
          ))}
        </div>

        {/* Add item link */}
        <div style={{
          marginTop: 10,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
          height: 44, borderRadius: R.md,
          border: `1.5px dashed ${p.outline}`,
          color: p.primary, ...t('labelL'), fontSize: 13,
        }}>
          <Icon name="plus" size={16} strokeWidth={2.5}/>
          Tambah menu
        </div>

        {/* Summary */}
        <SectionLabelOD palette={p}>Ringkasan</SectionLabelOD>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '12px 14px',
        }}>
          <SummaryLine palette={p} label="Subtotal"      value={rupiah(subtotal)}/>
          <SummaryLine palette={p} label="Pajak (10%)"   value={rupiah(tax)}/>
          <div style={{ height: 1, background: p.outlineSoft, margin: '8px 0' }}/>
          <SummaryLine palette={p} label="Total" value={rupiah(total)} big/>
        </div>

        {/* Payment method */}
        <SectionLabelOD palette={p}>Metode Pembayaran</SectionLabelOD>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
          <PaymentCard palette={p} method="cash"     label="Tunai"    active/>
          <PaymentCard palette={p} method="qris"     label="QRIS"/>
          <PaymentCard palette={p} method="transfer" label="Transfer"/>
        </div>

        {/* Cash received input (since cash is active) */}
        <div style={{ marginTop: 12 }}>
          <div style={{
            ...t('labelL'), color: p.onSurface, fontSize: 13, marginBottom: 6,
          }}>Uang diterima</div>
          <div style={{
            display: 'flex', alignItems: 'center',
            height: 52, padding: '0 14px', gap: 6,
            background: '#FFF',
            border: `1.5px solid ${p.primary}`,
            boxShadow: `0 0 0 4px ${p.primary}1A`,
            borderRadius: R.md,
          }}>
            <div style={{ ...t('bodyL'), color: p.onSurfaceVar, fontSize: 15 }}>Rp</div>
            <div style={{ flex: 1, ...t('titleM'), color: p.onSurface, fontSize: 18, fontWeight: 700 }}>
              120.000
            </div>
          </div>
          {/* Quick chips */}
          <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
            {['Pas', '+5rb', '+10rb', '+20rb', '+50rb'].map(c => (
              <div key={c} style={{
                padding: '6px 10px', borderRadius: R.pill,
                background: p.surfaceVariant, color: p.onSurface,
                ...t('labelM'), fontSize: 11,
              }}>{c}</div>
            ))}
          </div>
          <div style={{
            marginTop: 10, padding: '10px 14px',
            background: p.successContainer, color: p.success,
            borderRadius: R.md,
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          }}>
            <div style={{ ...t('labelL'), fontSize: 12 }}>Kembalian</div>
            <div style={{ ...t('titleM'), fontWeight: 700, fontSize: 16 }}>{rupiah(120000 - total)}</div>
          </div>
        </div>
      </div>

      {/* Sticky bottom — total + bayar */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
      }}>
        <div style={{
          height: 60, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', padding: '0 8px 0 18px', gap: 12,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyS'), opacity: 0.85, fontSize: 11 }}>Total bayar</div>
            <div style={{ ...t('titleM'), fontWeight: 700, fontSize: 18 }}>{rupiah(total)}</div>
          </div>
          <div style={{
            height: 44, padding: '0 16px 0 18px', borderRadius: R.md,
            background: p.onPrimary, color: p.primary,
            display: 'flex', alignItems: 'center', gap: 6,
            ...t('labelL'), fontSize: 14, fontWeight: 700,
          }}>
            Bayar
            <Icon name="arrow-right" size={16}/>
          </div>
        </div>
      </div>

      <BottomNav palette={p} active={1} cartCount={OD_ITEMS.reduce((s, x) => s + x.qty, 0)}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Item row
// ─────────────────────────────────────────────────────────────
function OrderItemRow({ item, palette, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', gap: 12, padding: '12px 12px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <ProductImg name={item.name} hue={item.hue} size={56} rounded={R.sm} palette={p}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8 }}>
          <div style={{
            ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
          }}>{item.name}</div>
          <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 14, fontWeight: 700, flexShrink: 0 }}>
            {rupiah(item.price * item.qty)}
          </div>
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
          {rupiah(item.price)} / pcs {item.note && <span> &middot; <i>{item.note}</i></span>}
        </div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
          <Stepper palette={p} qty={item.qty}/>
          <div style={{
            ...t('labelL'), color: p.onSurfaceVar, fontSize: 12,
            display: 'flex', alignItems: 'center', gap: 4,
          }}>
            <NoteIcon/>
            {item.note ? 'Edit catatan' : 'Tambah catatan'}
          </div>
        </div>
      </div>
    </div>
  );
}

// Reuse Stepper layout
function Stepper({ palette, qty }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', height: 32,
      background: p.primaryContainer,
      borderRadius: R.sm, padding: '0 3px',
    }}>
      <div style={{ width: 28, height: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', color: p.primary }}>
        <Icon name="minus" size={16} strokeWidth={2.5}/>
      </div>
      <div style={{ minWidth: 18, textAlign: 'center', ...t('labelL'), color: p.onPrimaryContainer, fontSize: 13, fontWeight: 700 }}>
        {qty}
      </div>
      <div style={{ width: 28, height: 28, display: 'flex', alignItems: 'center', justifyContent: 'center', color: p.primary }}>
        <Icon name="plus" size={16} strokeWidth={2.5}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Summary line
// ─────────────────────────────────────────────────────────────
function SummaryLine({ palette, label, value, big }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '4px 0',
    }}>
      <div style={{
        ...t('bodyM'), fontSize: big ? 15 : 13,
        color: big ? p.onSurface : p.onSurfaceVar,
        fontWeight: big ? 700 : 500,
      }}>{label}</div>
      <div style={{
        ...t('titleM'), color: p.onSurface,
        fontSize: big ? 20 : 14, fontWeight: 700,
      }}>{value}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Payment card
// ─────────────────────────────────────────────────────────────
function PaymentCard({ palette, method, label, active }) {
  const p = palette;
  const icons = {
    cash: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="6" width="20" height="12" rx="2"/>
        <circle cx="12" cy="12" r="3"/>
      </svg>
    ),
    qris: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="3" y="3" width="7" height="7" rx="1"/>
        <rect x="14" y="3" width="7" height="7" rx="1"/>
        <rect x="3" y="14" width="7" height="7" rx="1"/>
        <path d="M14 14h3v3h-3zM21 14v3M14 21h7M17 17v4"/>
      </svg>
    ),
    transfer: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
           stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <rect x="2" y="5" width="20" height="14" rx="2"/>
        <path d="M2 10h20M6 15h2"/>
      </svg>
    ),
  };
  return (
    <div style={{
      padding: '14px 10px', textAlign: 'center',
      background: active ? p.primaryContainer : '#FFF',
      border: `1.5px solid ${active ? p.primary : p.outlineSoft}`,
      borderRadius: R.md,
      color: active ? p.primary : p.onSurfaceVar,
      position: 'relative',
    }}>
      {active && (
        <div style={{
          position: 'absolute', top: -6, right: -6,
          width: 20, height: 20, borderRadius: '50%',
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="m5 13 4 4L19 7"/>
          </svg>
        </div>
      )}
      <div style={{ display: 'flex', justifyContent: 'center' }}>
        {icons[method]}
      </div>
      <div style={{
        ...t('labelL'), fontSize: 12, marginTop: 6,
        color: active ? p.onPrimaryContainer : p.onSurface,
        fontWeight: 700,
      }}>{label}</div>
    </div>
  );
}

function SectionLabelOD({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function SaveIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
      <path d="M17 21v-8H7v8M7 3v5h8"/>
    </svg>
  );
}
function NoteIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 20h9M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4 12.5-12.5z"/>
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

Object.assign(window, { OrderDetailPage });
