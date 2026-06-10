// SYNC DATA — sync local DB with server
// Original: 3 bare pill buttons (Product, Orders, Categories) — no context
// Redesign: per-item status, last sync info, connection state, sync-all CTA

function SyncDataPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Sinkronisasi Data</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Tarik data dari server, kirim order offline
          </div>
        </div>
      </div>

      {/* Connection status card */}
      <div style={{ padding: '8px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 14px',
          background: p.successContainer,
          border: `1px solid ${p.success}33`,
          borderRadius: R.md,
        }}>
          <div style={{
            width: 8, height: 8, borderRadius: '50%', background: p.success,
            boxShadow: `0 0 0 4px ${p.success}22`, flexShrink: 0,
          }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('labelL'), color: p.success, fontSize: 13 }}>Terhubung ke server</div>
            <div style={{ ...t('bodyS'), color: p.success, opacity: 0.85, marginTop: 2, fontSize: 12 }}>
              Terakhir sinkron: 2 jam lalu &middot; 24 Mei 19:24
            </div>
          </div>
        </div>
      </div>

      {/* Sync items list */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 16px 8px' }}>
        <div style={{
          ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
          textTransform: 'uppercase', letterSpacing: 0.8,
          marginBottom: 8, paddingLeft: 4,
        }}>Data untuk disinkronkan</div>

        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          overflow: 'hidden',
        }}>
          <SyncRow palette={p}
            title="Produk"
            count="48 item lokal"
            status={{ tone: 'ok', label: 'Terbaru' }}
            timeAgo="2 jam lalu"
          />
          <SyncRow palette={p}
            title="Kategori"
            count="6 kategori lokal"
            status={{ tone: 'ok', label: 'Terbaru' }}
            timeAgo="2 jam lalu"
          />
          <SyncRow palette={p}
            title="Order Pending"
            count="3 order menunggu dikirim"
            status={{ tone: 'warn', label: 'Belum upload' }}
            timeAgo="—"
            direction="upload"
            last
          />
        </div>

        {/* Activity log preview */}
        <div style={{
          ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
          textTransform: 'uppercase', letterSpacing: 0.8,
          marginTop: 20, marginBottom: 8, paddingLeft: 4,
        }}>Aktivitas terakhir</div>

        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '10px 14px',
        }}>
          <LogLine palette={p} ok text="Produk diperbarui (48 item)"  time="19:24"/>
          <LogLine palette={p} ok text="Kategori diperbarui (6 item)" time="19:24"/>
          <LogLine palette={p}    text="Order #1248 berhasil dikirim" time="18:11"/>
        </div>
      </div>

      {/* Sticky bottom — Sync All */}
      <div style={{ padding: '12px 16px 12px', flexShrink: 0, borderTop: `1px solid ${p.outlineSoft}`, background: p.surface }}>
        <div style={{
          height: 54, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', padding: '0 8px 0 20px', gap: 10,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10 }}>
            <SyncIconLocal/>
            Sinkronkan semua
          </div>
          <div style={{
            padding: '4px 10px', borderRadius: R.pill,
            background: `${p.onPrimary}22`, color: p.onPrimary,
            ...t('labelM'), fontSize: 11,
          }}>3 pending</div>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// SyncRow
// ─────────────────────────────────────────────────────────────
function SyncRow({ palette, title, count, status, timeAgo, direction = 'download', last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '14px 14px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: R.sm,
        background: status.tone === 'warn' ? p.warningContainer : p.primaryContainer,
        color: status.tone === 'warn' ? '#92400E' : p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        {direction === 'upload' ? <UploadIcon/> : <DownloadIcon/>}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 15, fontWeight: 600 }}>
            {title}
          </div>
          <StatusDot palette={p} {...status}/>
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 12 }}>
          {count} &middot; {timeAgo}
        </div>
      </div>
      <div style={{
        padding: '8px 12px', borderRadius: R.sm,
        background: 'transparent', color: p.primary,
        border: `1.5px solid ${p.outline}`,
        ...t('labelL'), fontSize: 12,
      }}>
        Sync
      </div>
    </div>
  );
}

function StatusDot({ palette, tone, label }) {
  const p = palette;
  const fg = tone === 'ok' ? p.success : '#A66400';
  return (
    <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
      <div style={{ width: 6, height: 6, borderRadius: '50%', background: fg }}/>
      <div style={{ ...t('labelM'), fontSize: 10, color: fg, textTransform: 'uppercase', letterSpacing: 0.4 }}>
        {label}
      </div>
    </div>
  );
}

function LogLine({ palette, ok, text, time }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 10, padding: '5px 0',
    }}>
      <div style={{
        width: 18, height: 18, borderRadius: '50%',
        background: ok ? p.successContainer : p.surfaceVariant,
        color: ok ? p.success : p.onSurfaceVar,
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
          <path d="m5 13 4 4L19 7"/>
        </svg>
      </div>
      <div style={{ flex: 1, ...t('bodyM'), color: p.onSurface, fontSize: 13 }}>{text}</div>
      <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11 }}>{time}</div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Icons local
// ─────────────────────────────────────────────────────────────
function DownloadIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 3v14M5 12l7 7 7-7M5 21h14"/>
    </svg>
  );
}
function UploadIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M12 21V7M5 12l7-7 7 7M5 3h14"/>
    </svg>
  );
}
function SyncIconLocal() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 12a9 9 0 0 1-15 6.7L3 16"/>
      <path d="M3 12a9 9 0 0 1 15-6.7L21 8"/>
      <path d="M21 3v5h-5"/>
      <path d="M3 21v-5h5"/>
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

Object.assign(window, { SyncDataPage });
