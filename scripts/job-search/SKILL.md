# Job Search Skill

## When to Use This Skill

Use this skill when the user:
- Asks to search or apply for jobs ("postula a trabajos", "busca ofertas", "job search")
- Asks to check application status / follow-ups ("novedades", "actualizaciones", "respuestas")
- Asks to do their weekly job search session
- Asks to respond to recruiters or schedule interviews
- Invokes `skill("job-search")`

## Overview

This skill automates the user's weekly job search lifecycle. The CV (website repo at `/Users/cenco/Github/Personal/me`) is the **source of truth**. The skill maintains a structured profile (`PROFILE.md`), searches for matching jobs, applies to them, tracks all applications (`APPLICATIONS.md`), checks for updates via LinkedIn messages and Gmail, follows up, and responds to recruiters — all autonomously.

## Key Files (all in the repo)

| File | Purpose | Versioned |
|---|---|---|
| `scripts/job-search/PROFILE.md` | Structured profile auto-generated from CV + target companies list | Yes |
| `scripts/job-search/APPLICATIONS.md` | Registry of all applications, connections, interviews, follow-ups | Yes |
| `scripts/job-search/templates/connection-templates.md` | Templates for recruiter messages (connection, follow-up, response) | Yes |
| `scripts/job-search/templates/cover-letter-templates.md` | Templates for cover letters by role type | Yes |
| `job-search-log.md` | Detailed session log (append-only) | No (gitignored) |

## MCPs and Tools

| Tool | Usage | Required |
|---|---|---|
| `mcp1_*` (Chrome perfil German) | Browser automation: LinkedIn, Gmail, job sites, applications | **Yes** — primary tool |
| `mcp6_*` (LinkedIn MCP) | Fast scraping: search jobs, get details, read inbox, search conversations | Optional — accelerates but `mcp1_*` covers everything |
| `read_file` / `edit` / `write_to_file` | Read CV, update PROFILE.md and APPLICATIONS.md | Yes |

## Execution Flow — 100% Autónomo

El usuario lanza el flujo y el agente ejecuta todas las fases secuencialmente. Solo se detiene a pedir confirmación antes de enviar mensajes o conexiones a recruiters.

---

### Phase 0: Sync CV → PROFILE.md

1. Read CV files:
   - `src/pages/index.astro` → summary, experience, achievements
   - `src/components/Aside/Skills.astro` → skills
   - `src/components/Aside/TechStack.astro` → tech stack
   - `src/components/Aside/Certificates.astro` → certifications

2. Read current `scripts/job-search/PROFILE.md`.

3. If CV has changes not in PROFILE.md → regenerate PROFILE.md. Inform user: "Detecté cambios en tu CV y actualicé PROFILE.md: [changes]".

4. If no changes → proceed silently.

---

### Phase 1: Trazabilidad — Revisar actualizaciones de aplicaciones existentes

**Objetivo**: Detectar respuestas de recruiters, entrevistas agendadas, rechazos, y aplicaciones sin respuesta que necesitan follow-up.

#### 1a. LinkedIn Messages

**Option A — LinkedIn MCP (faster):**
```
mcp6_get_inbox(limit: 20)
```
For each conversation that looks like a recruiter response:
```
mcp6_get_conversation(linkedin_username: [username])
```

**Option B — Browser automation:**
1. `mcp1_browser_navigate` to `https://www.linkedin.com/messaging/`
2. Take snapshot, scan recent conversations
3. For each conversation from a recruiter or company, open it and read the latest message
4. Look for: interview invitations, requests for availability, rejection notices, requests for more info

#### 1b. Gmail (other job sites notify via email)

1. `mcp1_browser_navigate` to `https://mail.google.com/`
2. Take snapshot, scan inbox for:
   - Subject lines containing: "application", "job", "position", "interview", "offer", "rejected", "unfortunately", "congratulations", "Computrabajo", "Bumeran", "Glassdoor", "Indeed"
   - Emails from recruiters or company domains
