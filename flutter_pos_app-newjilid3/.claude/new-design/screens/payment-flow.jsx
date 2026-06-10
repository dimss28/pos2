// PAYMENT FLOW — confirmation modal + success/receipt
// Original: tiny modal "Payment - Cash" with bare input, then full-page receipt.
// Redesign: full bottom sheets with proper hierarchy, receipt with breakdown,
// done + print + share actions.

const PF_ITEMS = [
  { name: 'Pisang Goreng',         qty: 2, price: 15000, hue: 50 },
  { name: 'Nasi Goreng Spesial',   qty: 1, price: 30000, hue: 38 },
  { name: 'Kentang Goreng',        qty: 2, price: 24000, hue: 45 },
];
const PF_SUB = PF_ITEMS.reduce((s, x) => s + x.qty * x.price, 0); // 108000
const PF_TAX = Math.round(PF_SUB * 0.10);                          // 10800
const PF_TOTAL = PF_SUB + PF_TAX;                                  // 118800
const PF_RECEIVED = 120000;
const PF_CHANGE = PF_RECEIVED - PF_TOTAL;                          // 1200

// ─────────────────────────────────────────────────────────────
// 1) CONFIRMATION MODAL — “Bayar Tunai” bottom sheet
// ─────────────────────────────────────────────────────────────
function PaymentConfirmSheet({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, position: 'relative', background: '#000', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, background: p.surface, opacity: 0.4 }}/>

      <div style={{
        background: p.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '12px 20px 20px',
        boxShadow: '0 -16px 40px rgba(0,0,0,0.25)',
      }}>
        <div style={{
          width: 40, height: 4, borderRadius: 2,
          background: p.outline, margin: '0 auto 14px',
        }}/>

        {/* Header */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm,
            background: p.primaryContainer, color: p.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <CashIcon/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 16 }}>Pembayaran Tunai</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              Hitung uang dari pelanggan
            </div>
          </div>
        </div>

        {/* Total to pay — prominent */}
        <div style={{
          marginTop: 14, padding: '14px 16px',
          background: p.onSurface, color: p.surface,
          borderRadius: R.md,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div style={{ ...t('bodyM'), opacity: 0.7, fontSize: 12 }}>Total tagihan</div>
          <div style={{ ...t('displayM'), fontSize: 22, fontWeight: 700, color: p.surface }}>
            {rupiah(PF_TOTAL)}
          </div>
        </div>

        {/* Cash received */}
        <div style={{ marginTop: 14 }}>
          <div style={{
            ...t('labelL'), color: p.onSurface, fontSize: 13, marginBottom: 6,
          }}>Uang diterima</div>
          <div style={{
            display: 'flex', alignItems: 'center',
            height: 60, padding: '0 16px', gap: 8,
            background: '#FFF',
            border: `1.5px solid ${p.primary}`,
            boxShadow: `0 0 0 4px ${p.primary}1A`,
            borderRadius: R.md,
          }}>
            <div style={{ ...t('titleM'), color: p.onSurfaceVar, fontSize: 18, fontWeight: 600 }}>Rp</div>
            <div style={{ flex: 1, ...t('displayM'), color: p.onSurface, fontSize: 24, fontWeight: 700 }}>
              {PF_RECEIVED.toLocaleString('id-ID')}
            </div>
          </div>
          <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
            {['Pas', '+5rb', '+10rb', '+20rb', '+50rb'].map(c => (
              <div key={c} style={{
                padding: '6px 10px', borderRadius: R.pill,
                background: c === '+20rb' ? p.primaryContainer : p.surfaceVariant,
                color: c === '+20rb' ? p.primary : p.onSurface,
                ...t('labelM'), fontSize: 11, fontWeight: c === '+20rb' ? 700 : 500,
              }}>{c}</div>
            ))}
          </div>
        </div>

        {/* Change due — green band */}
        <div style={{
          marginTop: 14, padding: '12px 16px',
          background: p.successContainer, color: p.success,
          borderRadius: R.md,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div>
            <div style={{ ...t('labelL'), fontSize: 12 }}>Kembalian</div>
            <div style={{ ...t('bodyS'), opacity: 0.85, fontSize: 11, marginTop: 1 }}>
              Sampaikan ke pelanggan
            </div>
          </div>
          <div style={{ ...t('titleM'), fontWeight: 700, fontSize: 20 }}>{rupiah(PF_CHANGE)}</div>
        </div>

        {/* Actions */}
        <div style={{ display: 'flex', gap: 10, marginTop: 18 }}>
          <div style={{
            flex: 1, height: 52, borderRadius: R.md,
            border: `1.5px solid ${p.outline}`, color: p.onSurface,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelL'), fontSize: 14,
          }}>Batal</div>
          <div style={{
            flex: 2, height: 52, borderRadius: R.md,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            ...t('labelL'), fontSize: 14, fontWeight: 700,
            boxShadow: `0 6px 16px ${p.primary}40`,
          }}>
            Konfirmasi Bayar
            <Icon name="arrow-right" size={16}/>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// 2) PAYMENT SUCCESS — receipt sheet
// ─────────────────────────────────────────────────────────────
function PaymentSuccessSheet({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, position: 'relative', background: '#000', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, background: p.surface, opacity: 0.4 }}/>

      <div style={{
        background: p.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '12px 20px 20px',
        boxShadow: '0 -16px 40px rgba(0,0,0,0.25)',
        maxHeight: '90%', overflow: 'hidden',
        display: 'flex', flexDirection: 'column',
      }}>
        <div style={{
          width: 40, height: 4, borderRadius: 2,
          background: p.outline, margin: '0 auto 14px', flexShrink: 0,
        }}/>

        {/* Success hero — compact */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, flexShrink: 0 }}>
          <div style={{
            width: 48, height: 48, borderRadius: '50%',
            background: p.success, color: '#FFF',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: `0 8px 20px ${p.success}40`,
            flexShrink: 0,
          }}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
              <path d="m5 13 4 4L19 7"/>
            </svg>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('titleL'), color: p.onSurface, fontSize: 17 }}>
              Pembayaran berhasil
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 11 }}>
              #TRX-2026-1248 &middot; 24 Mei 2026, 22:04
            </div>
          </div>
          <div style={{
            padding: '4px 10px', borderRadius: R.pill,
            background: p.successContainer, color: p.success,
            ...t('labelM'), fontSize: 11, fontWeight: 700,
          }}>LUNAS</div>
        </div>

        {/* Receipt body — scrollable */}
        <div style={{ flex: 1, overflowY: 'auto', marginTop: 16, marginBottom: 4 }}>
          {/* Big total */}
          <div style={{
            padding: '14px 16px',
            background: p.surfaceVariant,
            borderRadius: R.md,
          }}>
            <div style={{ ...t('labelM'), color: p.onSurfaceVar, fontSize: 10, textTransform: 'uppercase', letterSpacing: 0.6 }}>
              Total dibayar
            </div>
            <div style={{ ...t('displayL'), color: p.onSurface, marginTop: 4, fontSize: 28, fontWeight: 700, letterSpacing: '-0.5px' }}>
              {rupiah(PF_TOTAL)}
            </div>
          </div>

          {/* Detail rows */}
          <div style={{
            marginTop: 12, padding: '6px 14px',
            background: '#FFF',
            border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
          }}>
            <DetailRow palette={p} label="Metode" value="Tunai"/>
            <DetailRow palette={p} label="Uang diterima" value={rupiah(PF_RECEIVED)}/>
            <DetailRow palette={p} label="Kembalian" value={rupiah(PF_CHANGE)} accent/>
            <DetailRow palette={p} label="Kasir" value="Rina Astuti"/>
            <DetailRow palette={p} label="Meja" value="Meja 4" last/>
          </div>

          {/* Item recap */}
          <div style={{ ...t('labelM'), fontSize: 10, color: p.onSurfaceVar,
                        textTransform: 'uppercase', letterSpacing: 0.6, marginTop: 14, marginBottom: 6 }}>
            Item ({PF_ITEMS.reduce((s, x) => s + x.qty, 0)})
          </div>
          <div style={{
            background: '#FFF',
            border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
          }}>
            {PF_ITEMS.map((it, i) => (
              <div key={i} style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                padding: '9px 14px',
                borderBottom: i === PF_ITEMS.length - 1 ? 'none' : `1px solid ${p.outlineSoft}`,
              }}>
                <div>
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
          </div>
        </div>

        {/* Actions */}
        <div style={{ display: 'flex', gap: 8, marginTop: 12, flexShrink: 0 }}>
          <ActionPF palette={p} icon={<ShareIconPF/>}/>
          <ActionPF palette={p} icon={<PrintIconPF/>} label="Cetak ulang"/>
          <div style={{
            flex: 1.4, height: 50, borderRadius: R.md,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            ...t('labelL'), fontSize: 14, fontWeight: 700,
            boxShadow: `0 6px 16px ${p.primary}40`,
          }}>
            Order baru
            <Icon name="arrow-right" size={16}/>
          </div>
        </div>
      </div>
    </div>
  );
}

