---
name: galiprandi.me
description: Editorial resume and portfolio for Germán A. Aliprandi — austere, typographic, print-first.
colors:
  ink: "light-dark(#000, #fff)"
  muted-ink: "light-dark(#616161, #abb0c2)"
  paper: "light-dark(#fff, #16181c)"
  paper-pill: "light-dark(#e7e7e7, #353535)"
  paper-tint: "light-dark(#f5f5f5, #1f2229)"
  accent-blue: "#0055FF"
  warn-amber: "#ffa000"
  warn-amber-bg: "#fff8e1"
  dialog-veil: "rgb(189 189 189 / 0.6)"
typography:
  display:
    fontFamily: '"Montserrat Variable", sans-serif'
    fontSize: "2.3rem"
    fontWeight: 400
    lineHeight: 1.1
    letterSpacing: "normal"
  headline:
    fontFamily: '"Montserrat Variable", sans-serif'
    fontSize: "1.6rem"
    fontWeight: 400
    lineHeight: 1.2
  title:
    fontFamily: '"Montserrat Variable", sans-serif'
    fontSize: "1.15rem"
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: '"Montserrat Variable", sans-serif'
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: '"Montserrat Variable", sans-serif'
    fontSize: "0.9em"
    fontWeight: 400
    letterSpacing: "normal"
  mono:
    fontFamily: "Menlo, Monaco, Lucida Console, Liberation Mono, DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace"
    fontSize: "0.9em"
    fontWeight: 400
rounded:
  none: "0"
  xs: "3px"
  sm: "6px"
  md: "8px"
  lg: "0.5rem"
  xl: "1rem"
  pill: "999px"
  circle: "20%"
spacing:
  xs: "0.5em"
  sm: "1em"
  md: "1.3em"
  lg: "2em"
  xl: "3em"
  page-x: "3em"
  page-bottom: "4em"
components:
  link-inline:
    textColor: "{colors.ink}"
    padding: "0"
  link-muted:
    textColor: "{colors.muted-ink}"
    padding: "0"
  pill:
    backgroundColor: "{colors.paper-pill}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    padding: "0.2em 0.6em"
  blockquote:
    backgroundColor: "{colors.paper-tint}"
    textColor: "{colors.muted-ink}"
    rounded: "0 8px 0 0"
    padding: "1em 1.5em"
  timeline-item:
    textColor: "{colors.muted-ink}"
    padding: "0 0 0 1.5em"
  tldr-trigger:
    backgroundColor: "transparent"
    textColor: "{colors.muted-ink}"
    padding: "0"
  tldr-dialog:
    backgroundColor: "{colors.paper-pill}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "2em"
---

# Design System: galiprandi.me

## Overview

**Creative North Star: "The Editorial Resume"**

This is a resume that grew up. It treats the page as a printed document first and a web page second — wide margins, generous whitespace, a single typographic family carrying every role, and an austere monochrome palette where the absence of color is the design statement. The sidebar (aside) is the marginalia of an editorial spread: contact, skills, certificates, the quiet supporting cast. The main column is the article itself: experience, narrative, evidence.

The system supports light and dark modes natively via `light-dark()`, but neither mode introduces color for branding. Dark mode is a tonal inversion, not a chromatic event. The single accent (`#0055FF`) appears only in functional contexts (links in certain routes) and never as decoration. Print is a first-class surface with its own token overrides (pt units, tighter leading, suppressed ornamentation) — the PDF a recruiter prints must look intentional, not like a screenshot of a website.

Components are deliberately quiet. The timeline uses a thin left border with a single `o` glyph as a node — not a decorative dot, not an icon, just typography doing structural work. Pills are muted background chips, not badges. The TL;DR modal is the only elevated surface in the system, and even it uses the pill background rather than introducing a new card color. Everything recedes so the content — 20 years of engineering pedigree, the Cencosud case, the blog posts — can lead.

**Key Characteristics:**
- Monochrome with `light-dark()` tonal inversion; color is functional, never decorative
- Single font family (Montserrat Variable) across all roles; weight + size carry hierarchy
- Print-first: pt units, A4 page geometry, suppressed ornamentation in `@media print`
- Flat by default: no shadows except the TL;DR dialog; depth is conveyed by tonal layering
- Two-column editorial layout (aside 25% / main 75% in print) that collapses to centered single column under 900px
- Components recede; content leads

## Colors

The palette is an austere monochrome with one functional accent. Light and dark modes are tonal inversions of the same neutral scale — no hue shift between modes.

### Primary
- **Ink** (`light-dark(#000, #fff)`): Primary text color. Black on paper in light mode, white on dark surface. Used for headings, body copy, and high-emphasis labels.

### Neutral
- **Muted Ink** (`light-dark(#616161, #abb0c2)`): Secondary text, metadata, timeline entries, aside content, link labels. The workhorse color for everything that supports the main narrative.
- **Paper** (`light-dark(#fff, #16181c)`): Page background. Pure white in light, near-black with a slight blue undertone in dark.
- **Paper Pill** (`light-dark(#e7e7e7, #353535)`): Background for pills, the TL;DR dialog, and tonal chips. One step off the page surface.
- **Paper Tint** (`light-dark(#f5f5f5, #1f2229)`): Background for blockquotes and tonal layering. Two steps off the page surface.

