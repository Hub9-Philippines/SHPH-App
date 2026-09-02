# DESIGN.md — SerbisyoHub PH Visual Engine
## Stack: Next.js + Tailwind CSS v4 + React Three Fiber + GSAP

This file outlines the source of truth for the platform's cross-layer design tokens. AI agents must strictly implement these exact structures for light mode, dark mode, 3D WebGL scenes, and lifecycle animations to maintain feature parity.

---

## 1. Global Visual Theme & Color Space
*   **Parity Target:** Matches Vue 3 + Ionic custom web styles (`--shph-*`).
*   **Tailwind v4 Configuration:** Tokens are declared as CSS-first variables using the `@theme` directive.
*   **3D Space Mapping:** R3F elements translate hex strings via standard hex interpretation (`new THREE.Color('#1E3A8A')`).

### Base Theme Configuration (Tailwind v4 `@theme`)
Drop this theme declaration block into your `global.css` file:

```css
@import "tailwindcss";

@theme {
  /* Light Mode Defaults (:root / default fallback) */
  --color-primary: #1E3A8A;
  --color-on-primary: #FFFFFF;
  --color-secondary: #39D2C0;
  --color-tertiary: #EE8B60;
  --color-alternate: #E0E3E7;
  --color-primary-text: #0F172A;
  --color-secondary-text: #64748B;
  --color-text-tertiary: #94A3B8;
  --color-primary-background: #FFFFFF;
  --color-secondary-background: #F7F7F7;
  --color-bg-page: #F8FAFC;
  --color-surface-alt: #F1F5F9;
  --color-border: #E2E8F0;
  
  /* Additional Structural Sub-Tokens */
  --color-icon-background: #D4F0EF;
  --color-primary-light: #D4F0EF;
  --color-primary-dark: #49B8C4;
  --color-primary-brand-text: #0D6D78;

  /* Global Semantics & Action Modifiers */
  --color-success: #0D808A; /* successTeal usage */
  --color-warning: #F59E0B; /* Amber marker */
  --color-error: #DC2626;   /* Hard validation state */
  --color-action-primary: #1E3A8A;
  --color-destructive-soft: #EF4444; /* Separate from validation error */

  /* Layout Radii Scales */
  --radius-sm: 10px;
  --radius-md: 14px;
  --radius-lg: 16px;
  --radius-card: 24px;
  --radius-pill: 9999px;

  /* Spacing Rhythm Scales */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 12px;
  --spacing-lg: 16px;
  --spacing-xl: 24px;
}

/* Dark Mode Variable Overrides */
@media (prefers-color-scheme: dark) {
  :root {
    --color-primary-text: #FFFFFF;
    --color-secondary-text: #95A1AC;
    --color-primary-background: #1D2428;
    --color-secondary-background: #14181B;
    --color-bg-page: #0F172A;
    --color-border: #3A3A4E;
    --color-surface-alt: #2A2A3C;
    --color-text-tertiary: #94A3B8;
  }
}
```

---

## 2. Dynamic Status Mapping (State & Canvas Fill)
Dynamic components must derive color styling programmatically from the active state context instead of using hardcoded tailwind modifiers:

*   **`confirmed`** $\rightarrow$ Text: `#0D6D78` | Bg: `#D4F0EF`
*   **`en_route` / `arrived` / `in_progress` / `on_site`** $\rightarrow$ Text: `#166534` | Bg: `#E7F6EC`
*   **`completed`** $\rightarrow$ Text: `#475569` | Bg: `#EEF1F5`
*   **`cancelled` / `disputed`** $\rightarrow$ Text: `#B91C1C` | Bg: `#FDE9E9`
*   **`pending` / `inquiry` / `searching`** $\rightarrow$ Text: `#92400E` | Bg: `#FDF0DD`
*   **`default` (Fallback)** $\rightarrow$ Text: `#475569` | Bg: `#EEF1F5`

---

## 3. Web Page Layout Structure & Rules
*   **Typography:** The single canonical font is **Plus Jakarta Sans**. *Poppins is strictly banned across all layers.* Use Monospace layout aesthetics tracking metadata via standard monospaced utility strings.
*   **Container Width constraints:** 
    *   Narrow layouts: `560px`
    *   Readable column text blocks: `760px`
    *   Wide desktop rows: `1100px`
    *   Dashboard wrap limits: `1200px`
*   **Grid System Rule:** Standard layout elements use 16px horizontal container margins (`p-lg` / `px-4`), with a layout space of 24px (`py-xl` / `gap-6`) applied explicitly between standalone content blocks.

---

## 4. 3D React Three Fiber (R3F) Integration
*   **Theming Unification:** Materials and lighting systems use the dynamic variables mapped in Section 1. Ambient lighting uses an intensity scalar of `0.4` with color `#C5C6C7`. Highlight spots use an intensity of `1.2` with `--color-primary` (`#1E3A8A`) to cast dynamic shadows.
*   **Layer Ordering:** Canvas instances remain absolute structural backdrops (`fixed inset-0 pointer-events-none z-0`). Foreground interactive cards utilize `relative z-10 pointer-events-auto` to handle focus loops.

---

## 5. GSAP Motion & Component Lifecycle
*   **Clean Transitions:** Mount interactive canvas steps or view changes utilizing `useLayoutEffect` hooks. Ensure every GSAP animation sequence initializes an active context tracker and runs `ctx.revert()` cleanly on layout unmount to block memory leaks.
*   **Motion Quality curves:** Standard clickable items use responsive UI curves (`power2.out`). 3D camera shifts or screen layout expansions use slower easing signatures (`power4.inOut`).
