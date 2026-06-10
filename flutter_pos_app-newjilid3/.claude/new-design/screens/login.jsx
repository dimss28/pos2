// LOGIN SCREEN VARIATIONS
// Three takes on login for the POS app. All assume Android phone frame.
// Variation A — Classic centered form, brand mark at top
// Variation B — Hero color block top, white sheet rises with form
// Variation C — Minimal wordmark, airy form with big affordances

const PRODUCT_NAME = 'POS Batch 11';
const TAGLINE = 'Login to your account';
const BRAND_TAG = 'by Code with Bahri';

// ─────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────
function BrandMark({ color, size = 56, accent }) {
  // Coffee cup mark — abstract, original, cafe-fitting
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.32,
      background: color, color: accent || '#FFF',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: `0 8px 20px ${color}33`,
    }}>
      <svg width={size * 0.6} height={size * 0.6} viewBox="0 0 24 24" fill="none">
        {/* steam */}
        <path d="M9 2c-.5 1 .5 1.5 0 2.5s.5 1.5 0 2.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
        <path d="M13 2c-.5 1 .5 1.5 0 2.5s.5 1.5 0 2.5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"/>
        {/* cup */}
        <path d="M4 10h13v6a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5v-6z" stroke="currentColor" strokeWidth="2" strokeLinejoin="round"/>
        {/* handle */}
        <path d="M17 12h2a2.5 2.5 0 0 1 0 5h-2" stroke="currentColor" strokeWidth="2" strokeLinecap="round"/>
      </svg>
    </div>
  );
}

function TextField({ icon, placeholder, value, type = 'text', trailing, palette, focused, autofill }) {
  const p = palette;
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 12,
      height: 56, padding: '0 16px',
      borderRadius: R.md,
      background: '#FFF',
      border: `1.5px solid ${focused ? p.primary : p.outline}`,
      boxShadow: focused ? `0 0 0 4px ${p.primary}1A` : 'none',
      transition: 'all .15s',
    }}>
      {icon && <Icon name={icon} size={20} color={focused ? p.primary : p.onSurfaceVar} strokeWidth={2}/>}
      <div style={{ flex: 1, minWidth: 0, ...t('bodyL'), color: value ? p.onSurface : p.onSurfaceVar }}>
        {value ? (type === 'password' ? '•'.repeat(value.length) : value) : placeholder}
      </div>
      {trailing}
    </div>
  );
}

