// TRANSACTION DETAIL — full page receipt
// Reached from History after tapping a transaction. Permanent record.
// Status banner (LUNAS/Refund), full breakdown, actions: print, share, refund.

const TD_ITEMS = [
  { name: 'Nasi Goreng Spesial', qty: 3, price: 30000, hue: 38, note: '' },
  { name: 'Kentang Goreng',      qty: 1, price: 24000, hue: 45, note: 'less salt' },
  { name: 'Es Teh Lemon',        qty: 2, price: 12000, hue: 50, note: '' },
];
const TD_SUB    = TD_ITEMS.reduce((s, x) => s + x.qty * x.price, 0); // 138000
const TD_DISC   = 10000;
const TD_TAX    = Math.round((TD_SUB - TD_DISC) * 0.10);
const TD_TOTAL  = TD_SUB - TD_DISC + TD_TAX;
const TD_PAID   = 150000;
const TD_CHANGE = TD_PAID - TD_TOTAL;

function TransactionDetailPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Detail Transaksi</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontFamily: 'ui-monospace, monospace', fontSize: 11 }}>
            #TRX-2026-1248
          </div>
        </div>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <DotsIcon/>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 16px' }}>
        {/* Status hero */}
        <div style={{
          padding: '16px 16px',
          background: p.successContainer, color: p.success,
          borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 14,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: '50%',
            background: p.success, color: '#FFF',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            flexShrink: 0,
          }}>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
              <path d="m5 13 4 4L19 7"/>
            </svg>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('titleM'), color: p.success, fontSize: 16, fontWeight: 700 }}>
              Pembayaran lunas
            </div>
            <div style={{ ...t('bodyS'), color: p.success, opacity: 0.85, fontSize: 11, marginTop: 2 }}>
              24 Mei 2026 &middot; 22:09 WIB
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ ...t('bodyS'), color: p.success, opacity: 0.7, fontSize: 10 }}>Total</div>
            <div style={{ ...t('titleM'), color: p.success, fontSize: 18, fontWeight: 700 }}>
              {rupiah(TD_TOTAL)}
            </div>
          </div>
        </div>

        {/* Order info */}
        <SectionLabelTD palette={p}>Info Order</SectionLabelTD>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '4px 14px',
        }}>
          <InfoRowTD palette={p} label="Meja"            value="Meja 4"/>
          <InfoRowTD palette={p} label="Pelanggan"       value="Walk-in"/>
          <InfoRowTD palette={p} label="Kasir"           value="Rina Astuti · Siang"/>
          <InfoRowTD palette={p} label="Metode"          value="Tunai" badge="cash"/>
          <InfoRowTD palette={p} label="Diproses"        value="2 detik" last/>
        </div>

        {/* Items */}
        <SectionLabelTD palette={p}>Item ({TD_ITEMS.reduce((s, x) => s + x.qty, 0)})</SectionLabelTD>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`, overflow: 'hidden',
        }}>
          {TD_ITEMS.map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '11px 14px',
              borderBottom: i === TD_ITEMS.length - 1 ? 'none' : `1px solid ${p.outlineSoft}`,
            }}>
              <ProductImg name={it.name} hue={it.hue} size={40} rounded={R.sm} palette={p}/>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 600 }}>{it.name}</div>
                <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
                  {it.qty} × {rupiah(it.price)} {it.note && <span> &middot; <i>{it.note}</i></span>}
                </div>
              </div>
              <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>
                {rupiah(it.qty * it.price)}
              </div>
            </div>
          ))}
        </div>

        {/* Breakdown */}
        <SectionLabelTD palette={p}>Rincian</SectionLabelTD>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '4px 14px',
        }}>
          <BreakdownRow palette={p} label="Subtotal"          value={rupiah(TD_SUB)}/>
          <BreakdownRow palette={p} label="Diskon promo"      value={`−${rupiah(TD_DISC)}`} muted/>
          <BreakdownRow palette={p} label="Pajak (10%)"       value={rupiah(TD_TAX)}/>
          <div style={{ borderTop: `1.5px solid ${p.onSurface}22`, margin: '6px 0' }}/>
          <BreakdownRow palette={p} label="Total"             value={rupiah(TD_TOTAL)}    big/>
          <BreakdownRow palette={p} label="Uang diterima"     value={rupiah(TD_PAID)}     mt/>
          <BreakdownRow palette={p} label="Kembalian"         value={rupiah(TD_CHANGE)}   accent last/>
        </div>

        {/* Note */}
        <SectionLabelTD palette={p}>Catatan</SectionLabelTD>
        <div style={{
          padding: '12px 14px',
          background: p.surfaceVariant, borderRadius: R.md,
          ...t('bodyM'), color: p.onSurface, fontSize: 13, lineHeight: '19px',
        }}>
          Pelanggan minta antar ke meja outdoor, kentang goreng tanpa garam.
        </div>

        {/* Audit log */}
        <SectionLabelTD palette={p}>Aktivitas</SectionLabelTD>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '8px 14px',
        }}>
          <ActivityLine palette={p} ok text="Order dibuat oleh Rina"           time="22:08"/>
          <ActivityLine palette={p} ok text="Pembayaran Tunai diterima"        time="22:09"/>
          <ActivityLine palette={p} ok text="Struk dicetak (Epson TM-T82)"     time="22:09" last/>
        </div>
      </div>

      {/* Sticky bottom — primary actions */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
        display: 'flex', gap: 8,
      }}>
        <ActionTD palette={p} icon={<ShareIconTD/>}  label="Bagikan"/>
        <ActionTD palette={p} icon={<RefundIconTD/>} label="Refund" danger/>
        <ActionTD palette={p} icon={<PrintIconTD/>}  label="Cetak ulang" primary/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Pieces
// ─────────────────────────────────────────────────────────────
function InfoRowTD({ palette, label, value, badge, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '9px 0',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{ ...t('bodyM'), color: p.onSurfaceVar, fontSize: 12 }}>{label}</div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        {badge === 'cash' && (
          <div style={{
            padding: '2px 8px', borderRadius: R.pill,
            background: p.successContainer, color: p.success,
            ...t('labelM'), fontSize: 10, fontWeight: 700,
          }}>CASH</div>
        )}
        <div style={{ ...t('labelL'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>{value}</div>
      </div>
    </div>
  );
}

function BreakdownRow({ palette, label, value, big, accent, muted, mt, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '6px 0',
      marginTop: mt ? 6 : 0,
      borderTop: mt ? `1px solid ${p.outlineSoft}` : 'none',
      paddingTop: mt ? 10 : 6,
    }}>
      <div style={{
        ...t('bodyM'), fontSize: big ? 14 : 12,
        color: big ? p.onSurface : p.onSurfaceVar,
        fontWeight: big ? 700 : 500,
      }}>{label}</div>
      <div style={{
        ...t('titleM'),
        fontSize: big ? 18 : 13, fontWeight: 700,
        color: accent ? p.success : (muted ? p.onSurfaceVar : p.onSurface),
      }}>{value}</div>
    </div>
  );
}

function ActivityLine({ palette, ok, text, time, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '7px 0',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{
        width: 18, height: 18, borderRadius: '50%',
        background: ok ? p.successContainer : p.surfaceVariant,
        color: ok ? p.success : p.onSurfaceVar,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
          <path d="m5 13 4 4L19 7"/>
        </svg>
      </div>
      <div style={{ flex: 1, ...t('bodyM'), color: p.onSurface, fontSize: 12 }}>{text}</div>
      <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11 }}>{time}</div>
    </div>
  );
}

function ActionTD({ palette, icon, label, primary, danger }) {
  const p = palette;
  const bg = primary ? p.primary : 'transparent';
  const fg = primary ? p.onPrimary : (danger ? p.error : p.onSurface);
  const border = primary ? 'none' : `1.5px solid ${danger ? p.error + '55' : p.outline}`;
  return (
    <div style={{
      flex: primary ? 1.4 : 1,
      height: 50, borderRadius: R.md,
      background: bg, color: fg, border,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      ...t('labelL'), fontSize: 13, fontWeight: primary ? 700 : 600,
      boxShadow: primary ? `0 6px 16px ${p.primary}40` : 'none',
    }}>
      {icon}
      {label}
    </div>
  );
}

function SectionLabelTD({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function DotsIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
      <circle cx="6"  cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="18" cy="12" r="2"/>
    </svg>
  );
}
function ShareIconTD() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
      <path d="m16 6-4-4-4 4"/><path d="M12 2v14"/>
    </svg>
  );
}
function RefundIconTD() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 7v6h6"/>
      <path d="M21 17a9 9 0 1 0-3.3 6.5"/>
    </svg>
  );
}
function PrintIconTD() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9V3h12v6"/>
      <rect x="3" y="9" width="18" height="9" rx="2"/>
      <rect x="6" y="14" width="12" height="7"/>
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

Object.assign(window, { TransactionDetailPage });
