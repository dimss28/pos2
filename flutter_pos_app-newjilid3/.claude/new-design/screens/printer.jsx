// PRINTER MANAGEMENT
// Original: bare "Search" button + "No data available"
// Redesign: connected status + scan flow + pairing instructions + permission hint

function PrinterPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Printer Thermal</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Pilih printer untuk cetak struk
          </div>
        </div>
      </div>

      {/* Connected printer card */}
      <div style={{ padding: '8px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 14px',
          background: p.warningContainer,
          border: `1px solid ${p.warning}33`,
          borderRadius: R.md,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm,
            background: '#FFF', color: '#92400E',
            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
          }}>
            <PrinterIcon/>
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('labelL'), color: '#7C4A0E', fontSize: 13 }}>Belum ada printer tersambung</div>
            <div style={{ ...t('bodyS'), color: '#8A5A20', marginTop: 2, fontSize: 12 }}>
              Struk akan disimpan sebagai PDF sampai printer di-pair.
            </div>
          </div>
        </div>
      </div>

      {/* Available devices section */}
      <div style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '20px 18px 8px',
      }}>
        <div style={{
          ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
          textTransform: 'uppercase', letterSpacing: 0.8,
        }}>Perangkat tersedia</div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 6,
          ...t('labelL'), color: p.primary, fontSize: 12,
        }}>
          <ScanIcon color={p.primary}/>
          Pindai ulang
        </div>
      </div>

      {/* Empty state */}
      <div style={{ flex: 1, padding: '0 16px', minHeight: 0, overflowY: 'auto' }}>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1.5px dashed ${p.outline}`,
          padding: '24px 20px',
          textAlign: 'center',
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: R.md,
            background: p.surfaceVariant, color: p.onSurfaceVar,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            margin: '0 auto',
          }}>
            <BluetoothSearchIcon/>
          </div>
          <div style={{ ...t('titleM'), color: p.onSurface, marginTop: 14, fontSize: 16 }}>
            Belum ada perangkat ditemukan
          </div>
          <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 6, fontSize: 13 }}>
            Pastikan printer dalam jangkauan dan dalam mode pairing.
          </div>
        </div>

        {/* Pairing instructions */}
        <div style={{
          marginTop: 16,
          background: p.surfaceVariant, borderRadius: R.md,
          padding: '14px 16px',
        }}>
          <div style={{
            ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
            textTransform: 'uppercase', letterSpacing: 0.6, marginBottom: 10,
          }}>Cara pairing</div>
          <PairStep n="1" text="Nyalakan printer thermal" palette={p}/>
          <PairStep n="2" text="Aktifkan Bluetooth di HP" palette={p}/>
          <PairStep n="3" text="Tekan Pindai untuk mulai mencari" palette={p}/>
        </div>

        {/* Bluetooth permission hint */}
        <div style={{
          marginTop: 12,
          display: 'flex', alignItems: 'flex-start', gap: 10,
          padding: '10px 14px',
          background: 'transparent',
          border: `1px solid ${p.outlineSoft}`, borderRadius: R.md,
        }}>
          <div style={{ color: p.onSurfaceVar, marginTop: 2 }}>
            <InfoIcon/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13 }}>
              Izin Bluetooth diperlukan untuk scan perangkat.
            </div>
            <div style={{ ...t('labelL'), color: p.primary, fontSize: 12, marginTop: 4 }}>
              Buka Pengaturan
            </div>
          </div>
        </div>
      </div>

      {/* Sticky scan CTA */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
      }}>
        <div style={{
          height: 54, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <ScanIcon color={p.onPrimary}/>
          Pindai perangkat
        </div>
      </div>
    </div>
  );
}

function PairStep({ n, text, palette }) {
  const p = palette;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '4px 0' }}>
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

// Icons
function PrinterIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M6 9V3h12v6"/>
      <rect x="3" y="9" width="18" height="9" rx="2"/>
      <rect x="6" y="14" width="12" height="7"/>
    </svg>
  );
}
function ScanIcon({ color }) {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke={color || 'currentColor'} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12a9 9 0 0 1-15 6.7L3 16"/>
      <path d="M3 12a9 9 0 0 1 15-6.7L21 8"/>
      <path d="M21 3v5h-5"/>
      <path d="M3 21v-5h5"/>
    </svg>
  );
}
function BluetoothSearchIcon() {
  return (
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m7 7 10 10-5 5V2l5 5L7 17"/>
    </svg>
  );
}
function InfoIcon() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="9"/>
      <path d="M12 8v.01M11 12h1v5h1"/>
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

Object.assign(window, { PrinterPage });