function PrimaryButton({ label, palette, loading, fullWidth = true, leading, style }) {
  const p = palette;
  return (
    <div style={{
      height: 56, borderRadius: R.md,
      background: p.primary, color: p.onPrimary,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10,
      ...t('labelL'), fontSize: 16, fontWeight: 700,
      width: fullWidth ? '100%' : 'auto',
      boxShadow: `0 6px 16px ${p.primary}40`,
      ...style,
    }}>
      {loading ? (
        <div style={{
          width: 20, height: 20, borderRadius: '50%',
          border: `2.5px solid ${p.onPrimary}55`, borderTopColor: p.onPrimary,
        }}/>
      ) : (
        <>
          {leading}
          {label}
        </>
      )}
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation A — Classic
// ─────────────────────────────────────────────────────────────
function LoginA({ palette }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, background: p.surface, padding: '40px 24px 24px',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* brand */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14, marginTop: 32 }}>
        <BrandMark color={p.primary} size={76}/>
        <div style={{
          ...t('labelM'), color: p.primary, fontWeight: 700,
          letterSpacing: '1.5px', textTransform: 'uppercase',
        }}>{BRAND_TAG}</div>
      </div>

      {/* title block */}
      <div style={{ textAlign: 'center', marginTop: 28 }}>
        <div style={{ ...t('displayM'), color: p.onSurface, fontSize: 28 }}>{PRODUCT_NAME}</div>
        <div style={{ ...t('bodyM'), color: p.onSurfaceVar, marginTop: 6 }}>{TAGLINE}</div>
      </div>

      {/* form */}
      <div style={{ marginTop: 36, display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div>
          <div style={{ ...t('titleS'), color: p.onSurface, marginBottom: 10, paddingLeft: 2 }}>Email</div>
          <TextField icon="mail" placeholder="kasir@cafe.id" value="kasir@cafe.id" palette={p} focused/>
        </div>
        <div>
          <div style={{ ...t('titleS'), color: p.onSurface, marginBottom: 10, paddingLeft: 2 }}>Password</div>
          <TextField
            icon="lock" type="password" placeholder="Password" value="rahasia123" palette={p}
            trailing={<Icon name="eye-off" size={20} color={p.onSurfaceVar}/>}
          />
        </div>
        <div style={{ alignSelf: 'flex-end', ...t('labelL'), color: p.primary }}>
          Lupa password?
        </div>
      </div>

      {/* button + footer */}
      <div style={{ marginTop: 28 }}>
        <PrimaryButton label="Login" palette={p}/>
      </div>

      <div style={{ flex: 1 }}/>
      <div style={{ textAlign: 'center', ...t('bodyS'), color: p.onSurfaceVar }}>
        v1.4.2 · build 220
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation B — Hero block + sheet
// ─────────────────────────────────────────────────────────────
function LoginB({ palette }) {
  const p = palette;
  return (
    <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: p.primary }}>
      {/* hero band */}
      <div style={{
        padding: '40px 28px 60px', color: p.onPrimary, position: 'relative', overflow: 'hidden',
      }}>
        {/* decorative blob */}
        <div style={{
          position: 'absolute', right: -40, top: -40, width: 200, height: 200,
          borderRadius: '50%', background: `${p.onPrimary}14`,
        }}/>
        <div style={{
          position: 'absolute', right: 40, bottom: -50, width: 120, height: 120,
          borderRadius: '50%', background: `${p.onPrimary}10`,
        }}/>
        <BrandMark color={`${p.onPrimary}22`} accent={p.onPrimary} size={52}/>
        <div style={{ ...t('displayM'), marginTop: 20 }}>Selamat datang<br/>kembali.</div>
        <div style={{ ...t('bodyM'), opacity: 0.85, marginTop: 8 }}>
          Masuk ke {PRODUCT_NAME} untuk lanjutkan kasir kamu.
        </div>
      </div>

      {/* white sheet */}
      <div style={{
        flex: 1, background: p.surface,
        borderTopLeftRadius: 32, borderTopRightRadius: 32,
        padding: '32px 24px 24px', marginTop: -28,
        display: 'flex', flexDirection: 'column', gap: 14,
        boxShadow: '0 -8px 24px rgba(0,0,0,0.06)',
      }}>
        <div style={{ ...t('titleM'), color: p.onSurface }}>Masuk Akun</div>

        <TextField icon="mail" placeholder="Email kamu" value="kasir@warungbu.id" palette={p}/>
        <TextField
          icon="lock" type="password" value="rahasia123" palette={p} focused
          trailing={<Icon name="eye" size={20} color={p.primary}/>}
        />

        {/* remember + forgot row */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 2 }}>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <div style={{
              width: 20, height: 20, borderRadius: 6, background: p.primary,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <Icon name="check" size={14} color={p.onPrimary} strokeWidth={3}/>
            </div>
            <span style={{ ...t('bodyM'), color: p.onSurface }}>Ingat saya</span>
          </div>
          <span style={{ ...t('labelL'), color: p.primary }}>Lupa password?</span>
        </div>

        <div style={{ flex: 1 }}/>

        <PrimaryButton label="Masuk Sekarang" palette={p}/>
        <div style={{ textAlign: 'center', ...t('bodyS'), color: p.onSurfaceVar }}>
          Belum punya akun? <span style={{ color: p.primary, fontWeight: 700 }}>Hubungi admin</span>
        </div>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// Variation C — Minimal / Airy
// ─────────────────────────────────────────────────────────────
function LoginC({ palette }) {
  const p = palette;
  return (
    <div style={{
      flex: 1, background: p.surface, padding: '24px 24px 24px',
      display: 'flex', flexDirection: 'column',
    }}>
      {/* tiny brand row */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, paddingTop: 16 }}>
        <BrandMark color={p.primary} size={36}/>
        <div style={{ ...t('titleS'), color: p.onSurface }}>{PRODUCT_NAME}</div>
      </div>

      {/* big headline */}
      <div style={{ marginTop: 56 }}>
        <div style={{ ...t('displayL'), color: p.onSurface, fontSize: 36, lineHeight: '42px' }}>
          Hai, siap<br/>
          jualan<br/>
          <span style={{ color: p.primary }}>hari ini?</span>
        </div>
      </div>

      {/* form, label-on-border style */}
      <div style={{ marginTop: 36, display: 'flex', flexDirection: 'column', gap: 18 }}>
        <FloatingField label="Email" value="kasir@warungbu.id" palette={p}/>
        <FloatingField
          label="Password" value="rahasia123" type="password" palette={p} focused
          trailing={<span style={{ ...t('labelL'), color: p.primary }}>Lihat</span>}
        />
      </div>

      <div style={{ flex: 1 }}/>

      {/* footer button + hints */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between' }}>
          <span style={{ ...t('bodyS'), color: p.onSurfaceVar }}>v1.4.2</span>
          <span style={{ ...t('labelL'), color: p.onSurface }}>Lupa password?</span>
        </div>
        <div style={{
          display: 'flex', height: 60, borderRadius: R.lg, overflow: 'hidden',
          background: p.primary, alignItems: 'center',
          padding: '0 6px 0 24px',
          boxShadow: `0 10px 24px ${p.primary}44`,
        }}>
          <span style={{ flex: 1, color: p.onPrimary, ...t('titleM'), fontWeight: 700 }}>Masuk</span>
          <div style={{
            width: 48, height: 48, borderRadius: R.md,
            background: `${p.onPrimary}22`, color: p.onPrimary,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <Icon name="arrow-right" size={22}/>
          </div>
        </div>
      </div>
    </div>
  );
}

function FloatingField({ label, value, type, palette, focused, trailing }) {
  const p = palette;
  return (
    <div style={{
      position: 'relative', borderBottom: `2px solid ${focused ? p.primary : p.outline}`,
      paddingTop: 18, paddingBottom: 10,
      display: 'flex', alignItems: 'flex-end', gap: 10,
    }}>
      <div style={{
        position: 'absolute', top: 0, left: 0,
        ...t('labelM'), color: focused ? p.primary : p.onSurfaceVar,
      }}>{label}</div>
      <div style={{ flex: 1, ...t('bodyL'), fontSize: 18, color: p.onSurface }}>
        {type === 'password' ? '•'.repeat(value.length) : value}
      </div>
      {trailing}
    </div>
  );
}

Object.assign(window, { LoginA, LoginB, LoginC });
