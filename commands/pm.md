---
description: Project management hub. Use for ANY project management task: creating PRDs/TRDs, project status, filing bugs, bootstrapping projects, or tracking what to work on next. Single entry point for all PM workflows.
---

# /pm — Project Management Hub

Single entry point for all project management workflows. Detects environment, loads config, and routes to the correct action.

**On invocation:** read `pm-actions/shared.md` for database schemas and templates, then read the action-specific file listed below.

---

## Environment Detection

Detect on every invocation:

| Signal | Full Mode (Claude Code) | Light Mode (Claude.ai / Desktop) |
|---|---|---|
| Bash tool available | Yes | No |
| File system access | Yes | No |
| `gh` CLI | Yes | No |
| Notion MCP tools | Yes | Yes |

**Full mode** — all actions available.
**Light mode** — create, trd, ready, status, bug, enhancement only.

When light mode user requests a full-only action:
> "That action requires Claude Code (terminal + GitHub CLI). Run `/pm [action]` there."

---

## Configuration

**Load order** — project-level first, then system-level:

1. Project `CLAUDE.md` (repo root) — look for `## Notion` section
2. `~/.claude/CLAUDE.md` — fallback

**Required keys:**

| Key | Used By |
|---|---|
| PRD Database ID | create, trd, ready, bootstrap |
| PRD Page ID | trd, ready, bootstrap, status |
| Dashboard Page ID | bootstrap, status, bug, enhancement |
| Project Board Data Source ID | bootstrap, status, bug, enhancement |

If a required key is missing for the current action, ask the user.

---

## Router

**If `$ARGUMENTS` is `help`**, show usage and stop:

```
/pm — Project Management Hub

Usage:
  /pm                     — Show interactive menu
  /pm help                — Show this help
  /pm create              — Create a new PRD via guided interview
  /pm trd [PRD ref]       — Create a TRD from an existing PRD
  /pm ready [PRD ref]     — Mark a PRD as GitHub Ready
  /pm bootstrap [PRD ref] — Populate Notion board + create GitHub milestones & issues  [Full]
  /pm status              — Project health summary (live in Full, cached in Light)
  /pm next                — Recommend what to work on next                             [Full]
  /pm bug ["description"] — File a bug (GitHub + Notion in Full, Notion-only in Light)
  /pm enhancement ["desc"]— File an enhancement (same dual-write pattern)
  /pm bughunt [#N or desc]— Investigate and root-cause a bug                           [Full]

[Full] = requires Claude Code (terminal + GitHub CLI).

Workflow: create -> trd -> ready -> bootstrap -> next -> (build) -> status
```

**If `$ARGUMENTS` is empty or unrecognized**, show menu filtered by environment:

Full mode:
```
What would you like to do?

 1. create       — Create a new PRD (guided interview)
 2. trd          — Create a TRD from an existing PRD
 3. ready        — Mark a PRD as GitHub Ready
 4. bootstrap    — Populate Notion board + create GitHub milestones & issues
 5. status       — Project health summary
 6. next         — What should I work on next?
 7. bug          — File a bug report
 8. enhancement  — File an enhancement request
 9. bughunt      — Investigate and root-cause a bug
```

Light mode: show 1-3, 5, 7-8 only.

**Routing table** — once action is determined, read the action file and follow it:

| Action | File | Mode |
|---|---|---|
| create | `pm-actions/create.md` | Full + Light |
| trd | `pm-actions/trd.md` | Full + Light |
| ready | `pm-actions/ready.md` | Full + Light |
| bootstrap | `pm-actions/bootstrap.md` | Full only |
| status | `pm-actions/status.md` | Full + Light |
| next | `pm-actions/next.md` | Full only |
| bug | `pm-actions/bug.md` | Full + Light |
| enhancement | `pm-actions/enhancement.md` | Full + Light |
| bughunt | `pm-actions/bughunt.md` | Full only |

**After completing any action**, offer the logical next step:
- create -> "Want to continue to the TRD?"
- trd -> "Want to mark the PRD as ready?"
- ready -> "Ready to bootstrap? (Switch to Claude Code if needed)"
- bootstrap -> "Run `/pm next` to see what to work on first."
- bug/enhancement -> "Run `/pm next` to see how this affects priorities."
