# claude-skills

A complete project management pipeline for Claude Code — from product idea to structured GitHub project, powered by Notion and GitHub.

## How the Pipeline Works

```
Idea → PRD → TRD → Bootstrap → GitHub → Build
```

Every project follows the same flow:

1. **Create a PRD** (`/pm-create-prd`) — A guided interview captures product requirements: what you're building, why, for whom, and how you'll measure success. The PRD is saved to your Notion PRDs database.

2. **Create a TRD** (`/pm-create-trd`) — A technical interview builds the implementation plan: architecture, tool decisions, milestones, stories, and dependencies. The TRD is saved as a child page of the PRD in Notion.

3. **Mark as Ready** (`/pm-prd-ready`) — Validates the PRD has substance and a TRD, then sets `GitHub Ready = true` in Notion. This is the gate between planning and execution.

4. **Bootstrap the Project** (`/pm-bootstrap`) — Reads the PRD + TRD from Notion and generates the full GitHub project structure: milestones, issues with TDD checklists, a dependency map, and a CLAUDE.md file. One atomic operation.

5. **Build** — Use `/pm-next` to find what to work on (and optionally hand off to agent teams via `/pm-team`), `/pm-bug` and `/pm-enhancement` to track issues as they arise, `/pm-bughunt` to investigate problems, and `/pm-status` for project health checks. Reference process rules anytime with `/pm-dod`, `/pm-git-workflow`, and `/pm-parallel`.

### Configuration

Skills read the Notion PRD database ID from `~/.claude/notion-config.json` (system-level, shared across all projects). On first run, if the config file doesn't exist, the skill will ask for your Notion PRD database ID and create it. No hardcoded IDs are stored in the skills themselves.

---

## Installation

### As a Claude Code Plugin (recommended)
Inside any Claude Code session:
```
/plugin marketplace add https://github.com/paulmona/claude
```

### Manual Install
```bash
cp skills/* ~/.claude/commands/
```

---

## Skills Reference

### /pm-create-prd

Guides you through a structured interview to create a Product Requirements Document and saves it to Notion.

**Usage:** `/pm-create-prd` or `/pm-create-prd "Feature name"`

**What it does:**
- Walks through 9 interview topics one at a time: name, problem, goals, non-goals, user stories, success metrics, stakeholders, open questions, and priority
- Coaches you to keep product and technical concerns separate — technical details are redirected to the TRD
- Probes thin answers with follow-up questions to get depth
- Flags production-only metrics that will need instrumentation
- Auto-numbers the PRD by scanning existing entries in Notion
- Drafts the full PRD in Markdown for review before saving
- Creates the page in your Notion PRDs database with Status: Draft

**Output:** A Notion page titled `PRD-{NNN}: {Feature Name}` with all sections populated.

**Next step:** `/pm-create-trd`

---

### /pm-create-trd

Guides you through a technical interview to create a Technical Requirements Document, then saves it as a child page of the PRD in Notion.

**Usage:** `/pm-create-trd PRD-009` or `/pm-create-trd "Feature name"`

**What it does:**
- Locates the PRD in Notion and pulls its content for context
- Walks through 9 technical topics: architecture, tool decisions, interface mapping, observability, milestones, stories per milestone, dependencies, risks, and open questions
- Ensures observability is a dedicated milestone, not an afterthought
- Keeps stories atomic — if a story has "and" in it, it's probably two stories
- Can auto-generate interface mappings from OpenAPI specs or API docs
- Story IDs are sequential (S1, S2, S3...) with explicit dependency declarations
- Drafts the full TRD in Markdown for review before saving
- Creates the TRD as a child page of the PRD in Notion
- Updates the PRD page with a link back to the TRD

**Output:** A Notion page titled `TRD: {Feature Name}` nested under the PRD.

**Next step:** `/pm-prd-ready`

---

### /pm-prd-ready

Validates a PRD and marks it as GitHub Ready in Notion — the gate between planning and execution.

**Usage:** `/pm-prd-ready PRD-002` or `/pm-prd-ready` (lists available PRDs)

