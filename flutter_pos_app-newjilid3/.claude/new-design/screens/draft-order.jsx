// DRAFT ORDER FLOW
// 1) Open Bill modal — input table + order name before saving as draft
// 2) Draft Orders list (collapsed) — table + name + total + Pay + expand
// 3) Draft Orders list (expanded) — items breakdown visible

// ─────────────────────────────────────────────────────────────
// Sample drafts
// ─────────────────────────────────────────────────────────────
const DR_DRAFTS = [
  {
    id: 1, table: 'Meja 12', name: 'Rozak',
    items: [
      { name: 'Nasi Goreng Spesial', qty: 3, price: 30000, hue: 38 },
      { name: 'Kentang Goreng',      qty: 1, price: 24000, hue: 45 },
    ],
    createdAgo: '5 menit lalu',
  },
  {
    id: 2, table: 'Meja 4', name: 'Pak Andi',
    items: [
      { name: 'Kopi Susu Gula Aren', qty: 2, price: 22000, hue: 28 },
      { name: 'Croissant Mentega',   qty: 1, price: 19000, hue: 45 },
    ],
    createdAgo: '12 menit lalu',
  },
  {
    id: 3, table: 'Takeaway', name: 'Mba Sari',
    items: [
      { name: 'Matcha Latte', qty: 1, price: 25000, hue: 130 },
    ],
    createdAgo: '24 menit lalu',
  },
];

const totalOf = (items) => items.reduce((s, x) => s + x.qty * x.price, 0);
const countOf = (items) => items.reduce((s, x) => s + x.qty, 0);

// ─────────────────────────────────────────────────────────────
// 1) OPEN BILL — modal sheet
// ─────────────────────────────────────────────────────────────
function OpenBillSheet({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, position: 'relative', background: '#000', display: 'flex', flexDirection: 'column' }}>
      {/* Dimmed faux background */}
      <div style={{ flex: 1, background: p.surface, opacity: 0.4 }}/>

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
          background: p.outline, margin: '0 auto 16px',
        }}/>

        {/* Title */}
        <div style={{ ...t('titleL'), color: p.onSurface, fontSize: 19 }}>Simpan ke Draft</div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 4, fontSize: 13 }}>
          Tandai order untuk dibayar nanti
        </div>

        {/* Form */}
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <FormField palette={p} label="Meja / Lokasi" value="Meja 12"
                     placeholder="cth. Meja 4 / Takeaway"/>
          <FormField palette={p} label="Nama Pelanggan" value="Rozak"
                     placeholder="opsional" subtle/>
        </div>

        {/* Order quick recap */}
        <div style={{
          marginTop: 16, padding: '12px 14px',
          background: p.surfaceVariant, borderRadius: R.md,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11 }}>
              4 item dipesan
            </div>
            <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 17, fontWeight: 700, marginTop: 2 }}>
              {rupiah(114000)}
            </div>
          </div>
          <div style={{
            ...t('labelL'), color: p.onSurfaceVar, fontSize: 12,
            display: 'flex', alignItems: 'center', gap: 4,
          }}>
            Lihat detail
            <Icon name="chev-right" size={14}/>
          </div>
        </div>

        {/* Print toggle */}
        <div style={{
          marginTop: 12,
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '10px 14px',
          border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
        }}>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 13, fontWeight: 600 }}>
              Cetak bukti pesanan
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              Untuk dapur / barista
            </div>
          </div>
          <div style={{
            width: 40, height: 22, borderRadius: 11,
            background: p.primary, position: 'relative',
          }}>
            <div style={{
              position: 'absolute', top: 2, left: 20,
              width: 18, height: 18, borderRadius: '50%', background: '#FFF',
            }}/>
          </div>
        </div>

        {/* Actions */}
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <div style={{
            flex: 1, height: 50, borderRadius: R.md,
            border: `1.5px solid ${p.outline}`, color: p.onSurface,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelL'), fontSize: 14,
          }}>Batal</div>
          <div style={{
            flex: 2, height: 50, borderRadius: R.md,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            ...t('labelL'), fontSize: 14, fontWeight: 700,
            boxShadow: `0 6px 16px ${p.primary}40`,
          }}>
            <SaveIconDR/>
            Simpan &amp; Cetak
          </div>
        </div>
      </div>
    </div>
  );
}