function DetailRow({ palette, label, value, accent, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '8px 0',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{ ...t('bodyM'), color: p.onSurfaceVar, fontSize: 12 }}>{label}</div>
      <div style={{
        ...t('labelL'), fontSize: 13, fontWeight: 700,
        color: accent ? p.success : p.onSurface,
      }}>{value}</div>
    </div>
  );
}

function ActionPF({ palette, icon, label }) {
  const p = palette;
  return (
    <div style={{
      flex: label ? 1.2 : 0.6,
      height: 50, padding: '0 12px', borderRadius: R.md,
      border: `1.5px solid ${p.outline}`,
      color: p.onSurface,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      ...t('labelL'), fontSize: 12,
    }}>
      {icon}
      {label}
    </div>
  );
}

// Icons
function CashIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="6" width="20" height="12" rx="2"/>
      <circle cx="12" cy="12" r="3"/>
    </svg>
  );
}
function ShareIconPF() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
      <path d="m16 6-4-4-4 4"/><path d="M12 2v14"/>
    </svg>
  );
}
function PrintIconPF() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9V3h12v6"/>
      <rect x="3" y="9" width="18" height="9" rx="2"/>
      <rect x="6" y="14" width="12" height="7"/>
    </svg>
  );
}

Object.assign(window, { PaymentConfirmSheet, PaymentSuccessSheet });