3. Open relevant emails and extract:
   - Company name
   - Job title
   - Status update (interview invite, rejection, request for info, offer)
   - Any action needed (schedule call, send documents, complete assessment)

#### 1c. Cross-reference with APPLICATIONS.md

1. For each update found, match it to an existing application in APPLICATIONS.md
2. Update the "Estado" and "Última actualización" columns
3. If a new interview is scheduled → add to "Convocatorias / Entrevistas" table
4. If an application has been >14 days without response → add to "Follow-ups pendientes" table
5. If a recruiter responded → update "Conexiones con recruiters" table (Respondió: ✅)

#### 1d. Respond to recruiters

For each recruiter message that requires a response:
1. Use template from `scripts/job-search/templates/connection-templates.md` ("Respuesta a recruiter")
2. Adapt to the specific message content
3. **Show the user the draft response and ask for confirmation before sending**
4. Send via `mcp6_send_message` (with `confirm_send: true`) or browser automation
5. Update APPLICATIONS.md

#### 1e. Send follow-ups

For each application in "Follow-ups pendientes":
1. Use template "Follow-up tras aplicación"
2. **Show the user and ask for confirmation before sending**
3. Send via LinkedIn message or email (depending on how the application was made)
4. Update APPLICATIONS.md: change state to `en_revision`, add note about follow-up sent

---

### Phase 2: Búsqueda de nuevas ofertas

**Minimum target: 5 new applications per session.**

#### 2a. LinkedIn search

**Option A — LinkedIn MCP:**
```
mcp6_search_jobs(
  keywords: [rotate through target_keywords from PROFILE.md],
  location: "Remote" or "Argentina",
  experience_level: "mid_senior, director",
  work_type: "remote, hybrid",
  date_posted: "past_week",
  max_pages: 3
)
```
Run 2-3 searches with different keywords.

Also search informal posts:
```
mcp6_search_posts(keywords: "Buscamos AI Engineer" / "hiring Engineering Manager" / "estamos contratando AI", date_posted: "past-week")
```

**Option B — Browser automation:**
Navigate to LinkedIn job search with filters:
```
https://www.linkedin.com/jobs/search/?f_AL=true&f_E=4%2C5%2C6&f_WT=2%2C3&keywords=AI%20Engineer&location=Remote&f_TPR=r604800
```

#### 2b. Target company search

For each company in PROFILE.md "Empresas objetivo" (Tier 1 first, then Tier 2):
1. Search LinkedIn jobs filtered by company: `mcp6_search_jobs(keywords: [target_keywords], location: "Remote")` and filter by company name
2. Or navigate to the company's LinkedIn jobs page
3. This catches roles that might not appear in general keyword searches

#### 2c. Other platforms

If LinkedIn doesn't yield enough ALTO-fit jobs:
1. Navigate to Computrabajo, Bumeran, Glassdoor, Indeed
2. If profile not aligned → align first (headline, summary, experience from PROFILE.md)
3. Search with target keywords
4. Mark profile as aligned in PROFILE.md when done

#### 2d. Check APPLICATIONS.md for duplicates

Before presenting jobs, cross-reference with APPLICATIONS.md. **Never apply to the same job twice.**

---

### Phase 3: Fit scoring

For each job found, score against PROFILE.md:

- **ALTO**: 3+ target keywords match, correct seniority (mid-senior/director), remote, no exclude keywords, company in Tier 1-2, incluye leadership (10+ team), AI adoption/architecture/strategy focus, industria de interés, salary range compatible (USD 4.5k-6k+)
- **MEDIO**: 1-2 target keywords match, or correct seniority but onsite/hybrid, or IC role with some leadership, or Tier 3 company, or crypto/fintech (OK if AI role), or salary below range but good company
- **BAJO**: No keyword match, or multiple exclude keywords, or junior/internship, or pure IC without leadership, or freelance/contract