function FormField({ palette, label, value, placeholder, subtle }) {
  const p = palette;
  const focused = !subtle;
  return (
    <div>
      <div style={{ ...t('labelL'), color: p.onSurface, fontSize: 13, marginBottom: 6 }}>{label}</div>
      <div style={{
        display: 'flex', alignItems: 'center',
        height: 52, padding: '0 14px',
        background: '#FFF',
        border: `1.5px solid ${focused ? p.primary : p.outline}`,
        boxShadow: focused ? `0 0 0 4px ${p.primary}1A` : 'none',
        borderRadius: R.md,
      }}>
        <div style={{
          flex: 1, ...t('bodyL'), fontSize: 15,
          color: value ? p.onSurface : p.onSurfaceVar,
        }}>{value || placeholder}</div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 2) DRAFT ORDERS — list page
// ─────────────────────────────────────────────────────────────
function DraftOrdersPage({ palette, expandedId }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Draft Order</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            {DR_DRAFTS.length} pesanan menunggu dibayar
          </div>
        </div>
      </div>

      {/* Search */}
      <div style={{ padding: '4px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          height: 48, padding: '0 14px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <Icon name="search" size={18} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar, fontSize: 13 }}>
            Cari meja atau nama pelanggan...
          </div>
        </div>
      </div>

      {/* Summary chip row */}
      <div style={{
        margin: '12px 16px 8px',
        padding: '10px 14px',
        background: p.warningContainer,
        border: `1px solid ${p.warning}33`,
        borderRadius: R.md,
        display: 'flex', alignItems: 'center', gap: 10,
      }}>
        <div style={{
          width: 6, height: 6, borderRadius: '50%', background: p.warning,
          flexShrink: 0,
        }}/>
        <div style={{ flex: 1, ...t('bodyM'), color: '#7C4A0E', fontSize: 12 }}>
          Total {rupiah(DR_DRAFTS.reduce((s, d) => s + totalOf(d.items), 0))} di {DR_DRAFTS.length} order
        </div>
        <div style={{ ...t('labelL'), color: '#7C4A0E', fontSize: 11 }}>
          Print semua
        </div>
      </div>

      {/* Draft list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px' }}>
        {DR_DRAFTS.map(d => (
          <DraftCard key={d.id} draft={d} palette={p} expanded={d.id === expandedId}/>
        ))}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Draft card (collapsible)
// ─────────────────────────────────────────────────────────────
function DraftCard({ draft, palette, expanded }) {
  const p = palette;
  const total = totalOf(draft.items);
  return (
    <div style={{
      background: '#FFF', borderRadius: R.md,
      border: `1px solid ${expanded ? p.primary + '55' : p.outlineSoft}`,
      boxShadow: expanded ? `0 0 0 1.5px ${p.primary}33` : 'none',
      marginBottom: 10, overflow: 'hidden',
    }}>
      {/* Header row */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '12px 14px',
      }}>
        <div style={{
          width: 40, height: 40, borderRadius: R.sm,
          background: p.primaryContainer, color: p.primary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          flexShrink: 0,
        }}>
          {draft.table.toLowerCase().includes('takeaway') ? <BagIcon/> : <TableIcon/>}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{
              ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 700,
              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
            }}>
              {draft.table} &middot; {draft.name}
            </div>
          </div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
            {countOf(draft.items)} item &middot; {draft.createdAgo}
          </div>
        </div>
        <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 15, fontWeight: 700 }}>
          {rupiah(total)}
        </div>
        <div style={{
          height: 36, padding: '0 14px', borderRadius: R.sm,
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', gap: 6,
          ...t('labelL'), fontSize: 12, fontWeight: 700,
          boxShadow: `0 4px 10px ${p.primary}40`,
        }}>
          Bayar
        </div>
        <div style={{
          width: 32, height: 32, borderRadius: R.sm,
          color: p.onSurfaceVar,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transform: expanded ? 'rotate(180deg)' : 'none',
          transition: 'transform .15s',
        }}>
          <Icon name="chev-down" size={18}/>
        </div>
      </div>

      {/* Expanded body */}
      {expanded && (
        <div style={{
          padding: '0 14px 14px',
          borderTop: `1px solid ${p.outlineSoft}`,
        }}>
          <div style={{
            ...t('labelM'), fontSize: 10, color: p.onSurfaceVar,
            textTransform: 'uppercase', letterSpacing: 0.5,
            marginTop: 12, marginBottom: 6,
          }}>Item dipesan</div>
          {draft.items.map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '8px 0',
              borderBottom: i === draft.items.length - 1 ? 'none' : `1px solid ${p.outlineSoft}`,
            }}>
              <ProductImg name={it.name} hue={it.hue} size={36} rounded={R.sm} palette={p}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 600 }}>{it.name}</div>
                <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
                  {it.qty} × {rupiah(it.price)}
                </div>
              </div>
              <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>
                {rupiah(it.qty * it.price)}
              </div>
            </div>
          ))}

          {/* Inline actions */}
          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <InlineBtn palette={p} label="Edit" icon={<EditIcon/>}/>
            <InlineBtn palette={p} label="Cetak ulang" icon={<PrintSmall/>}/>
            <InlineBtn palette={p} label="Hapus" icon={<TrashIcon/>} danger/>
          </div>
        </div>
      )}
    </div>
  );
}

function InlineBtn({ palette, label, icon, danger }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, height: 36, borderRadius: R.sm,
      border: `1px solid ${p.outlineSoft}`,
      color: danger ? p.error : p.onSurface,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      ...t('labelL'), fontSize: 12,
    }}>
      {icon}
      {label}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons
// ─────────────────────────────────────────────────────────────
function TableIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 11h18M5 11v8M19 11v8M3 7h18"/>
    </svg>
  );
}
function BagIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 2 4 7v13a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7l-2-5z"/>
      <path d="M4 7h16M9 11a3 3 0 0 0 6 0"/>
    </svg>
  );
}
function SaveIconDR() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
      <path d="M17 21v-8H7v8M7 3v5h8"/>
    </svg>
  );
}
function EditIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
      <path d="M18.5 2.5a2.12 2.12 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
    </svg>
  );
}
function PrintSmall() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9V3h12v6"/>
      <rect x="3" y="9" width="18" height="9" rx="2"/>
      <rect x="6" y="14" width="12" height="7"/>
    </svg>
  );
}
function TrashIcon() {
  return (
    <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
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

Object.assign(window, { OpenBillSheet, DraftOrdersPage });
