# Workflow Proposal — Current vs. Proposed

## Current Workflow (end-to-end)

```
Phase 1: Planning (Notion)
──────────────────────────
  /pm-create-prd ─── reads Notion DB ID from CLAUDE.md
       │              creates PRD page in Notion
       ▼
  /pm-create-trd ─── reads Notion DB ID from CLAUDE.md
       │              creates TRD as child page of PRD
       ▼
  /pm-prd-ready ──── reads Notion DB ID from CLAUDE.md
       │              sets GitHub Ready = true on PRD
       ▼

Phase 2: Bootstrap (GitHub + repo)
───────────────────────────────────
  /pm-bootstrap ──── reads PRD + TRD from Notion
       │              interviews user about frontend
       │
       ├─ Step 1: Create GitHub Milestones (M1, M2...)
       ├─ Step 2: Create GitHub Issues (with DoD in every body)
       ├─ Step 3: Create & pin Dependency Map issue
       └─ Step 4: Generate CLAUDE.md ◄── THIS IS THE PROBLEM
                    │
                    │  The generated CLAUDE.md contains BOTH:
                    │
                    │  ✅ Project-specific context
                    │     • Build & Run Commands
                    │     • Architecture, Data Models, Patterns
                    │     • Frontend details
                    │     • API Contracts
                    │
                    │  ❌ Universal process rules (same every project)
                    │     • Definition of Done (13-item checklist)
                    │     • Git Workflow — MANDATORY
                    │     • GitHub Workflow conventions
                    │     • Parallel Development rules
                    │     • Staying Up to Date
                    │     • Notion IDs
                    │
                    ▼

Phase 3: Development (daily work)
─────────────────────────────────
  Every session loads CLAUDE.md → ALL of it, every time
       │
       ├─ /pm-next ──── recommends next issue to work on
       │                 (does NOT inject DoD or git rules — assumes CLAUDE.md has them)
       │
       ├─ Developer works on issue
       │    • CLAUDE.md DoD section governs how they work
       │    • CLAUDE.md Git Workflow section governs branching/commits
       │    • CLAUDE.md Parallel Dev section loaded even if solo
       │    • CLAUDE.md Notion IDs loaded even if not using pm-* skills
       │
       ├─ /pm-bug ───── creates bug issue (embeds DoD in issue body — DUPLICATED)
       ├─ /pm-enhancement ── creates enhancement issue (embeds DoD — DUPLICATED)
       ├─ /pm-bughunt ── investigates bugs, optionally fixes with TDD
       └─ /pm-status ─── project health dashboard

  Wasted every session:
    ~200 tokens DoD (only matters when completing)
    ~150 tokens Git Workflow (only matters when committing/branching)
    ~100 tokens GitHub Workflow (only matters when creating issues/branches)
    ~200 tokens Parallel Dev (only matters in multi-agent)
    ~50 tokens Staying Up to Date (should be in skill logic)
    ~50 tokens Notion IDs (only matters for pm-* skills)
    ────────
    ~750 tokens of process rules loaded every session, most sessions don't need them
```

### Current Workflow Pain Points

1. **Token waste** — ~750 tokens of universal process rules loaded on every session regardless of task
2. **Duplication** — DoD checklist appears in CLAUDE.md AND in every issue body AND in `/pm-bug` AND in `/pm-enhancement`
3. **No just-in-time delivery** — Rules are either always-on (CLAUDE.md) or always-embedded (issue templates). No middle ground.
4. **Notion IDs pollute project docs** — Config data living in a documentation file
5. **Parallel dev rules loaded for solo work** — Most sessions are single-agent
6. **Skills can't share rules with agents** — Subagents don't inherit CLAUDE.md unless you explicitly pass it. Process rules in CLAUDE.md don't help spawned agents anyway.

---

## Proposed Workflow

