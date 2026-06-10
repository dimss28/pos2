// CLOSE KASIR — End-of-shift reconciliation page
// Original: dialog "Are you sure?" — too dangerous, no audit trail
// Redesign: shift summary + payment breakdown + cash reconciliation
//           with auto-calculated variance, notes, print option.

function CloseKasirPage({ palette }) {
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Tutup Kasir</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            Rekonsiliasi akhir shift
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '4px 16px 16px' }}>
        {/* Shift identity card */}
        <div style={{
          padding: '14px 14px',
          background: p.primary, color: p.onPrimary,
          borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 14,
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
              Shift Siang &middot; 08:00 → 21:51 (13j 51m)
            </div>
          </div>
        </div>

        {/* Summary metrics */}
        <SectionLabelCK palette={p}>Ringkasan Shift</SectionLabelCK>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          <SummaryCellCK palette={p} label="Transaksi"    value="42"/>
          <SummaryCellCK palette={p} label="Item Terjual" value="98"/>
          <SummaryCellCK palette={p} label="Order Batal"  value="2"/>
          <SummaryCellCK palette={p} label="Total Pendapatan" value="Rp1.24jt" wide accent/>
        </div>

        {/* Payment breakdown */}
        <SectionLabelCK palette={p}>Pendapatan per Metode</SectionLabelCK>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          overflow: 'hidden',
        }}>
          <PaymentRow palette={p} method="Cash"     count={22} amount={624000}/>
          <PaymentRow palette={p} method="QRIS"     count={14} amount={486000}/>
          <PaymentRow palette={p} method="Transfer" count={6}  amount={130000} last/>
        </div>

        {/* Cash reconciliation — the important bit */}
        <SectionLabelCK palette={p}>Rekonsiliasi Kas</SectionLabelCK>
        <div style={{
          background: '#FFF', borderRadius: R.md,
          border: `1px solid ${p.outlineSoft}`,
          padding: '4px 14px',
        }}>
          <ReconRow palette={p} label="Modal awal"           value="Rp200.000" />
          <ReconRow palette={p} label="+ Pemasukan cash"     value="Rp624.000" />
          <ReconRow palette={p} label="− Pengeluaran cash"   value="Rp45.000"  />
          <ReconRow palette={p} label="Estimasi kas akhir"   value="Rp779.000" highlight/>
        </div>

        {/* Physical cash input */}
        <div style={{ marginTop: 10 }}>
          <label style={{ ...t('labelL'), color: p.onSurface, fontSize: 13, display: 'block', marginBottom: 6 }}>
            Kas fisik di laci <span style={{ color: p.error }}>*</span>
          </label>
          <div style={{
            display: 'flex', alignItems: 'center',
            height: 56, padding: '0 14px', gap: 6,
            background: '#FFF',
            border: `1.5px solid ${p.primary}`,
            boxShadow: `0 0 0 4px ${p.primary}1A`,
            borderRadius: R.md,
          }}>
            <div style={{ ...t('bodyL'), color: p.onSurfaceVar, fontSize: 16 }}>Rp</div>
            <div style={{ flex: 1, ...t('titleM'), color: p.onSurface, fontSize: 20, fontWeight: 700 }}>
              775.000
            </div>
          </div>
          {/* Variance */}
          <div style={{
            display: 'flex', alignItems: 'center', gap: 8,
            marginTop: 8, padding: '10px 14px',
            background: p.warningContainer, borderRadius: R.md,
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: '50%',
              background: p.warning, color: '#FFF',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 9v4M12 17v.01"/><circle cx="12" cy="12" r="10"/>
              </svg>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ ...t('labelL'), color: '#7C4A0E', fontSize: 13 }}>
                Selisih kurang Rp4.000
              </div>
              <div style={{ ...t('bodyS'), color: '#8A5A20', fontSize: 11, marginTop: 1 }}>
                Hitung ulang atau jelaskan di catatan
              </div>
            </div>
          </div>
        </div>

        {/* Notes */}
        <SectionLabelCK palette={p}>Catatan (opsional)</SectionLabelCK>
        <div style={{
          minHeight: 80, padding: '12px 14px',
          background: '#FFF',
          border: `1.5px solid ${p.outline}`,
          borderRadius: R.md,
          ...t('bodyM'), color: p.onSurface, fontSize: 13, lineHeight: '18px',
        }}>
          Selisih Rp4.000 — kemungkinan kembalian customer Mas Andi tadi siang...
        </div>

        {/* Print toggle */}
        <div style={{ marginTop: 14 }}>
          <SwitchRowCK palette={p}
            title="Cetak struk closing"
            subtitle="Print rekap untuk arsip & owner"
            value
          />
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
          <span>Tutup Kasir &amp; Akhiri Shift</span>
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
// Helpers
// ─────────────────────────────────────────────────────────────
function SummaryCellCK({ palette, label, value, wide, accent }) {
  const p = palette;
  return (
    <div style={{
      gridColumn: wide ? '1 / -1' : 'auto',
      padding: '12px 14px',
      background: accent ? p.onSurface : '#FFF',
      color: accent ? p.surface : p.onSurface,
      border: accent ? 'none' : `1px solid ${p.outlineSoft}`,
      borderRadius: R.md,
    }}>
      <div style={{
        ...t('labelM'), fontSize: 11,
        color: accent ? `${p.surface}AA` : p.onSurfaceVar,
        textTransform: 'uppercase', letterSpacing: 0.5,
      }}>{label}</div>
      <div style={{
        ...t('displayM'), fontSize: wide ? 26 : 20, fontWeight: 700, marginTop: 4,
        color: accent ? p.surface : p.onSurface,
      }}>{value}</div>
    </div>
  );
}

