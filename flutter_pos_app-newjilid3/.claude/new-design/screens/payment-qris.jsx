// PAYMENT — QRIS (waiting for scan)
// Original: blue band title + spinner + tiny text. No actual QR shown,
// no status, no timer.
// Redesign: bottom sheet with QR code, amount, status, countdown, actions.

function PaymentQRISSheet({ palette }) {
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
            <Icon name="qr" size={18}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 16 }}>Pembayaran QRIS</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              Sudut Kopi · Bandung
            </div>
          </div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            padding: '5px 10px', borderRadius: R.pill,
            background: p.warningContainer, color: '#7C4A0E',
            ...t('labelM'), fontSize: 11, fontWeight: 700,
          }}>
            <PulseDotQR/>
            Menunggu
          </div>
        </div>

        {/* QR card */}
        <div style={{
          marginTop: 14, padding: '18px 18px',
          background: '#FFF',
          border: `1.5px solid ${p.outlineSoft}`,
          borderRadius: R.md,
        }}>
          {/* QRIS brand strip */}
          <div style={{
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
            marginBottom: 12,
          }}>
            <div style={{
              ...t('titleM'), color: '#C8102E', fontSize: 18, fontWeight: 800,
              letterSpacing: '-0.5px',
            }}>QRIS</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 10, fontFamily: 'ui-monospace, monospace' }}>
              NMID: ID2024MID5fA9
            </div>
          </div>

          {/* QR code */}
          <div style={{
            display: 'flex', justifyContent: 'center',
            padding: '8px 0',
          }}>
            <FauxQR palette={p} size={200}/>
          </div>

          {/* Amount */}
          <div style={{
            marginTop: 12, paddingTop: 12,
            borderTop: `1px dashed ${p.outline}`,
            display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
          }}>
            <div style={{ ...t('bodyM'), color: p.onSurfaceVar, fontSize: 12 }}>Total bayar</div>
            <div style={{ ...t('displayM'), color: p.onSurface, fontSize: 22, fontWeight: 700 }}>
              {rupiah(90000)}
            </div>
          </div>
        </div>

        {/* Countdown + instruction */}
        <div style={{
          marginTop: 12, padding: '10px 14px',
          background: p.surfaceVariant, borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: '50%',
            background: '#FFF', color: p.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            flexShrink: 0,
          }}>
            <ClockIcon/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 12 }}>
              QR berlaku <b style={{ color: p.onSurface }}>4 menit 32 detik</b> lagi
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              Pelanggan scan dengan e-wallet apapun
            </div>
          </div>
        </div>

        {/* Actions */}
        <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
          <div style={{
            flex: 1, height: 48, borderRadius: R.md,
            border: `1.5px solid ${p.outline}`, color: p.onSurface,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            ...t('labelL'), fontSize: 13,
          }}>
            <PrintSmallQR/>
            Cetak QR
          </div>
          <div style={{
            flex: 1, height: 48, borderRadius: R.md,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            ...t('labelL'), fontSize: 13, fontWeight: 700,
            boxShadow: `0 6px 16px ${p.primary}40`,
          }}>
            <RefreshIcon/>
            Cek Status
          </div>
        </div>

        {/* Cancel link */}
        <div style={{
          textAlign: 'center', marginTop: 10,
          ...t('labelL'), color: p.error, fontSize: 12,
        }}>
          Batalkan transaksi
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Faux QR — render an authentic-looking QR using a CSS grid
// ─────────────────────────────────────────────────────────────
function FauxQR({ palette, size = 200 }) {
  const N = 21;
  // Deterministic pseudo-random grid
  const cells = [];
  for (let r = 0; r < N; r++) {
    for (let c = 0; c < N; c++) {
      const v = ((r * 7 + c * 13 + (r ^ c) * 3) % 7) < 3;
      cells.push({ r, c, v });
    }
  }
  // Finder pattern positions
  const isFinder = (r, c) => {
    const inBox = (r0, c0) => r >= r0 && r < r0 + 7 && c >= c0 && c < c0 + 7;
    return inBox(0, 0) || inBox(0, N - 7) || inBox(N - 7, 0);
  };
  const finderFill = (r, c) => {
    const inBox = (r0, c0) => {
      const dr = r - r0, dc = c - c0;
      if (dr < 0 || dr > 6 || dc < 0 || dc > 6) return null;
      if (dr === 0 || dr === 6 || dc === 0 || dc === 6) return true;
      if (dr === 1 || dr === 5 || dc === 1 || dc === 5) return false;
      return true;
    };
    return inBox(0, 0) ?? inBox(0, N - 7) ?? inBox(N - 7, 0);
  };

  const px = size / N;
  return (
    <div style={{
      width: size, height: size,
      display: 'grid',
      gridTemplateColumns: `repeat(${N}, 1fr)`,
      gridTemplateRows: `repeat(${N}, 1fr)`,
      padding: 0,
      position: 'relative',
    }}>
      {cells.map((cell, i) => {
        const fill = isFinder(cell.r, cell.c) ? finderFill(cell.r, cell.c) : cell.v;
        return (
          <div key={i} style={{
            background: fill ? '#0E1014' : 'transparent',
          }}/>
        );
      })}
      {/* Center logo */}
      <div style={{
        position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -50%)',
        width: px * 5, height: px * 5, borderRadius: 6,
        background: '#FFF',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 0 0 2px #FFF',
      }}>
        <div style={{
          width: px * 3.5, height: px * 3.5, borderRadius: 4,
          background: palette.primary, color: palette.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          ...t('titleM'), fontSize: px * 2.6, fontWeight: 800,
        }}>K</div>
      </div>
    </div>
  );
}

// Icons
function PulseDotQR() {
  return (
    <div style={{
      width: 6, height: 6, borderRadius: '50%', background: '#A66400',
      animation: 'pulseDotQR 1.3s ease-in-out infinite',
    }}>
      <style>{`@keyframes pulseDotQR { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.4;transform:scale(0.8)} }`}</style>
    </div>
  );
}
function ClockIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>
    </svg>
  );
}
function PrintSmallQR() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9V3h12v6"/>
      <rect x="3" y="9" width="18" height="9" rx="2"/>
      <rect x="6" y="14" width="12" height="7"/>
    </svg>
  );
}
function RefreshIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12a9 9 0 0 1-15 6.7L3 16"/>
      <path d="M3 12a9 9 0 0 1 15-6.7L21 8"/>
      <path d="M21 3v5h-5"/>
      <path d="M3 21v-5h5"/>
    </svg>
  );
}

Object.assign(window, { PaymentQRISSheet });
