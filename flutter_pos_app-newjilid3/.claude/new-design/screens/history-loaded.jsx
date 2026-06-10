// HISTORY — Loaded with transactions
// Original: cramped card with overflow text + only "Print Receipt"
// Redesign: date grouping, payment method badge color-coded, expand/collapse
// per row, share + print + detail actions, filter chips + summary header.

const HX_TXNS = [
  {
    id: 'TRX-2026-1248', date: 'today',  time: '22:09', method: 'cash',
    items: [
      { name: 'Nasi Goreng Spesial', qty: 3, price: 30000, hue: 38 },
      { name: 'Kentang Goreng',      qty: 1, price: 24000, hue: 45 },
    ],
    table: 'Meja 4',
  },
  {
    id: 'TRX-2026-1247', date: 'today',  time: '22:03', method: 'qris',
    items: [
      { name: 'Kopi Susu Gula Aren', qty: 2, price: 22000, hue: 28 },
      { name: 'Croissant Mentega',   qty: 1, price: 19000, hue: 45 },
    ],
    table: 'Takeaway',
  },
  {
    id: 'TRX-2026-1246', date: 'today',  time: '21:48', method: 'transfer',
    items: [
      { name: 'Matcha Latte',  qty: 1, price: 25000, hue: 130 },
      { name: 'Pisang Goreng', qty: 2, price: 15000, hue: 50 },
    ],
    table: 'Meja 8',
  },
  {
    id: 'TRX-2026-1244', date: 'yesterday', time: '19:21', method: 'cash',
    items: [
      { name: 'Americano Panas', qty: 1, price: 18000, hue: 18 },
    ],
    table: 'Meja 2',
  },
  {
    id: 'TRX-2026-1243', date: 'yesterday', time: '14:05', method: 'qris',
    items: [
      { name: 'Nasi Goreng Spesial', qty: 2, price: 30000, hue: 38 },
    ],
    table: 'Takeaway',
  },
];

const txnTotal = (tx) => tx.items.reduce((s, x) => s + x.qty * x.price, 0);
const txnCount = (tx) => tx.items.reduce((s, x) => s + x.qty, 0);

