---
title: "De islas a una red mesh: agentes que se descubren y colaboran"
description: "Los agentes de IA se multiplicaron pero viven aislados. Qué cambia cuando dejan de ser appliances cerrados y se convierten en nodos de una red que se autodescubre, pide permiso y delega trabajo real."
pubDate: 2026-10-06T00:00:00-03:00
tags: ["AI", "Agents", "A2A", "ACP", "Open Source"]
lang: es
postSlug: agents-mesh-network
---

Los agentes de IA se multiplicaron en el último año. Codex, Claude Code, Devin, OpenCode, agentes custom armados con el AI SDK de Vercel o LangGraph. Cada uno cada vez más capaz. Y sin embargo, todos comparten la misma arquitectura solitaria: corren aislados en su propio proceso, con su propio contexto, sin saber que existen otros.

El resultado es que el usuario termina siendo el middleware humano: detectás un error, lo copiás, se lo pegás al agente que vive en el repo afectado, esperás la respuesta, la llevás a otro lado. Los agentes son brillantes. La plomería entre ellos somos nosotros.

> La pregunta incómoda: ¿por qué tus agentes no pueden pedirse ayuda entre ellos?

## No es "agentes que hablan" — es delegación real

Es tentador pensar esto como "un chatbot le habla a otro". No es eso. Es algo bastante más útil: **delegación de trabajo entre unidades autónomas**.

Pedir información es trivial — un doc compartido o un MCP server lo resuelven. Delegar una tarea es distinto: le pasás responsabilidad a un agente que tiene su propio filesystem, sus herramientas, su contexto y sus permisos. No te responde una pregunta; *encarga el trabajo y te devuelve el resultado hecho*.

```
agente-monitoring (mirando errores de producción)
    │  detecta una racha de 500s en /checkout
    ▼
agente-del-repo (vive en ese repo, conoce el código)
    │  abre el código, corre los tests, reproduce
    ▼
"el retry de payment.ts no tiene backoff — el fix está listo para revisar"
```

Nadie fue a buscar el swagger. Nadie copió el stack trace a un chat. El agente que sabe de ese código hizo el trabajo.

## La red no discrimina

Acá está la parte que me parece más potente: la red es agnóstica de vendor.

Un agente enterprise como Codex o Claude Code y un agente que armaste vos en un fin de semana con `streamText` y dos tools son **pares de igual jerarquía**. Misma red, mismo protocolo, mismos derechos.

```
Codex (repo backend)        ──┐
Claude Code (repo frontend)  ──┤
Devin (infra)                ──┤── mesh A2A
tu facturador (AI SDK, ~200 líneas) ──┤
tu monitor (LangGraph)       ──┘
```

Esto cambia la ecuación del vendor lock-in: el agente es un peer intercambiable dentro de **tu** red. Si mañana sale uno mejor para backend, lo enchufás, se autodescubre, y los demás empiezan a delegarle sin que tengas que reconfigurar nada. La red es tuya, no del proveedor.

## Lo que esto habilita (con ejemplos concretos)

**Blue/green de agentes.** Querés probar si Claude Code maneja mejor un tipo de tarea que Codex, sin apagar el que funciona. Levantás el nuevo como peer paralelo en la misma red — se autodescubre, probás una delegación, y si convence asume el rol; si no, lo matás y el viejo nunca dejó de correr. Es el despliegue blue/green que conocés, pero de agentes. El peer es el servicio; el runtime adentro es reemplazable en caliente.

**Especialistas, no generalistas.** En vez de un super-agente que intenta todo, una constelación de especialistas: uno corrige textos, otro traduce, otro codea, otro revisa métricas. Cada delegación va al que sabe hacerlo. Probé exactamente esto en vivo: un orquestador Devin descubriendo y delegándole a un corrector corriendo Antigravity y a un traductor corriendo OpenCode — cuatro runtimes distintos hablando el mismo idioma.

**Incident routing sin intervención.** El agente que vigila Grafana detecta el patrón, encuentra al agente del repo afectado en la red, y le pasa el diagnóstico — no te manda una alerta, le *delega la investigación* al que puede resolverla.

## Por qué mesh y no grafo

Frameworks como LangGraph o CrewAI ya orquestan agentes — pero lo hacen como **un grafo dentro de un solo proceso**: vos cableás nodos y aristas, todo comparte el mismo runtime, y meter las capacidades reales de un agente como Codex (su filesystem, sus tools, sus permisos) dentro de un nodo significa reimplementarlo.

La mesh invierte eso: cada agente es una unidad autónoma completa que corre en su propio proceso, su propio repo, su propia máquina. Se descubren entre sí — por broadcast en la LAN, por un archivo compartido en el mismo host, o por un registry de descubrimiento — y se hablan directo, peer to peer. No hay broker en el medio viendo todas las conversaciones.

Y lo más importante: **descubrirse no es confiarse**. Un agente nuevo aparece en la red y queda en estado `pending` hasta que el dueño lo aprueba explícitamente — los dos lados tienen que aceptar, como agregar a alguien en Telegram. Que un agente sea mío no significa automáticamente que quiero que colabore con todo lo demás.

## Qué hace esto hoy, honestamente

Todo esto vive en [acp-connector](https://github.com/galiprandi/acp-connector) v0.11.0 — el bridge que ya conectaba Telegram/Discord con agentes ACP ahora los convierte en nodos de una red A2A.

Lo que funciona hoy:
- Discovery real en LAN / mismo host / contenedores
- Pairing con doble opt-in y comandos `/a2a` para gestionar la red
- `message/send` y `message/stream` (SSE) spec-compliant
- El agente recibe tools MCP (`list_remote_agents`, `send_message`) para descubrir y delegar por su cuenta
- Interoperabilidad probada: Devin, OpenCode, pi, Antigravity delegándose tareas entre sí

Lo que falta (fase 2):
- Confianza criptográfica para peers fuera de tu LAN (JWS, OAuth2/mTLS)
- Tasks asincrónicas de larga duración con notificaciones push
- El wiring completo del escenario Grafana: hoy pueden delegar; que sepan *cuándo* hacerlo bien es el problema siguiente

## El cambio de modelo mental

La industria de agentes hoy está construyendo appliances: productos cerrados que solo podés usar desde su interfaz, aislados por vendor.

El modelo alternativo es tratar a los agentes como **servicios**: descubribles en la red, deployables independientemente, intercambiables en caliente, delegables entre sí. Como los microservicios, pero la unidad no es un endpoint — es una entidad con contexto, herramientas y responsabilidad propia.

Los agentes ya no están solos. Se conocen, colaboran y trabajan en equipo — en una red que es tuya.
