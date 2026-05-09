
## 2025-05-14 - Standardizing Print Margins & A4 Compliance | Learning: Inconsistent @page margins and forced page breaks can cause CVs to leak into second pages unexpectedly. | Acción: Established 10mm as the standard print margin in global.css and removed forced breaks in single-page CV routes.

## 2025-05-14 - Consolidation of CV at Root | Learning: Maintaining multiple CV versions (em, ext, tl) creates maintenance overhead and technical debt. | Acción: Consolidated the Engineering Manager CV as the canonical version at root (/), removed redundant routes, and updated all internal links.

## 2025-05-14 - Lumen Print Typography Standard | Learning: Certain print engines clip content when 'overflow: hidden' is set on body in one-page layouts. A4 single-page compliance requires specific font sizes (16pt/12pt/10pt) to fit content within 1123px at 96 DPI. | Acción: Set 'overflow: visible' on body.one-page during print and standardized print font sizes in global.css.
