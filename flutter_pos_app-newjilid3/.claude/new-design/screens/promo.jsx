// PROMO / DISCOUNT — applied in order + management page
// 1) DiscountSheet — bottom sheet di Order Detail untuk apply promo/voucher/manual
// 2) ManagePromoPage — list & atur promo (di Setting hub)

// ─────────────────────────────────────────────────────────────
// Sample promos
// ─────────────────────────────────────────────────────────────
const PR_PROMOS = [
  {
    id: 1, name: 'Happy Hour Coffee',
    type: 'percent', value: 20,
    schedule: 'Sen–Jum, 14:00–17:00',
    appliesTo: 'Semua kopi', code: null, active: true,
    badge: 'NOW',
  },
  {
    id: 2, name: 'Member Sudut Kopi',
    type: 'percent', value: 10,
    schedule: 'Setiap hari', appliesTo: 'Member terdaftar',
    code: 'MEMBER10', active: true,
  },
  {
    id: 3, name: 'Buy 1 Get 1 Croissant',
    type: 'b1g1', value: null,
    schedule: 'Sabtu–Minggu, 09:00–11:00',
    appliesTo: 'Croissant Mentega', code: null, active: true,
  },
  {
    id: 4, name: 'Welcome Voucher',
    type: 'rp', value: 15000,
    schedule: 'Sekali pakai', appliesTo: 'Min. Rp50.000',
    code: 'WELCOME15', active: true,
  },
  {
    id: 5, name: 'Promo 17 Agustus',
    type: 'percent', value: 17,
    schedule: '17 Agt 2026', appliesTo: 'Semua produk',
    code: 'MERDEKA17', active: false,
  },
];

