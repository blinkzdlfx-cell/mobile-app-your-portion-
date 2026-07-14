---
name: Serene Covenant Admin
colors:
  surface: '#f7f9fd'
  surface-dim: '#d8dade'
  surface-bright: '#f7f9fd'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f8'
  surface-container: '#eceef2'
  surface-container-high: '#e6e8ec'
  surface-container-highest: '#e0e2e6'
  on-surface: '#191c1f'
  on-surface-variant: '#414844'
  inverse-surface: '#2d3134'
  inverse-on-surface: '#eff1f5'
  outline: '#717973'
  outline-variant: '#c1c8c2'
  surface-tint: '#3f6653'
  primary: '#012d1d'
  on-primary: '#ffffff'
  primary-container: '#1b4332'
  on-primary-container: '#86af99'
  inverse-primary: '#a5d0b9'
  secondary: '#006c48'
  on-secondary: '#ffffff'
  secondary-container: '#92f7c3'
  on-secondary-container: '#00734d'
  tertiary: '#152b1c'
  on-tertiary: '#ffffff'
  tertiary-container: '#2a4131'
  on-tertiary-container: '#93ad98'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c1ecd4'
  primary-fixed-dim: '#a5d0b9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#274e3d'
  secondary-fixed: '#92f7c3'
  secondary-fixed-dim: '#75daa8'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005235'
  tertiary-fixed: '#cee9d3'
  tertiary-fixed-dim: '#b3cdb7'
  on-tertiary-fixed: '#092012'
  on-tertiary-fixed-variant: '#354c3b'
  background: '#f7f9fd'
  on-background: '#191c1f'
  surface-variant: '#e0e2e6'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '600'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-mono:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  sidebar-width: 260px
  topbar-height: 72px
  container-max-width: 1440px
  gutter: 24px
  margin-desktop: 40px
  margin-mobile: 16px
---

## Brand & Style
The design system scales the "Serene Covenant" mobile experience into a premium, high-utility desktop environment. The brand personality is authoritative yet tranquil, characterized by a **Minimalist Corporate** aesthetic that prioritizes clarity and executive focus. 

The target audience consists of administrators and stakeholders who manage high-stakes data. The UI must evoke a sense of calm control through the strategic use of expansive whitespace, a disciplined color palette, and high-precision typography. The style avoids visual noise, opting for refined elevation and soft edges to humanize the data-heavy environment.

## Colors
The color strategy centers on a deep "Forest Green" primary accent to anchor the interface in stability and growth. 

- **Primary (#1b4332):** Reserved for high-priority actions, sidebar active states, and critical branding elements.
- **Secondary & Tertiary:** Used exclusively for data visualization and subtle status indicators to provide tonal depth without breaking the calm atmosphere.
- **Surface:** The background is a crisp absolute white to maximize the "breathability" of the high-density layout.
- **Borders (#E5E7EB):** A consistent light gray is used for structural definition, ensuring UI elements are organized without creating visual "clutter."

## Typography
This design system utilizes **Inter** exclusively to ensure maximum legibility across complex data tables and dashboards. 

The hierarchy is structured to guide the eye from macro-level insights (Display) to micro-level data points (Data-Mono). For data-heavy screens, use `body-md` as the standard for table cells and `label-sm` in all-caps for column headers to create a professional, "ledger-like" appearance. Tight letter spacing is applied to larger headlines to maintain a modern, premium feel.

## Layout & Spacing
The system employs a **Fluid Grid** with fixed structural components. 

- **Sidebar:** A fixed 260px vertical navigation bar anchors the left side.
- **Main Canvas:** A flexible area with a 40px margin that ensures content never feels cramped against the sidebar or screen edges.
- **Rhythm:** An 8px base grid governs all padding and margins. Dashboard cards should use 24px internal padding (`gutter`) to maintain the "Serene" aspect of the brand.
- **Responsiveness:** On tablet/mobile, the sidebar collapses into a hamburger menu or bottom navigation, and margins reduce to 16px to maximize screen real estate.

## Elevation & Depth
Elevation is handled through **Ambient Shadows** and **Tonal Layering** rather than heavy borders.

- **Level 0 (Surface):** The main background (#FFFFFF).
- **Level 1 (Cards):** Uses a very soft, highly diffused shadow (e.g., `0px 4px 20px rgba(0, 0, 0, 0.05)`) to lift content without creating harsh contrast.
- **Level 2 (Dropdowns/Modals):** A slightly more pronounced shadow with a subtle #1b4332 tint (2% opacity) to provide depth while remaining on-brand.
- **Structural Separation:** The sidebar and topbar are separated from the main canvas by the `#E5E7EB` border rather than shadows, maintaining a clean, architectural look.

## Shapes
The design system adopts a **Rounded** shape language to soften the corporate nature of the dashboard. 

Standard components (inputs, buttons) utilize a 0.5rem (8px) radius. Dashboard cards and primary containers use a more generous `rounded-xl` (20px) radius to create a distinct, high-end feel. This contrast between "precise" functional elements and "soft" containers creates a modern, sophisticated balance.

## Components

### Sidebar & Navigation
The sidebar is minimalist. Icons should be 24px, linear (2px stroke), using the primary green for active states. Text labels are `label-md`. The top navigation bar contains a global search with a subtle background fill and the admin profile with a 32px circular avatar.

### Data Tables
Tables are high-contrast with #FFFFFF backgrounds. 
- **Headers:** `label-sm`, uppercase, gray text, with a bottom border of 1px `#E5E7EB`.
- **Rows:** 56px minimum height. Hover states should use a very faint green tint (#f0fdf4) rather than gray.
- **Actions:** Subtle 3-dot vertical icons or "ghost" buttons to keep the focus on the data.

### Rounded Cards
Every dashboard module sits in a card. Use a 20px corner radius and 24px internal padding. Title the cards using `headline-sm`. 

### Charts & Visualization
Charts utilize a palette of Primary Green (#1b4332), Mint (#52b788), and a soft Sage (#d8f3dc). Lines should be 3px thick with smoothed (bezier) curves to match the rounded shape language of the UI.

### Buttons
- **Primary:** Solid #1b4332 with white text.
- **Secondary:** White background with #E5E7EB border and #1b4332 text.
- **Tertiary/Ghost:** No border or background, used for low-priority actions in tables.