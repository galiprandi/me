---
target: src/pages/index.astro
total_score: 22
max_score: 36
na_heuristics: 7,10
p0_count: 0
p1_count: 8
p2_count: 9
p3_count: 7
timestamp: 2026-07-27T02-43-51Z
slug: src-pages-index-astro
---
---
target: src/pages/index.astro
total_score: 22
max_score: 36
na_heuristics: "7,10"
p0_count: 0
p1_count: 8
p2_count: 9
p3_count: 7
---

# Critique: src/pages/index.astro (landing page /)

## Method: dual-agent (A: 2d8266b3 · B: e5a3aa72)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Role hidden on root page; no active nav state (no nav exists) |
| 2 | Match System / Real World | 2 | Promised multi-route architecture (/em, /tl, /ext) doesn't exist; recruiters can't choose their path |
| 3 | User Control and Freedom | 2 | No navigation between role variants; trapped in single narrative |
| 4 | Consistency and Standards | 3 | Class names inconsistent (`.skill` on non-skill sections); aside gap conflict between screen/print |
| 5 | Error Prevention | 3 | Missing routes could cause 404s if linked externally |
| 6 | Recognition Rather Than Recall | 2 | No visual cues that this is a landing page with alternatives |
| 7 | Flexibility and Efficiency | n/a | Single-path resume; no shortcuts applicable |
| 8 | Aesthetic and Minimalist Design | 4 | Excellent — editorial aesthetic achieved, components recede, content leads |
| 9 | Error Recovery | 3 | No errors to recover from, but no guidance if user expects role routes |
| 10 | Help and Documentation | n/a | Resume doesn't require help docs |
| **Total** | | **22/36** | **Needs work — strong aesthetics, broken product promise** |

## Design Specificity Verdict

**LLM assessment:** Authored to this product, but with a critical implementation gap. The editorial resume aesthetic, the Cencosud AI workflow narrative, and the austere monochrome design system are product-specific. However, the core product promise — "Route the recruiter" via role-specific paths (`/em`, `/tl`, `/ext`) — is completely unimplemented. The landing page contains all content but lacks the routing architecture that would make this a differentiated, recruiter-focused experience. Without the role routes, this is a well-executed single-page resume that could serve any senior engineer.

