---
title: "Cómo construir un SDLC con agentes de IA: arquitectura, instrumentación y resultados"
description: "Guía concreta sobre cómo construir, instrumentar y medir un flujo de desarrollo de software con agentes de IA. Incluye arquitectura del MCP, tags de trazabilidad, funnel de conversión y resultados reales de un equipo piloto."
pubDate: 2026-08-04T00:00:00-03:00
tags: ["AI", "Agent-First", "SDLC", "MCP", "Workflow", "Instrumentation"]
lang: es
postSlug: how-to-build-ai-sdlc
---

Cuando un equipo de desarrollo adopta agentes de IA de forma aislada (un copilot acá, un chatbot allá), el impacto es marginal. Cuando se instrumenta el flujo completo de extremo a extremo, los números cambian. En un equipo piloto de 800+ developers, el throughput creció 440% en cuatro meses tras implementar el flujo que describe este post.

Esto no es teoría. Es una guía de cómo construirlo, cómo medirlo y qué resultados podés esperar.

## El problema que nadie quiere admitir

La mayoría de los equipos pierden horas —a veces días— en tareas que no aportan valor directo. Requisitos ambiguos que se descubren en code review. Contexto que se pierde entre planning y desarrollo. Diseños que se traducen mal a código. PRs revisados a ciegas porque nadie recuerda qué se acordó hace una semana.

Las herramientas de IA individuales ayudan, pero no resuelven el problema de fondo: **el contexto se pierde entre etapas**. Un agente que escribe código rápido no sirve si no sabe qué escribir. Un agente que redacta tickets no sirve si el que desarrolla no los lee.

La solución no es mejor IA. Es un flujo diseñado para que el contexto viaje de una etapa a la siguiente sin fricción, y para que cada agente trabaje con la información completa.

## Arquitectura del flujo

El flujo tiene cuatro etapas secuenciales. La salida de cada una es la entrada exacta de la siguiente:

**User Story → Refinamiento → Desarrollo → Revisión funcional**

Cada etapa tiene un rol humano principal y un agente especializado. El agente no reemplaza al humano: lo amplifica.

### 1. User Story

El Product Owner describe la necesidad en lenguaje natural. El agente estructura eso en una historia de usuario con criterios de aceptación claros y una sección de entregables técnicos que incluye copias, tokens de diseño, componentes, layout, accesibilidad y assets. Todo autocontenido: desarrollo y revisión no necesitan abrir otra herramienta.

Si falta información, el agente la detecta y pregunta. Nunca inventa respuestas.

### 2. Refinamiento

El agente propone un plan de alto nivel para que el equipo lo debata en minutos. Una vez aprobado, desglosa cada tarea en subtareas con criterios de aceptación testeables, tests propuestos y estimación. El equipo se concentra en deliberar, no en redactar tickets.

### 3. Desarrollo

El agente lee la subtarea, propone un plan de implementación, escribe código, ejecuta tests. El desarrollador revisa cada paso y aprueba. Simbiosis: el agente produce rápido y consistente, el humano decide y valida.

### 4. Revisión funcional

El revisor, asistido por su agente, cruza el código del PR contra los criterios de aceptación de la User Story original. Ejecuta tests, analiza calidad y seguridad, genera evidencia. No es code review tradicional: es aseguramiento automatizado de que la entrega cumple con lo que el negocio pidió.

La decisión final siempre es humana. El agente asegura que esa decisión esté informada.

## Cómo construir el MCP

Para que este flujo funcione en equipos reales, con herramientas reales, necesitás un **MCP (Model Context Protocol) server** que actúe como gatekeeper del proceso. No es opcional: sin un MCP que estandarice cómo los agentes interactúan con tus herramientas, cada equipo hace lo suyo y la consistencia se pierde.

### Control de acceso basado en roles