### Accent (functional, rare)
- **Accent Blue** (`#0055FF`): Appears only in functional link contexts in certain routes. Not used for branding, decoration, or hover states. Its rarity is the point.

### Warning (contextual)
- **Warn Amber** (`#ffa000`) / **Warn Amber BG** (`#fff8e1`): Used together for warning callouts (e.g., missing-language banner in the blog). Not part of the core palette.

### Named Rules
**The No Decoration Rule.** Color is never used decoratively. The accent appears only where it carries functional meaning (a link, a warning). If a surface needs emphasis, use tonal layering (Paper Tint) or typographic weight — not hue.

## Typography

**Display & Body Font:** Montserrat Variable (with `system-ui, sans-serif` fallback)
**Mono Font:** Menlo, Monaco, Lucida Console, Liberation Mono, DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace

**Character:** A single variable font family carries every typographic role — display, body, label, mono fallback is the only departure. Hierarchy is expressed through weight (400 → 600) and size, never through family contrast. This is the editorial resume: one voice, many registers.

### Hierarchy
- **Display** (400, 2.3rem, 1.1): Author name in the header. Uppercase via `.upper` class. The only display-sized text on the page.
- **Headline** (400, 1.6rem, 1.2): Role/subtitle in header, blog post titles. Uppercase for section headers.
- **Title** (600, 1.15rem, 1.3): Position titles in experience items, section headings (`h3.upper`). The weight shift to 600 is the primary hierarchy signal.
- **Body** (400, 1rem, 1.5): All body copy, list items, aside content. `text-wrap: pretty` enabled. Max line length governed by the 1000px container and 75% main column.
- **Label** (400, 0.9em): Nav links, small metadata, timeline company lines. Often paired with `.light` (muted ink).
- **Mono** (400, 0.9em): Code blocks only. Never used for UI labels.

### Print Hierarchy (overrides in `@media print`)
- Body: 10pt, line-height 1.15
- h2: 13pt
- h3: 11pt
- small-in-print: 8.5pt, line-height 1.1

### Named Rules
**The One Family Rule.** Montserrat Variable is the only typeface. Weight and size carry all hierarchy. Introducing a second display family would break the editorial resume contract.

**The Uppercase Section Rule.** Section headers (`h3.upper`) are uppercased. This is the only text transformation in the system and it marks structural divisions.

## Layout

A two-column editorial spread with a constrained measure.

- **Container:** `max-width: 1000px`, centered, `padding: 0 3em 4em 3em`
- **Columns:** Flex row, `gap: 2em`. Aside (sidebar) on the left, main content on the right. In print, aside is 25% / main is 75%.
- **Aside:** Flex column, `gap: 1.3em` (screen) / `0.3em` (print). Contains Contact, PersonalBlog, Contributions, Skills, TechStack, Certificates — in that order.
- **Breakpoint:** `max-width: 900px` → columns become `column-reverse`, centered text, aside gaps collapse, list styling removed, header stacks vertically.
- **Print geometry:** A4, `@page margin: 10mm` (5mm top on first page), `main max-height: calc(297mm - 20mm)`, `overflow: hidden`. Page breaks avoided inside sections, list items, and paragraphs. Orphans/widows: 3.
- **Spacing rhythm:** `em`-based throughout (0.5em, 1em, 1.3em, 2em, 3em). No fixed `px` spacing in the core layout.

## Elevation & Depth

This system is **flat by default**. Depth is conveyed through tonal layering (Paper → Paper Pill → Paper Tint), not shadows.

The single exception is the TL;DR dialog, which uses `box-shadow: 0 4px 20px rgba(0,0,0,0.3)` to signal its elevated modal state. This is the only shadow in the entire system and it exists because a modal must read as floating above the page.

### Named Rules
**The Flat-By-Default Rule.** Surfaces are flat. Shadows appear only on the TL;DR dialog. If a new component needs to convey elevation, use tonal layering (Paper Tint background) or a border — not a shadow.

## Shapes

The form language is restrained and functional. Most surfaces have no radius (the editorial resume is squared). Radius appears only where it softens a functional element.

- **No radius:** Blockquotes (left border only), sections, timeline items, page edges
- **xs (3px):** Small UI elements, minor softening
- **sm (6px):** Medium UI elements
- **md (8px):** Blockquote right side (`0 8px 8px 0`), TL;DR dialog
- **lg (0.5rem) / xl (1rem):** Larger containers (used sparingly)
- **pill (999px):** Pills/chips only
- **circle (20%):** Profile image, icon containers

