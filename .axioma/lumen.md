
## 2025-05-14 - Standardizing Print Margins & A4 Compliance | Learning: Inconsistent @page margins and forced page breaks can cause CVs to leak into second pages unexpectedly. | Acción: Established 10mm as the standard print margin in global.css and removed forced breaks in single-page CV routes.

## 2025-05-14 - Consolidation of CV at Root | Learning: Maintaining multiple CV versions (em, ext, tl) creates maintenance overhead and technical debt. | Acción: Consolidated the Engineering Manager CV as the canonical version at root (/), removed redundant routes, and updated all internal links.

## 2026-05-09 - Blog Title Standardization | Learning: Blog post titles should be concise and focused to maintain clarity and UI consistency. | Acción: Added a rule that blog post titles must not contain subtitles or extra descriptive phrases beyond the main topic.

## 2025-05-14 - Dynamic Sidebar Content Promotion | Learning: Using getCollection allows for automated content promotion (e.g., Personal Blog entries) while maintaining styling consistency via shared CSS classes like .skill and .upper. | Acción: Created PersonalBlog.astro to automatically fetch and list the latest 5 blog posts, replacing hardcoded links in the sidebar.

## 2026-05-11 - Interactive Accessibility Standards | Learning: Using non-semantic elements (like `<span>`) for interactive components prevents keyboard navigation and fails screen readers. | Acción: Established the use of semantic `<button>` with dynamic `aria-label` and visible `:focus-visible` states for all floating interactive components.

## 2025-05-14 - Print Typography Standardization | Aprendizaje: Los estándares de tipografía de impresión Lumen (h1:16pt, h2:13pt, h3:11pt, body:10pt) garantizan un equilibrio óptimo entre legibilidad y densidad de información para una sola hoja A4. | Acción: Estandarizar tamaños de fuente en print.css para cumplir con el estándar Lumen.
## 2026-05-13 - Focus Standard & Theme Consistency | Aprendizaje: Centralizing accessibility states prevents UI fragmentation and hardcoded color drift. | Acción: Defined global :focus-visible and refactored TlDrModal to use theme variables.

## 2026-05-14 - Semantic Icon Accuracy & Typo Cleanup | Aprendizaje: Misaligned or semantically incorrect icons (like using NPM icon for a portfolio link) degrade the professional polish of the CV. Filename typos (IconPorfolio) can lead to broken imports during refactors. | Acción: Corrected the filename typo and standardized the contact section to use the `IconPortfolio` component, improving semantic accuracy.

## 2026-05-15 - Personal Blog Entry Limit & Navigation | Aprendizaje: Displaying too many recent blog entries in the CV sidebar can compromise the single-page A4 layout. Providing a "More articles..." link improves UX by guiding users to the full blog index without cluttering the resume. | Acción: Limited recent entries to 4 and added a 'no-print' navigation link to the blog index in PersonalBlog.astro.