**Deterministic scan:** 4 findings (exit 0):
- `#727070` in Podcast.astro line 51 — color outside DESIGN.md palette (advisory, real)
- `border-left: 4px solid` in global.css line 79 — flagged as "side-tab accent border" AI tell (FALSE POSITIVE — this is a blockquote's editorial left border, a deliberate design-system choice, not a card accent)
- Montserrat flagged as "overused font" in global.css:16 and print.css:16 (FALSE POSITIVE in context — Montserrat Variable was a deliberate brand commitment by the user, not a default AI choice; the detector flags it because it's common, but here it's intentional)

**Visual overlays:** Skipped — browser automation unavailable in this session. Dev server not running (port 8080 occupied by unrelated Docker proxy). No reliable user-visible overlay available.

## Overall Impression

The editorial aesthetic is genuinely achieved — this looks like a resume that respects the reader. But the product's core differentiator (role-based routing) is a documented promise that the code doesn't keep. A recruiter lands on a generic single-page CV instead of being routed to a narrative matched to the role they're hiring for. The single biggest opportunity: make the landing page a router, not a content dump.

## What's Working

1. **The Cencosud narrative** (index.astro lines 29-38): Compelling evidence-led persuasion. Specific scale numbers (+120k employees, +800 developers), competitive differentiation ("selected over Google and AWS"), projected impact (3x TTM). This is the credibility anchor — when it appears, it works.

2. **Design system execution**: Montserrat Variable carries all hierarchy, the monochrome palette is austere, flat design lets content lead. The `.upper` section headers and `.light` class for metadata create clear visual rhythm without decoration. The detector's "overused font" flag is a false positive here — this was a deliberate choice.

3. **Print-first commitment**: print.css is thorough — A4 geometry, `page-break-inside: avoid` on sections, orphans/widows control, `.small-in-print` at 8.5pt. This respects the recruiter who prints or PDFs. (Though it has bugs — see Priority Issues.)

## Priority Issues

### [P1] Missing Multi-Route Architecture
**What**: README and PRODUCT.md promise role-specific routes (`/em`, `/tl`, `/ext`) to route recruiters by hiring intent. These routes do not exist — only `/`, `/blog/*`, and `/portfolio` are implemented.
**Why it matters**: A recruiter hiring for an EM role wants a different narrative than one hiring for a Tech Lead. The single-page approach forces everyone through the same content, reducing relevance and conversion. The product's core differentiator is broken.
**Fix**: Implement the three missing routes with role-filtered content. Add a nav component to the landing page: "I'm hiring for: [Engineering Manager] [Tech Lead] [See Full Background]".
**Suggested command**: `$impeccable shape` (plan the routing UX before building)

### [P1] Header Role Hidden on Root Page
**What**: Header.astro line 17 conditionally hides the role (`!isRootPage && <h2>`). On the landing page, the header shows only the name.
**Why it matters**: The first thing a recruiter sees is "Germán A. Aliprandi" with no title. They must read into the summary paragraph to understand the positioning. Friction on the 30-second scan.
**Fix**: Show the role on the root page. Use `.light` to de-emphasize if needed. "Software Engineer | SDLC & AI Strategy Architect" is a key credibility marker.
**Suggested command**: `$impeccable clarify`

### [P1] Cencosud Case Buried in Section 2
**What**: The strongest differentiator (Cencosud AI workflow selected over Google/AWS) is in the second section, after a generic summary.
**Why it matters**: Recruiters scan top-down. If they don't scroll past section 1, they miss the "wow" factor. The generic summary doesn't differentiate from other 20-year engineers.
**Fix**: Restructure the opening — lead with the Cencosud case as the hook, follow with summary/Axioma as supporting context. Or use the blockquote component to make the key numbers skimmable.
**Suggested command**: `$impeccable layout`

### [P1] Missing `rel="noopener noreferrer"` on External Links
**What**: Contact.astro lines 23, 33, 43 and PersonalBlog.astro line 22 — external links with `target="_blank"` missing security attributes.
**Why it matters**: Tabnabbing security vulnerability. The linked page can access the opener's window object.
**Fix**: Add `rel="noopener noreferrer"` to all `target="_blank"` links.
**Suggested command**: `$impeccable harden`

### [P1] Heading Hierarchy Violation (h1 → h3 gap)
**What**: index.astro uses `<h3>` for all section headings directly inside `<main>` with no `<h2>` in the main content area. The `<h1>` is in Header.astro.
**Why it matters**: Screen readers navigate by heading hierarchy. The h1→h3 gap breaks the document outline for assistive technology.
**Fix**: Change section headings to `<h2>` (they're top-level sections of the main content), or add an intermediate `<h2>` for grouping.
**Suggested command**: `$impeccable audit`

### [P1] Print CSS Overflow Risk
**What**: print.css lines 32-36 — `main { max-height: calc(297mm - 20mm); overflow: hidden; }` will truncate content exceeding one A4 page.
**Why it matters**: A resume that truncates in print defeats the print-first commitment. Content beyond page 1 is silently lost.
**Fix**: Remove `max-height` and `overflow: hidden` from `main` in print. Let content flow naturally with `page-break-inside: avoid` on sections handling pagination.
**Suggested command**: `$impeccable harden`

### [P1] Missing H1 Font Size in Print CSS
**What**: print.css defines h2 (13pt) and h3 (11pt) but not h1. Header.astro's h1 uses `2.3rem` which is uncontrolled in print.
**Why it matters**: The author name may render at an unintended size in print/PDF. AGENTS.md risk #2 explicitly calls for fixed heading sizes.
**Fix**: Add `h1 { font-size: 16pt !important; }` to print.css (per AGENTS.md risk #2 example).
**Suggested command**: `$impeccable harden`

### [P1] Missing ARIA Labels on Decorative Icons
**What**: Contact.astro lines 12, 19, 29, 39 — SVG icons (IconEmail, IconLinkedin, IconGithub, IconPortfolio) lack `aria-hidden="true"`.
**Why it matters**: Screen readers announce decorative icons redundantly with the adjacent text links.
**Fix**: Add `aria-hidden="true"` to all decorative SVG icons in Contact.astro.
**Suggested command**: `$impeccable audit`

### [P2] No Navigation to Role Variants
**What**: Even if role routes existed, there's no UI on the landing page to navigate to them.
**Why it matters**: The product promise is "Route the recruiter," but the recruiter has no way to choose their route.
**Fix**: Add a nav component below the header or in the sidebar with role-selection links.
**Suggested command**: `$impeccable shape`

### [P2] Mobile Contact Buried
**What**: global.css line 101 — `flex-direction: column-reverse` at <900px pushes the sidebar (with contact) below main content.
**Why it matters**: Mobile recruiters must scroll through all experience sections to reach contact. May not reach it.
**Fix**: On mobile, keep contact at the top or add a sticky contact button. Consider `position: sticky` for the Contact section.
**Suggested command**: `$impeccable adapt`

### [P2] Missing Skip Navigation Link
**What**: Layout.astro — no "skip to main content" link at the start of the page.
**Why it matters**: Keyboard users must tab through all header/aside content to reach main content.
**Fix**: Add a visually-hidden skip link as the first element in `<body>`.
**Suggested command**: `$impeccable audit`

### [P2] Color Contrast Uncertainty in Dark Mode
**What**: global.css lines 3-5 — `#abb0c2` on `#16181c` in dark mode could not be verified for AA contrast.
**Why it matters**: If contrast fails AA, dark mode is inaccessible to low-vision users.
**Fix**: Verify contrast ratio; if below 4.5:1, lighten the muted-ink dark value.
**Suggested command**: `$impeccable audit`

### [P2] Aside Gap Conflict in Print
**What**: print.css sets `aside { gap: 30pt !important; }` but Aside.astro has `aside { gap: 0.3em; }` in its print media query. Conflicting values.
**Why it matters**: The 30pt gap wastes vertical space in print; the 0.3em was the intended compact value.
**Fix**: Remove the `30pt !important` override from print.css and let Aside.astro's `0.3em` stand.
**Suggested command**: `$impeccable harden`

### [P2] 900px Breakpoint Removes List Indicators
**What**: global.css line 107 — `ul { padding: 0; list-style: none; }` at <900px.
**Why it matters**: List items lose visual structure on mobile, becoming a wall of text.
**Fix**: Keep `list-style: circle` on mobile for experience sections; only remove for aside lists if needed.
**Suggested command**: `$impeccable adapt`

### [P2] Header Image Hidden by Default
**What**: Header.astro lines 69-72 — profile image `display: none` by default, only shows via `?pic` query param.
**Why it matters**: The profile photo is a credibility marker. Hiding it by default makes the header feel impersonal.
**Fix**: Show the image by default; keep the `?pic` param as an override if needed.
**Suggested command**: `$impeccable clarify`

### [P2] Undocumented Color in Podcast Component
**What**: Podcast.astro line 51 — `#727070` used but not in DESIGN.md palette.
**Why it matters**: Design system drift — a color outside the documented tokens.
**Fix**: Either add `#727070` to DESIGN.md as a token (e.g., `podcast-muted`) or replace it with an existing token like `muted-ink`.
**Suggested command**: `$impeccable document`

## Persona Red Flags

**Recruiter Scanning for Senior Engineering Leadership**:
- Header (Header.astro:17): Role hidden — can't quickly confirm this is a leadership candidate
- Section 1 (index.astro:13-26): Generic summary doesn't signal leadership scale. Must read to section 2 to find "+800 developers" and "selected over Google/AWS"
- No role routing: Can't jump to an Engineering Manager-focused narrative
- Contact location: Must scan sidebar to find email/LinkedIn — no prominent CTA
- On mobile: contact buried at bottom after column-reverse

**Technical Peer Evaluating AI/SDLC Credibility**:
- Axioma framework mention (index.astro:18-21): Named but not linked or explained. No link to GitHub, no context. Peer can't verify the claim.
- Open source list (index.astro:176-206): 7 projects with no differentiation. Can't tell which are production-grade vs experiments.
- No links to technical artifacts from main content — GitHub links only in aside.

**Mobile User (Recruiter on Phone)**:
- Column-reverse layout (global.css:101): Sidebar with contact drops below main content. Must scroll through all experience to reach contact.
- Dense content: 5 experience sections with nested bullets — hard to parse on small screen.
- No mobile-specific CTA: No sticky contact button for mobile users.
- h1 at 2.3rem with no mobile scaling — may be too large on small screens.

## Minor Observations

1. **ExperienceItem component not used**: ExperienceItem.astro exists with timeline styling but index.astro uses raw `<ul>`/`<li>` instead. The timeline's typographic `o` node is absent from the landing page.
2. **Education component unused**: Education.astro exists but isn't imported in index.astro.
3. **Misleading class names**: All aside sections use `<section class="skill">` except Contact. The "skill" class on Certificates/Contributions/PersonalBlog is misleading.
4. **Blog link redundancy**: PersonalBlog in sidebar shows recent posts; footer has a separate "Blog" link.
5. **Date format inconsistency**: Experience uses "Jan 2026 – Present"; certificates use "(03/2022)".
6. **Print CSS comments in Spanish**: print.css lines 1-2, 96 — comments in Spanish while codebase is English.
7. **Manifesto center-alignment on mobile**: Footer manifesto may wrap awkwardly when centered on narrow screens.

## Questions to Consider

1. If the multi-route architecture is the core differentiator, why does the landing page default to a generic single-page view instead of forcing a route choice? Should the landing page be a router — "I'm hiring for: [EM] [TL] [See All]" — rather than a content page?

2. The Cencosud case is the strongest credibility marker but it's buried in paragraph form. What if the landing page opened with a "credibility dashboard" — key numbers (+120k, +800, 3x TTM, selected over Google/AWS) as visual metrics — before any narrative text?

3. The open source list is undifferentiated. What if each project had a relevance tag — e.g., fastify-lm marked "Production-used at Cencosud," Axioma marked "Core framework" — to help recruiters prioritize?

4. The role is hidden on the root page. What if the header dynamically showed the role based on the recruiter's apparent intent (URL param from LinkedIn job post)?
