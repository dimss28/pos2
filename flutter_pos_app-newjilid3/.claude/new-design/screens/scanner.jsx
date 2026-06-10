// SCANNER PAGE — full-screen camera with viewport overlay
// Original: top app bar + raw camera + tiny hint
// Redesign: edge-to-edge camera, overlay viewport with corner brackets,
//           animated scan line, clear instructions, helpful actions.

function ScannerPage({ palette }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, position: 'relative', overflow: 'hidden',
      background: '#0E0A06',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Simulated camera preview — warm cafe scene, very dim */}
      <CameraBackdrop/>

      {/* Dark vignette overlay (cuts a square out of the middle) */}
      <ScannerOverlay palette={p}/>

      {/* Top bar — transparent, overlaid */}
      <div style={{
        position: 'relative', zIndex: 5,
        padding: '12px 12px 0',
        display: 'flex', alignItems: 'center', gap: 8,
      }}>
        <RoundButton><CloseIcon/></RoundButton>
        <div style={{ flex: 1, textAlign: 'center', color: '#FFF', ...t('titleM'), fontWeight: 600 }}>
          Scan Produk
        </div>
        <RoundButton><FlashIcon/></RoundButton>
      </div>

      {/* Center caption above viewport (positioned absolutely so layout doesn't shift) */}
      <div style={{
        position: 'absolute', top: 90, left: 0, right: 0,
        textAlign: 'center', zIndex: 5,
      }}>
        <div style={{ ...t('bodyM'), color: '#FFFFFFDD' }}>
          Arahkan kamera ke barcode atau QR
        </div>
        <div style={{ ...t('bodyS'), color: '#FFFFFF88', marginTop: 4 }}>
          Pastikan kode berada di dalam kotak
        </div>
      </div>

      {/* Spacer pushes bottom content down */}
      <div style={{ flex: 1 }}/>

      {/* Bottom action sheet */}
      <div style={{
        position: 'relative', zIndex: 5,
        padding: '20px 16px 20px',
        background: 'linear-gradient(to top, rgba(14,10,6,0.92) 0%, rgba(14,10,6,0.6) 70%, rgba(14,10,6,0) 100%)',
      }}>
        {/* Detected hint chip — shows when nothing detected yet */}
        <div style={{
          alignSelf: 'center', display: 'flex', justifyContent: 'center',
          marginBottom: 16,
        }}>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 8,
            padding: '6px 14px', borderRadius: R.pill,
            background: 'rgba(255,255,255,0.12)',
            border: '1px solid rgba(255,255,255,0.2)',
            color: '#FFF', ...t('labelM'), fontSize: 12,
          }}>
            <PulseDot/>
            Mencari kode...
          </div>
        </div>

        {/* Row of secondary actions */}
        <div style={{ display: 'flex', gap: 10 }}>
          <SecondaryAction icon={<FlipCamIcon/>} label="Balik kamera"/>
          <SecondaryAction icon={<KeyboardIcon/>} label="Input manual" highlight palette={p}/>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Camera backdrop — warm cafe table simulation
