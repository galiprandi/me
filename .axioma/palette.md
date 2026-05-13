## 2025-05-15 - [TlDrModal Accessibility & Feedback]
**Learning:** React components in Astro using experimental APIs (like Chrome's AI Summarizer) often default to being hidden or null when the API is missing. This makes verification difficult in headless environments. Additionally, standardizing accessibility attributes (`aria-label`, `aria-labelledby`) and visual feedback (`:focus-visible`, hover transitions) even in "experimental" features ensures they are inclusive from the start.
**Action:** Always include localized `aria-label` for trigger buttons and ensure `:focus-visible` is implemented for all interactive elements to support keyboard-only users.

## 2025-05-22 - [Rejected: Copy-to-Clipboard on Contact]
**Learning:** Adding interactive utility buttons (like "Copy") to the core contact section of a professional CV can be perceived as unnecessary clutter or a deviation from the desired minimalist aesthetic, even if implemented surgically.
**Action:** Do not attempt to add "Copy to Clipboard" or similar interactive helper buttons to the `Contact.astro` component; maintain the static link format as preferred by the user.