// ─────────────────────────────────────────────────────────────
// 1) Discount sheet (in order detail)
// ─────────────────────────────────────────────────────────────
function DiscountSheet({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, position: 'relative', background: '#000', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, background: p.surface, opacity: 0.4 }}/>

      <div style={{
        background: p.surface,
        borderTopLeftRadius: 24, borderTopRightRadius: 24,
        padding: '12px 20px 20px',
        boxShadow: '0 -16px 40px rgba(0,0,0,0.25)',
        maxHeight: '92%', display: 'flex', flexDirection: 'column',
      }}>
        <div style={{
          width: 40, height: 4, borderRadius: 2,
          background: p.outline, margin: '0 auto 14px', flexShrink: 0,
        }}/>

        {/* Title row */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexShrink: 0 }}>
          <div style={{
            width: 36, height: 36, borderRadius: R.sm,
            background: p.primaryContainer, color: p.primary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <PromoIcon/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('titleM'), color: p.onSurface, fontSize: 16 }}>Diskon &amp; Voucher</div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 1 }}>
              Pilih promo untuk order ini
            </div>
          </div>
          <div style={{
            padding: '4px 10px', borderRadius: R.pill,
            background: p.successContainer, color: p.success,
            ...t('labelM'), fontSize: 11, fontWeight: 700,
          }}>3 tersedia</div>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', marginTop: 14, marginBottom: 4 }}>
          {/* Voucher code */}
          <SectionLabelPR palette={p}>Kode voucher</SectionLabelPR>
          <div style={{ display: 'flex', gap: 8 }}>
            <div style={{
              flex: 1, display: 'flex', alignItems: 'center',
              height: 48, padding: '0 14px',
              background: '#FFF',
              border: `1.5px solid ${p.outline}`,
              borderRadius: R.md,
              ...t('bodyL'), color: p.onSurfaceVar, fontSize: 14,
              fontFamily: 'ui-monospace, monospace',
            }}>MEMBER10</div>
            <div style={{
              padding: '0 18px', height: 48, borderRadius: R.md,
              background: p.primary, color: p.onPrimary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              ...t('labelL'), fontSize: 13, fontWeight: 700,
            }}>Pakai</div>
          </div>

          {/* Suggested promos */}
          <SectionLabelPR palette={p}>Promo otomatis</SectionLabelPR>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            <PromoCard palette={p} promo={PR_PROMOS[0]} applied/>
            <PromoCard palette={p} promo={PR_PROMOS[2]}/>
          </div>

          {/* Manual discount */}
          <SectionLabelPR palette={p}>Diskon manual</SectionLabelPR>
          <div style={{
            background: '#FFF', borderRadius: R.md,
            border: `1px solid ${p.outlineSoft}`,
            padding: '12px 14px',
          }}>
            {/* Type toggle */}
            <div style={{
              display: 'flex', padding: 3, gap: 0,
              background: p.surfaceVariant, borderRadius: R.sm,
            }}>
              <TypeToggle palette={p} label="Persen %"   active/>
              <TypeToggle palette={p} label="Rupiah Rp"/>
            </div>
            {/* Input */}
            <div style={{
              marginTop: 10,
              display: 'flex', alignItems: 'center',
              height: 52, padding: '0 14px', gap: 8,
              background: '#FFF',
              border: `1.5px solid ${p.outline}`,
              borderRadius: R.md,
            }}>
              <div style={{ flex: 1, ...t('titleM'), color: p.onSurfaceVar, fontSize: 18, fontWeight: 700 }}>
                0
              </div>
              <div style={{ ...t('titleM'), color: p.onSurfaceVar, fontSize: 16 }}>%</div>
            </div>
            <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 6 }}>
              Butuh otorisasi owner untuk diskon &gt; 25%
            </div>
          </div>
        </div>

        {/* Action */}
        <div style={{ display: 'flex', gap: 10, marginTop: 12, flexShrink: 0 }}>
          <div style={{
            flex: 1, height: 50, borderRadius: R.md,
            border: `1.5px solid ${p.outline}`, color: p.onSurface,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            ...t('labelL'), fontSize: 14,
          }}>Batal</div>
          <div style={{
            flex: 2, height: 50, borderRadius: R.md,
            background: p.primary, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '0 16px',
            ...t('labelL'), fontSize: 14, fontWeight: 700,
            boxShadow: `0 6px 16px ${p.primary}40`,
          }}>
            <span>Pakai diskon</span>
            <span>Hemat {rupiah(13800)}</span>
          </div>
        </div>
      </div>
    </div>
  );
}

function PromoCard({ palette, promo, applied }) {
  const p = palette;
  const valueLabel = promo.type === 'percent' ? `${promo.value}%`
                  : promo.type === 'rp'      ? `Rp${(promo.value / 1000)}rb`
                  : 'Beli 1 Gratis 1';
  return (
    <div style={{
      padding: '12px 14px',
      background: applied ? p.primaryContainer : '#FFF',
      border: `1.5px solid ${applied ? p.primary : p.outlineSoft}`,
      borderRadius: R.md,
      display: 'flex', gap: 12, alignItems: 'center',
      position: 'relative',
    }}>
      {/* Coupon notch left */}
      <div style={{
        width: 40, padding: '8px 0', textAlign: 'center',
        borderRight: `1.5px dashed ${applied ? p.primary + '55' : p.outline}`,
        marginRight: 2,
      }}>
        <div style={{ ...t('titleM'), color: applied ? p.primary : p.onSurface,
                      fontSize: 14, fontWeight: 800, lineHeight: 1 }}>
          {promo.type === 'b1g1' ? '1+1' : valueLabel.replace('Rp', '')}
        </div>
        <div style={{ ...t('labelM'), fontSize: 9, color: p.onSurfaceVar, marginTop: 2 }}>
          {promo.type === 'percent' ? 'OFF' : promo.type === 'rp' ? 'rb OFF' : 'GRATIS'}
        </div>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 13, fontWeight: 700 }}>
            {promo.name}
          </div>
          {promo.badge === 'NOW' && (
            <div style={{
              padding: '2px 6px', borderRadius: R.pill,
              background: p.error, color: '#FFF',
              ...t('labelM'), fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
            }}>BERLANGSUNG</div>
          )}
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
          {promo.appliesTo} &middot; {promo.schedule}
        </div>
      </div>
      {applied ? (
        <div style={{
          width: 26, height: 26, borderRadius: '50%',
          background: p.primary, color: p.onPrimary,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
            <path d="m5 13 4 4L19 7"/>
          </svg>
        </div>
      ) : (
        <div style={{
          padding: '6px 12px', borderRadius: R.sm,
          color: p.primary, ...t('labelL'), fontSize: 11,
          border: `1px solid ${p.outline}`,
        }}>Pakai</div>
      )}
    </div>
  );
}

