# AGENTS

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

## Búsqueda Laboral Automatizada

### Skill: `job-search`

Instalada en `~/.codeium/windsurf/skills/job-search/SKILL.md`. Se invoca con `skill("job-search")` cuando el usuario pide buscar/aplicar a ofertas, revisar novedades, o hacer follow-ups.

**Artefactos en el repo**:
- `scripts/job-search/PROFILE.md` — Perfil estructurado auto-generado desde el CV + lista de empresas objetivo (Tier 1-3)
- `scripts/job-search/APPLICATIONS.md` — Registro de aplicaciones, conexiones, entrevistas y follow-ups (memoria persistente)
- `scripts/job-search/templates/` — Templates de mensajes a recruiters y cover letters
- `job-search-log.md` — Log detallado por sesión (no versionado)

**MCPs**:
- `mcp1_*` (Chrome perfil German) — Browser automation para todo: LinkedIn, Gmail, job sites
- `mcp6_*` (LinkedIn MCP) — Scraping rápido de jobs, inbox, conversaciones (opcional)

**Flujo (100% autónomo)**:
1. **Sync CV → PROFILE.md** — Detecta cambios en `.astro` y regenera
2. **Trazabilidad** — Revisa LinkedIn messages + Gmail por actualizaciones de aplicaciones existentes
3. **Responder recruiters** — Si hay mensajes que requieren respuesta, redacta y pide confirmación
4. **Follow-ups** — Si hay aplicaciones sin respuesta >14 días, envía follow-up
5. **Búsqueda** — LinkedIn (MCP o browser) + empresas objetivo (Tier 1-3) + otros sitios
6. **Fit scoring** — ALTO/MEDIO/BAJO, auto-descarta research/junior
7. **Aplicar** — Mínimo 5 por sesión, Easy Apply o sitio externo, sin duplicar
8. **Conectar con recruiters** — Con confirmación del usuario
9. **Registrar** — Cada acción en APPLICATIONS.md inmediatamente
10. **Resumen** — Aplicaciones, conexiones, novedades, entrevistas, pendientes

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
- Ver lista completa con URLs de careers en `scripts/job-search/PROFILE.md`

### Nota sobre inglés

Nivel B2+. Puede trabajar en inglés escrito y técnico. No descartar posiciones en inglés. Priorizar empresas latinas o con cultura latina donde la barrera idiomática no sea crítica.
