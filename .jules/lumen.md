
## 2025-05-14 - Standardizing Print Margins & A4 Compliance | Learning: Inconsistent @page margins and forced page breaks can cause CVs to leak into second pages unexpectedly. | Acción: Established 10mm as the standard print margin in global.css and removed forced breaks in single-page CV routes.

## 2025-05-14 - Consolidation of CV at Root | Learning: Maintaining multiple CV versions (em, ext, tl) creates maintenance overhead and technical debt. | Acción: Consolidated the Engineering Manager CV as the canonical version at root (/), removed redundant routes, and updated all internal links.

## 2026-05-08 - Precision Print Typography | Learning: `overflow: hidden` on the body container can silently truncate CV content in some print engines, leading to incomplete PDFs. | Acción: Set `overflow: visible` on `body.one-page` for print media and standardized hierarchy (H1: 16pt, H3: 12pt, Body: 10pt) to guarantee A4 single-page safety (~1053px height).
