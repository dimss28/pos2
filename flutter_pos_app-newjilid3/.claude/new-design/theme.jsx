// Design tokens for POS redesign.
// Three palettes, swappable via Tweaks. Quicksand font throughout.

const PALETTES = {
  espresso: {
    name: 'Espresso',
    primary: '#5C3A21',          // deep coffee bean
    primaryDark: '#3E2613',
    onPrimary: '#FFFFFF',
    primaryContainer: '#F1E4D4', // cream foam
    onPrimaryContainer: '#3E2613',
    secondary: '#2A1F14',
    surface: '#FAF5EE',          // latte cream
    surfaceVariant: '#ECE0D0',
    surfaceDim: '#D9CAB6',
    outline: '#C8B89E',
    outlineSoft: '#E8DCC8',
    onSurface: '#2A1F14',
    onSurfaceVar: '#6B5C4A',
    success: '#5A7A3A',
    successContainer: '#E3EFD0',
    warning: '#B87A1E',
    warningContainer: '#F8E6C2',
    error: '#A8392E',
    errorContainer: '#F5D7D3',
  },
  caramel: {
    name: 'Caramel Latte',
    primary: '#B8743D',          // caramel
    primaryDark: '#8A5527',
    onPrimary: '#FFFFFF',
    primaryContainer: '#F8E6D0',
    onPrimaryContainer: '#4A2810',
    secondary: '#1F1812',
    surface: '#FBF6EE',          // foam
    surfaceVariant: '#EFE4D2',
    surfaceDim: '#DECDB2',
    outline: '#C9B59A',
    outlineSoft: '#EBDFCB',
    onSurface: '#241B12',
    onSurfaceVar: '#6E5E48',
    success: '#5A7A3A',
    successContainer: '#E3EFD0',
    warning: '#B87A1E',
    warningContainer: '#F8E6C2',
    error: '#A8392E',
    errorContainer: '#F5D7D3',
  },
  matcha: {
    name: 'Matcha',
    primary: '#6B8E3D',          // earthy matcha
    primaryDark: '#4F6B2A',
    onPrimary: '#FFFFFF',
    primaryContainer: '#E4ECCD',
    onPrimaryContainer: '#2A3815',
    secondary: '#1B2014',
    surface: '#F8FAF0',          // pale cream-green
    surfaceVariant: '#E8ECD8',
    surfaceDim: '#D2D9BD',
    outline: '#BAC3A0',
    outlineSoft: '#E2E8CF',
    onSurface: '#1C2114',
    onSurfaceVar: '#5E6650',
    success: '#5A7A3A',
    successContainer: '#E4ECCD',
    warning: '#B87A1E',
    warningContainer: '#F8E6C2',
    error: '#A8392E',
    errorContainer: '#F5D7D3',
  },
};

// Spacing — 4pt grid
const SP = { 1: 4, 2: 8, 3: 12, 4: 16, 5: 20, 6: 24, 8: 32, 10: 40, 12: 48 };

// Radius
const R = { xs: 6, sm: 10, md: 14, lg: 20, xl: 28, pill: 999 };

// Type — Quicksand scale (Material 3-ish)
const TYPE = {
  family: "'Quicksand', system-ui, sans-serif",
  displayL:  { size: 32, weight: 700, lh: '40px', track: '-0.5px' },
  displayM:  { size: 26, weight: 700, lh: '32px', track: '-0.3px' },
  titleL:    { size: 22, weight: 700, lh: '28px', track: '-0.2px' },
  titleM:    { size: 18, weight: 600, lh: '24px' },
  titleS:    { size: 15, weight: 600, lh: '20px' },
  bodyL:     { size: 16, weight: 500, lh: '24px' },
  bodyM:     { size: 14, weight: 500, lh: '20px' },
  bodyS:     { size: 12, weight: 500, lh: '16px' },
  labelL:    { size: 14, weight: 600, lh: '18px', track: '0.1px' },
  labelM:    { size: 12, weight: 600, lh: '16px', track: '0.3px' },
  priceL:    { size: 22, weight: 700, lh: '26px', track: '-0.2px' },
  priceM:    { size: 17, weight: 700, lh: '22px' },
};

// Formatters
const rupiah = (n) => 'Rp' + n.toLocaleString('id-ID');

// Helper to apply type
const t = (token) => {
  const v = TYPE[token];
  if (!v) return {};
  return {
    fontFamily: TYPE.family,
    fontSize: v.size,
    fontWeight: v.weight,
    lineHeight: v.lh,
    letterSpacing: v.track || 'normal',
  };
};

Object.assign(window, { PALETTES, SP, R, TYPE, t, rupiah });