function TypeToggle({ palette, label, active }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, padding: '8px 0', textAlign: 'center', borderRadius: 6,
      background: active ? '#FFF' : 'transparent',
      color: active ? p.onSurface : p.onSurfaceVar,
      boxShadow: active ? `0 1px 3px ${p.onSurface}1A` : 'none',
      ...t('labelL'), fontSize: 12, fontWeight: 700,
    }}>{label}</div>
  );
}

// ─────────────────────────────────────────────────────────────
// 2) Manage Promo page (in Settings)
// ─────────────────────────────────────────────────────────────
function ManagePromoPage({ palette }) {
  const p = palette;
  const active = PR_PROMOS.filter(x => x.active);
  const inactive = PR_PROMOS.filter(x => !x.active);
  return (
    <div style={{ flex: 1, background: p.surface, display: 'flex', flexDirection: 'column', minHeight: 0, position: 'relative' }}>
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
          <div style={{ ...t('titleL'), color: p.onSurface }}>Promo &amp; Voucher</div>
          <div style={{ ...t('bodyS'), color: p.onSurfaceVar, marginTop: 2 }}>
            {active.length} aktif &middot; {inactive.length} terjadwal/nonaktif
          </div>
        </div>
      </div>

      {/* Search */}
      <div style={{ padding: '4px 16px 0' }}>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          height: 44, padding: '0 14px',
          background: p.surfaceVariant, borderRadius: R.md,
        }}>
          <Icon name="search" size={16} color={p.onSurfaceVar}/>
          <div style={{ flex: 1, ...t('bodyM'), color: p.onSurfaceVar, fontSize: 13 }}>
            Cari nama atau kode promo...
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 90px' }}>
        {/* Live now banner */}
        <div style={{
          marginBottom: 12,
          padding: '10px 14px',
          background: p.primary, color: p.onPrimary,
          borderRadius: R.md,
          display: 'flex', alignItems: 'center', gap: 10,
          boxShadow: `0 6px 16px ${p.primary}33`,
        }}>
          <div style={{
            width: 6, height: 6, borderRadius: '50%', background: p.onPrimary,
            boxShadow: `0 0 0 4px ${p.onPrimary}22`,
            animation: 'pulsePR 1.4s ease-in-out infinite',
          }}/>
          <style>{`@keyframes pulsePR { 0%,100%{opacity:1} 50%{opacity:.4} }`}</style>
          <div style={{ flex: 1 }}>
            <div style={{ ...t('labelL'), fontSize: 12, fontWeight: 700 }}>Happy Hour Coffee aktif</div>
            <div style={{ ...t('bodyS'), opacity: 0.85, fontSize: 11, marginTop: 1 }}>
              20% off · sampai 17:00 hari ini
            </div>
          </div>
          <div style={{ ...t('labelL'), fontSize: 11, opacity: 0.9 }}>
            Pause &middot;
          </div>
        </div>

        <SectionLabelPR palette={p}>Aktif</SectionLabelPR>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {active.map(promo => <PromoManageRow key={promo.id} promo={promo} palette={p}/>)}
        </div>

        <SectionLabelPR palette={p}>Terjadwal / nonaktif</SectionLabelPR>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {inactive.map(promo => <PromoManageRow key={promo.id} promo={promo} palette={p} dim/>)}
        </div>
      </div>

      {/* FAB extended */}
      <div style={{
        position: 'absolute', right: 16, bottom: 20,
        height: 52, padding: '0 20px', borderRadius: R.lg,
        background: p.primary, color: p.onPrimary,
        display: 'flex', alignItems: 'center', gap: 8,
        boxShadow: `0 10px 24px ${p.primary}55`,
        ...t('labelL'), fontSize: 14, fontWeight: 700,
      }}>
        <Icon name="plus" size={18} strokeWidth={2.5}/>
        Buat Promo
      </div>
    </div>
  );
}