```
Phase 1: Planning (Notion) — UNCHANGED
──────────────────────────────────────
  /pm-create-prd ─── reads Notion DB ID from .claude/notion-config.json
       │              (fallback: ask user, then write the config file)
       ▼
  /pm-create-trd ─── reads Notion DB ID from .claude/notion-config.json
       ▼
  /pm-prd-ready ──── reads Notion DB ID from .claude/notion-config.json

  Change: Notion IDs move from CLAUDE.md to a config file.
  Skills that need them read the config file directly.
  First pm-* skill run on a fresh repo creates the config file.


Phase 2: Bootstrap (GitHub + repo) — SLIMMER
─────────────────────────────────────────────
  /pm-bootstrap ──── reads PRD + TRD from Notion
       │
       ├─ Step 1: Create GitHub Milestones (M1, M2...)
       ├─ Step 2: Create GitHub Issues
       │           • Issue bodies reference DoD by name, NOT inline
       │           • "This issue follows the standard Definition of Done.
       │             Run /pm-dod to review the checklist."
       │
       ├─ Step 3: Create & pin Dependency Map issue
       │
       ├─ Step 4: Generate CLAUDE.md (SLIM — project context only)
       │           • Build & Run Commands
       │           • Local Development Environment
       │           • Architecture (directories, data models, patterns, data flow, API contracts)
       │           • Frontend (framework, components, pages, styling, integration)
       │           • NO DoD, NO git rules, NO parallel dev, NO Notion IDs
       │
       ├─ Step 5 (NEW): Generate .claude/notion-config.json
       │           { "prd_database_id": "...", "prd_page_id": "...", "trd_page_id": "..." }
       │
       └─ Step 6 (NEW): Generate .claude/file-owners.json
                   Maps issue numbers to their file boundaries
                   (consumed by /pm-parallel at invocation time)


Phase 3: Development (daily work) — JUST-IN-TIME RULES
───────────────────────────────────────────────────────

  Every session loads CLAUDE.md → ONLY project context (~400 tokens saved)
       │
       ▼
  ┌─────────────────────────────────────────────────────────────┐
  │  /pm-next ─── "Work on #14: Implement lead scoring"        │
  │       │                                                     │
  │       │  ENHANCED: /pm-next now includes:                   │
  │       │    • Git sync (fetch/pull before work)              │
  │       │    • Branch creation command                        │
  │       │    • "Run /pm-dod before marking complete"          │
  │       │                                                     │
  │       ▼                                                     │
  │  Developer works on issue                                   │
  │    • CLAUDE.md provides project context (architecture,      │
  │      build commands, data models)                           │
  │    • No process rules loaded — just project knowledge       │
  │                                                             │
  │       ▼                                                     │
  │  Ready to commit? ──► /pm-git-workflow                      │
  │       │                 Injects: branch naming, commit       │
  │       │                 format, PR rules, "no issue = no     │
  │       │                 work" — ONLY when needed             │
  │       │                                                     │
  │       │  OR: Hook on git commands auto-injects rules        │
  │       │      (user never has to remember to invoke it)       │
  │       │                                                     │
  │       ▼                                                     │
  │  Ready to close? ──► /pm-dod                                │
  │       │                Injects: TDD checklist, coverage      │
  │       │                targets, completion criteria           │
  │       │                                                     │
  │       ▼                                                     │
  │  Multi-agent work? ──► /pm-parallel                         │
  │                         Injects: file ownership rules        │
  │                         Reads .claude/file-owners.json       │
  │                         ONLY loaded when spawning agents     │
  └─────────────────────────────────────────────────────────────┘

  Standalone skills (unchanged behavior, updated Notion lookup):
       ├─ /pm-bug ───── creates bug issue (references DoD, doesn't inline it)
       ├─ /pm-enhancement ── creates enhancement (references DoD, doesn't inline it)
       ├─ /pm-bughunt ── investigates bugs
       └─ /pm-status ─── project health dashboard


  Agent/subagent support (NEW):
       │
       ▼
  Worker agents get skills preloaded:
       ┌──────────────────────────────────────┐
       │  ---                                  │
       │  name: issue-worker                   │
       │  description: Work on a GitHub issue  │
       │  skills:                              │
       │    - pm-dod                           │
       │    - pm-git-workflow                  │
       │  ---                                  │
       │                                       │
       │  Agent has DoD + git rules injected   │
       │  at startup. No CLAUDE.md dependency. │
       └──────────────────────────────────────┘
```