**What it does:**
- If no argument, searches Notion for Approved PRDs not yet marked GitHub Ready and presents the list
- Confirms with the user before making any changes
- Sets `GitHub Ready = true` on the PRD page in Notion

**Output:** The PRD's GitHub Ready property is set to true.

**Next step:** `/pm-bootstrap`

---

### /pm-bootstrap

The core skill. Reads a PRD and TRD from Notion and generates a complete GitHub project structure in one operation.

**Usage:** `/pm-bootstrap PRD-002 paulmona/my-repo`

**What it does:**

1. **Pre-flight** — Resolves the Notion database ID (from `~/.claude/notion-config.json` or asks and creates it), fetches the PRD (must be Approved + GitHub Ready), fetches the TRD (warns if missing), and runs a frontend requirements interview if the project has UI.

2. **Milestones** — Creates GitHub milestones from the PRD/TRD milestone sections. Ensures full-stack coverage if the project has a frontend — scaffolding, feature milestones, and frontend integration all get milestones.

3. **Issues** — Decomposes each milestone into discrete, testable issues (1-4 hours each). Every build issue gets a paired test issue written first (TDD). Issues include user story, acceptance criteria, Definition of Done checklist, dependencies, and file ownership boundaries for parallel development. Issues are presented one milestone at a time for review before creation.

4. **Dependency Map** — Creates a pinned GitHub issue showing the full dependency graph organized into parallelizable phases.

5. **CLAUDE.md** — Generates and commits a project-specific CLAUDE.md with build commands, architecture docs, git workflow rules, file ownership rules, and the Definition of Done.

**Supports resuming** — State is saved to `.claude/bootstrap-state.json` after each step. If interrupted, running `/pm-bootstrap` again detects the state file and offers to resume or start fresh.

**Output:** A fully structured GitHub project ready for development.

**Next step:** `/pm-next`

---

### /pm-next

Analyzes GitHub project state and recommends the highest-priority unblocked work.

**Usage:** `/pm-next paulmona/my-repo`

**What it does:**
- Syncs local repo first (`git fetch origin && git pull origin main`)
- Fetches all open milestones, issues, labels, and the pinned dependency map
- Identifies the active milestone (earliest incomplete)
- Classifies issues as UNBLOCKED, BLOCKED, or IN PROGRESS
- Applies priority ordering: test before build (TDD), setup before features, bugs before enhancements
- Flags issues with missing milestones, labels, or DoD checklists
- Offers a work mode choice: work on the issue directly, or batch unblocked issues for agent teams via `/pm-team`

**Output:**
```
## Project Status — repo — date

### Active Milestone: M2: Core Build (60% — 6/10 issues)

### Recommended Next (unblocked, highest priority)
#14 Write failing tests for lead scoring — test issue, TDD requires this before #15

### Also Unblocked (can run in parallel)
#16 Implement API proxy endpoint
#18 Write failing tests for report generation

### Blocked
#15 Implement lead scoring — waiting on #14

### Flags
2 issues have no type label

How would you like to proceed?
- Work on #14 now (start in this session)
- Batch unblocked issues for agent team (hand off to /pm-team)
```

---

### /pm-team

Orchestrates parallel agent work on multiple GitHub issues. Validates issues, checks for file conflicts, and spawns `pm-issue-worker` agents in isolated worktrees.

**Usage:** `/pm-team paulmona/my-repo #12 #13 #14` or `/pm-team` (interactive — fetches unblocked issues and lets you pick)

**What it does:**
- Syncs local repo and fetches all specified issues
- Validates each issue is unblocked (checks dependency map)
- Checks for file ownership conflicts — two issues modifying the same file cannot run in parallel
- Presents the validated batch for confirmation
- Spawns a `pm-issue-worker` agent per issue, each in an isolated worktree
- Reports results as agents complete (PRs created, blockers hit)

