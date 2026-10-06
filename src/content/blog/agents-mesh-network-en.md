---
title: "From Islands to a Mesh: Agents That Discover and Collaborate"
description: "AI agents multiplied but live in isolation. What changes when they stop being closed appliances and become nodes in a network that self-discovers, asks permission, and delegates real work."
pubDate: 2026-10-06T00:00:00-03:00
tags: ["AI", "Agents", "A2A", "ACP", "Open Source"]
lang: en
postSlug: agents-mesh-network
---

AI agents multiplied over the last year. Codex, Claude Code, Devin, OpenCode, custom agents built with the Vercel AI SDK or LangGraph. Each one increasingly capable. And yet they all share the same lonely architecture: running isolated in their own process, with their own context, unaware that others exist.

The result is that the user ends up being the human middleware: you spot an error, copy it, paste it to the agent living in the affected repo, wait for the answer, carry it somewhere else. The agents are brilliant. The plumbing between them is us.

> The uncomfortable question: why can't your agents ask each other for help?

## Not "agents talking" — real delegation

It's tempting to picture this as "a chatbot talking to another chatbot". It isn't. It's something far more useful: **delegation of work between autonomous units**.

Asking for information is trivial — a shared doc or an MCP server solves that. Delegating a task is different: you hand responsibility to an agent that has its own filesystem, its own tools, its own context and permissions. It doesn't answer a question; it *takes ownership of the work and returns the finished result*.

```
monitoring agent (watching production errors)
    │  detects a streak of 500s on /checkout
    ▼
repo agent (lives in that repo, knows the code)
    │  opens the code, runs the tests, reproduces
    ▼
"payment.ts retries have no backoff — fix ready for review"
```

Nobody went looking for the swagger. Nobody pasted a stack trace into a chat. The agent that actually knows that code did the work.

## The network doesn't discriminate

Here's the part I find most powerful: the network is vendor-agnostic.

An enterprise agent like Codex or Claude Code and an agent you built over a weekend with `streamText` and two tools are **peers of equal standing**. Same network, same protocol, same rights.

```
Codex (backend repo)         ──┐
Claude Code (frontend repo)  ──┤
Devin (infra)                ──┤── A2A mesh
your billing bot (AI SDK, ~200 lines) ──┤
your monitor (LangGraph)     ──┘
```

This changes the vendor lock-in equation: the agent is an interchangeable peer inside **your** network. If tomorrow a better backend agent ships, you plug it in, it self-discovers, and the others start delegating to it without you reconfiguring anything. The network is yours, not the vendor's.

## What this unlocks (with concrete examples)

**Blue/green agents.** You want to test whether Claude Code handles a task type better than Codex, without shutting down the one that works. You launch the new one as a parallel peer on the same network — it self-discovers, you try a delegation, and if it convinces you it takes over; if not, you kill it and the old one never stopped running. It's the blue/green deployment you already know, but for agents. The peer is the service; the runtime inside is hot-swappable.

**Specialists, not generalists.** Instead of a super-agent that attempts everything, a constellation of specialists: one fixes copy, one translates, one codes, one watches metrics. Every delegation goes to the one that knows how. I tested exactly this live: a Devin orchestrator discovering and delegating to a proofreader running Antigravity and a translator running OpenCode — four different runtimes speaking the same language.

**Incident routing without intervention.** The agent watching Grafana detects the pattern, finds the repo agent on the network, and hands off the diagnosis — it doesn't send you an alert, it *delegates the investigation* to the one that can resolve it.

## Why mesh, not graph

Frameworks like LangGraph or CrewAI already orchestrate agents — but as **a graph inside a single process**: you wire nodes and edges, everything shares the same runtime, and embedding the real capabilities of an agent like Codex (its filesystem, tools, permissions) inside a node means reimplementing it.

The mesh inverts that: every agent is a complete autonomous unit running in its own process, its own repo, its own machine. They discover each other — via LAN broadcast, a shared file on the same host, or a discovery registry — and talk directly, peer to peer. No broker in the middle watching every conversation.

And critically: **discovering isn't trusting**. A new agent shows up on the network and sits in `pending` state until its owner explicitly approves it — both sides must accept, like adding someone on Telegram. An agent being mine doesn't automatically mean I want it collaborating with everything else.

## What this does today, honestly

All of this lives in [acp-connector](https://github.com/galiprandi/acp-connector) v0.11.0 — the bridge that already connected Telegram/Discord to ACP agents now turns them into nodes of an A2A network.

What works today:
- Real discovery on LAN / same host / containers
- Double opt-in pairing and `/a2a` commands to manage the network
- `message/send` and `message/stream` (SSE), spec-compliant
- The agent gets MCP tools (`list_remote_agents`, `send_message`) to discover and delegate on its own
- Proven interoperability: Devin, OpenCode, pi, Antigravity delegating tasks to each other

What's missing (phase 2):
- Cryptographic trust for peers beyond your LAN (JWS, OAuth2/mTLS)
- Long-running async tasks with push notifications
- The full Grafana wiring: today they can delegate; knowing *when* to delegate well is the next problem

## The mental model shift

The agent industry today is building appliances: closed products you can only use through their interface, siloed by vendor.

The alternative model treats agents as **services**: discoverable on the network, independently deployable, hot-swappable, delegable to each other. Like microservices, except the unit isn't an endpoint — it's an entity with context, tools, and its own responsibility.

Agents aren't alone anymore. They know each other, collaborate, and work as a team — on a network that is yours.
