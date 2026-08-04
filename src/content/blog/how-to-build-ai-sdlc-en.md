---
title: "How to build an AI-powered SDLC: architecture, instrumentation and results"
description: "A concrete guide on how to build, instrument and measure a software development workflow with AI agents. Includes MCP architecture, tracing tags, conversion funnel and real results from a pilot team."
pubDate: 2026-08-04T00:00:00-03:00
tags: ["AI", "Agent-First", "SDLC", "MCP", "Workflow", "Instrumentation"]
lang: en
postSlug: how-to-build-ai-sdlc
---

When a development team adopts AI agents in isolation (a copilot here, a chatbot there), the impact is marginal. When you instrument the full end-to-end workflow, the numbers change. In a pilot team of 800+ developers, throughput grew 440% in four months after implementing the flow described in this post.

This is not theory. It is a guide on how to build it, how to measure it, and what results you can expect.

## The problem no one wants to admit

Most teams lose hours — sometimes days — on tasks that don't add direct value. Ambiguous requirements discovered during code review. Context lost between planning and development. Designs that translate poorly to code. PRs reviewed blindly because no one remembers what was agreed a week ago.

Individual AI tools help, but they don't solve the core problem: **context gets lost between stages**. An agent that writes code fast is useless if it doesn't know what to write. An agent that drafts tickets is useless if the developer doesn't read them.

The solution isn't better AI. It's a workflow designed so that context travels from one stage to the next without friction, and so that each agent works with complete information.

## The flow architecture

The flow has four sequential stages. The output of each one is the exact input of the next:

**User Story → Refinement → Development → Functional Review**

Each stage has a primary human role and a specialized agent. The agent doesn't replace the human: it amplifies them.

### 1. User Story

The Product Owner describes the need in natural language. The agent structures it into a user story with clear acceptance criteria and a technical deliverables section that includes copy, design tokens, components, layout, accessibility and assets. All self-contained: development and review don't need to open another tool.

If information is missing, the agent detects it and asks. It never invents answers.

### 2. Refinement

The agent proposes a high-level plan for the team to debate in minutes. Once approved, it breaks down each task into subtasks with testable acceptance criteria, proposed tests and estimation. The team focuses on deliberating, not on writing tickets.

### 3. Development

The agent reads the subtask, proposes an implementation plan, writes code, runs tests. The developer reviews each step and approves. Symbiosis: the agent produces fast and consistently, the human decides and validates.

### 4. Functional Review

The reviewer, assisted by their agent, cross-references the PR code against the acceptance criteria of the original User Story. Runs tests, analyzes quality and security, generates evidence. This is not traditional code review: it is automated assurance that the delivery meets what the business asked for.

The final decision is always human. The agent ensures that decision is informed.

## How to build the MCP

For this flow to work in real teams with real tools, you need an **MCP (Model Context Protocol) server** that acts as the process gatekeeper. It's not optional: without an MCP that standardizes how agents interact with your tools, each team does their own thing and consistency is lost.

### Role-based access control

The MCP implements RBAC over the flow. Agents can't execute any action at any time: they must activate a role before acting. Each role unlocks only the tools it needs for that stage.

- **user-story**: can create and update user stories
- **refinement**: can create subtasks and update tickets
- **development**: can update tickets and create commits
- **functional-review**: can update tickets and approve/reject PRs

Read tools (list tickets, get details) are always allowed. Write tools require an active role. If an agent tries to write without a role, it gets a "Contract Violation" and can't continue.

This isn't security against attackers. It's **forced consistency**: teams in different countries working with the same MCP generate identical tickets because the MCP injects the same system prompts and the same rules.

### Dedicated tools

The MCP exposes specific tools for each stage of the flow. They aren't generic wrappers over an API: they're tools built for the flow.

- `wi_create`: creates user stories with structured format (acceptance criteria, deliverables, story points)
- `wi_refine`: generates plan and subtasks linked to the parent story
- `wi_develop`: implements subtasks with code, tests and commits
- `wi_review`: validates acceptance criteria against PR code
- `wi_get`: fetches the full context of a ticket (the "Zero-Hit": the agent reads everything without asking)
- `wi_list`: lists tickets for a project
- `wi_update`: updates tickets (transitions, comments, labels)
- `wi_create_subtask`: creates subtasks with AF (agent-first) format

### System prompts loaded from files

The system prompts that define each role's behavior don't live in code. They live in markdown files loaded at runtime. This allows versioning, review and updates without redeploying. And it allows an AI Ops team to approve changes before they reach production.

## How to instrument for measurement

