# Shared: Database Schemas & Templates

## Notion Database Schemas

**PRDs Database** properties:

| Property | Type | Values |
|---|---|---|
| Name | title | `PRD-NNN: Feature Name` |
| Status | select | Draft, In Review, Approved, Shelved |
| Priority | select | P0 - Now, P1 - Next, P2 - Later, Shelved |
| Category | select | Internal Ops, Client Demo, GTM |
| GitHub Ready | checkbox | true/false |
| Status Dashboard | URL | link to dashboard child page |

**Project Board Database** (inline, child of dashboard) properties:

| Property | Type | Values |
|---|---|---|
| Story | title | story/bug/enhancement title |
| Status | select | To Do, In Progress, Done, Blocked |
| Milestone | select | M1, M2, M3, etc. |
| Phase | select | Phase 1, Phase 2, Phase 3, etc. |
| Dependencies | rich_text | depends on story IDs |
| Description | rich_text | story description |
| Type | select | Story, Bug, Enhancement, Chore |
| GitHub Issue | URL | link to GitHub issue |

---

## Definition of Done (Standard)

Used by bootstrap issues, bugs, and enhancements:

```
- [ ] Failing test written first and committed before implementation
- [ ] Implementation makes test pass
- [ ] Full test suite passes -- no regressions
- [ ] No commented-out code, no hardcoded values
- [ ] Every TODO references a GitHub issue number
- [ ] Merged via PR -- issue closed on merge only
```

## Definition of Done (Bug)

```
- [ ] Failing test reproduces the bug -- committed before fix
- [ ] Fix makes the test pass
- [ ] Full test suite passes -- no regressions
- [ ] Error state now handled and tested
- [ ] Merged via PR -- issue closed on merge only
```

---

## Issue Body Template (Bootstrap)

```
## Story
As a [role], I want [action] so that [outcome].

## Context
[1-2 sentences: why this matters, where it fits]

## Acceptance Criteria
- [ ] [Specific, testable criterion]

## Definition of Done
[Insert Standard DoD from above]

## Dependencies
- Blocked by: #[N] -- [reason] (or "None")
- Blocks: #[N] -- [reason] (or "None")

## Technical Details (from TRD)
[Relevant models, contracts, constraints]

## Files (ownership for parallel development)
- Creates: [file list]
- Modifies: [file list or "none -- uses auto-loaded pattern"]
```

**Labels:** Type (setup/build/test/integration/frontend/docs/bug/chore) + Feature (F1/F2/F3...).

---

## Bug Report Template

```
## Bug Report

## What is happening
[Current behaviour]

## What should happen
[Expected behaviour]

## Steps to Reproduce
1. [Step]

## Environment
[Context]

## Definition of Done
[Insert Bug DoD from above]

## Notes
[Additional context]
```

## Enhancement Request Template

```
## Enhancement Request

## Current Behaviour
[What happens today, or "N/A" if net-new]

## Proposed Behaviour
[What should happen]

## Motivation
[Why this matters]

## Acceptance Criteria
- [ ] [Specific, testable criterion]

## Definition of Done
[Insert Standard DoD from above]

## Notes
[Additional context]
```

---

## Resume State Schema

For multi-step operations (bootstrap, bughunt, create, trd), save to `.claude/pm-state.json` in the project directory:

```json
{
  "version": 1,
  "action": "bootstrap|bughunt|create|trd",
  "project_name": "...",
  "started_at": "ISO",
  "updated_at": "ISO",
  "current_step": "...",
  "data": { }
}
```

**For interview actions (create, trd)**, `data` stores completed topics:

```json
{
  "data": {
    "completed_topics": {
      "name_and_pitch": { "name": "Feature X", "pitch": "..." },
      "problem": "...",
      "goals": ["...", "..."]
    },
    "current_topic": 4,
    "prd_ref": "PRD-009"
  }
}
```

If state exists, present summary and ask: "Resume from where you left off, or start fresh?"
If resume: show a recap of completed topics, then continue from the next unanswered topic.
If fresh: delete state file and start over.