**Output:**
```
## Agent Team — paulmona/my-repo

Ready to spawn 3 agents in parallel:

| Agent | Issue | Title                        | Files Created            |
|-------|-------|------------------------------|--------------------------|
| 1     | #12   | Write failing tests for...   | test/scoring.test.js     |
| 2     | #13   | Implement scoring...         | src/scoring.js           |
| 3     | #15   | Wire scoring to frontend     | public/js/scoring.js     |

No file conflicts detected. All issues unblocked.

Launch agents?
```

---

### /pm-dod

Quick reference for the TDD workflow and 13-item Definition of Done checklist. Also preloadable into agent definitions via `skills:` frontmatter.

**Usage:** `/pm-dod`

**What it does:**
- Outputs the full Red-Green-Refactor TDD workflow
- Outputs the complete DoD checklist (same content that's in CLAUDE.md and issue bodies)
- Lists common failures to watch for

**Use cases:**
- Human: quick reference before opening a PR or during code review
- Agent teams: preloaded into `pm-issue-worker` so agents always have the DoD available

---

### /pm-git-workflow

Quick reference for git and GitHub workflow conventions. Also preloadable into agent definitions.

**Usage:** `/pm-git-workflow`

**What it does:**
- Outputs branch naming rules (`feature/<issue-number>-short-description`)
- Outputs commit message format (`Verb noun (#issue-number)`)
- Outputs PR rules (never merge to main, never run `gh pr merge`)
- Outputs sync rules (always fetch/pull before starting work)
- Outputs the full label system (type, feature, severity, priority)

---

### /pm-parallel

Quick reference for parallel development rules and file ownership conventions. Also preloadable into agent definitions.

**Usage:** `/pm-parallel`

**What it does:**
- Outputs file ownership rules (check issue boundaries before modifying files)
- Outputs modular architecture patterns (route loaders, barrel files, auto-discovery)
- Outputs phase rules (scaffolding runs alone in Phase 1, same-phase issues must not touch same files)
- Explains Option A (modular, preferred) vs Option B (sequential, fallback) architecture

---

### /pm-status

Generates a health summary of the entire GitHub project.

**Usage:** `/pm-status paulmona/my-repo`

**What it does:**
- Fetches all milestones (open and recently closed), all issues, and the dependency map
- Calculates per-milestone: % complete, open issues by type, blocked count, missing labels
- Tracks velocity: issues closed in last 7 and 30 days
- Estimates milestone completion at current pace

**Output:**
```
## Project Status — repo — date

### Milestones
| Milestone | Progress | Open | Bugs | Blocked | Status |
|---|---|---|---|---|---|
| M1: Scaffolding | 100% | 0 | 0 | 0 | Complete |
| M2: Core Build | 60% (6/10) | 4 | 1 | 1 | Active |
| M3: Integration | 0% | 8 | 0 | 0 | Not started |

### Open Bugs / Blocked Issues / Health Flags / Velocity

Overall: Yellow — M2 progressing but 1 critical bug blocking #22
```

---

### /pm-bug

Creates a structured bug report as a GitHub issue.

**Usage:** `/pm-bug "Lead scoring returns null when company size is missing"`

**What it does:**
- If no description provided, asks for one
- Asks for: repo, related milestone, severity (Critical / High / Low)
- Creates a GitHub issue with: what's happening, what should happen, steps to reproduce, environment, and a TDD-based Definition of Done checklist
- Applies labels: `bug`, severity, and feature label (F1/F2/F3)
- Assigns to the relevant milestone
- Supports save & exit for pausing before creation

**Output:** A labeled, milestone-assigned bug issue in GitHub.

---

### /pm-enhancement

Creates a structured enhancement request as a GitHub issue.

**Usage:** `/pm-enhancement "Add email notification when assessment report is ready"`

**What it does:**
- If no description provided, asks for one
- Asks for: repo, change type (existing behaviour or net-new), related milestone, priority (High / Medium / Low)
- Flags enhancements that don't fit an existing milestone — may need a new milestone or PRD update
- Creates a GitHub issue with: current behaviour, proposed behaviour, motivation, acceptance criteria, and Definition of Done checklist
- Applies labels: `enhancement`, priority, and feature label
- Assigns to the relevant milestone
- Supports save & exit for pausing before creation

**Output:** A labeled, milestone-assigned enhancement issue in GitHub.

---

### /pm-bughunt

A structured investigation workflow for troubleshooting and root-causing bugs.

**Usage:** `/pm-bughunt #55` or `/pm-bughunt "app crashes on form submit"` or `/pm-bughunt` (browse open bugs)

**What it does:**

1. **Identify** — Fetches the bug from GitHub, or browses open bugs, or takes a description. Optionally creates a GitHub issue to track the investigation.

2. **Gather Evidence** — Asks for error output, logs, reproduction steps, observability data, environment, and recent changes. Asks only what's relevant, not all at once.

3. **Investigate** — Reproduces locally, traces the code path, forms hypotheses ranked by likelihood, and tests each one. Adds comments to GitHub after each hypothesis. Offers to pause after each hypothesis test.

4. **Root Cause** — Presents findings with root cause, affected code, and fix approach. Options: fix it now (TDD), document it, assign to a team, or save & exit.

5. **Fix (if chosen)** — Creates branch, writes failing test, commits, implements fix, runs full suite. All TDD.

**Supports resuming** — State saved to `.claude/bughunt-state.json` with full hypothesis history. Offers save & exit at every natural breakpoint.

**Output:** Root cause analysis, optionally a fix via PR, GitHub issue updated with findings.

---

## Agent Definitions

### pm-issue-worker

A worktree-isolated agent that works on a single GitHub issue following full TDD discipline. Used by `/pm-team` to run multiple issues in parallel.

**Location:** `agents/pm-issue-worker.md`

**Preloaded skills:** `pm-dod`, `pm-git-workflow`, `pm-parallel`

**What it does:**
1. Reads `CLAUDE.md` for project-specific context
2. Fetches the issue from GitHub for requirements and file boundaries
3. Creates a feature branch
4. Writes a failing test first (Red) and commits it
5. Implements to pass the test (Green) and commits
6. Refactors while green and commits
7. Runs the full test suite
8. Self-checks against the Definition of Done
9. Pushes and creates a PR via `gh pr create`

**Rules:**
- Never merges to main or merges PRs — leaves both for human review
- Stops and reports if it discovers a file ownership conflict
- Stops and reports if the issue is unclear or missing acceptance criteria

**How it's used:** You don't invoke this directly. `/pm-team` spawns these agents, one per issue, each in its own worktree.

### Dual-Mode Design

The process skills (`pm-dod`, `pm-git-workflow`, `pm-parallel`) exist as **copies** of content that's also in the generated CLAUDE.md. This is intentional:

- **Human mode:** You invoke `/pm-dod` etc. as quick references. CLAUDE.md has the rules inline. No agent definitions involved.
- **Agent teams mode:** `/pm-team` spawns `pm-issue-worker` agents. Each agent reads CLAUDE.md (rules) AND gets the skills preloaded (structured workflow). The duplication is reinforcement.
- **No mode selection at bootstrap time.** Both paths are always available. CLAUDE.md is never slimmed down.

---

## Standards

All skills that create or resolve issues embed a strict Definition of Done:

- Failing test written first and committed before any implementation (TDD Red)
- Implementation written to make test pass (Green)
- Code refactored while keeping tests green
- Full test suite passes — no regressions
- Happy path: 100% test coverage
- Non-happy path: 100% target (edge cases can be lower, document exceptions)
- Error states: 100% — every error state handled AND tested, no exceptions
- No commented-out code
- No hardcoded values — config or constants only
- Every TODO references a GitHub issue number
- Functions are single-responsibility
- No issue = no work started, no exceptions
- Merged via PR — issue closed on merge only, not before

---

## Requirements

- [Claude Code CLI](https://claude.ai/claude-code)
- [Notion MCP integration](https://www.notion.so/integrations) connected to Claude Code
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated
- A Notion database for PRDs (the database ID is stored in `~/.claude/notion-config.json`, shared across all projects)
