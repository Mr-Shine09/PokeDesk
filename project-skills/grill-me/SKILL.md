---
name: grill-me
description: Challenge a product, feature, architecture, implementation plan, or launch proposal through focused adversarial questioning. Use when a user asks to be grilled, pressure-tested, challenged, red-teamed, or wants assumptions converted into explicit decisions, experiments, acceptance criteria, and stop conditions before implementation.
---

# Grill Me

Turn an appealing idea into a defensible plan without draining its personality.

## Workflow

1. Restate the proposed outcome in one sentence.
2. Separate known facts, assumptions, preferences, and unknowns.
3. Ask only high-leverage questions whose answers can change scope, architecture, UX, privacy, cost, or schedule.
4. Challenge contradictions directly and explain the consequence of leaving each unresolved.
5. Convert answers into decisions, experiments, acceptance criteria, or deferred risks.
6. End each round with a verdict: `ready`, `ready with experiments`, or `not ready`.

## Grilling Order

Cover these lenses in order, skipping only those that clearly do not apply:

1. User and job: who benefits, what moment triggers use, and what existing behavior it replaces.
2. Success: observable behavior, quality bar, failure budget, and the evidence required to claim completion.
3. Scope: smallest lovable version, explicit exclusions, and which attractive features are distractions.
4. Interaction: first run, controls, interruption cost, accessibility, reduced motion, and recovery from mistakes.
5. Data and privacy: observed signals, stored data, permissions, retention, and whether a less invasive design works.
6. Technical risk: uncertain platform behavior, unsupported integrations, performance, packaging, and rollback.
7. Operations: diagnostics, updates, compatibility, support burden, and maintenance owner.

## Question Discipline

- Ask one to three questions per round.
- Lead with the question most likely to invalidate the current plan.
- Offer a recommended default when the choice is reversible and the evidence is adequate.
- Do not ask questions that local inspection, official documentation, or a small prototype can answer.
- Do not accept words such as “fast,” “small,” or “polished” without a measurable or reviewable bar.
- Do not let implementation begin while a privacy-sensitive signal source or core state transition is undefined.

## Output

Maintain a compact decision record:

```text
Decision: <what is settled>
Evidence: <source, experiment, or user answer>
Risk: <remaining uncertainty>
Next gate: <criterion required before implementation continues>
```

When the user explicitly asks to proceed despite an unresolved risk, record the exception and its consequence instead of repeatedly objecting.