// ─────────────────────────────────────────────────────────────
function CameraBackdrop() {
  return (
    <div style={{
      position: 'absolute', inset: 0, zIndex: 0,
      background: 'radial-gradient(ellipse at 30% 40%, #6B3F1E 0%, #3A1F0C 45%, #1A0E05 85%)',
      overflow: 'hidden',
    }}>
      {/* faint noise via repeating gradient */}
      <div style={{
        position: 'absolute', inset: 0,
        backgroundImage: 'repeating-conic-gradient(rgba(255,255,255,0.02) 0deg 1deg, transparent 1deg 3deg)',
        opacity: 0.4,
      }}/>
      {/* hint of an out-of-focus barcode / cup edge */}
      <div style={{
        position: 'absolute', left: '40%', top: '55%', width: 160, height: 100,
        borderRadius: 8,
        background: 'rgba(0,0,0,0.25)',
        filter: 'blur(8px)',
        transform: 'rotate(-6deg)',
      }}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Scanner overlay — vignette + viewport corners + scan line
// ─────────────────────────────────────────────────────────────
function ScannerOverlay({ palette }) {
  const p = palette;
  const size = 260;
  const corner = 28;
  const thick = 4;
  return (
    <>
      {/* Dark vignette using box-shadow trick: a centered transparent square
          with massive shadow darkens the area outside. */}
      <div style={{
        position: 'absolute', top: '50%', left: '50%',
        width: size, height: size,
        transform: 'translate(-50%, -50%)',
        borderRadius: 16,
        boxShadow: '0 0 0 2000px rgba(0,0,0,0.62)',
        zIndex: 1,
      }}/>

      {/* Corner brackets */}
      <div style={{
        position: 'absolute', top: '50%', left: '50%',
        width: size, height: size,
        transform: 'translate(-50%, -50%)',
        zIndex: 2, pointerEvents: 'none',
      }}>
        <Corner pos="tl" color={p.primary} corner={corner} thick={thick}/>
        <Corner pos="tr" color={p.primary} corner={corner} thick={thick}/>
        <Corner pos="bl" color={p.primary} corner={corner} thick={thick}/>
        <Corner pos="br" color={p.primary} corner={corner} thick={thick}/>

        {/* scan line — pulses vertically via CSS animation */}
        <div style={{
          position: 'absolute', left: 12, right: 12,
          height: 2,
          background: `linear-gradient(to right, transparent, ${p.primary}, transparent)`,
          boxShadow: `0 0 12px ${p.primary}, 0 0 24px ${p.primary}AA`,
          animation: 'scanline 2.2s ease-in-out infinite',
        }}/>
      </div>

      <style>{`
        @keyframes scanline {
          0%   { top: 16px; opacity: 0; }
          15%  { opacity: 1; }
          85%  { opacity: 1; }
          100% { top: ${size - 18}px; opacity: 0; }
        }
        @keyframes pulse-dot {
          0%, 100% { opacity: 1; transform: scale(1); }
          50%      { opacity: 0.4; transform: scale(0.85); }
        }
      `}</style>
    </>
  );
}

function Corner({ pos, color, corner, thick }) {
  // Render an L using two divs absolutely positioned
  const offset = 0;
  const styles = {
    tl: { top: offset, left: offset, borderTop: `${thick}px solid ${color}`, borderLeft: `${thick}px solid ${color}`, borderTopLeftRadius: 12 },
    tr: { top: offset, right: offset, borderTop: `${thick}px solid ${color}`, borderRight: `${thick}px solid ${color}`, borderTopRightRadius: 12 },
    bl: { bottom: offset, left: offset, borderBottom: `${thick}px solid ${color}`, borderLeft: `${thick}px solid ${color}`, borderBottomLeftRadius: 12 },
    br: { bottom: offset, right: offset, borderBottom: `${thick}px solid ${color}`, borderRight: `${thick}px solid ${color}`, borderBottomRightRadius: 12 },
  };
  return <div style={{ position: 'absolute', width: corner, height: corner, ...styles[pos] }}/>;
}

// ─────────────────────────────────────────────────────────────
// Small UI pieces
// ─────────────────────────────────────────────────────────────
function RoundButton({ children }) {
  return (
    <div style={{
      width: 40, height: 40, borderRadius: '50%',
      background: 'rgba(0,0,0,0.45)',
      border: '1px solid rgba(255,255,255,0.12)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      color: '#FFF',
    }}>{children}</div>
  );
}

function SecondaryAction({ icon, label, highlight, palette }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, height: 52, borderRadius: R.md,
      background: highlight ? p.primary : 'rgba(255,255,255,0.08)',
      border: highlight ? 'none' : '1px solid rgba(255,255,255,0.18)',
      color: highlight ? p.onPrimary : '#FFF',
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      ...t('labelL'), fontSize: 14,
    }}>
      {icon}
      {label}
    </div>
  );
}

function PulseDot() {
  return (
    <div style={{
      width: 8, height: 8, borderRadius: '50%', background: '#7AE49A',
      boxShadow: '0 0 8px #7AE49A',
      animation: 'pulse-dot 1.4s ease-in-out infinite',
    }}/>
  );
}

// Icons local to this screen (white, no stroke color from palette)
const _SI = (children) => (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
       stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">{children}</svg>
);

function CloseIcon()    { return _SI(<><path d="M18 6 6 18M6 6l12 12"/></>); }
function FlashIcon()    { return _SI(<><path d="M13 2 4 14h7l-1 8 9-12h-7l1-8z"/></>); }
function FlipCamIcon()  { return _SI(<><path d="M16 3h3a2 2 0 0 1 2 2v3M21 16v3a2 2 0 0 1-2 2h-3M8 21H5a2 2 0 0 1-2-2v-3M3 8V5a2 2 0 0 1 2-2h3"/><circle cx="12" cy="12" r="3"/></>); }
function KeyboardIcon() { return _SI(<><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M7 14h10"/></>); }

Object.assign(window, { ScannerPage });
