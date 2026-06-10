// SETTINGS — Hub menu konfigurasi
// Original: 2x3 grid of giant illustrated icon cards + logout pill
// Redesign: profile header + grouped list with functional icons + status info
// UX wins: scannable, shows live status per item, destructive logout demoted

function SettingsPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Pengaturan</div>
        </div>
      </div>

      {/* Scrollable body */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px' }}>
        {/* Profile card */}
        <div style={{
          padding: '14px 14px',
          background: '#FFF',
          border: `1px solid ${p.outlineSoft}`,
          borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 12,
        }}>
          <div style={{
            width: 48, height: 48, borderRadius: '50%',
            background: p.primaryContainer, color: p.onPrimaryContainer,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('titleM'), fontWeight: 700,
          }}>RA</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('titleS'), color: p.onSurface }}>Rina Astuti</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
              Kasir · Shift Siang
            </div>
          </div>
          <div style={{
            ...t('labelM'), color: p.success, fontSize: 11,
            padding: '4px 10px', background: p.successContainer, borderRadius: R.pill,
          }}>Aktif</div>
        </div>

        {/* Section: Produk & Penjualan */}
        <SectionLabel palette={p}>Produk &amp; Penjualan</SectionLabel>
        <Group palette={p}>
          <Tile palette={p} icon="box"    title="Kelola Produk"     subtitle="48 produk tersimpan"/>
          <Tile palette={p} icon="chart"  title="Laporan Penjualan" subtitle="Lihat ringkasan & export PDF"/>
          <Tile palette={p} icon="lock"   title="Tutup Kasir"       subtitle="Akhiri shift & hitung kas" last/>
        </Group>

        {/* Section: Perangkat & Pembayaran */}
        <SectionLabel palette={p}>Perangkat &amp; Pembayaran</SectionLabel>
        <Group palette={p}>
          <Tile palette={p} icon="printer" title="Printer Thermal" status={{ tone: 'ok',   label: 'Terhubung' }}/>
          <Tile palette={p} icon="qris"    title="Server Key QRIS" status={{ tone: 'warn', label: 'Belum diatur' }} last/>
        </Group>

        {/* Section: Data */}
        <SectionLabel palette={p}>Data</SectionLabel>
        <Group palette={p}>
          <Tile palette={p} icon="sync" title="Sinkronisasi" subtitle="Terakhir: 2 jam lalu" last/>
        </Group>

        {/* Section: Akun */}
        <SectionLabel palette={p}>Akun</SectionLabel>
        <Group palette={p}>
          <Tile palette={p} icon="exit" title="Keluar" destructive last/>
        </Group>

        {/* Version footer */}
        <div style={{
          textAlign: 'center', marginTop: 18,
          ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11,
        }}>
          POS Batch 11 · v1.4.2 (build 220)
        </div>
      </div>

      <BottomNav palette={p} active={3}/>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Tile
// ─────────────────────────────────────────────────────────────
function Tile({ palette, icon, title, subtitle, status, destructive, last }) {
  const p = palette;
  const accent = destructive ? p.error : p.primary;
  const accentBg = destructive ? p.errorContainer : p.primaryContainer;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: R.sm,
        background: accentBg, color: accent,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
      }}>
        <SettingIcon name={icon}/>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...t('bodyL'), color: destructive ? p.error : p.onSurface, fontSize: 15, fontWeight: 600 }}>
          {title}
        </div>
        {subtitle && (
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 12 }}>
            {subtitle}
          </div>
        )}
      </div>
      {status && <StatusChip palette={p} {...status}/>}
      {!destructive && (
        <div style={{ color: p.onSurfaceVar, opacity: 0.5 }}>
          <Chevron/>
        </div>
      )}
    </div>
  );
}

function StatusChip({ palette, tone, label }) {
  const p = palette;
  const bg = tone === 'ok'   ? p.successContainer : p.warningContainer;
  const fg = tone === 'ok'   ? p.success          : '#92400E';
  return (
    <div style={{
      display: 'inline-flex', alignItems: 'center', gap: 5,
      padding: '4px 9px', borderRadius: R.pill,
      background: bg, color: fg,
      ...t('labelM'), fontSize: 11,
    }}>
      <div style={{ width: 6, height: 6, borderRadius: '50%', background: fg }}/>
      {label}
    </div>
  );
}

function Group({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      marginTop: 8,
      background: '#FFF',
      border: `1px solid ${p.outlineSoft}`,
      borderRadius: R.md,
      overflow: 'hidden',
    }}>{children}</div>
  );
}

function SectionLabel({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 2, paddingLeft: 4,
    }}>{children}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons — functional, monoline
// ─────────────────────────────────────────────────────────────
function SettingIcon({ name }) {
  const props = {
    width: 18, height: 18, viewBox: '0 0 24 24',
    fill: 'none', stroke: 'currentColor', strokeWidth: 2,
    strokeLinecap: 'round', strokeLinejoin: 'round',
  };
  switch (name) {
    case 'box':
      return <svg {...props}><path d="M3 7l9-4 9 4-9 4-9-4z"/><path d="M3 7v10l9 4 9-4V7"/><path d="M12 11v10"/></svg>;
    case 'chart':
      return <svg {...props}><path d="M4 20V8M10 20V4M16 20v-8M22 20H2"/></svg>;
    case 'lock':
      return <svg {...props}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>;
    case 'printer':
      return <svg {...props}><path d="M6 9V3h12v6"/><rect x="3" y="9" width="18" height="9" rx="2"/><rect x="6" y="14" width="12" height="7"/></svg>;
    case 'qris':
      return <svg {...props}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3h-3zM21 14v3M14 21h7M17 17v4"/></svg>;
    case 'sync':
      return <svg {...props}><path d="M21 12a9 9 0 0 1-15 6.7L3 16"/><path d="M3 12a9 9 0 0 1 15-6.7L21 8"/><path d="M21 3v5h-5"/><path d="M3 21v-5h5"/></svg>;
    case 'exit':
      return <svg {...props}><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/></svg>;
    default: return null;
  }
}

function Chevron() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="m9 6 6 6-6 6"/>
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

Object.assign(window, { SettingsPage });
