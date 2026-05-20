---
title: "MD Is All You Need"
description: "Exploring the transformation of technical documentation in the AI era: from passive manuals to dynamic, structured context for autonomous agents."
pubDate: 2026-05-20T00:00:00-03:00
tags: ["AI", "Documentation", "Agents", "Engineering", "MD"]
lang: en
postSlug: md-is-all-you-need
---

In the era of AI-augmented development, software is written at an unprecedented speed. A team of engineers assisted by autonomous agents can generate today, in a single workday, the same volume of code that previously required a month of manual development. This exponential acceleration has exposed the major fault line in modern software engineering: **static documentation**.

> "Documentation is often that place where lies settle, grow, and will eventually be promoted to dogmas."

When code mutates continuously through automated pipelines, traditional hand-written documentation becomes fiction within hours of its creation. If an autonomous agent attempts to resolve a ticket based on obsolete specifications, the system collapses due to hallucinations or misinterpretations of the software's actual behavior.

For agents to operate with maximum precision, documentation can no longer be conceived as a passive reading manual for humans. It must transform into **dynamic, structured, low-token context variables**, specifically designed as the model's navigation map. The friction of writing has disappeared thanks to AI; the current challenge lies in the orchestration, validation, and persistence of technical truth.

## The Documentation Pyramid

To solve the problem of consistency at scale, the documentation of an agent-oriented organization must be structured into a three-layered architecture. Each layer has a distinct purpose, abstraction level, and automated validation method.

```
       [ Layer 2: Corporate ]      --> KMS, IDPs, Wikis (Business Processes)
      [ Layer 1: The Repository ]    --> The Fantastic 5 (Indexable Context)
     [ Layer 0: Behavior ]     --> Asserts and Tests (Executable Truth)

```

### Layer 0: Hard Behavior (The Executable Truth)

The base of the pyramid consists of assertions from unit, integration, and end-to-end (E2E) tests. It is the only living documentation that cannot lie: if the code changes and contradicts the test, the suite fails and the continuous integration (CI) pipeline stops. It represents the technical specification at its purest and most deterministic level.

### Layer 1: The Repository (The Indexable Context)

Located at the root of each project, this layer is composed of **The Fantastic 5**. It acts as the repository's local manifesto and operates analogously to a local *Model Context Protocol* (MCP). Its function is to synthesize Layer 0 code into hierarchically structured .md files. It is the optimized context that the agent consumes before examining the system's internal logic.

### Layer 2: Corporate (Transversal Processes)

The top of the pyramid houses knowledge management systems (KMS), internal developer portals (IDP), and institutional wikis. It documents transversal business processes, distributed enterprise architectures, security policies, and global deployment methodologies. It is asynchronously fed via pipelines from the data consolidated in Layer 1.

## The Boy Scout Principle for Autonomous Agents

The methodology for documentary consistency is governed by an absolute and unbreakable rule imposed on any model interacting with the repository: **The Boy Scout Principle**.

It doesn't matter if an agent has been invoked to fix a visual bug, optimize a database query, or add a new endpoint; if during the analysis phase the model detects a *gap* (information breach), a semantic inconsistency, or a contradiction between Layer 1 files and the actual code execution, **it has the imperative obligation to stop, correct the documentation, and close the gap** before proceeding with its primary task.

No Pull Request can be approved if the agent introduces code that misaligns the Fantastic 5 ecosystem.

## The Fantastic 5: Layer 1 Architecture

Each of these five files must reside in the repository root in Markdown (.md) format, the native language of LLMs due to its clean hierarchical structure and high information density per token.

### 1. README.md

#### What it stores
The technical roadmap, the business purpose the repository solves, the precise tech stack, required environment variables, system prerequisites, and the sequential initialization and local deployment commands.

#### What it's for
To ensure immediate and deterministic onboarding for both human developers and software agents. It allows setting up the simulated development or testing environment without the need to infer configurations.

#### How it is structured and managed
 * **Owner:** Human Developer.
 * **Update Trigger:** Only upon repository creation or structural changes in the development infrastructure (e.g., Node runtime version update, local database engine migration, or addition of global system dependencies).

