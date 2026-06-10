// DRAFT ORDER — Empty State
// Page untuk order yang disimpan sementara (parked).
// Empty: jelaskan apa itu draft + CTA buat order baru.

function DraftOrderEmpty({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      {/* App bar — clean, no colored band */}
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
            Pesanan yang ditunda pembayarannya
          </div>
        </div>
      </div>

      {/* Search — disabled karena kosong */}
      <div style={{ padding: '8px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          height: 48, padding: '0 14px',
          background: p.surfaceVariant, borderRadius: R.md,
          opacity: 0.5,
        }}>
          <Icon name="search" size={18} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar }}>Cari nama meja atau pelanggan...</div>
        </div>
      </div>

      {/* Empty state */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '24px 32px', textAlign: 'center',
      }}>
        <DraftEmptyVisual palette={p}/>

        <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 24 }}>
          Belum ada draft
        </div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 8, maxWidth: 300 }}>
          Order yang disimpan sementara akan muncul di sini. Berguna saat pelanggan masih duduk dan akan bayar nanti.
        </div>

        {/* Small explainer card */}
        <div style={{
          marginTop: 24, width: '100%', maxWidth: 320,
          padding: '14px 16px',
          background: p.surfaceVariant, borderRadius: R.md,
          textAlign: 'left',
        }}>
          <div style={{ ...t('labelL'), color: p.onSurface, marginBottom: 10 }}>
            Cara bikin draft:
          </div>
          <Step n="1" text="Tambahkan menu di Home" palette={p}/>
          <Step n="2" text="Buka keranjang, tekan Simpan Draft" palette={p}/>
          <Step n="3" text="Draft muncul di halaman ini" palette={p}/>
        </div>
      </div>

      {/* Action area */}
      <div style={{ padding: '12px 16px 16px', flexShrink: 0 }}>
        <div style={{
          height: 52, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <Icon name="plus" size={18} strokeWidth={2.5}/>
          Buat order baru
        </div>
      </div>
    </div>
  );
}

function Step({ n, text, palette }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10,
      padding: '6px 0',
    }}>
      <div style={{
        width: 22, height: 22, borderRadius: '50%',
        background: p.primary, color: p.onPrimary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        ...t('labelM'), fontSize: 11, fontWeight: 700, flexShrink: 0,
      }}>{n}</div>
      <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13 }}>{text}</div>
    </div>
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

// Visual — stacked receipt cards, last one outlined (draft slot)
function DraftEmptyVisual({ palette }) {
  const p = palette;
  return (
    <div style={{
      width: 140, height: 100, position: 'relative',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* receipt card behind */}
      <div style={{
        position: 'absolute', width: 84, height: 92,
        borderRadius: R.sm,
        background: '#FFF',
        border: `1.5px solid ${p.outlineSoft}`,
        transform: 'rotate(-6deg) translate(-12px, 2px)',
        boxShadow: `0 4px 12px ${p.onSurface}10`,
      }}>
        <ReceiptLines palette={p}/>
      </div>
      {/* main empty slot — dashed */}
      <div style={{
        position: 'relative', width: 84, height: 92,
        borderRadius: R.sm,
        background: `${p.primaryContainer}66`,
        border: `2px dashed ${p.primary}88`,
        transform: 'rotate(4deg) translate(14px, 0)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: p.primary,
      }}>
        <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" strokeWidth="1.8" strokeLinecap="round">
          <path d="M12 5v14M5 12h14"/>
        </svg>
      </div>
    </div>
  );
}

function ReceiptLines({ palette }) {
  const p = palette;
  return (
    <div style={{ padding: '10px 8px', display: 'flex', flexDirection: 'column', gap: 5 }}>
      <div style={{ height: 5, width: '60%', background: p.surfaceDim, borderRadius: 2 }}/>
      <div style={{ height: 4, width: '90%', background: p.surfaceVariant, borderRadius: 2 }}/>
      <div style={{ height: 4, width: '80%', background: p.surfaceVariant, borderRadius: 2 }}/>
      <div style={{ height: 4, width: '70%', background: p.surfaceVariant, borderRadius: 2 }}/>
      <div style={{ height: 1, width: '100%', background: p.outlineSoft, marginTop: 4 }}/>
      <div style={{ height: 5, width: '50%', background: p.primary, borderRadius: 2, marginTop: 2 }}/>
    </div>
  );
}

Object.assign(window, { DraftOrderEmpty });