**Auto-discard without asking**: AI Research, ML Research, NLP Research, Computer Vision Research, Data Scientist, Data Analyst, Internship, Junior, Trainee, PhD required, Freelance, Contract, IC-only roles without leadership.

**Bonus criteria** (upgrade MEDIO → ALTO):
- Role involves AI adoption strategy + people management + architecture decisions (mix de todo)
- Team size 10+ with multiple squads
- Environment: producto propio, plataforma interna, o transformación organizacional
- Travel up to 25% accepted

Present filtered list (ALTO + MEDIO) to user for approval. Show: title, company, location, fit score, 1-line reason, salary if visible, URL.

---

### Phase 4: Aplicar

For each approved job, in priority order (ALTO first, Tier 1 companies first):

#### Easy Apply (LinkedIn)
1. `mcp1_browser_navigate` to job URL
2. Snapshot, find "Easy Apply" button, click it
3. Complete each step (snapshot before each interaction — refs change!)
4. On cover letter / additional questions: adapt template from `scripts/job-search/templates/cover-letter-templates.md`
5. Submit, confirm success message
6. **Record in APPLICATIONS.md immediately**

#### External site
1. Click "Apply" → redirect to external site
2. `mcp1_browser_navigate` to follow redirect
3. Complete external form
4. If login required → inform user
5. **Record in APPLICATIONS.md immediately**

#### Connect with recruiter (complementary)
1. If recruiter identified on job posting → `mcp6_connect_with_person` with note from templates
2. **ALWAYS require user confirmation** (`confirm_send: true`)
3. **Record in APPLICATIONS.md under "Conexiones con recruiters"**

---

### Phase 5: Registrar y resumir

1. After each application → append row to "Aplicaciones" table in APPLICATIONS.md
2. After each connection → append to "Conexiones con recruiters" table
3. After each follow-up → update "Follow-ups pendientes" table
4. At session end → append row to "Resumen por sesión" table
5. Also append detailed entries to `job-search-log.md`

**Final summary to user:**
- 📊 Total aplicaciones enviadas: X/5 mínimo
- 📋 Lista de aplicaciones: título, empresa, URL, método, fit
- 🤝 Conexiones realizadas: recruiter, empresa
- 📨 Follow-ups enviados: empresa, días sin respuesta
- 📰 Novedades detectadas: entrevistas, respuestas, rechazos
- 🗑️ Ofertas descartadas: título, empresa, motivo
- ⏳ Pendientes para próxima sesión: ofertas MEDIO no aplicadas, follow-ups futuros
- 📅 Próximas entrevistas: fecha, empresa, tipo

---

## Critical Rules

1. **NEVER apply to the same job twice** — always check APPLICATIONS.md first
2. **NEVER send a connection request, message, or follow-up without user confirmation** (`confirm_send: true`)
3. **ALWAYS take a fresh `mcp1_browser_snapshot`** before interacting with dynamic elements
4. **ALWAYS update APPLICATIONS.md immediately** after each action (not at the end)
5. **Minimum 5 new applications** per session — if LinkedIn doesn't have enough, expand to other sites
6. **Auto-discard** research roles, internships, junior positions without asking
7. **CV is source of truth** — if PROFILE.md and CV disagree, CV wins
8. **APPLICATIONS.md is the memory** — it's versioned and persists across sessions
9. **Trazabilidad first** — always check for updates on existing applications before searching for new ones
10. **English B2+** — do not auto-discard English-language job postings; the user can work in English
11. **Prioritize Tier 1 companies** — large Latin companies where the user's profile and language fit best

## Error handling

- If `mcp6_*` unavailable → use `mcp1_*` for everything
- If `mcp1_*` unavailable → inform user that Chrome perfil German MCP is required
- If job posting removed → skip, log as "descartado — oferta no disponible"
- If Easy Apply fails → try external link, or inform user
- If Gmail not logged in → inform user, skip email check, continue with LinkedIn only
- If LinkedIn session expired → navigate to login page, inform user to log in, then continue
