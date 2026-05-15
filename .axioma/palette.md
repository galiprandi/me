## 2025-05-22 - [Contact Section Static Links]
**Learning:** Adding interactive utility buttons (like "Copy") to the contact section of this professional CV is a rejected pattern. The user prefers the minimalist aesthetic of static links.
**Action:** Do not implement "Copy to Clipboard" or similar UI enhancements in the `Contact.astro` component.

## 2025-05-23 - [Robust Custom Media Player State]
**Learning:** For custom media players (like the Podcast component), relying on click-toggle logic for UI state leads to desyncs (e.g., if playback fails or ends). Using native media events (`play`, `pause`, `ended`) ensures the UI accurately reflects the internal state.
**Action:** Always synchronize custom media controls using native media events and ensure icons are marked `aria-hidden="true"` when the button has a descriptive `aria-label`.