---

## Side-by-Side: What Changes Where

### CLAUDE.md — Before vs. After

```
BEFORE (~1100 tokens)                    AFTER (~350 tokens)
─────────────────────                    ────────────────────
✅ Build & Run Commands                  ✅ Build & Run Commands
✅ Local Dev Environment                 ✅ Local Dev Environment
✅ Architecture                          ✅ Architecture
✅ Frontend                              ✅ Frontend
❌ Definition of Done          ───►      /pm-dod skill
❌ Git Workflow — MANDATORY    ───►      /pm-git-workflow skill
❌ GitHub Workflow              ───►      /pm-git-workflow skill
❌ Parallel Development        ───►      /pm-parallel skill
❌ Staying Up to Date          ───►      /pm-next (baked in)
❌ Notion IDs                  ───►      .claude/notion-config.json
```

### DoD — Before vs. After

```
BEFORE: Duplicated in 4 places
  1. CLAUDE.md (loaded every session)
  2. Every issue body (created by /pm-bootstrap)
  3. /pm-bug issue template (hardcoded in skill)
  4. /pm-enhancement issue template (hardcoded in skill)

AFTER: Single source of truth
  1. /pm-dod skill (the canonical source)
  2. Issue bodies say "Follows standard DoD — run /pm-dod to review"
  3. /pm-bug and /pm-enhancement reference the skill
  4. Worker agents preload it via skills: [pm-dod]
```

### New Files Created by Bootstrap

```
BEFORE                              AFTER
──────                              ─────
CLAUDE.md (fat)                     CLAUDE.md (slim, project-only)
.claude/bootstrap-state.json        .claude/bootstrap-state.json
                                    .claude/notion-config.json (NEW)
                                    .claude/file-owners.json (NEW)
```

---

## New Skills Summary

| Skill | Type | Trigger | What It Injects |
|---|---|---|---|
| `/pm-dod` | On-demand | Starting/completing an issue, preparing a PR | TDD workflow, 13-item checklist, closure rules |
| `/pm-git-workflow` | On-demand or hook | Branching, committing, opening PRs | Branch naming, commit format, PR rules, sync rules, no-issue-no-work |
| `/pm-parallel` | On-demand | Multi-agent / worktree sessions | File ownership, modular architecture rules, phase serialization |

### Skills That Change

| Skill | Change |
|---|---|
| `/pm-bootstrap` | Slim CLAUDE.md template, generate config files, remove DoD from issue bodies |
| `/pm-next` | Add git sync step, add branch creation, reference `/pm-dod` |
| `/pm-bug` | Replace inline DoD with reference to `/pm-dod` |
| `/pm-enhancement` | Replace inline DoD with reference to `/pm-dod` |
| `/pm-create-prd` | Read Notion IDs from `.claude/notion-config.json` instead of CLAUDE.md |
| `/pm-create-trd` | Read Notion IDs from `.claude/notion-config.json` instead of CLAUDE.md |
| `/pm-prd-ready` | Read Notion IDs from `.claude/notion-config.json` instead of CLAUDE.md |

### Skills That Don't Change

| Skill | Why |
|---|---|
| `/pm-status` | Doesn't reference CLAUDE.md or DoD directly |
| `/pm-bughunt` | Uses CLAUDE.md only for repo detection (still works with slim version) |

---

## Migration Path

1. **Create the 3 new skills** — `/pm-dod`, `/pm-git-workflow`, `/pm-parallel`
2. **Update `/pm-bootstrap` Step 4** — Slim CLAUDE.md template, add Steps 5-6 for config files
3. **Update Notion-reading skills** — Switch from CLAUDE.md parsing to `.claude/notion-config.json`
4. **Update `/pm-bug` and `/pm-enhancement`** — Replace inline DoD with skill reference
5. **Update `/pm-next`** — Add git sync, branch creation, DoD reference
6. **Existing projects** — Run a one-time migration to slim existing CLAUDE.md files and generate config files. Could be a `/pm-migrate` skill or manual.

No existing workflow breaks. The same commands work the same way — they just pull process rules from skills instead of CLAUDE.md. The user experience is identical; the token budget is better.