function PromoManageRow({ promo, palette, dim }) {
  const p = palette;
  const valueLabel = promo.type === 'percent' ? `${promo.value}%`
                  : promo.type === 'rp'      ? `Rp${(promo.value / 1000)}rb`
                  : 'B1G1';
  return (
    <div style={{
      padding: '12px 14px',
      background: '#FFF', borderRadius: R.md,
      border: `1px solid ${p.outlineSoft}`,
      display: 'flex', gap: 12, alignItems: 'center',
      opacity: dim ? 0.7 : 1,
    }}>
      <div style={{
        width: 48, height: 48, borderRadius: R.sm,
        background: dim ? p.surfaceVariant : p.primaryContainer,
        color: dim ? p.onSurfaceVar : p.primary,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        flexShrink: 0,
        ...t('titleM'), fontSize: 14, fontWeight: 800,
      }}>
        {valueLabel}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ ...t('bodyL'), color: p.onSurface, fontSize: 13, fontWeight: 700,
                        overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {promo.name}
          </div>
          {promo.badge === 'NOW' && (
            <div style={{
              padding: '2px 6px', borderRadius: R.pill,
              background: p.error, color: '#FFF',
              ...t('labelM'), fontSize: 9, fontWeight: 700, letterSpacing: 0.4,
            }}>LIVE</div>
          )}
          {promo.code && (
            <div style={{
              padding: '2px 6px', borderRadius: R.pill,
              background: p.surfaceVariant, color: p.onSurface,
              fontFamily: 'ui-monospace, monospace', fontSize: 10, fontWeight: 700,
            }}>{promo.code}</div>
          )}
        </div>
        <div style={{ ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 3 }}>
          {promo.appliesTo}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, ...t('bodyS'), color: p.onSurfaceVar, fontSize: 11, marginTop: 2 }}>
          <CalIconSmall/>
          {promo.schedule}
        </div>
      </div>
      {/* Switch */}
      <div style={{
        width: 36, height: 22, borderRadius: 11,
        background: promo.active ? p.primary : p.outline,
        position: 'relative', flexShrink: 0,
      }}>
        <div style={{
          position: 'absolute', top: 2, left: promo.active ? 16 : 2,
          width: 18, height: 18, borderRadius: '50%', background: '#FFF',
        }}/>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Bits
// ─────────────────────────────────────────────────────────────
function SectionLabelPR({ palette, children }) {
  const p = palette;
  return (
    <div style={{
      ...t('labelM'), fontSize: 11, color: p.onSurfaceVar,
      textTransform: 'uppercase', letterSpacing: 0.8,
      marginTop: 16, marginBottom: 8, paddingLeft: 2,
    }}>{children}</div>
  );
}

function PromoIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M20.6 13.4 13.4 20.6a1.4 1.4 0 0 1-2 0L3 12.2V3h9.2l8.4 8.4a1.4 1.4 0 0 1 0 2z"/>
      <circle cx="7.5" cy="7.5" r="1.5"/>
    </svg>
  );
}
function CalIconSmall() {
  return (
    <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
         stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="5" width="18" height="16" rx="2"/>
      <path d="M3 10h18M8 3v4M16 3v4"/>
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

Object.assign(window, { DiscountSheet, ManagePromoPage });
