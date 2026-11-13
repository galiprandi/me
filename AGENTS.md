# AGENTS

## Reglas de Oro

### Regla de Oro 1 — Preferencias del usuario siempre actualizadas
Cuando el usuario explicita una preferencia, objetivo, dato personal o criterio de decisión, el agente debe **actualizar inmediatamente** todos los artefactos relevantes (AGENTS.md, PROFILE.md, APPLICATIONS.md, etc.) sin necesidad de que el usuario lo pida explícitamente. Nunca dejar que una preferencia explicitada quede solo en el contexto de la conversación.

### Regla de Oro 2 — Objetivos del usuario
El objetivo principal del usuario es **aplicar conocimiento en optimizar flujos y procesos con AI**. El rol de Manager es altamente valorado pero **sacrificable** si la paga y el proyecto son lo suficientemente interesantes. Esta jerarquía debe respetarse al evaluar oportunidades y al redactar respuestas a recruiters.

### Regla de Oro 3 — Re-login headed
Cuando una sesión se cierre o se necesite re-loguear a cualquier plataforma (LinkedIn, Gmail, etc.), el agente debe **abrir el navegador en modo headed** (visible) para que el usuario haga login manualmente. Nunca intentar loguear programáticamente con credenciales del usuario. El flujo es: detectar sesión cerrada → abrir browser headed → avisar al usuario → esperar confirmación → continuar.

### Regla de Oro 4 — Sync con GitHub profile README
Cada cambio o update en el CV (`/me`) que afecte contenido visible (título, experiencia, proyectos, certificaciones, métricas, links, idiomas) debe contemplar la **actualización o sync del README.md del repo `galiprandi/galiprandi`** (perfil de GitHub) por consistencia. Ambos artefactos deben reflejar la misma información. El agente debe detectar automáticamente qué cambió en `/me` y propagarlo al profile README sin necesidad de que el usuario lo pida explícitamente.

## Matriz de Consulta Documental
- Para entender restricciones de arquitectura antes de codificar: Consultar obligatoriamente `ADR.md`
- Para asegurar la consistencia estética y reusabilidad de componentes visuales: Consultar y actualizar `DESIGN.md`
- Para validar el impacto en la lógica de negocio existente: Consultar y sincronizar `BEHAVIOR.md`
- Para dudas de stack o bootstrap: Consultar `README.md`

## Restricciones Operativas Locales
- Prohibido el uso de librerías externas no listadas en package.json sin aprobación previa vía ADR.
- Todo cambio de lógica debe incluir su respectivo test unitario que valide la regla de negocio.
- `context-organizer` corre en pre-commit y mantiene `BEHAVIOR.md` automáticamente.

## Reglas pendientes y riesgos

Estas reglas deben considerarse al implementar el CV imprimible:

1) **Fuente concreta**
   - Definir una familia tipográfica explícita (la misma del sitio) para evitar inconsistencias.

2) **Tamaños exactos de headings**
   - Establecer un set fijo (ejemplo): h1 16pt, h2 14pt, body 10.75pt.

3) **Overflow de enlaces en sidebar**
   - Añadir control para enlaces largos: `word-break: break-word;` y `hyphens: auto;`.

4) **Validación multi-navegador de impresión**
   - Probar la salida de impresión en Chrome y Edge (motores distintos) para asegurar consistencia de paginado y cortes.

5) **Operación del servidor de desarrollo**
   - El servidor dev puede estar ya ejecutándose; no iniciarlo manualmente. Si se detiene, solicitar al usuario que lo reinicie.
   - Luego de cada cambio, debes buscar evidencia gráfica navegando a la ruta necesaria para verificar el resultado.

6) **Evidencia gráfica tras cambios**
   - Tras cada ajuste relevante, capturar evidencia visual (screenshot o print preview) de la ruta afectada para validar render e impresión.

## Workflow de verificación del CV imprimible (1 página A4)

El CV debe imprimir en **exactamente 1 página** vía Ctrl+P. Un párrafo cortado al final arruina el resultado, por lo que **ningún cambio de contenido se da por terminado sin verificar el PDF**.

### Verificación obligatoria antes de subir

```bash
npm run verify:print
```

`scripts/verify-print.sh` hace todo el loop solo: `astro build` → sirve `dist/` → imprime PDF con Chrome headless → valida `Pages: 1` y `yMax ≤ 745` (A4). Exit 0 = OK, exit 1 = hay que compensar ~14pt por línea impresa nueva. **Correrlo siempre antes de commitear cambios de contenido.**

El CSS de impresión ya limita el layout a 1 página, así que `Pages: 1` es solo sanity check: el riesgo real que cubre el script es que la última línea quede cortada abajo (por eso el criterio es `yMax`, no solo el conteo de páginas).

Referencia manual (si el script falla o hay que inspeccionar):

```bash
npx astro build
cd dist && python3 -m http.server 8899 &
# PDF vía browser wrapper o: google-chrome --headless=new \
#   --no-pdf-header-footer --print-to-pdf=/tmp/cv.pdf http://localhost:8899/
pdfinfo /tmp/cv.pdf | grep Pages
pdftotext -bbox /tmp/cv.pdf - | grep -oE 'yMax="[0-9.]+"' \
  | sed 's/yMax="//;s/"//' | sort -rn | head -1
```

### Criterios de aceptación