Without instrumentation you don't know if it works. And if you don't know if it works, you can't improve.

### Automatic tags in the ticket system

Every time an agent executes an MCP tool, the system automatically applies tags to the ticket:

- `w-ai`: always, on any ticket that goes through the flow
- `w-ai:created`: when the user story is created
- `w-ai:refined`: when subtasks are refined
- `w-ai:developed`: when code is implemented
- `w-ai:validated`: when functional review is done

With those tags you can measure virtually anything in your ticket system:

- **AI flow throughput**: tickets with `w-ai:created` per sprint/month
- **Per-stage conversion**: how many tickets with `w-ai:created` reach `w-ai:refined`, and from there to `w-ai:developed`
- **Full cycle**: tickets with all four tags (full-cycle)
- **Lead time AI vs non-AI**: compare tickets with `w-ai` vs without the tag
- **DORA filtered**: deployment frequency, lead time, change failure rate, MTTR — all filterable by `w-ai`

### Audit log

Every MCP tool invocation is persisted to a document database with: session, user, tool, parameters, ticket, project, active role, result, duration, user agent. Fire-and-forget: it doesn't block the agent's response. Two-year TTL so the database doesn't grow indefinitely.

### Adoption dashboard

With the audit log you build a dashboard that shows the **AI SDLC conversion funnel**:

- **Unique WIs per stage**: how many work items went through creation, refinement, development, review
- **Drop-off between stages**: how many are lost from one stage to the next
- **Conversion from previous stage**: percentage of WIs that advance
- **Parking time**: average and median time between consecutive stages (in hours)
- **Coverage**: percentage of WIs that went through multiple stages vs full cycle (4/4)
- **Heatmap**: activity by day of week and hour
- **KPIs with delta**: work items, users, sessions, projects, tool calls — compared against the previous period

The funnel is the most useful piece. It doesn't tell you "we have X tool calls". It tells you **where work items are lost**. If 60% of tickets reach refinement but only 20% reach development, you know the bottleneck is there.

## Results from a pilot team

The flow was evaluated against solutions from the major hyperscalers. The internal proposal was chosen for three reasons: process control, multi-country standardization and cost.

A pilot team adopted the full flow between February and March. These are the results:

| Metric | Before | After | Change |
|---|---|---|---|
| Monthly throughput | 5 items (January) | 27 items (May) | +440% |
| Time-to-market | baseline | 2x-3x faster | with full e2e flow |
| Release flow | 50 min | 5 min | 10x |
| Operational costs | baseline | -75% | |

The throughput growth isn't direct causality — there are seasonal and team factors — but the correlation is clear: a structured flow, with preserved context and aligned teams, delivers more and better.

## What I learned

**1. RBAC wasn't security. It was consistency.**

The first version of the MCP had no roles. It worked, but each team used agents differently. Some created tickets with one format, others with another. When I added RBAC with system prompts injected per role, tickets from teams in different countries became identical. The gating wasn't to prevent agents from doing bad things: it was to ensure they did things the same way.

**2. The funnel is worth more than individual KPIs.**

"We have 500 tool calls this month" tells you nothing. "80% of tickets reach refinement but only 30% reach review" tells you exactly where to intervene. The conversion funnel is the metric that drove the most decisions. If I had to keep one piece of the dashboard, it would be that.

**3. Fire-and-forget in audit was key to adoption.**

If the audit log blocks the agent's response, the agent feels slow. If the agent feels slow, developers stop using it. Fire-and-forget (persisting in the background without waiting) was the decision that made the MCP have no perceptible latency. Developers don't know there's an audit log running. They just know the agent responds fast.

**4. System prompts have to live outside the code.**

The first system prompts were hardcoded in TypeScript. Every change required build + deploy. When I moved them to markdown files loaded at runtime, the AI Ops team could iterate prompts without touching code. Iteration time went from days to minutes. And the 69 content integrity tests ensure nothing breaks when someone edits a prompt.

## What's next

The current flow is stable in production. Next steps are:

- **Prompt registry with versioning**: version control over system prompts, with approval flow and change history
- **Reuse dashboard**: which prompts are reused most, which are most effective, adoption trends per stage
- **Continuous optimization**: user feedback for fine-tuning prompts and tools

## Closing

If you're exploring AI agent adoption in your team or company, I'm interested in exchanging ideas. What I described here isn't a universal recipe: it's what worked in a specific context, with a specific stack and a specific culture. But the principles — e2e flow, instrumentation, RBAC for consistency — are replicable.

The original post on the Workflow AI concepts is [here](/blog/ai-workflow). This is the complement: how to build it and what happens when you put it in production.