El MCP implementa RBAC sobre el flujo. Los agentes no pueden ejecutar cualquier acción en cualquier momento: deben activar un rol antes de actuar. Cada rol desbloquea solo las herramientas que necesita para esa etapa.

- **user-story**: puede crear y actualizar historias de usuario
- **refinement**: puede crear subtareas y actualizar tickets
- **development**: puede actualizar tickets y crear commits
- **functional-review**: puede actualizar tickets y aprobar/rechazar PRs

Las herramientas de lectura (listar tickets, obtener detalle) siempre están permitidas. Las de escritura requieren rol activo. Si un agente intenta escribir sin rol, recibe un "Contract Violation" y no puede continuar.

Esto no es seguridad contra atacantes. Es **consistencia forzada**: equipos en distintos países trabajando con el mismo MCP generan tickets idénticos porque el MCP les inyecta los mismos system prompts y las mismas reglas.

### Herramientas dedicadas

El MCP expone herramientas específicas para cada etapa del flujo. No son wrappers genéricos sobre una API: son herramientas construidas para el flujo.

- `wi_create`: crea historias de usuario con formato estructurado (criterios de aceptación, entregables, story points)
- `wi_refine`: genera plan y subtareas vinculadas a la historia padre
- `wi_develop`: implementa subtareas con código, tests y commits
- `wi_review`: valida criterios de aceptación contra el código del PR
- `wi_get`: trae el contexto completo de un ticket (el "Zero-Hit": el agente lee todo sin preguntar)
- `wi_list`: lista tickets de un proyecto
- `wi_update`: actualiza tickets (transiciones, comentarios, labels)
- `wi_create_subtask`: crea subtareas con formato AF (agent-first)

### System prompts cargados desde archivos

Los system prompts que definen el comportamiento de cada rol no viven en el código. Viven en archivos markdown que se cargan en runtime. Esto permite versionarlos, revisarlos y actualizarlos sin redeploy. Y permite que un equipo de AI Ops apruebe cambios antes de que lleguen a producción.

## Cómo instrumentar para medir

Sin instrumentación no sabés si funciona. Y si no sabés si funciona, no podés mejorar.

### Tags automáticos en el sistema de tickets

Cada vez que un agente ejecuta una herramienta del MCP, el sistema aplica automáticamente tags al ticket:

- `w-ai`: siempre, en cualquier ticket que pase por el flujo
- `w-ai:created`: cuando se crea la historia de usuario
- `w-ai:refined`: cuando se refinan las subtareas
- `w-ai:developed`: cuando se implementa el código
- `w-ai:validated`: cuando se hace la revisión funcional

Con esos tags podés medir prácticamente cualquier cosa en tu sistema de tickets:

- **Throughput del flujo AI**: tickets con `w-ai:created` por sprint/mes
- **Conversión por etapa**: cuántos tickets con `w-ai:created` llegan a `w-ai:refined`, y de ahí a `w-ai:developed`
- **Ciclo completo**: tickets con los cuatro tags (full-cycle)
- **Lead time AI vs no-AI**: comparar tickets con `w-ai` vs sin el tag
- **DORA filtrado**: deployment frequency, lead time, change failure rate, MTTR — todo filtrable por `w-ai`

### Audit log

Cada invocación de una herramienta del MCP se persiste en una base de datos documental con: sesión, usuario, herramienta, parámetros, ticket, proyecto, rol activo, resultado, duración, user agent. Fire-and-forget: no bloquea la respuesta del agente. TTL de dos años para que la base no crezca indefinidamente.

### Dashboard de adopción

Con el audit log construís un dashboard que muestra el **funnel de conversión del SDLC agéntico**:

- **WIs únicos por etapa**: cuántos work items pasaron por creation, refinement, development, review
- **Drop-off entre etapas**: cuántos se pierden de una etapa a la siguiente
- **Conversión desde etapa anterior**: porcentaje de WIs que avanzan
- **Parking time**: tiempo promedio y mediano entre etapas consecutivas (en horas)
- **Coverage**: porcentaje de WIs que pasaron por múltiples etapas vs ciclo completo (4/4)
- **Heatmap**: actividad por día de semana y hora
- **KPIs con delta**: work items, usuarios, sesiones, proyectos, tool calls — comparado contra el período anterior

