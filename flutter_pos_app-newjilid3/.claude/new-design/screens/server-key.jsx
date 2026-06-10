// SAVE SERVER KEY — Midtrans QRIS config
// Original: bare textfield + tiny disabled-looking save button
// Redesign: explainer, environment toggle, masked key with show/hide,
// sensitivity hint, "where to find" help link.

function SaveServerKeyPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Server Key QRIS</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Konfigurasi Midtrans untuk pembayaran QR
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 16px 16px' }}>
        {/* Explainer card */}
        <div style={{
          display: 'flex', gap: 12, padding: '14px 16px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm,
            background: p.primaryContainer, color: p.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
          }}>
            <InfoCircle/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('bodyM'), color: p.onSurface, fontSize: 13, lineHeight: '18px' }}>
              Server key dipakai untuk generate QRIS pembayaran via Midtrans. Tanpa key ini, opsi bayar QR tidak akan muncul saat checkout.
            </div>
            <div style={{ ...t('labelL'), color: p.primary, fontSize: 12, marginTop: 8 }}>
              Cara mendapat server key →
            </div>
          </div>
        </div>

        {/* Current status */}
        <SectionLabelSK palette={p}>Status saat ini</SectionLabelSK>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 14px',
          background: '#FFF',
          border: `1px solid ${p.outlineSoft}`,
          borderRadius: R.md,
        }}>
          <div style={{
            width: 8, height: 8, borderRadius: '50%', background: p.success,
            boxShadow: `0 0 0 4px ${p.success}22`, flexShrink: 0,
          }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>
              Key tersimpan
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2,
                          fontFamily: 'ui-monospace, monospace', fontSize: 12 }}>
              SB-Mid-server-•••••••••••••5fA9
            </div>
          </div>
          <div style={{
            ...t('labelL'), color: p.error, fontSize: 12,
            padding: '6px 10px', borderRadius: R.sm,
          }}>Hapus</div>
        </div>

        {/* Environment selector */}
        <SectionLabelSK palette={p}>Environment</SectionLabelSK>
        <div style={{
          display: 'flex', padding: 4,
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <EnvTab palette={p} label="Sandbox" sub="Untuk testing" active/>
          <EnvTab palette={p} label="Production" sub="Transaksi asli"/>
        </div>

        {/* Server key input */}
        <SectionLabelSK palette={p}>Server Key</SectionLabelSK>
        <div style={{
          display: 'flex', alignItems: 'center',
          height: 56, padding: '0 6px 0 14px', gap: 8,
          background: '#FFF',
          border: `1.5px solid ${p.primary}`,
          boxShadow: `0 0 0 4px ${p.primary}1A`,
          borderRadius: R.md,
        }}>
          <div style={{
            flex: 1, ...t('bodyL'), color: p.onSurface,
            fontFamily: 'ui-monospace, monospace', fontSize: 14,
            overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
          }}>
            SB-Mid-server-aB3cD4eF5gH6iJ7kL8mN9oP0qR1sT2u
          </div>
          <div style={{
            width: 40, height: 40, borderRadius: R.sm,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: p.onSurfaceVar,
          }}>
            <Icon name="eye-off" size={20}/>
          </div>
        </div>

        {/* Helper hints */}
        <div style={{
          marginTop: 10, display: 'flex', alignItems: 'flex-start', gap: 8,
          color: p.onSurfaceVar,
        }}>
          <div style={{ marginTop: 1 }}><LockSmall/></div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 12, lineHeight: '16px' }}>
            Server key bersifat <b>rahasia</b>. Disimpan terenkripsi di perangkat ini saja.
          </div>
        </div>
      </div>

      {/* Sticky save */}
      <div style={{
        padding: '12px 16px 12px', flexShrink: 0,
        borderTop: `1px solid ${p.outlineSoft}`, background: p.surface,
      }}>
        <div style={{
          height: 54, borderRadius: R.md, background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
          ...t('labelL'), fontSize: 15, fontWeight: 700,
          boxShadow: `0 6px 16px ${p.primary}40`,
        }}>
          Simpan Server Key
        </div>
      </div>
    </div>
  );
}

function SectionLabelSK({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function EnvTab({ palette, label, sub, active }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, padding: '10px 12px',
      borderRadius: R.sm,
      background: active ? '#FFF' : 'transparent',
      boxShadow: active ? `0 1px 4px ${p.onSurface}1A` : 'none',
      textAlign: 'left',
    }}>
      <div style={{
        ...t('labelL'), color: active ? p.onSurface : p.onSurfaceVar,
        fontSize: 13, fontWeight: 700,
      }}>{label}</div>
      <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>{sub}</div>
    </div>
  );
}

// Icons
function InfoCircle() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="9"/><path d="M12 8v.01M11 12h1v5h1"/>
    </svg>
  );
}
function LockSmall() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="11" width="16" height="10" rx="2"/>
      <path d="M8 11V8a4 4 0 0 1 8 0v3"/>
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

Object.assign(window, { SaveServerKeyPage });
