# CLAUDE.md Review — What Should Stay, What Should Go

## Problem

The `/pm-bootstrap` skill generates a CLAUDE.md that contains both **project-specific context** (architecture, build commands, data models) and **universal process rules** (git workflow, DoD, parallel dev rules). The process rules are identical across every bootstrapped project and consume context window tokens on every session — even when they're irrelevant to the current task.

CLAUDE.md should contain only what Claude needs to know about **this project** on **every session**. Everything else should be delivered just-in-time via skills.

---

## Items to Remove from CLAUDE.md

### 1. Definition of Done (DoD)

**What it is:** A 13-item TDD checklist applied when completing an issue.

**Why it should leave:**
- Identical across all projects — not project-specific
- Only relevant when you're actively closing or completing an issue
- Burns ~200 tokens every session regardless of task
- Already duplicated in every issue body (the issue template embeds it)

**Recommendation:** Move to a new `/pm-dod` skill or inject via `/pm-next` when starting work on an issue.

---

### 2. Git Workflow — MANDATORY

**What it is:** Rules like "never merge directly to main", "never run `gh pr merge`", branch naming, commit format.

**Why it should leave:**
- Universal behavioral guardrails, not project-specific
- Only relevant during git operations (branching, committing, PR creation)
- Takes up significant space with warnings and emphasis
- Irrelevant during sessions focused on reading code, debugging, or design

**Recommendation:** Create a `/pm-git-workflow` skill that gets invoked when creating branches, committing, or opening PRs. Could also be implemented as a Claude Code hook on git commands.

---

### 3. GitHub Workflow Conventions

**What it is:** Milestone naming (M1, M2...), issue tagging (F1, F2...), branch naming (`feature/<issue>-description`), commit message format.

**Why it should leave:**
- Process convention, not project knowledge
- Same across all bootstrapped projects
- Only needed when interacting with GitHub issues/milestones/branches

**Recommendation:** Merge into the `/pm-git-workflow` skill above. One skill covers all git + GitHub conventions.

---

### 4. Parallel Development — File Conflict Prevention

**What it is:** Rules for file ownership, architecture patterns to avoid merge conflicts, instructions for multi-agent worktree sessions.

**Why it should leave:**
- Only relevant during multi-agent parallel sessions
- Most sessions are single-agent — this entire block is dead weight
- Large section (~15 lines) that adds no value to typical sessions
- The specific file paths referenced (e.g., `src/routes/`, `public/js/`) are project-specific but the *rules* are universal

**Recommendation:** Create a `/pm-parallel` skill. When spawning parallel agents or working in worktrees, invoke this skill. The project-specific file ownership map can be stored in `.claude/file-owners.json` generated during bootstrap, and the skill reads it at invocation time.

---

### 5. Staying Up to Date (git sync reminders)

**What it is:** "Always sync before starting work", "always sync when resuming", "check branch freshness."

**Why it should leave:**
- Standard git hygiene, not project-specific
- Already handled by resume logic in `/pm-bootstrap` and should be in `/pm-next`
- Boilerplate that adds no unique project context

**Recommendation:** Bake into existing skills (`/pm-next`, `/pm-bootstrap` resume) rather than creating a standalone skill. These skills already partially do this.

---

### 6. Notion IDs

**What it is:** PRD Database ID, PRD Page ID, TRD Page ID — used by pm-* skills.

**Why it should leave:**
- Only relevant when running pm-* commands
- During normal coding sessions this is completely irrelevant context
- Configuration data, not project knowledge

**Recommendation:** Move to `.claude/notion-config.json`. The pm-* skills already need to read config — they can read it from a dedicated config file instead of parsing CLAUDE.md. This also makes it easier to update IDs without modifying CLAUDE.md.

---

## What STAYS in CLAUDE.md

These sections provide project-specific context needed on virtually every session:

| Section | Why It Stays |
|---|---|
| **Build & Run Commands** | Needed every session to run, test, and lint the project |
| **Local Development Environment** | Prerequisites, setup steps, troubleshooting — essential project context |
| **Architecture** | Component hierarchy, key directories — core orientation for any task |
| **Data Models** | Schemas and structures — needed for understanding the codebase |
| **Patterns** | Design patterns specific to this project |
| **Data Flow** | How data moves through the system |
| **API Contracts** | Endpoints and contracts — needed when touching any API code |
| **Frontend** (all subsections) | Framework, components, pages, styling — needed when touching UI |

---

## New Skills to Create

### `/pm-dod` — Definition of Done

**Purpose:** Inject the DoD checklist when starting or completing work on an issue.

**When to invoke:**
- When starting work on an issue (via `/pm-next` or manually)
- When preparing a PR for review
- When checking if work is complete

**What it contains:**
- The full TDD workflow (Red/Green/Refactor)
- The 13-item completion checklist
- Rules about issue closure (merge only, never before)

**Implementation:** Can be a standalone skill OR integrated as a section that `/pm-next` automatically includes when recommending work.

---

### `/pm-git-workflow` — Git & GitHub Conventions

**Purpose:** Inject git workflow rules and GitHub conventions when performing git/GitHub operations.

**When to invoke:**
- Creating a branch
- Making commits
- Opening a PR
- Any git operation in project context

**What it contains:**
- Branch naming: `feature/<issue-number>-short-description`
- Commit format: `Verb noun (#N)`
- PR rules: never merge directly to main, never run `gh pr merge`
- Milestone/label conventions (M1, M2, F1, F2)
- Git sync requirements (fetch/pull before work)
- No issue = no work started

**Alternative:** Could be implemented as a Claude Code **hook** on git commands instead of a skill. A hook would fire automatically without needing explicit invocation.

---

### `/pm-parallel` — Parallel Development Rules

**Purpose:** Inject file ownership rules and conflict prevention guidelines when running multi-agent sessions.

**When to invoke:**
- Spawning worktree agents
- Starting parallel development on multiple issues
- Any multi-agent session

**What it contains:**
- File ownership rules (read from `.claude/file-owners.json`)
- Architecture rules (modular patterns, auto-loaders)
- Test file isolation rules
- Scaffolding-first sequencing
- Phase-based serialization for shared files

**Depends on:** A `.claude/file-owners.json` generated during bootstrap (new addition to bootstrap) that maps issues to their file boundaries.

---

## Changes to `/pm-bootstrap`

To support this refactor, the bootstrap skill needs these updates:

1. **Slim down the CLAUDE.md template** — Remove the 6 sections listed above. Keep only project-specific context sections.

2. **Generate `.claude/notion-config.json`** — Store Notion IDs here instead of CLAUDE.md.

3. **Generate `.claude/file-owners.json`** — Extract file ownership data from issue descriptions during creation and write it to a config file for `/pm-parallel` to consume.

4. **Update pm-* skills** — Change Notion ID lookup from "parse CLAUDE.md" to "read `.claude/notion-config.json`".

---

## Summary

| Current CLAUDE.md Section | Action | Destination |
|---|---|---|
| Build & Run Commands | **Keep** | CLAUDE.md |
| Local Dev Environment | **Keep** | CLAUDE.md |
| Architecture (all subsections) | **Keep** | CLAUDE.md |
| Frontend (all subsections) | **Keep** | CLAUDE.md |
| Definition of Done | **Remove** | New `/pm-dod` skill |
| Git Workflow — MANDATORY | **Remove** | New `/pm-git-workflow` skill |
| GitHub Workflow | **Remove** | New `/pm-git-workflow` skill |
| Parallel Development | **Remove** | New `/pm-parallel` skill |
| Staying Up to Date | **Remove** | Bake into `/pm-next` and `/pm-bootstrap` |
| Notion IDs | **Remove** | `.claude/notion-config.json` |
