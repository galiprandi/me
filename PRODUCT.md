# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

**Primary:** Recruiters and HR professionals evaluating the candidate for senior engineering leadership or AI strategy roles. They scan quickly, look for credibility markers (scale, impact, years), and need to decide whether to initiate contact within a short session.

**Secondary:** Technical peers and community members reading the blog for knowledge, not evaluating for hire.

## Product Purpose

A professional resume and portfolio that converts recruiter visits into job conversations. Success means a recruiter finishes a route understanding the candidate's differentiated value (AI-augmented SDLC at corporate scale) and reaches out via the contact channels. The blog supports this by building technical authority that recruiters may verify.

## Positioning

An "Agent-First" SDLC architect who industrialized AI-augmented engineering for Cencosud (+120k employees, +800 developers), selected over Google and AWS for the ability to govern agent behavior at corporate scale via Context Engineering. This combination of deep engineering pedigree (20+ years) and proven AI workflow design at enterprise scale is the claim a neighboring resume could not truthfully copy.

## Operating Context

- **Single CV at `/`:** One complete resume that works for any recruiter regardless of the role they are hiring for. No role-based routing (ADR-002).
- **Blog at `/blog`:** Technical content (es/en) for community authority; RSS feeds in both languages; tag pages. Not case studies for clients.
- **Portfolio at `/portfolio`:** Projects & open source contributions.
- **Printable CV:** A print-optimized PDF path exists (`em-print.pdf`) for recruiters who prefer offline review or attach to ATS.
- **Deployment:** Static site on GitHub Pages (`galiprandi.github.io/me/`), built via GitHub Actions on push to `main`.
- **Dev server:** Runs locally on `:8080` during development; must not be manually restarted by agents.

## Capabilities and Constraints

- **Stack:** Astro 6 + React 19 + TypeScript, pnpm, GitHub Pages deploy.
- **i18n:** Blog supports Spanish and English with a unified language switcher in the nav (ADR-001).
- **Print:** Print CSS must produce consistent paginated output across Chrome and Edge; font family, heading sizes, and sidebar link overflow are tracked risks (see AGENTS.md).
- **No external libraries** beyond `package.json` without an ADR.
- **Open decision:** None currently. Multi-route architecture explicitly abandoned (ADR-002).

## Brand Commitments

- **Name:** Germán A. Aliprandi
- **Title:** Software Engineer — SDLC & AI Strategy Architect
- **Voice:** Technical, evidence-led, concise. Claims are backed by scale numbers (employees, developers, TTM multiples).
- **Contact:** galiprandi@gmail.com, LinkedIn (linkedin.com/in/galiprandi), GitHub (galiprandi).
- **Identity constraint:** The incumbent visual implementation is the authority; refinement preserves it, redesign would replace it only with explicit user direction.

## Evidence on Hand

- **Cencosud case:** AI-augmented SDLC adopted as core engineering strategy for +120k employees, +800 developers, selected over Google and AWS, projected 3x TTM acceleration. (Stated in README and `/em` route copy.)
- **20+ years** of technical expertise stated in README.
- **Open source:** `@galiprandi/react-tools` (npm), GitHub profile with multiple public repos.
- **Blog posts:** Real technical content (e.g., GitHub account isolation for macOS) in es/en.
- **Printable PDF:** `em-print.pdf` committed as artifact of the print path.
- **Absences to respect:** No fabricated testimonials, customer logos, benchmarks, or pricing. No claim of specific employer outcomes beyond what is stated.

## Product Principles

1. **Evidence over assertion:** Every credibility claim carries a scale number or a verifiable artifact.
2. **One strong narrative:** The CV must work for any recruiter without role-based routing — the opening must hook all audiences.
3. **Authority via substance:** The blog earns technical authority with real problems and real solutions, not opinion posts.
4. **Print is a first-class surface:** Recruiters who print or PDF must get a polished, paginated document, not an afterthought.
5. **Preserve the incumbent world:** The existing visual identity is the baseline; changes refine rather than replace unless explicitly directed.

## Accessibility & Inclusion

No product-specific accessibility standard has been formally established beyond standard web best practices. The print path must remain usable for recruiters using assistive reading tools on PDF.
