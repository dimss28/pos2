// BUKA KASIR — Open shift / start cash drawer
// Pairs with CloseKasir. Captures initial cash float, shift selection,
// runs a preparation checklist (printer, QRIS, sync), shows previous close
// summary so user has continuity.

function BukaKasirPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Buka Kasir</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Mulai shift baru
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 16px' }}>
        {/* Cashier identity (primary card) */}
        <div style={{
          padding: '14px 14px',
          background: p.primary, color: p.onPrimary,
          borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 12,
          boxShadow: `0 8px 20px ${p.primary}33`,
        }}>
          <div style={{
            width: 44, height: 44, borderRadius: '50%',
            background: `${p.onPrimary}22`, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('titleM'), fontWeight: 700,
          }}>RA</div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('titleS'), color: p.onPrimary, fontSize: 14 }}>Rina Astuti</div>
            <div style={{ ...t('bodyS'), opacity: 0.85, fontSize: 12, marginTop: 2 }}>
              Senin, 24 Mei &middot; 08:00
            </div>
          </div>
          <div style={{ ...t('labelM'), color: p.onPrimary, opacity: 0.7, fontSize: 11 }}>
            Bukan kamu?
          </div>
        </div>

        {/* Previous shift recap — kasih konteks */}
        <SectionLabelBK palette={p}>Shift sebelumnya</SectionLabelBK>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          padding: '10px 12px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <div style={{
            width: 32, height: 32, borderRadius: R.sm,
            background: '#FFF', color: p.onSurfaceVar,
            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
          }}>
            <ClockIconBK/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 12 }}>
              <b style={{ fontWeight: 700 }}>Bahri</b> tutup kemarin 23:14
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              28 transaksi &middot; Rp842.000 &middot; selisih Rp0
            </div>
          </div>
          <div style={{
            padding: '4px 8px', borderRadius: R.pill,
            background: p.successContainer, color: p.success,
            ...t('labelM'), fontSize: 10, fontWeight: 700,
          }}>BALANCED</div>
        </div>

        {/* Shift picker */}
        <SectionLabelBK palette={p}>Pilih shift</SectionLabelBK>
        <div style={{
          display: 'flex', gap: 8,
        }}>
          <ShiftOption palette={p} label="Pagi"   time="06:00 – 14:00"/>
          <ShiftOption palette={p} label="Siang"  time="14:00 – 22:00" active/>
          <ShiftOption palette={p} label="Malam"  time="22:00 – 06:00"/>
        </div>

        {/* Modal awal kas */}
        <SectionLabelBK palette={p}>Modal awal kas <span style={{ color: p.error }}>*</span></SectionLabelBK>
        <div style={{
          display: 'flex', alignItems: 'center',
          height: 60, padding: '0 16px', gap: 8,
          background: '#FFF',
          border: `1.5px solid ${p.primary}`,
          boxShadow: `0 0 0 4px ${p.primary}1A`,
          borderRadius: R.md,
        }}>
          <div style={{ ...t('titleM'), color: p.onSurfaceVar, fontSize: 18, fontWeight: 600 }}>Rp</div>
          <div style={{ flex: 1, ...t('displayM'), color: p.onSurface, fontSize: 24, fontWeight: 700 }}>
            200.000
          </div>
        </div>
        <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
          {[100000, 200000, 300000, 500000].map(v => (
            <div key={v} style={{
              flex: 1, padding: '8px 0', textAlign: 'center', borderRadius: R.sm,
              background: v === 200000 ? p.primaryContainer : p.surfaceVariant,
              color: v === 200000 ? p.primary : p.onSurface,
              ...t('labelM'), fontSize: 11, fontWeight: v === 200000 ? 700 : 500,
              border: `1px solid ${v === 200000 ? p.primary + '44' : 'transparent'}`,
            }}>Rp{(v / 1000)}rb</div>
          ))}
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 6, paddingLeft: 4 }}>
          Uang fisik yang sudah disiapkan di laci kasir untuk kembalian.
        </div>

        {/* Checklist persiapan */}
        <SectionLabelBK palette={p}>Cek persiapan</SectionLabelBK>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          overflow: 'hidden',
        }}>
          <ChecklistRow palette={p}
            title="Printer Thermal" detail="Epson TM-T82 tersambung"
            status="ok"
          />
          <ChecklistRow palette={p}
            title="Server Key QRIS" detail="Sandbox · ...5fA9"
            status="ok"
          />
          <ChecklistRow palette={p}
            title="Sinkronisasi data" detail="Terakhir: 2 jam lalu"
            status="warn" action="Sync"
          />
          <ChecklistRow palette={p}
            title="Stok kritis" detail="3 produk perlu di-restock"
            status="warn" action="Lihat" last
          />
        </div>

        {/* Notes */}
        <SectionLabelBK palette={p}>Catatan (opsional)</SectionLabelBK>
        <div style={{
          minHeight: 60, padding: '12px 14px',
          background: '#FFF',
          border: `1.5px solid ${p.outline}`,
          borderRadius: R.md,
          ...t('bodyM'), color: p.onSurfaceVar, fontSize: 13,
        }}>
          mis. promo happy hour 17–19, espresso machine baru di-service...
        </div>
      </div>

      {/* Sticky CTA */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
      }}>
        <div style={{
          height: 56, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '0 8px 0 20px',
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          <span>Mulai Shift Siang</span>
          <div style={{
            width: 40, height: 40, borderRadius: R.sm,
            background: `${p.onPrimary}22`, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="arrow-right" size={20} strokeWidth={2.5}/>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────
function ShiftOption({ palette, label, time, active }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, padding: '12px 10px', textAlign: 'center',
      background: active ? p.primaryContainer : '#FFF',
      border: `1.5px solid ${active ? p.primary : p.outlineSoft}`,
      borderRadius: R.md,
      position: 'relative',
    }}>
      {active && (
        <div style={{
          position: 'absolute', top: -6, right: -6,
          width: 18, height: 18, borderRadius: '50%',
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="m5 13 4 4L19 7"/>
          </svg>
        </div>
      )}
      <div style={{ ...t('labelL'), color: active ? p.onPrimaryContainer : p.onSurface,
                    fontSize: 13, fontWeight: 700 }}>{label}</div>
      <div style={{ ...t('bodyS'), color: active ? p.primary : p.onSurfaceVar,
                    fontSize: 10, marginTop: 2 }}>{time}</div>
    </div>
  );
}

function ChecklistRow({ palette, title, detail, status, action, last }) {
  const p = palette;
  const ok = status === 'ok';
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{
        width: 28, height: 28, borderRadius: '50%',
        background: ok ? p.successContainer : p.warningContainer,
        color: ok ? p.success : '#7C4A0E',
        display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
      }}>
        {ok ? (
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
            <path d="m5 13 4 4L19 7"/>
          </svg>
        ) : (
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
            <path d="M12 9v4M12 17v.01"/><circle cx="12" cy="12" r="9"/>
          </svg>
        )}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 13, fontWeight: 600 }}>{title}</div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>{detail}</div>
      </div>
      {action && (
        <div style={{
          padding: '6px 10px', borderRadius: R.sm,
          color: p.primary, ...t('labelL'), fontSize: 12,
          border: `1px solid ${p.outline}`,
        }}>{action}</div>
      )}
    </div>
  );
}

function SectionLabelBK({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function ClockIconBK() {
  return (
    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>
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

Object.assign(window, { BukaKasirPage });