### Named Rules
**The Squared Default Rule.** The default radius is 0. Radius is added only to soften functional elements (pills, dialogs, the blockquote's open right corner). Large rounded containers would break the editorial document feel.

## Components

### Links (inline)
- **Shape:** No radius, no border (transparent bottom border that appears on hover)
- **Default:** `color: inherit`, `border-bottom: 1px solid transparent`
- **Hover:** `border-bottom-color: inherit` (underline appears in current text color)
- **Muted variant:** `.light` class → `color: var(--color-texts-light)`, used in aside and metadata
- **Focus:** `outline: 2px solid var(--color-texts-light)`, `outline-offset: 4px`

### Pills / Chips
- **Shape:** `border-radius: 999px` (full pill)
- **Background:** `var(--color-bg-pill)` — one step off page surface
- **Text:** Ink color, often `.light` (muted)
- **Padding:** `0.2em 0.6em` (approximate, observed)
- **Use:** Tech stack tags, skill markers in aside

### Blockquote
- **Shape:** `border-radius: 0 8px 8px 0` (squared left, rounded right)
- **Background:** `var(--color-tint)` (Paper Tint)
- **Border:** `border-left: 4px solid var(--color-texts-light)`
- **Text:** Muted ink, italic
- **Padding:** `1em 1.5em`
- **Use:** Blog article pull quotes, editorial emphasis

### Timeline Item (ExperienceItem)
- **Shape:** No radius. Left border with typographic node.
- **Border:** `border-left: 0.13em solid var(--color-texts-light)`
- **Node:** `::before` content `"o"` at `font-size: 1.5em`, positioned over the border with page-color background — a typographic bullet, not a decorative dot
- **Text:** Muted ink throughout. Position title is `font-weight: 600`, company is `font-weight: 500` at 95% size
- **Padding:** `padding-left: 1.5em`, `margin-left: 0.4em`
- **Mobile (<900px):** Border and node removed, centered, larger position title
- **Print:** Border and node removed, flush left

### TL;DR Trigger (button)
- **Shape:** No radius, no border, no background
- **Text:** Muted ink, `font-size: 0.9em`
- **Hover:** Color shifts to `light-dark(#000, #fff)` (full ink)
- **Padding:** 0 — reads as a link, not a button
- **Accessibility:** `aria-label` in user's language, only renders if Chrome AI APIs available

### TL;DR Dialog (modal)
- **Shape:** `border-radius: 8px`, `border: none`
- **Background:** `var(--color-bg-pill)` (Paper Pill — the only elevated surface)
- **Shadow:** `0 4px 20px rgba(0,0,0,0.3)` — the only shadow in the system
- **Backdrop:** `rgb(189 189 189 / 0.6)` via `dialog::backdrop`
- **Padding:** `2em`, `max-width: 600px`, `max-height: 80vh` with `overflow-y: auto`
- **Close:** `×` glyph at `1.5em`, absolute positioned top-right, muted ink

### Section
- **Shape:** No radius, no border, no background
- **Header:** `h3.upper` — uppercase title, standard h3 margins
- **Content:** Optional `content[]` rendered as `<p class="light small-in-print">`
- **Print:** `page-break-inside: avoid`, `margin-bottom: 9pt`

### Aside (sidebar)
- **Layout:** Flex column, `gap: 1.3em`
- **Contains (in order):** Contact, PersonalBlog, Contributions, Skills, TechStack, Certificates
- **Link overflow:** `word-break: break-word; hyphens: auto` (per AGENTS.md risk #3)
- **Print:** `gap: 0.3em`, `flex-basis: 25%`

### Header
- **Layout:** Flex row, space-between, `padding: 2em 0`
- **Left:** `h1.upper` (author name, 2.3rem) + `h2.upper.light` (role, hidden on root page)
- **Right:** Profile image (123×123, hidden by default, shown with `?pic` query param)
- **Mobile:** `column-reverse`, centered
- **Print:** Image shown at 100px height, `padding: 1em 0`

## Do's and Don'ts

### Do:
- **Do** use `light-dark()` for all color tokens — it is the canonical source of truth for both modes.
- **Do** express hierarchy through font-weight (400 → 600) and size, never through family contrast.
- **Do** use tonal layering (Paper → Paper Pill → Paper Tint) to convey depth without shadows.
- **Do** keep the aside link overflow safe: `word-break: break-word; hyphens: auto` on all aside links.
- **Do** test print output in both Chrome and Edge — paginated consistency is a tracked risk.
- **Do** use the `.upper` class for section headers — it is the only text transformation in the system.
- **Do** preserve the 1000px max-width container — the editorial measure is intentional.

### Don't:
- **Don't** introduce a second font family for display or body — Montserrat Variable is the only voice.
- **Don't** add shadows to any component except the TL;DR dialog. Flat is the default.
- **Don't** use the accent blue (`#0055FF`) decoratively — it is functional only.
- **Don't** add large border-radius to containers — the default is squared; radius softens functional elements only.
- **Don't** replace the timeline's typographic `o` node with an icon or decorative dot — the glyph is the design.
- **Don't** add external libraries beyond `package.json` without an ADR (per AGENTS.md).
- **Don't** manually restart the dev server — it runs on `:8080` and is managed by the user (per AGENTS.md).