function HistoryLoaded({ palette, expandedId = 'TRX-2026-1248' }) {
  const p = palette;
  const todayTxns = HX_TXNS.filter(x => x.date === 'today');
  const yestTxns  = HX_TXNS.filter(x => x.date === 'yesterday');
  const dayTotal  = todayTxns.reduce((s, x) => s + txnTotal(x), 0);

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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Riwayat Transaksi</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            {HX_TXNS.length} transaksi
          </div>
        </div>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <CalendarIcon/>
        </div>
      </div>

      {/* Filter chips */}
      <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '4px 16px 0' }}>
        {[
          { label: 'Hari Ini', active: true },
          { label: 'Minggu Ini' },
          { label: 'Bulan Ini' },
          { label: 'Custom' },
        ].map((chip, i) => (
          <div key={i} style={{
            flexShrink: 0, padding: '8px 14px', borderRadius: R.pill,
            background: chip.active ? p.onSurface : 'transparent',
            color: chip.active ? p.surface : p.onSurface,
            border: chip.active ? 'none' : `1.5px solid ${p.outline}`,
            ...t('labelL'), fontSize: 13,
          }}>{chip.label}</div>
        ))}
      </div>

      {/* Summary card */}
      <div style={{ padding: '12px 16px 4px' }}>
        <div style={{
          padding: '14px 16px',
          background: p.onSurface, color: p.surface,
          borderRadius: R.md,
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        }}>
          <div>
            <div style={{ ...t('labelM'), opacity: 0.7, fontSize: 10, textTransform: 'uppercase', letterSpacing: 0.6 }}>
              Pendapatan hari ini
            </div>
            <div style={{ ...t('displayM'), color: p.surface, marginTop: 4, fontSize: 22, fontWeight: 700 }}>
              {rupiah(dayTotal)}
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div style={{ ...t('bodyS'), opacity: 0.7, fontSize: 11 }}>{todayTxns.length} transaksi</div>
            <div style={{ ...t('labelL'), color: p.surface, fontSize: 12, marginTop: 4, opacity: 0.9 }}>
              Lihat laporan →
            </div>
          </div>
        </div>
      </div>

      {/* Transactions list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 16px' }}>
        <DayHeader palette={p}>Hari Ini · Senin, 24 Mei</DayHeader>
        {todayTxns.map(tx => (
          <TxnCard key={tx.id} txn={tx} palette={p} expanded={tx.id === expandedId}/>
        ))}

        <DayHeader palette={p}>Kemarin · 23 Mei</DayHeader>
        {yestTxns.map(tx => (
          <TxnCard key={tx.id} txn={tx} palette={p} expanded={false}/>
        ))}
      </div>

      <BottomNav palette={p} active={2}/>
    </div>
  );
}

function DayHeader({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      position: 'sticky', top: 0, zIndex: 1,
      padding: '8px 0 6px', background: p.surface,
      ...t('labelM'), fontSize: 10, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Transaction card
// ─────────────────────────────────────────────────────────────
function TxnCard({ txn, palette, expanded }) {
  const p = palette;
  const total = txnTotal(txn);
  const itemCount = txnCount(txn);

  return (
    <div style={{
      background: '#FFF', borderRadius: R.md,
      border: `1px solid ${expanded ? p.primary + '55' : p.outlineSoft}`,
      boxShadow: expanded ? `0 0 0 1.5px ${p.primary}33` : 'none',
      marginBottom: 10, overflow: 'hidden',
    }}>
      {/* Collapsed header row */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '12px 14px',
      }}>
        <MethodBadge palette={p} method={txn.method}/>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>
              {txn.id.slice(-4)}
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11 }}>
              {txn.time} &middot; {txn.table}
            </div>
          </div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
            {itemCount} item
          </div>
        </div>
        <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 15, fontWeight: 700 }}>
          {rupiah(total)}
        </div>
        <div style={{
          width: 28, height: 28, borderRadius: R.sm,
          color: p.onSurfaceVar,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          transform: expanded ? 'rotate(180deg)' : 'none',
        }}>
          <Icon name="chev-down" size={18}/>
        </div>
      </div>

      {/* Expanded */}
      {expanded && (
        <div style={{ padding: '0 14px 14px', borderTop: `1px solid ${p.outlineSoft}` }}>
          <div style={{
            ...t('labelM'), fontSize: 10, color: p.onSurfaceVar,
            textTransform: 'uppercase', letterSpacing: 0.5,
            marginTop: 12, marginBottom: 6,
          }}>Item</div>
          {txn.items.map((it, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '8px 0',
              borderBottom: i === txn.items.length - 1 ? 'none' : `1px solid ${p.outlineSoft}`,
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

          <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
            <TxnAction palette={p} icon={<EyeIcon/>}    label="Detail"/>
            <TxnAction palette={p} icon={<ShareSmall/>} label="Bagikan"/>
            <TxnAction palette={p} icon={<PrintSmall/>} label="Cetak ulang" primary/>
          </div>
        </div>
      )}
    </div>
  );
}

function MethodBadge({ palette, method }) {
  const p = palette;
  const map = {
    cash:     { bg: p.successContainer, fg: p.success, label: 'Cash', icon: <CashSmall/> },
    qris:     { bg: p.primaryContainer, fg: p.primary, label: 'QRIS', icon: <QRSmall/>   },
    transfer: { bg: p.warningContainer, fg: '#7C4A0E', label: 'TF',   icon: <TransferSmall/> },
  };
  const m = map[method];
  return (
    <div style={{
      width: 40, height: 40, borderRadius: R.sm,
      background: m.bg, color: m.fg,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      flexShrink: 0,
    }}>{m.icon}</div>
  );
}

function TxnAction({ palette, icon, label, primary }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, height: 38, borderRadius: R.sm,
      background: primary ? p.primary : 'transparent',
      color: primary ? p.onPrimary : p.onSurface,
      border: primary ? 'none' : `1px solid ${p.outlineSoft}`,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
      ...t('labelL'), fontSize: 12, fontWeight: primary ? 700 : 500,
    }}>
      {icon}
      {label}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Small icons
// ─────────────────────────────────────────────────────────────
function CashSmall() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="3"/>
    </svg>
  );
}
function QRSmall() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/>
      <rect x="3" y="14" width="7" height="7" rx="1"/>
      <path d="M14 14h3v3h-3zM21 14v3M14 21h7M17 17v4"/>
    </svg>
  );
}
function TransferSmall() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="2" y="5" width="20" height="14" rx="2"/>
      <path d="M2 10h20M6 15h2"/>
    </svg>
  );
}
function CalendarIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="5" width="18" height="16" rx="2"/>
      <path d="M3 10h18M8 3v4M16 3v4"/>
    </svg>
  );
}
function EyeIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>
    </svg>
  );
}
function ShareSmall() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
      <path d="m16 6-4-4-4 4"/><path d="M12 2v14"/>
    </svg>
  );
}
function PrintSmall() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
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

Object.assign(window, { HistoryLoaded });
