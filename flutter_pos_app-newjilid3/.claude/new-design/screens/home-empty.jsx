// HOME — Empty State (belum sync, belum ada produk)
// Goal: informatif tentang KENAPA kosong + action yang jelas untuk sync

function HomeEmpty({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0 }}>
      {/* App bar — soft, bukan colored band */}
      <div style={{
        padding: '14px 20px 16px',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      }}>
        <div>
          <div style={{ ...t('titleL'), color: p.onSurface }}>Menu Cafe</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>Sudut Kopi · Bandung</div>
        </div>
        <div style={{
          width: 44, height: 44, borderRadius: R.md,
          background: p.surfaceVariant, color: p.onSurface,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Icon name="receipt" size={20}/>
        </div>
      </div>

      {/* Search — visible tapi terasa "kosong" karena gak ada hasil */}
      <div style={{ padding: '0 16px' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          height: 52, padding: '0 8px 0 16px',
          background: p.surfaceVariant, borderRadius: R.md,
          opacity: 0.6,
        }}>
          <Icon name="search" size={20} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar }}>Cari produk...</div>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm, background: p.onSurface, color: p.surface,
            display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.4,
          }}>
            <Icon name="qr" size={18}/>
          </div>
        </div>
      </div>

      {/* Sync status banner — informatif */}
      <div style={{ padding: '16px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 14px',
          background: p.warningContainer,
          border: `1px solid ${p.warning}33`,
          borderRadius: R.md,
        }}>
          <div style={{
            width: 8, height: 8, borderRadius: '50%', background: p.warning,
            boxShadow: `0 0 0 4px ${p.warning}22`, flexShrink: 0,
          }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('labelL'), color: '#7C4A0E' }}>Belum pernah sinkron</div>
            <div style={{ ...t('bodyS'), color: '#8A5A20', marginTop: 2 }}>
              Data produk tersimpan di server, belum di-load ke perangkat ini.
            </div>
          </div>
        </div>
      </div>

      {/* Empty state — typographic, no oversized cart icon */}
      <div style={{
        flex: 1, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        padding: '16px 32px 0', textAlign: 'center', minHeight: 0,
      }}>
        {/* Geometric visual — bukan generic cart icon */}
        <EmptyVisual palette={p}/>

        <div style={{ ...t('titleL'), color: p.onSurface, marginTop: 20 }}>
          Yuk, sinkronkan menu
        </div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 6, maxWidth: 280 }}>
          Tarik daftar produk, kategori, dan harga dari server supaya kasir bisa mulai jualan.
        </div>

        {/* What will be synced — small inline list */}
        <div style={{
          marginTop: 14, display: 'flex', gap: 8, flexWrap: 'wrap', justifyContent: 'center',
        }}>
          {['Produk', 'Kategori', 'Harga & stok'].map(item => (
            <div key={item} style={{
              padding: '5px 11px', borderRadius: R.pill,
              background: p.surfaceVariant, color: p.onSurfaceVar,
              ...t('labelM'),
            }}>{item}</div>
          ))}
        </div>
      </div>

      {/* Action area — sticky bottom above nav */}
      <div style={{
        padding: '12px 16px 10px',
        display: 'flex', flexDirection: 'column', gap: 8,
        flexShrink: 0,
      }}>
        <div style={{
          height: 52, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <SyncIcon size={18}/>
          Sinkronkan sekarang
        </div>
        <div style={{
          height: 44, borderRadius: R.md,
          border: `1.5px solid ${p.outline}`, color: p.onSurface, background: 'transparent',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          ...t('labelL'), fontSize: 14,
        }}>
          Tambah produk manual
        </div>
      </div>

      <BottomNav palette={p} active={0}/>
    </div>
  );
}

// Custom empty visual — abstract, not the generic cart icon
function EmptyVisual({ palette }) {
  const p = palette;
  return (
    <div style={{
      width: 160, height: 96, position: 'relative',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    }}>
      {/* Stack of "cards" representing not-yet-loaded products */}
      <div style={{
        position: 'absolute', width: 80, height: 80,
        borderRadius: R.md,
        border: `2px dashed ${p.outline}`,
        background: `${p.surfaceVariant}66`,
        transform: 'rotate(-8deg) translate(-22px, 4px)',
      }}/>
      <div style={{
        position: 'absolute', width: 80, height: 80,
        borderRadius: R.md,
        border: `2px dashed ${p.outline}`,
        background: `${p.surfaceVariant}66`,
        transform: 'rotate(6deg) translate(20px, 0)',
      }}/>
      <div style={{
        position: 'relative',
        width: 80, height: 80,
        borderRadius: R.md,
        background: p.primaryContainer, color: p.onPrimaryContainer,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: `0 8px 20px ${p.primary}22`,
      }}>
        <SyncIcon size={30} color={p.primary}/>
      </div>
    </div>
  );
}

function SyncIcon({ size = 20, color = 'currentColor' }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
         stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12a9 9 0 0 1-15 6.7L3 16"/>
      <path d="M3 12a9 9 0 0 1 15-6.7L21 8"/>
      <path d="M21 3v5h-5"/>
      <path d="M3 21v-5h5"/>
    </svg>
  );
}

Object.assign(window, { HomeEmpty });
