---
name: session-ledger
description: Create and maintain a single living Markdown project ledger across Codex sessions. Use when a repository requires an updatable plan, dated session history, implementation status, decision log, risks, verification evidence, GitHub issue mapping, or a precise handoff for the next session.
---

# Session Ledger

Keep one project document authoritative, current, and useful to a fresh contributor.

## Start of Session

1. Read the entire ledger before changing project files.
2. Confirm the current date and repository state.
3. Reconcile the ledger with code, tests, and GitHub issues; evidence wins over stale prose.
4. Select the smallest unfinished milestone that advances the stated goal.

## Required Sections

Maintain:

- purpose and product principles
- current status and next gate
- scope and non-goals
- architecture and state model
- phased implementation plan with acceptance criteria
- GitHub issue map
- decision log
- risk register
- verification matrix
- dated session log
- next-session handoff

## Update Rules

- Use `YYYY-MM-DD` dates.
- Mark work complete only with evidence such as file paths, test commands, screenshots, or issue links.
- Record decisions separately from hypotheses.
- Add newly discovered risks instead of rewriting history to imply they were known.
- Keep one current status summary; retain chronological session entries below it.
- Link issue numbers after repository creation and keep the mapping synchronized when scope changes.
- End every implementation session by updating the ledger before reporting completion.

## Session Entry Template

```markdown
### YYYY-MM-DD — <short session title>

- Objective:
- Completed:
- Decisions:
- Verification:
- Risks or blockers:
- Next:
```

If the session made no repository change, still record material decisions or explicitly state that the ledger required no update.