```markdown
# [Repository Name]

## System Purpose
Brief description of the business domain this service solves.

## Tech Stack
* Runtime / Language: Node.js v20+, TypeScript v5.
* Main Framework: Fastify.
* Persistence: PostgreSQL via Prisma ORM.

## Environment Configuration
Exact commands to replicate environment variables (.env.example).

## Local Initialization
1. `npm install`
2. `npm run db:migrate`
3. `npm run dev`
```

### 2. AGENTS.md

#### What it stores
The internal operating manual for the Artificial Intelligences manipulating the repository. It contains the inventory of available skills and tools, security policies for command execution, local coding restrictions, and **contextual routing rules** explicitly indicating when and under what criteria each of the repository's other Markdown files should be consulted and updated.

#### What it's for
It acts as the project's dynamic and bounded *system prompt*. It prevents the agent from assuming generic industry conventions that conflict with the repository's specific design and architecture decisions.

#### How it is structured and managed
 * **Owner:** Co-owned (Human + context-organizer). The human defines ethical and operational boundaries; the agent optimizes internal skill instructions when friction is detected in execution.
 * **Update Trigger:** When adding or modifying automated capabilities, code analysis tools, or autonomous workflows in the pipeline.

```markdown
# AGENTS.md - System Instructions

## Documentary Consultation Matrix
* To understand architecture restrictions before coding: Mandatory consultation of `ADR.md`.
* To ensure aesthetic consistency and visual component reusability: Consult and update `DESIGN.md`.
* To validate impact on existing business logic: Consult and synchronize `BEHAVIOR.md`.

## Local Operational Restrictions
1. Use of external libraries not listed in package.json is prohibited without prior ADR approval.
2. Every logic change must include its respective unit test validating the business rule.
3. The CI agent will mandatorily execute the BEHAVIOR.md parser on every pre-commit.
```

### 3. DESIGN.md

#### What it stores
UI/UX design guidelines under the standard Google Labs specification for design.md. It stores design tokens (exact color palettes, typographic scales, spacing), the catalog of reusable web components consolidated in the project, and patterns for common visual state management (loading screens, error handling, empty lists, and WCAG accessibility criteria).

#### What it's for
To prevent visual fragmentation and UI degradation. When autonomous agents generate views or frontend components at scale, they tend to invent ad-hoc styles if they lack restrictions; this file forces them to reuse the existing component infrastructure and maintain the application's aesthetic consistency.

#### How it is structured and managed
 * **Owner:** The AI Agent, induced by the operational skill defined in AGENTS.md.
 * **Update Trigger:** Autonomous and proactive. Every time the agent generates or refactors interfaces and detects that a new visual pattern or modular component is repeated and justifies its abstraction, it documents it immediately to ensure future reuse.

```markdown
# DESIGN.md - UI/UX Specifications (Google Labs Std)

## Centralized Design Tokens
* Primary Brand Color: `#0055FF` (use CSS variable `--color-primary`)
* Background Surface: `#FFFFFF` / `#121212` (native Dark Mode support)

## Consolidated Component Catalog
### [Button Component]
* Location: `/src/components/ui/Button.tsx`
* Allowed variants: `primary`, `secondary`, `danger`.
* Restrictions: Must always include the `aria-label` property if the content is an icon.

## Global State Management
Every asynchronous data view must implement the `<SkeletonLoader />` component during the fetching phase, mapping errors through the global Error Boundary `/src/components/errors/GlobalBoundary.tsx`.
```

### 4. BEHAVIOR.md

#### What it stores
The living and detailed functional specification of the system's business rules, written in structured prose using ubiquitous language. It does not describe the technical implementation of the code, but the **actual observed and verified behavior** of the application.

#### What it's for
To drastically optimize the *context window* of language models. Instead of forcing an agent to read and index thousands of lines of source code spread across dozens of testing files (full of boilerplate, mock initializations, dependency injections, and test environment configurations) to deduce what the system does, the model reads a single summarized file describing the current behavior with total accuracy. This reduces token consumption by orders of magnitude and eradicates functional hallucinations.

#### How it is structured and managed
 * **Owner:** context-organizer (100% Automated and Original).
 * **Update Trigger:** On each successful execution of the automated test suite in pre-commit hooks or the CI/CD pipeline. A proprietary script extracts structured output from describe() and it() blocks, and the AI polishes the semantics hierarchically. Manual editing of this file is not allowed.

```markdown
# BEHAVIOR.md - Living Specifications

