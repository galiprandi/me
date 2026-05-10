## 2025-05-15 - [Enhance Podcast Accessibility & Fix Print Overflow]
**Learning:** Interactive elements implemented as `<span>` or `<div>` are invisible to screen readers and keyboard users unless explicitly managed. Converting them to semantic `<button>` elements with ARIA labels significantly improves accessibility with minimal code changes. Additionally, `overflow: hidden` on the body during print can cause content clipping in some browsers.
**Action:** Always use semantic HTML for interactive elements. Ensure print styles use `overflow: visible` to prevent content loss.
