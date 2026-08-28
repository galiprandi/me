---
title: "SDD: Are We Stumbling Over the 90s Again?"
description: "A critique of hyper-specification dogmatism in Spec-Driven Development: why reviving Big Design Up Front with LLMs reproduces the C3 project's mistakes, and why Context Engineering and TDD are the way forward."
pubDate: 2026-08-28T00:00:00-03:00
tags: ["SDD", "Spec-Driven Development", "AI", "Context Engineering", "TDD", "XP"]
lang: en
postSlug: sdd-90s-again
---

Spec-Driven Development: Are We Stumbling Over the 90s Again?

The C3 (Chrysler Comprehensive Compensation) project from the mid-90s had an ambitious goal: to unify the payroll of 87,000 employees into a single system built in Smalltalk. However, the team fell into a classic trap of the era: trying to foresee on paper every variation, business rule, and edge case before writing the first line of executable code. After nearly three years of development and millions of dollars invested, the result was disastrous. The system couldn't even issue a single paycheck and computed an unfeasible 1,000 hours of processing time per cycle.

The project collapsed from over-engineering and analysis paralysis. Its rescue came from a disruptive decision led by Kent Beck: discard the rigid scaffolding, implement only the bare minimum needed for the current iteration, and let the architecture emerge validated continuously by code and automated tests. From that crisis, Extreme Programming (XP) was born, popularizing the practice that architecture should not be frozen in an original document, but emerge from the real solution.

Today I watch with concern how a growing trend around Spec-Driven Development (SDD) threatens to drag us into a similar historical loop. A fundamental clarification is in order: the problem is not specification itself, nor SDD well applied to define context. The real danger lies in the dogmatism of hyper-specification and in how many of today's SDD frameworks, under the promise of rigor, push the developer to fill out endless templates that invariably lead to over-specification.

Seeking absolute control over the stochastic nature of language models, the goal becomes drafting hyper-detailed natural-language specifications for every corner of the system before implementing. This practice revives the concept of Big Design Up Front under a modern wrapper: the internal algorithm is micro-managed in prose, the model is stripped of freedom to propose idiomatic solutions, and a fragile structure is built that breaks at the first contact with the runtime.

There is also a recurring myth that keeping these dense specifications saves tokens. The reality is that it generates an interest rate on technical debt. Drafting the initial document consumes a verbose volume of tokens, and keeping it synchronized in parallel with the code as the system evolves in production is a utopia. When the specification inevitably becomes outdated, the model takes it as absolute empirical truth. This triggers hallucinations and infinite correction loops that end up costing infinitely more tokens than letting the LLM inspect the executable codebase directly.

SDD delivers its true value when it stays at its correct level of abstraction: delineating contracts, interfaces, business rules, and guardrails. The internal logic and determinism are not forced into a prose text, but into the automated test suite and approaches like TDD.

As software construction migrates from traditional languages to coordination in natural language, the most critical skill for a developer or architect is not writing exhaustive manuals before implementation. The real key lies in Context Engineering: knowing how to precisely manage what information to include in the prompt to strategically bias the model's behavior, preserving its degrees of freedom to solve without drowning it in implementation details.

> "Design is easy; the hard part is not over-designing before understanding the real problem."
> -- Kent Beck

Ultimately, AI did not come to resurrect the ghosts of Waterfall or to validate the illusion of Laplace's Demon in software engineering: that utopia of believing the developer can know in advance every state and nuance of a complex system to pour it into an omniscient specification. AI demands that we recover methodological maturity: accept emergent complexity, define clear contracts, and remember that definitive validity is not in documents or code, but in production, when the software finally faces users and proves its ability to deliver real value.