## Module: User Authentication
* MUST allow system access when the user provides valid and verified credentials.
* MUST NOT allow access and must return a 401 error code if the password is incorrect.
* MUST temporarily block the account for 15 minutes after registering 5 consecutive failed attempts.

## Module: Payment Processing
* MUST dispatch a telemetry event of type `order.paid` to the SQS message bus immediately after the payment gateway successfully confirms the transaction.
* MUST atomically revert reserved inventory stock if the gateway rejects the card for insufficient funds.
```

### 5. ADR.md (Architecture Decision Records)

#### What it stores
The historical, chronological, and immutable record of all software architecture, technical data design, and infrastructure decisions made in the project, following the standard industry format (Context, Decision, Consequences).

#### What it's for
To preserve the project's historical context. It decisively prevents the "infinite refactoring loop" where an autonomous agent, analyzing a piece of complex code locally, proposes a technical restructuring that the human team already debated, tested, and discarded months ago due to global operational restrictions.

#### How it is structured and managed
 * **Owner:** Human Developer (Tech Lead / Software Architect).
 * **Update Trigger:** Every time an irreversible, structural, or high-impact technical decision is made for the application's ecosystem.

```markdown
# ADR-004: Migration to Fastify in API Layer

## Context
The original Express.js-based server presents latency issues and high memory consumption under concurrent processing loads exceeding 10,000 requests per second.

## Decision
Migrate the routing and middleware layer to Fastify due to its optimized native performance and integrated JSON schema validation that reduces manual parsing.

## Consequences
* Positive: 40% reduction in CPU consumption in staging environments and strict typing of input/output payloads.
* Negative: Requires rewriting all custom authentication middlewares from the Express ecosystem.
```

## The Automation Engine: context-organizer

The operational viability of this methodology does not rest on human developer goodwill; it is sustained by the technical capacity of the **context-organizer** skill. This piece of engineering is responsible for closing the living feedback loop within the repository, acting under the following sequential and deterministic flow:

```
[Code Change] ➔ [Test Execution] ➔ [JSON Output Extraction] ➔ [Semantic AI] ➔ [BEHAVIOR.md Update]
```

 1. **Empirical Truth Extraction (Brute Force):** The context-organizer invokes an automated script in the local environment or CI/CD pipeline that executes the entire test suite using a structured reporter (e.g., in JSON format). This step ensures that only behavior that has successfully passed technical assertions is considered.
 2. **Proactive Semantic Optimization:** If the script detects that human developers or previous iterations wrote ambiguous or deficient test descriptions (like it("should work") or it("test case 4")), the model's skill kicks in asynchronously. It analyzes the source code of the specific test file, deduces the exact intent of the *assert*, and autonomously injects a correct semantic description into the test file via an automatic Pull Request.
 3. **Clean Documentary Compilation:** With corrected descriptions and a green execution, the context-organizer deterministically compiles the hierarchical output and updates the BEHAVIOR.md file at the module's root.

This mechanism ensures that the model turns to source code strictly when it needs to implement a functional change or repair a failure, but **never to infer the system's general behavior**. The truth is indexed and synthesized beforehand in Layer 1, ready for optimal AI context consumption.

## Links of Interest and Related Resources

 * **context-organizer Skill Framework:** Technical specifications of the integrated skill for management, autonomous curation of structured .md files, and the continuous documentary refactor engine.
 * **Google Labs Code - design.md Standard:** github.com/google-labs-code/design.md – Official industry specification for storing and structuring aesthetic and UI decisions in source code.
 * **Architecture Decision Records (ADR) Spec:** github.com/joelparkerhenderson/architecture-decision-record – Templates and best practices for implementing the immutable architecture decisions format.
 * **Model Context Protocol (MCP):** Documentation of the open protocol for optimized structured context transfer between repositories and large language models.

> *Author's Note:* The operational concept, compilation flow, and contextual injection logic of **BEHAVIOR.md** described in this article constitute an original technical and intellectual development created specifically for software architectures governed by Artificial Intelligence agents.
