---
name: Serene Covenant
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0edec'
  surface-container-high: '#ebe7e7'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#414844'
  inverse-surface: '#313030'
  inverse-on-surface: '#f3f0ef'
  outline: '#717973'
  outline-variant: '#c1c8c2'
  surface-tint: '#3f6653'
  primary: '#012d1d'
  on-primary: '#ffffff'
  primary-container: '#1b4332'
  on-primary-container: '#86af99'
  inverse-primary: '#a5d0b9'
  secondary: '#57615c'
  on-secondary: '#ffffff'
  secondary-container: '#d8e2dc'
  on-secondary-container: '#5b6560'
  tertiary: '#162b1a'
  on-tertiary: '#ffffff'
  tertiary-container: '#2c412e'
  on-tertiary-container: '#95ad95'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c1ecd4'
  primary-fixed-dim: '#a5d0b9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#274e3d'
  secondary-fixed: '#dbe5df'
  secondary-fixed-dim: '#bfc9c3'
  on-secondary-fixed: '#151d1a'
  on-secondary-fixed-variant: '#3f4945'
  tertiary-fixed: '#d0e9cf'
  tertiary-fixed-dim: '#b4cdb4'
  on-tertiary-fixed: '#0b2010'
  on-tertiary-fixed-variant: '#364c39'
  background: '#fcf9f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '600'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding-mobile: 20px
  container-padding-desktop: 40px
  gutter: 16px
  stack-sm: 8px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style

The design system is rooted in the concept of "Quiet Devotion." It targets a modern, faith-oriented audience seeking a sanctuary within their digital environment. The aesthetic is heavily influenced by **Premium Minimalism**, focusing on clarity, breathing room, and high-quality finishes that mirror the peacefulness of spiritual reflection.

The emotional response should be one of immediate calm and professional trust. By stripping away non-essential decorations and focusing on refined typography and organic spacing, the UI becomes a transparent vessel for scripture and community. It avoids "churchy" cliches in favor of an editorial, Apple-inspired sophistication—feeling both timeless and contemporary.

## Colors

The palette is anchored by **Deep Forest Green**, a color representing growth, life, and stability. This primary tone is used sparingly for key actions and branding moments to maintain a premium feel. 

The background is a strictly **Pure White**, ensuring the highest level of legibility and a sense of "infinite space." For depth and secondary surfaces, we utilize **Sage Green** and **Soft Grey** to provide gentle contrast without breaking the monochromatic peace. Text is rendered in **Deep Charcoal**, which is softer on the eyes than pure black while maintaining an authoritative presence.

## Typography

The typography uses **Inter** for its systematic precision and neutral elegance. To achieve a premium feel, the design system employs generous tracking (letter spacing) on labels and body text, creating a sense of "air" between characters.

Hierarchy is strictly enforced. Display sizes are bold and tight to create a focal point for daily verses, while body text remains legible and spacious for long-form reading. Labels use an uppercase treatment with increased tracking to differentiate them from interactive elements.

## Layout & Spacing

This design system utilizes a **Fluid Grid** with fixed maximum widths for desktop to ensure content remains digestible. The spacing rhythm is based on an 8px baseline, but the "emotional" spacing is defined by larger gaps (stack-lg) between distinct content sections to prevent visual clutter.

- **Mobile:** 4-column grid with 20px margins.
- **Tablet:** 8-column grid with 32px margins.
- **Desktop:** 12-column grid with 40px margins and a 1200px max-width container.

Use negative space aggressively. Content should never feel "trapped" or crowded; if in doubt, increase the padding.

## Elevation & Depth

Depth is conveyed through **Tonal Layering** and **Ambient Shadows**. We avoid heavy dropshadows in favor of very soft, diffused blurs that suggest a surface is lightly floating.

1.  **Level 0 (Background):** Pure White (#FFFFFF).
2.  **Level 1 (Cards/Surfaces):** A subtle border (1px solid #F2F2F2) or a very light Sage Green tint (#F8FAF9).
3.  **Level 2 (Active Elements):** An ambient shadow: `0px 10px 30px rgba(0, 0, 0, 0.04)`.

This creates a "pillowy" effect where the UI feels soft and approachable rather than rigid and technical.

## Shapes

The shape language is defined by **High Roundedness**. All primary containers, buttons, and input fields use a consistent corner radius to evoke a feeling of friendliness and safety.

- **Small elements (Buttons/Inputs):** 12px (rounded-lg)
- **Large elements (Cards/Modals):** 24px (rounded-xl)
- **Selection indicators:** Fully pill-shaped.

Avoid sharp corners entirely; even the smallest decorative elements should have at least a 4px radius.

## Components

### Buttons
Primary buttons use the Deep Modern Green (#1B4332) with white text. They are tall (min-height: 56px) with 12px rounded corners. Secondary buttons use a Sage Green tint with Dark Charcoal text and no border.

### Cards
Cards are the primary container for scripture and daily "portions." They should feature a 1px soft grey border and generous internal padding (min 24px). For featured content, use a subtle ambient shadow to elevate the card from the white background.

### Input Fields
Inputs are minimal: a soft grey background (#F5F5F5) with no border until focused. Upon focus, the border transitions to a 1.5px Deep Green stroke.

### Lists
List items are separated by generous whitespace rather than divider lines. If a divider is necessary, it must be 1px wide and colored in a very light grey (#F2F2F2), stopping 20px before the edges of the screen.

### Navigation
The bottom navigation bar uses a subtle glassmorphism effect (backdrop blur: 20px) with a semi-transparent white background, allowing content to peek through as the user scrolls, creating a sense of depth and continuity.