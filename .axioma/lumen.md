
## 2025-05-14 - Standardizing Print Margins & A4 Compliance | Learning: Inconsistent @page margins and forced page breaks can cause CVs to leak into second pages unexpectedly. | Acción: Established 10mm as the standard print margin in global.css and removed forced breaks in single-page CV routes.

## 2025-05-14 - Consolidation of CV at Root | Learning: Maintaining multiple CV versions (em, ext, tl) creates maintenance overhead and technical debt. | Acción: Consolidated the Engineering Manager CV as the canonical version at root (/), removed redundant routes, and updated all internal links.

## 2026-05-09 - Blog Title Standardization | Learning: Blog post titles should be concise and focused to maintain clarity and UI consistency. | Acción: Added a rule that blog post titles must not contain subtitles or extra descriptive phrases beyond the main topic.

## 2025-05-14 - Dynamic Sidebar Content Promotion | Learning: Using getCollection allows for automated content promotion (e.g., Personal Blog entries) while maintaining styling consistency via shared CSS classes like .skill and .upper. | Acción: Created PersonalBlog.astro to automatically fetch and list the latest 5 blog posts, replacing hardcoded links in the sidebar.

## 2026-05-11 - Interactive Accessibility Standards | Learning: Using non-semantic elements (like `<span>`) for interactive components prevents keyboard navigation and fails screen readers. | Acción: Established the use of semantic `<button>` with dynamic `aria-label` and visible `:focus-visible` states for all floating interactive components.
