// HISTORY — Empty State (belum ada transaksi)
// Original: bare "No data"
// Redesign: tetap tampilin filter (struktur) + informatif tentang apa yg akan muncul

function HistoryEmpty({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Riwayat Transaksi</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Transaksi yang sudah selesai
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

      {/* Filter chips — show structure even when empty */}
      <div style={{
        padding: '8px 16px 0',
        display: 'flex', gap: 8, overflowX: 'auto',
      }}>
        {[
          { label: 'Hari Ini', active: true },
          { label: 'Minggu Ini' },
          { label: 'Bulan Ini' },
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

      {/* Summary row (zero-state) — kasih konteks numerik */}
      <div style={{ padding: '16px 16px 0' }}>
        <div style={{
          display: 'flex', gap: 10,
          padding: '14px 16px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <SummaryCell label="Transaksi" value="0" palette={p}/>
          <div style={{ width: 1, background: p.outline, alignSelf: 'stretch' }}/>
          <SummaryCell label="Pendapatan" value="Rp0" palette={p}/>
        </div>
      </div>

      {/* Empty state */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '16px 32px 0', textAlign: 'center',
      }}>
        <HistoryEmptyVisual palette={p}/>

        <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 20 }}>
          Belum ada transaksi
        </div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 6, maxWidth: 290 }}>
          Setelah pelanggan bayar, riwayat akan muncul di sini lengkap dengan jumlah, metode bayar, dan jam transaksi.
        </div>
      </div>

      {/* Bottom CTA */}
      <div style={{ padding: '12px 16px 12px', flexShrink: 0 }}>
        <div style={{
          height: 52, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          Mulai order baru
        </div>
      </div>

      <BottomNav palette={p} active={2}/>
    </div>
  );
}

function SummaryCell({ label, value, palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1 }}>
      <div style={{ ...t('labelM'), color: p.onSurfaceVar, textTransform: 'uppercase', letterSpacing: 0.5, fontSize: 10 }}>
        {label}
      </div>
      <div style={{ ...t('titleM'), color: p.onSurface, marginTop: 4, fontSize: 20 }}>
        {value}
      </div>
    </div>
  );
}

// History empty visual — bar chart skeleton + receipt
function HistoryEmptyVisual({ palette }) {
  const p = palette;
  return (
    <div style={{
      width: 160, height: 110, position: 'relative',
      display: 'flex', alignItems: 'flex-end', justifyContent: 'center', gap: 8,
      padding: '0 16px',
    }}>
      {/* baseline */}
      <div style={{
        position: 'absolute', left: 12, right: 12, bottom: 8,
        height: 1, background: p.outline,
      }}/>
      {/* dashed bars */}
      {[36, 56, 28, 70, 44].map((h, i) => (
        <div key={i} style={{
          width: 16, height: h, borderRadius: 4,
          background: i === 3 ? p.primaryContainer : `${p.surfaceVariant}`,
          border: i === 3 ? `1.5px solid ${p.primary}` : `1.5px dashed ${p.outline}`,
        }}/>
      ))}
    </div>
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

function BackArrow({ color }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
         stroke={color} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 12H5M12 19l-7-7 7-7"/>
    </svg>
  );
}

Object.assign(window, { HistoryEmpty });