El funnel es la pieza más útil. No te dice "tenemos X tool calls". Te dice **dónde se pierden los work items**. Si el 60% de los tickets llegan a refinement pero solo el 20% llegan a development, sabés que el cuello de botella está ahí.

## Resultados de un equipo piloto

El flujo se evaluó contra soluciones de los principales hyperscalers. Se eligió la propuesta interna por tres razones: control del proceso, estandarización multi-país y costo.

Un equipo piloto adoptó el flujo completo entre febrero y marzo. Estos son los resultados:

| Métrica | Antes | Después | Cambio |
|---|---|---|---|
| Throughput mensual | 5 items (enero) | 27 items (mayo) | +440% |
| Time-to-market | baseline | 2x-3x más rápido | con flujo completo e2e |
| Release flow | 50 min | 5 min | 10x |
| Costos operativos | baseline | -75% | |

El crecimiento de throughput no es causalidad directa —hay factores estacionales y de equipo— pero la correlación es clara: un flujo estructurado, con contexto preservado y equipos alineados, entrega más y mejor.

## Lo que aprendí

**1. El RBAC no era seguridad. Era consistencia.**

La primera versión del MCP no tenía roles. Funcionaba, pero cada equipo usaba los agentes distinto. Unos creaban tickets con un formato, otros con otro. Cuando agregué RBAC con system prompts inyectados por rol, los tickets de equipos en distintos países se volvieron idénticos. El gateo no era para evitar que los agentes hicieran cosas malas: era para asegurar que hicieran las cosas igual.

**2. El funnel vale más que los KPIs individuales.**

"Tenemos 500 tool calls este mes" no te dice nada. "El 80% de los tickets llegan a refinement pero solo el 30% llegan a review" te dice exactamente dónde intervenir. El funnel de conversión es la métrica que más decisiones disparó. Si tuviera que quedarme con una sola pieza del dashboard, sería esa.

**3. Fire-and-forget en audit fue clave para la adopción.**

Si el audit log bloquea la respuesta del agente, el agente se siente lento. Si el agente se siente lento, los developers lo dejan de usar. Fire-and-forget (persistir en background sin esperar) fue la decisión que hizo que el MCP no tuviera latencia perceptible. Los developers no saben que hay un audit log corriendo. Solo saben que el agente responde rápido.

**4. Los system prompts tienen que vivir fuera del código.**

Los primeros system prompts estaban hardcoded en TypeScript. Cada cambio requería build + deploy. Cuando los moví a archivos markdown cargados en runtime, el equipo de AI Ops pudo iterar los prompts sin tocar código. El tiempo de iteración bajó de días a minutos. Y los 69 tests de integridad de contenido aseguran que nada se rompa cuando alguien edita un prompt.

## Qué viene

El flujo actual está estable en producción. Los próximos pasos son:

- **Prompt registry con versionado**: control de versiones sobre los system prompts, con flujo de aprobación e historial de cambios
- **Dashboard de reutilización**: qué prompts se reutilizan más, cuáles son más efectivos, tendencias de adopción por etapa
- **Optimización continua**: feedback de usuarios para ajuste fino de los prompts y las herramientas

## Cierre

Si estás explorando adoption de agentes de IA en tu equipo o empresa, me interesa cambiar ideas. Lo que describí acá no es una receta universal: es lo que funcionó en un contexto específico, con un stack específico y una cultura específica. Pero los principios —flujo e2e, instrumentación, RBAC para consistencia— son replicables.

El post original sobre los conceptos del Workflow AI está [acá](/blog/ai-workflow). Este es el complemento: cómo construirlo y qué pasa cuando lo ponés en producción.
