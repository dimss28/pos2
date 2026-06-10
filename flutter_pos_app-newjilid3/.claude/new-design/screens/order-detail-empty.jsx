// ORDER DETAIL — Empty State (keranjang kosong)
// Original: "No Data" + payment selector that does nothing + disabled total/process
// Redesign: focus on the actual problem — kasih clear path balik ke menu.

function OrderDetailEmpty({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Detail Order</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Belum ada item di keranjang
          </div>
        </div>
      </div>

      {/* Empty state */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '24px 32px', textAlign: 'center',
      }}>
        <EmptyCartVisual palette={p}/>

        <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 24 }}>
          Keranjang kosong
        </div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 8, maxWidth: 290 }}>
          Pilih menu dari halaman utama untuk mulai membuat order pelanggan.
        </div>

        {/* What happens next — preview alur */}
        <div style={{
          marginTop: 24, width: '100%', maxWidth: 320,
          padding: '14px 16px',
          background: p.surfaceVariant, borderRadius: R.md,
          textAlign: 'left',
        }}>
          <div style={{ ...t('labelM'), color: p.onSurfaceVar, marginBottom: 10, textTransform: 'uppercase', letterSpacing: 0.5 }}>
            Selanjutnya
          </div>
          <FlowStep n="1" text="Tambah menu dari katalog" palette={p}/>
          <FlowStep n="2" text="Pilih metode bayar (Cash / QR / Transfer)" palette={p}/>
          <FlowStep n="3" text="Cetak struk & selesai" palette={p}/>
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
          <BackArrow color={p.onPrimary}/>
          Pilih menu
        </div>
      </div>

      <BottomNav palette={p} active={1}/>
    </div>
  );
}

function FlowStep({ n, text, palette }) {
  const p = palette;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '5px 0' }}>
      <div style={{
        width: 20, height: 20, borderRadius: '50%',
        background: '#FFF', color: p.primary,
        border: `1.5px solid ${p.primary}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        ...t('labelM'), fontSize: 11, fontWeight: 700, flexShrink: 0,
      }}>{n}</div>
      <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13 }}>{text}</div>
    </div>
  );
}

// Empty cart visual — basket outline + receipt slot, no generic shopping cart
function EmptyCartVisual({ palette }) {
  const p = palette;
  return (
    <div style={{
      width: 140, height: 110, position: 'relative',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* base */}
      <div style={{
        width: 110, height: 80,
        borderRadius: 12,
        background: p.primaryContainer,
        position: 'relative',
        boxShadow: `0 8px 20px ${p.primary}22`,
      }}>
        {/* slits — looks like a basket or cart frame */}
        <div style={{
          position: 'absolute', inset: '14px 12px',
          display: 'flex', flexDirection: 'column', gap: 6, justifyContent: 'center',
        }}>
          <div style={{ height: 5, width: '90%', borderRadius: 3, background: `${p.primary}33` }}/>
          <div style={{ height: 5, width: '70%', borderRadius: 3, background: `${p.primary}33` }}/>
          <div style={{ height: 5, width: '80%', borderRadius: 3, background: `${p.primary}33` }}/>
        </div>
      </div>
      {/* hovering "add" tag */}
      <div style={{
        position: 'absolute', top: 0, right: 8,
        width: 36, height: 36, borderRadius: '50%',
        background: p.primary, color: p.onPrimary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: `0 6px 14px ${p.primary}55`,
      }}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
          <path d="M12 5v14M5 12h14"/>
        </svg>
      </div>
    </div>
  );
}

Object.assign(window, { OrderDetailEmpty });

// Local copy — Babel scripts don't share scope
function BackArrow({ color }) {
  return (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
         stroke={color} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M19 12H5M12 19l-7-7 7-7"/>
    </svg>
  );
}