- `Pages: 1` siempre.
- **`yMax` objetivo: ≤ ~700pt** (no 767). El Ctrl+P real del usuario imprime con headers/footers de Chrome (~50pt) que el `exec pdf` del wrapper no reproduce; con yMax=714 una línea quedaba cortada. La versión aceptada cerró en **yMax=697**.
- La última línea visible debe terminar con puntuación completa, nunca cortada.
- Si `yMax` supera el límite: comprimir texto (nunca reducir font-size ni margins sin aprobación).
- El dev server (`astro dev`) renderiza ~40pt más alto que el build; usar `dist/` para la medida final.
- Al aprobar una versión: copiar el PDF a `~/Downloads/` con nombre descriptivo (`cv_german_aliprandi_vN.pdf`).

### Estado actual calibrado (v10, validado por el usuario)

Última línea impresa: **Axioma** (yMax≈697). Margen restante ≈95pt (~3 líneas de buffer para el print real del usuario).

Ya ocultos del print con `no-print` (siguen visibles en la web):
- `mcp-vs-fnc`, `@galiprandi/react-tools`, `job-seeker` (items OSS secundarios)
- Bullet "Culture & Talent Management" de Egg (redundante: el header ya dice "mentored 30+ developers")
- Párrafo "Writes on..." (el signal de thought leadership queda en el título de la sección + Momentum)

**Regla práctica para próximos cambios:** cada línea nueva en el flujo impreso exige ~14pt de compensación (un `no-print` o una compresión equivalente). Al agregar contenido, apuntar a yMax ≤ 700 verificando con el loop de arriba antes de avisar al usuario.

### Notas

- Clases de impresión existentes: `small-in-print` (texto reducido al imprimir), `no-print` (oculto en PDF: items secundarios de experiencia, mcp-vs-fnc, footer).
- Contenido nuevo en secciones `no-print` no consume espacio en el PDF.
- Elementos nuevos en el flujo impreso requieren su equivalente en recorte o compresión: el documento está al límite de facto.

## Búsqueda Laboral Automatizada

### Skill: `job-search`

Auto-contenida en `.agents/skills/job-search/`. Se invoca con `skill("job-search")` cuando el usuario pide buscar/aplicar a ofertas, revisar novedades, o hacer follow-ups.

**Artefactos (todos en `.agents/skills/job-search/`)**:
- `SKILL.md` — Definición del skill y flujo de ejecución
- `PROFILE.md` — Perfil estructurado auto-generado desde el CV + lista de empresas objetivo (Tier 1-3) + estado de alineación por plataforma
- `APPLICATIONS.md` — Registro de aplicaciones, conexiones, entrevistas y follow-ups (memoria persistente)
- `templates/` — Templates de mensajes a recruiters y cover letters
- `api-captures/` — Capturas de endpoints HTTP como curl reutilizables (Indeed GraphQL, etc.)
- `tools/` — Scripts Node.js (.mjs) para parsing de CV, generación de perfil, y alineación bulk
- `job-search-log.md` — Log detallado por sesión (no versionado, en raíz del repo)

**MCPs**:
- `mcp1_*` (Chrome perfil German) — Browser automation para todo: LinkedIn, Gmail, job sites, profile editing, API capture
- `mcp6_*` (LinkedIn MCP) — Scraping rápido de jobs, inbox, conversaciones (opcional)
- `api-captures/*.sh` — Curl commands reutilizables extraídos del tráfico de red (ej: `indeed.sh` con funciones `get_experiences`, `update_experience`, `create_experience`)

**Flujo (100% autónomo)**:
1. **Sync CV → PROFILE.md** — Detecta cambios en `.astro` y regenera
2. **Profile Alignment** — Alinea perfiles en todas las plataformas (LinkedIn, Computrabajo, Bumeran, Glassdoor, Indeed, etc.) al CV. Captura APIs durante la edición para futura automatización via curl/scripts
3. **Trazabilidad** — Revisa LinkedIn messages + Gmail por actualizaciones de aplicaciones existentes
4. **Responder recruiters** — Si hay mensajes que requieren respuesta, redacta y pide confirmación
5. **Follow-ups** — Si hay aplicaciones sin respuesta >14 días, envía follow-up
6. **Búsqueda** — LinkedIn (MCP o browser) + empresas objetivo (Tier 1-3) + otros sitios
7. **Fit scoring** — ALTO/MEDIO/BAJO, auto-descarta research/junior
8. **Aplicar** — Mínimo 5 por sesión, Easy Apply o sitio externo, sin duplicar
9. **Conectar con recruiters** — Con confirmación del usuario
10. **Registrar** — Cada acción en APPLICATIONS.md inmediatamente
11. **Resumen** — Aplicaciones, conexiones, novedades, entrevistas, pendientes

### Aprendizajes clave de LinkedIn

1. LinkedIn usa editor tiptap — los `ref` cambian tras cada acción. SIEMPRE tomar `browser_snapshot` nuevo antes de interactuar.
2. Headline: `/in/galiprandi/edit/intro/` → Meta+A → reescribir → Save
3. About: `/in/galiprandi/edit/forms/summary/new/` → mismo patrón
4. Open to Work: `/in/galiprandi/opportunities/job-opportunities/edit/` → máx 5 job titles
5. `mcp6_send_message` y `mcp6_connect_with_person` requieren `confirm_send: true`

### Empresas objetivo (resumen)

- **Tier 1 (latinas grandes)**: Mercado Libre, Globant, dLocal, Rappi, Nubank
- **Tier 2 (globales con LATAM)**: Caylent, iFood, VTEX, Stone, EBANX
- **Tier 3 (scale-ups AI)**: Kiwi, Blanc Labs, Sezzle
- Ver lista completa con URLs de careers en `.agents/skills/job-search/PROFILE.md`

### Nota sobre inglés

Nivel B2+. Puede trabajar en inglés escrito y técnico. No descartar posiciones en inglés. Priorizar empresas latinas o con cultura latina donde la barrera idiomática no sea crítica.