function PaymentRow({ palette, method, count, amount, last }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      padding: '12px 14px',
      borderBottom: last ? 'none' : `1px solid ${p.outlineSoft}`,
    }}>
      <div style={{
        width: 32, height: 32, borderRadius: R.sm,
        background: p.primaryContainer, color: p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        ...t('labelM'), fontSize: 11, fontWeight: 700,
      }}>{method.slice(0, 2).toUpperCase()}</div>
      <div style={{ flex: 1 }}>
        <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>{method}</div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
          {count} transaksi
        </div>
      </div>
      <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 15, fontWeight: 700 }}>
        {rupiah(amount)}
      </div>
    </div>
  );
}

function ReconRow({ palette, label, value, highlight }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '10px 0',
      borderBottom: highlight ? 'none' : `1px solid ${p.outlineSoft}`,
      borderTop: highlight ? `1.5px solid ${p.onSurface}22` : 'none',
      marginTop: highlight ? 4 : 0,
    }}>
      <div style={{
        ...t('bodyM'), color: highlight ? p.onSurface : p.onSurfaceVar,
        fontSize: 13, fontWeight: highlight ? 700 : 500,
      }}>{label}</div>
      <div style={{
        ...t('titleM'), color: p.onSurface,
        fontSize: highlight ? 16 : 14, fontWeight: 700,
      }}>{value}</div>
    </div>
  );
}

function SectionLabelCK({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 18, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function SwitchRowCK({ palette, title, subtitle, value }) {
  const p = palette;
  return (
    <div style={{
      padding: '12px 14px', borderRadius: R.md,
      border: `1px solid ${p.outlineSoft}`, background: '#FFF',
      display: 'flex', alignItems: 'center', gap: 12,
    }}>
      <div style={{ flex: 1 }}>
        <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 14, fontWeight: 600 }}>{title}</div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2, fontSize: 12 }}>{subtitle}</div>
      </div>
      <div style={{
        width: 44, height: 24, borderRadius: 12,
        background: value ? p.primary : p.outline,
        position: 'relative', flexShrink: 0,
      }}>
        <div style={{
          position: 'absolute', top: 2, left: value ? 22 : 2,
          width: 20, height: 20, borderRadius: '50%',
          background: '#FFF', transition: 'left .15s',
        }}/>
      </div>
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

Object.assign(window, { CloseKasirPage });
