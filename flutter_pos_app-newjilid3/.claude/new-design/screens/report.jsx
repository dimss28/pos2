// REPORT — sales analytics + export & share
// Original: redundant headers, empty table, overflowing Filter button, no export
// Redesign: date range chips, 4-metric grid with trends, mini chart,
// proper product table, and export/share actions in app bar.

function ReportPage({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      {/* App bar with actions */}
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Laporan</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            18 – 24 Mei 2026
          </div>
        </div>
        <div style={{
          width: 40, height: 40, borderRadius: R.md,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <ShareIcon/>
        </div>
        <div style={{
          marginLeft: 4,
          display: 'flex', alignItems: 'center', gap: 6,
          padding: '0 12px', height: 40, borderRadius: R.md,
          background: p.primary, color: p.onPrimary,
          ...t('labelL'), fontSize: 12, fontWeight: 700,
        }}>
          <DownloadIcon/>
          PDF
        </div>
      </div>

      {/* Date range chips */}
      <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '8px 16px 4px' }}>
        {[
          { label: 'Hari Ini' },
          { label: '7 Hari', active: true },
          { label: '30 Hari' },
          { label: 'Pilih tanggal' },
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

      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 16px' }}>
        {/* Metrics grid */}
        <div style={{
          display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10,
        }}>
          <MetricCard palette={p}
            label="Pendapatan" value="Rp4.82jt"
            trend={{ dir: 'up', value: '12%' }}
            primary
          />
          <MetricCard palette={p}
            label="Transaksi" value="187"
            trend={{ dir: 'up', value: '8%' }}
          />
          <MetricCard palette={p}
            label="Item Terjual" value="412"
            trend={{ dir: 'up', value: '5%' }}
          />
          <MetricCard palette={p}
            label="Rata-rata / Order" value="Rp25.7rb"
            trend={{ dir: 'down', value: '3%' }}
          />
        </div>

        {/* Trend chart */}
        <SectionLabelRP palette={p}>Tren 7 Hari</SectionLabelRP>
        <div style={{
          padding: 16, background: '#FFF',
          border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
        }}>
          <TrendChart palette={p}/>
          <div style={{
            display: 'flex', justifyContent: 'space-between',
            marginTop: 10, ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11,
          }}>
            <span>Sen</span><span>Sel</span><span>Rab</span>
            <span>Kam</span><span>Jum</span><span>Sab</span><span>Min</span>
          </div>
        </div>

        {/* Product table */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <SectionLabelRP palette={p} noTopMargin>Penjualan per Produk</SectionLabelRP>
          <div style={{ ...t('labelL'), color: p.primary, fontSize: 12, marginTop: 18 }}>
            Urutkan: Qty ↓
          </div>
        </div>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`, overflow: 'hidden',
        }}>
          <ProductTableHeader palette={p}/>
          <ProductRow palette={p} name="Kopi Susu Gula Aren" cat="Kopi"   qty={62} total={1364000} hue={28}/>
          <ProductRow palette={p} name="Americano Panas"      cat="Kopi"   qty={48} total={864000}  hue={18}/>
          <ProductRow palette={p} name="Roti Bakar Coklat"    cat="Snack"  qty={36} total={540000}  hue={36}/>
          <ProductRow palette={p} name="Matcha Latte"         cat="Kopi"   qty={31} total={775000}  hue={130}/>
          <ProductRow palette={p} name="Nasi Goreng Spesial"  cat="Makanan"qty={22} total={616000}  hue={42} last/>
        </div>

        {/* Footer note */}
        <div style={{
          marginTop: 16, ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11,
          textAlign: 'center',
        }}>
          Data diperbarui terakhir 21:30 &middot; Cetak struk &amp; bukti melalui Riwayat
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Metric card
// ─────────────────────────────────────────────────────────────
function MetricCard({ palette, label, value, trend, primary }) {
  const p = palette;
  const bg = primary ? p.primary : '#FFF';
  const fg = primary ? p.onPrimary : p.onSurface;
  const subFg = primary ? `${p.onPrimary}CC` : p.onSurfaceVar;
  const trendColor = primary
    ? p.onPrimary
    : (trend.dir === 'up' ? p.success : p.error);
  const trendBg = primary
    ? `${p.onPrimary}22`
    : (trend.dir === 'up' ? p.successContainer : p.errorContainer);
  return (
    <div style={{
      padding: '14px 14px',
      background: bg, color: fg,
      borderRadius: R.md,
      border: primary ? 'none' : `1px solid ${p.outlineSoft}`,
      boxShadow: primary ? `0 8px 20px ${p.primary}33` : 'none',
    }}>
      <div style={{ ...t('labelM'), color: subFg, fontSize: 11, textTransform: 'uppercase', letterSpacing: 0.5 }}>
        {label}
      </div>
      <div style={{ ...t('displayM'), color: fg, marginTop: 6, fontSize: 22, fontWeight: 700, letterSpacing: '-0.3px' }}>
        {value}
      </div>
      <div style={{
        display: 'inline-flex', alignItems: 'center', gap: 4,
        marginTop: 8, padding: '3px 8px', borderRadius: R.pill,
        background: trendBg, color: trendColor,
        ...t('labelM'), fontSize: 11, fontWeight: 700,
      }}>
        {trend.dir === 'up' ? <TrendUp/> : <TrendDown/>}
        {trend.value}
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Trend chart — SVG line + bars
// ─────────────────────────────────────────────────────────────
function TrendChart({ palette }) {
  const p = palette;
  const data = [42, 65, 38, 70, 88, 95, 72];
  const max = 100;
  const w = 300, h = 88;
  const step = w / (data.length - 1);
  const yOf = (v) => h - (v / max) * h;
  const points = data.map((v, i) => `${i * step},${yOf(v)}`).join(' ');
  const area = `0,${h} ${points} ${w},${h}`;
  return (
    <svg width="100%" height={h} viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none">
      <defs>
        <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={p.primary} stopOpacity="0.25"/>
          <stop offset="100%" stopColor={p.primary} stopOpacity="0"/>
        </linearGradient>
      </defs>
      <polygon points={area} fill="url(#chartGrad)"/>
      <polyline points={points} fill="none" stroke={p.primary} strokeWidth="2.5"
                strokeLinecap="round" strokeLinejoin="round"/>
      {data.map((v, i) => (
        <circle key={i} cx={i * step} cy={yOf(v)} r={i === 5 ? 4 : 2.5}
                fill={i === 5 ? p.primary : '#FFF'} stroke={p.primary} strokeWidth="2"/>
      ))}
    </svg>
  );
}

// ─────────────────────────────────────────────────────────────
// Product table
// ─────────────────────────────────────────────────────────────
function ProductTableHeader({ palette }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '10px 14px',
      background: p.surfaceVariant,
      ...t('labelM'), color: p.onSurfaceVar, fontSize: 10, textTransform: 'uppercase', letterSpacing: 0.6,
    }}>
      <div style={{ flex: 1 }}>Produk</div>
      <div style={{ width: 50, textAlign: 'right' }}>Qty</div>
      <div style={{ width: 86, textAlign: 'right' }}>Total</div>
    </div>
  );
}

function ProductRow({ palette, name, cat, qty, total, hue, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '12px 14px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <ProductImg name={name} hue={hue} size={36} rounded={R.sm} palette={p}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 600,
                      overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>{cat}</div>
      </div>
      <div style={{ width: 50, textAlign: 'right', ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 600 }}>
        {qty}
      </div>
      <div style={{ width: 86, textAlign: 'right', ...t('bodyM'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>
        {rupiah(total)}
      </div>
    </div>
  );
}

function SectionLabelRP({ palette, children, noTopMargin }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: noTopMargin ? 18 : 22, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons
// ─────────────────────────────────────────────────────────────
function ShareIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
      <path d="m16 6-4-4-4 4"/>
      <path d="M12 2v14"/>
    </svg>
  );
}
function DownloadIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <path d="m7 10 5 5 5-5"/>
      <path d="M12 15V3"/>
    </svg>
  );
}
function TrendUp() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="m6 16 6-8 4 5 4-5"/><path d="M16 8h4v4"/>
    </svg>
  );
}
function TrendDown() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
      <path d="m6 8 6 8 4-5 4 5"/><path d="M16 16h4v-4"/>
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

Object.assign(window, { ReportPage });
