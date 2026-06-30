# Design System Master File

> **LOGIC:** When building a specific page, first check `design-system/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** Control Inteligente de Parqueaderos
**Generated:** 2026-06-30
**Category:** Mobile App (Flutter) — Parking / Location Service
**Platform:** Flutter + Material 3 (`useMaterial3: true`). This is a NATIVE MOBILE APP, not a website. Ignore any web/landing-page patterns below.

---

## Global Rules

### Color Palette

| Role | Hex | Flutter ColorScheme role |
|------|-----|--------------------------|
| Primary | `#0F766E` | `primary` (teal de confianza) |
| Secondary | `#14B8A6` | `secondary` (teal claro) |
| CTA/Accent | `#0369A1` | `tertiary` / botón de acción (azul) |
| Background | `#F0FDFA` | `surface` / `background` |
| Text | `#134E4A` | `onSurface` / `onBackground` |

**Color Notes:** Trust Teal + azul de acción. Paleta elegida por el usuario (2026-06-30). Maneja pagos y ubicación → debe transmitir confianza.

### Typography

- **Heading Font:** Outfit
- **Body Font:** Work Sans
- **Mood:** geometric, modern, clean, trustworthy, contemporary
- **Google Fonts:** [Outfit + Work Sans](https://fonts.google.com/share?selection.family=Outfit:wght@300;400;500;600;700|Work+Sans:wght@300;400;500;600;700)

**Flutter (google_fonts):**
```dart
textTheme: GoogleFonts.workSansTextTheme().copyWith(
  displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700),
  headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
  titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
),
```

### Spacing Variables

| Token | Value | Usage |
|-------|-------|-------|
| `--space-xs` | `4px` / `0.25rem` | Tight gaps |
| `--space-sm` | `8px` / `0.5rem` | Icon gaps, inline spacing |
| `--space-md` | `16px` / `1rem` | Standard padding |
| `--space-lg` | `24px` / `1.5rem` | Section padding |
| `--space-xl` | `32px` / `2rem` | Large gaps |
| `--space-2xl` | `48px` / `3rem` | Section margins |
| `--space-3xl` | `64px` / `4rem` | Hero padding |

### Shadow Depths

| Level | Value | Usage |
|-------|-------|-------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle lift |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, buttons |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, dropdowns |
| `--shadow-xl` | `0 20px 25px rgba(0,0,0,0.15)` | Hero images, featured cards |

---

## Component Specs

### Buttons

```css
/* Primary Button */
.btn-primary {
  background: #0369A1;
  color: white;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}

.btn-primary:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

/* Secondary Button */
.btn-secondary {
  background: transparent;
  color: #0F172A;
  border: 2px solid #0F172A;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 200ms ease;
  cursor: pointer;
}
```

### Cards

```css
.card {
  background: #F8FAFC;
  border-radius: 12px;
  padding: 24px;
  box-shadow: var(--shadow-md);
  transition: all 200ms ease;
  cursor: pointer;
}

.card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}
```

### Inputs

```css
.input {
  padding: 12px 16px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 16px;
  transition: border-color 200ms ease;
}

.input:focus {
  border-color: #0F172A;
  outline: none;
  box-shadow: 0 0 0 3px #0F172A20;
}
```

### Modals

```css
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
}

.modal {
  background: white;
  border-radius: 16px;
  padding: 32px;
  box-shadow: var(--shadow-xl);
  max-width: 500px;
  width: 90%;
}
```

---

## Style Guidelines

**Style:** Flat Design sobre Material 3 + tarjetas tipo *bento* (esquinas 16–24px).

**Keywords:** clean, 2D, limited palette, icon-led, card-based hierarchy, soft surfaces, WCAG AA/AAA, mobile-first.

**Best For:** Apps móviles cross-platform, dashboards, paneles administrativos.

**Key Effects:** Micro-interacciones 150–300ms (color/opacity), elevación sutil al tocar tarjetas, skeleton/spinner en estados de carga, SIN layout shift.

### App Pattern (mobile, NOT a landing page)

- **Navegación:** GoRouter con `redirect` según sesión/rol. Bottom nav o Drawer para secciones principales.
- **Pantallas:** Auth → Home(Maps) → Detalle parqueadero → Reserva → Pago → Check-in/out (QR) → Historial → Perfil → Panel Admin.
- **Tarjetas:** parqueaderos y espacios como cards bento con estado por color (libre/ocupado/reservado).
- **Botones de acción:** color CTA azul (`#0369A1`), `minimumSize` 48px de alto (touch target ≥44px).

---

## Anti-Patterns (Do NOT Use)

- ❌ Generic content
- ❌ No credentials
- ❌ AI purple/pink gradients

### Additional Forbidden Patterns

- ❌ **Emojis as icons** — Use SVG icons (Heroicons, Lucide, Simple Icons)
- ❌ **Missing cursor:pointer** — All clickable elements must have cursor:pointer
- ❌ **Layout-shifting hovers** — Avoid scale transforms that shift layout
- ❌ **Low contrast text** — Maintain 4.5:1 minimum contrast ratio
- ❌ **Instant state changes** — Always use transitions (150-300ms)
- ❌ **Invisible focus states** — Focus states must be visible for a11y

---

## Pre-Delivery Checklist

Before delivering any UI code, verify:

- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons from consistent icon set (Heroicons/Lucide)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard navigation
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px
- [ ] No content hidden behind fixed navbars
- [ ] No horizontal scroll on mobile
