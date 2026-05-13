## 2025-05-15 - [TlDrModal Accessibility & Feedback]
**Learning:** React components in Astro using experimental APIs (like Chrome's AI Summarizer) often default to being hidden or null when the API is missing. This makes verification difficult in headless environments. Additionally, standardizing accessibility attributes (`aria-label`, `aria-labelledby`) and visual feedback (`:focus-visible`, hover transitions) even in "experimental" features ensures they are inclusive from the start.
**Action:** Always include localized `aria-label` for trigger buttons and ensure `:focus-visible` is implemented for all interactive elements to support keyboard-only users.

## 2025-05-22 - [Surgical UX & Theme Consistency]
**Learning:** When implementing interactive micro-feedback (like "Copied!" tooltips), using CSS pseudo-elements (`::after`) significantly reduces DOM bloat and component complexity. Leveraging project-standard variables and the `light-dark()` function ensures visual harmony without manual theme toggling.
**Action:** Prioritize CSS-heavy feedback over JS-managed DOM elements to stay within surgical PR limits (< 50 lines). Ensure global utility classes like `.no-print` are defined outside scoped media queries.
