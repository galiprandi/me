
## 2025-05-14 - Standardizing Print Margins & A4 Compliance | Learning: Inconsistent @page margins and forced page breaks can cause CVs to leak into second pages unexpectedly. | Acción: Established 10mm as the standard print margin in global.css and removed forced breaks in single-page CV routes.

## 2025-05-14 - Consolidation of CV at Root | Learning: Maintaining multiple CV versions (em, ext, tl) creates maintenance overhead and technical debt. | Acción: Consolidated the Engineering Manager CV as the canonical version at root (/), removed redundant routes, and updated all internal links.

## 2026-05-08 - Surgical Print Typography | Learning: Achieving single-page A4 compliance requires a delicate balance between base font size (10pt) and vertical spacing (tightened header margins). Component-level @media print rules often conflict with global standards. | Acción: Centralized print styles in global.css, standardized headers (H1: 16pt, H3: 12pt), and optimized vertical margins to ensure height stays below 1123px at 96dpi.
