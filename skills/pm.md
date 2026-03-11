---
name: pm
description: Project management hub. Use for ANY project management task: creating PRDs/TRDs, project status, filing bugs, bootstrapping projects, or tracking what to work on next. Single entry point for all PM workflows.
---

# /pm — Project Management Hub

Single entry point for all project management workflows. Routes to the correct action based on argument or interactive menu.

## Usage

```
/pm                     — Show menu (filtered by environment)
/pm create              — Create PRD via guided interview
/pm trd [PRD ref]       — Create TRD from PRD
/pm ready [PRD ref]     — Mark PRD as GitHub Ready
/pm bootstrap [PRD ref] — Populate Notion board + GitHub milestones/issues
/pm status              — Project health summary
/pm next                — Recommend what to work on next
/pm bug ["description"] — File a bug
/pm enhancement ["desc"]— File an enhancement
/pm bughunt [#N or desc]— Investigate and root-cause a bug
```

---

## 1. Environment Detection

Detect environment on every invocation:

| Signal | Full Mode (Claude Code) | Light Mode (Claude.ai / Desktop) |
|---|---|---|
| Bash tool available | Yes | No |
| File system access | Yes | No |
| `gh` CLI | Yes | No |
| Notion MCP tools | Yes | Yes |

**Full mode** — offer all actions.
**Light mode** — offer: create, trd, ready, status, bug, enhancement. Hide: bootstrap, next, bughunt.

When in light mode and user requests a hidden action, respond:
> "That action requires Claude Code (needs terminal + GitHub CLI). Switch to Code and run `/pm [action]` there."

---

## 2. Configuration

**Load order** — check project-level first, then system-level:

1. Project `CLAUDE.md` (repo root) — look for `## Notion` section
2. `~/.claude/CLAUDE.md` — fallback

**Required keys:**

| Key | Source | Used By |
|---|---|---|
| PRD Database ID | CLAUDE.md | create, trd, ready, bootstrap |
| PRD Page ID | Project CLAUDE.md | trd, ready, bootstrap, status |
| Dashboard Page ID | Project CLAUDE.md | bootstrap, status, bug, enhancement |
| Project Board Data Source ID | Project CLAUDE.md | bootstrap, status, bug, enhancement |

If a required key is missing for the current action, ask the user.

---

## 3. Menu Router

If `$ARGUMENTS` is `help`, show usage summary and exit (do not show menu or start an action):

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

Workflow: create → trd → ready → bootstrap → next → (build) → status
```

If `$ARGUMENTS` is empty or unrecognized, show a menu filtered by environment:

**Full mode:**
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

**Light mode:** Show options 1-3, 5, 7-8 only.

After completing any action, offer the logical next step:
- After **create** -> "Want to continue to the TRD?"
- After **trd** -> "Want to mark the PRD as ready?"
- After **ready** -> "Ready to bootstrap? (Switch to Claude Code)"
- After **bootstrap** -> "Run `/pm next` to see what to work on first."
- After **bug/enhancement** -> "Run `/pm next` to see how this affects priorities."

---

## 4. Resume Support

For multi-step operations, save state to `.claude/pm-state.json` in the project directory.

Check for existing state on start of: bootstrap, bughunt.

```json
{
  "version": 1,
  "action": "bootstrap|bughunt",
  "project_name": "...",
  "started_at": "ISO",
  "updated_at": "ISO",
  "current_step": "...",
  "data": { }
}
```

If state exists, present summary and ask: "Resume from where you left off, or start fresh?"
If resume: sync with remote first (`git fetch origin && git pull origin main`), then skip completed steps.
If fresh: delete state file and start over.

---

## 5. Notion Database Schemas

**PRDs Database** — properties:

| Property | Type | Values |
|---|---|---|
| Name | title | `PRD-NNN: Feature Name` |
| Status | select | Draft, In Review, Approved, Shelved |
| Priority | select | P0 - Now, P1 - Next, P2 - Later, Shelved |
| Category | select | Internal Ops, Client Demo, GTM |
| GitHub Ready | checkbox | true/false |
| Status Dashboard | URL | link to dashboard child page |

**Project Board Database** (inline, child of dashboard) — properties:

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

## 6. Action: Create Project (PRD)

**Available in:** Full + Light mode

### Phase 1: Interview

Start warm. Ask one topic at a time. Wait for answers before moving on.

**Opening:**
> "Let's build your PRD. I'll walk you through the product requirements -- what we're building and why. Technical details like architecture and tooling will go into a TRD afterward. First: **what's the one-line pitch for this product or feature?**"

**Interview sequence:**

1. **Name & Pitch** -- What are we calling this? Elevator pitch?
2. **Problem** -- What problem? Who experiences it? How painful today?
3. **Goals** -- If this ships perfectly, what's true? (Push for 3-6 specific goals)
4. **Non-Goals** -- What are you explicitly NOT doing? (Help: "what might people assume is in scope?")
5. **Users & Stories** -- Who uses this? 2-5 user stories. Product-level, map to epics. Format: `As a [role], I want [action] so that [outcome].`
6. **Success Metrics** -- How will you know this worked? Push for quantifiable outcomes. Flag production-only metrics with `*(requires instrumentation)*`.
7. **Stakeholders** -- Who owns this? Who needs to be consulted or informed?
8. **Open Questions** -- Anything unresolved?
9. **Category & Priority** -- Internal Ops / Client Demo / GTM? P0 / P1 / P2?

**Coaching rules:**
- When user drifts into technical details, acknowledge and redirect: "Great context for the TRD. For the PRD, let's frame it as [product-level restatement]."
- Draw out thin answers: "What does that look like in practice?" / "Give me an example." / "How will you know it worked? Give me a number."
- Technology, architecture, implementation phases -> TRD. User needs, business outcomes, success measures -> PRD.

### Phase 2: Draft & Confirm

Draft full PRD in Markdown. Show to user:
> "Here's your draft PRD. Any sections to adjust before I save to Notion?"

Wait for approval. Apply edits.

### Phase 3: Save to Notion

**Step 1 -- Determine next PRD number.** Use `notion-search` to query PRDs database. Parse titles for `PRD-NNN`. Increment highest by 1. If none exist, start at `PRD-001`.

**Step 2 -- Create PRD page** via `notion-create-pages`:
- Parent: PRD Database ID (from config)
- Title: `PRD-{NNN}: {Feature Name}`
- Properties: Status=Draft, Priority={selected}, Category={selected}, GitHub Ready=false
- Body: full PRD markdown (Overview, Problem Statement, Goals, Non-Goals, User Stories, Success Metrics, Stakeholders & Ownership, Open Questions)

**Step 3 -- Create Project Status dashboard** via `notion-create-pages`:
- Parent: the PRD page ID (child page)
- Title: `Project Status: {Feature Name}`
- Body:

```markdown
## Milestone Progress

| Milestone | Total | Done | Open | Blocked | % Complete |
|---|---|---|---|---|---|
| (populated by bootstrap) | | | | | |

## Build Status

| Metric | Value |
|---|---|
| Total Stories | -- |
| Bugs Open | 0 |
| Velocity (7d) | -- |
| Health | -- |

## Quick Links

- **PRD:** [link to PRD page]
- **TRD:** (pending)
- **GitHub Repo:** (pending)
- **Dependency Map:** (pending)

## Story Board

(Project Board database will appear below)
```

**Step 4 -- Create Project Board database** via `notion-create-database`:
- Parent: dashboard page ID
- Title: `Project Board`
- Inline: true
- Schema: Story (title), Status (select: To Do/In Progress/Done/Blocked), Milestone (select), Phase (select), Dependencies (rich_text), Description (rich_text), Type (select: Story/Bug/Enhancement/Chore), GitHub Issue (URL)

**Step 5 -- Update PRD page** via `notion-update-page`:
- Set Status Dashboard URL property to the dashboard page URL

**After saving**, respond with link and offer next step: "Want to continue to the TRD?"

### Error Handling

- User bails mid-interview: "Want me to save what we have as a Draft so you can finish later?"
- Notion save fails: show full PRD as Markdown so nothing is lost
- Category/Priority unclear: default to Internal Ops / P1 - Next, mention assumption
- No existing PRDs: start at PRD-001

---

## 7. Action: Create TRD

**Available in:** Full + Light mode

### Phase 0: Locate the PRD

- User specifies PRD (name, number, or link): use `notion-search` to find it
- Same conversation as PRD creation: use the page ID from that step
- Ambiguous: ask "Which PRD? Give me a name or number."

Fetch PRD content via `notion-fetch`. Extract: Overview, Goals, Non-Goals, User Stories, technical notes.

### Phase 1: Interview

**Opening:**
> "I've pulled up **[PRD Title]**. Let's build the technical plan. First: **what's the high-level technical approach?**"

**Interview sequence:**

1. **Technical Approach** -- Architecture? What are we building?
2. **Tool & Technology Decisions** -- Languages, frameworks, SDKs, APIs? Why each? (Table: Tool | Purpose | Rationale)
3. **Interface Mapping** -- Endpoints (API), components (UI), or contracts (service)
4. **Observability** -- Monitoring tool? For each PRD metric marked `*(requires instrumentation)*`: what signal captures it, what threshold? Key signals per domain. Alerting rules. If unsure, offer defaults.
5. **Milestones** -- How to phase this? M1 = smallest shippable thing. Push for 2-4 milestones. Observability must be its own milestone or explicitly in the final one.
6. **Stories per Milestone** -- Discrete tasks per milestone. 3-8 stories each. Each = one GitHub issue. Story IDs: S1, S2, S3... Keep atomic.
7. **Dependencies** -- Which stories block others?
8. **Risks & Constraints** -- Known blockers, platform limitations?
9. **Open Questions** -- Unresolved technical decisions?

**Tips:**
- If user provides OpenAPI spec or API docs, auto-generate interface mapping and suggest milestone/story breakdowns
- If unsure about milestones, suggest: M1 = scaffolding + core, M2 = secondary features, M3 = polish + stretch

### Phase 2: Draft & Confirm

Draft full TRD in Markdown. Show to user. Wait for approval.

**TRD sections:** Summary, Architecture & Design Decisions (table + prose), API/Interface Mapping, Observability (tooling, signals table, alerting, analytics), Technical Milestones (with stories per milestone), Dependency Map (phased), Technical Risks & Constraints (table), Open Technical Questions.

### Phase 3: Save to Notion

**Step 1 -- Create TRD page** via `notion-create-pages`:
- Parent: PRD page ID (child page)
- Title: `TRD: {Feature Name}`
- Body: full TRD markdown

**Step 2 -- Update dashboard Quick Links** via `notion-fetch` + `notion-update-page`:
- Set TRD link in the Quick Links section of the dashboard page

**After saving**, offer next step: "Want to mark the PRD as ready?"

### Error Handling

- PRD not found: "Can't find that PRD. Double-check the name or number?"
- User bails: offer to save partial draft
- Notion fails: show full TRD as Markdown
- No PRD exists: "Need a PRD first -- want to run `/pm create`?"

---

## 8. Action: Mark Ready

**Available in:** Full + Light mode

### Steps

1. Find PRD via `notion-search` (by name/number from args, or list Approved PRDs not yet GitHub Ready)
2. Confirm Status = Approved. If not: "This PRD's status is [status]. Update it to Approved in Notion first."
3. Confirm with user: "Ready to mark **[PRD name]** as GitHub Ready? This signals it's ready for bootstrap."
4. Use `notion-update-page` to set GitHub Ready = true
5. Update dashboard status section if dashboard exists
6. Confirm and offer next step: "PRD marked GitHub Ready. Switch to Claude Code and run `/pm bootstrap` to create milestones and issues."

---

## 9. Action: Bootstrap

**Available in:** Full mode only (requires Bash + `gh` CLI)

### Pre-flight

1. Resolve Notion PRD Database ID from config
2. Fetch PRD from Notion. Confirm Status=Approved and GitHub Ready=true. If not, stop: "Run `/pm ready` first."
3. Fetch TRD (child page of PRD). If no TRD found, warn and offer to continue with PRD only.
4. Determine GitHub repo from project CLAUDE.md or ask user.

**Frontend interview** (if project has UI) -- ask if not answered in PRD/TRD:
- Has frontend? (web/mobile/CLI/API-only)
- Framework? (React, Vue, Next.js, vanilla JS, etc.)
- Existing designs? (Figma, mockups, TRD wireframes, generate from requirements, none)
- Styling approach? (Tailwind, CSS modules, plain CSS, component library)
- Responsive/mobile-friendly?
- Main pages/views?

5. Confirm: "Ready to bootstrap **[Project Name]** into **[repo]**. This will populate the Notion board, create GitHub milestones + issues, cross-link everything, and update the dashboard. Confirm?"

### Step 1: Populate Notion Project Board

For each story from the TRD, create a card in the Project Board database via `notion-create-pages`:
- Story (title): story title
- Status: To Do
- Milestone: M1/M2/etc.
- Phase: Phase N (from dependency map)
- Dependencies: dependency text
- Description: story description
- Type: Story
- GitHub Issue: (empty -- filled in Step 3)

**Save state** after all cards created.

### Step 2: Create GitHub Milestones

For each TRD milestone, create via `gh api`:
- Title: `M[N]: [Milestone Name]`
- Description: milestone scope from TRD

**Frontend milestone rule:** If `has_ui=true`, verify milestones cover full stack. If no explicit frontend integration milestone, create one.

**Save state** after milestones created.

### Step 3: Create GitHub Issues

Process one milestone at a time. For each milestone:

**Present issue plan** as summary table before creating:

```
### M[N]: [Name] -- [X] issues planned

| #  | Title                        | Type  | Labels      |
|----|------------------------------|-------|-------------|
| 1  | [Issue title]                | test  | test, F1    |
| 2  | [Issue title]                | build | build, F1   |
```

**Review gate** -- four options:
- **Approve** -- create issues as shown
- **Suggest changes** -- revise and re-present
- **Skip milestone** -- do not create issues for this milestone
- **Save & exit** -- save progress, resume later with `/pm bootstrap`

**Issue body template:**

```
## Story
As a [role], I want [action] so that [outcome].

## Context
[1-2 sentences: why this matters, where it fits]

## Acceptance Criteria
- [ ] [Specific, testable criterion]

## Definition of Done
- [ ] Failing test written first and committed before implementation
- [ ] Implementation makes test pass
- [ ] Full test suite passes -- no regressions
- [ ] No commented-out code, no hardcoded values
- [ ] Every TODO references a GitHub issue number
- [ ] Merged via PR -- issue closed on merge only

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

**After creating each issue**, update the corresponding Notion board card with the GitHub Issue URL via `notion-update-page`.

**Save state** after each milestone's issues are created.

### Step 4: Update Dashboard

Update the dashboard page milestone progress table with actual counts from GitHub.

### Step 5: Create Dependency Map

Create a pinned GitHub issue titled `Dependency Map -- [Project Name]` with phased issue list. Pin it.

### Step 6: Generate/Update CLAUDE.md

If no project CLAUDE.md exists, generate one with:
- Build & run commands (from TRD tech stack)
- Architecture overview (from TRD)
- Notion section with all IDs (PRD Database ID, PRD Page ID, Dashboard Page ID, Project Board Data Source ID)
- Frontend section (if applicable)
- Git workflow rules (branch naming, TDD, PR-only merges)
- Parallel development file ownership rules

Commit: `"Add CLAUDE.md (#[first issue number])"`

**Save state** with `current_step: "complete"`.

### Completion Summary

```
[Project Name] bootstrapped successfully

Notion Board:  [N] stories populated
Milestones:    [N] created in GitHub
Issues:        [N] created in GitHub (cross-linked to Notion)
Dep Map:       Pinned as issue #[N]
Dashboard:     Updated with milestone progress
CLAUDE.md:     [Created / Updated]

Next step: Run /pm next to see what to work on first.
```

---

## 10. Action: Status

**Available in:** Full + Light mode (different behavior)

### Full Mode (Claude Code)

1. Fetch from GitHub via `gh`:
   - All milestones (open + recently closed)
   - All open issues with labels and milestone assignment
   - All closed issues (velocity calculation)
   - Pinned Dependency Map issue

2. Calculate per-milestone: % complete, open by type, blocked count, missing labels

3. **Sync to Notion dashboard** -- update milestone progress table and build status via `notion-update-page`

4. Output status report:

```
## Project Status -- [repo] -- [date]

### Milestones

| Milestone | Progress | Open | Bugs | Blocked | Status |
|---|---|---|---|---|---|
| M1: [Name] | 100% | 0 | 0 | 0 | Complete |
| M2: [Name] | 60% (6/10) | 4 | 1 | 1 | Active |

### Open Bugs
#[N] [title] -- [milestone] -- [severity]

### Blocked Issues
#[N] [title] -- waiting on #[N] ([reason])

### Health Flags
- [N] issues have no milestone assigned
- [N] issues have no type label

### Velocity
Closed in last 7 days: [N] issues
Closed in last 30 days: [N] issues
Estimated completion of active milestone: [date or "insufficient data"]
```

5. One-line summary: "Overall: [Green/Yellow/Red] -- [assessment]"
   - Green = on track, no critical bugs, no systemic blockers
   - Yellow = minor blockers or bugs, progress continuing
   - Red = critical bugs, milestone blocked, or no progress in 7+ days

### Light Mode (Claude.ai / Desktop)

1. Read dashboard from Notion via `notion-fetch` (Dashboard Page ID from config)
2. Present the milestone progress and build status tables from the dashboard
3. Note: "This is the last synced state. For live data, run `/pm status` in Claude Code."

---

## 11. Action: Next

**Available in:** Full mode only

### Steps

1. Fetch from GitHub via `gh`:
   - Open milestones with % complete
   - All open issues with labels, milestone, dependencies
   - Pinned Dependency Map issue

2. Read Notion board for phase info via `notion-fetch`

3. Identify active milestone (earliest incomplete)

4. Classify open issues in active milestone:
   - **UNBLOCKED** -- no open dependencies, ready to start
   - **BLOCKED** -- depends on open issue
   - **IN PROGRESS** -- has activity (comments, linked branch)

5. Priority ordering for unblocked issues:
   - test before build (TDD -- failing test must exist first)
   - setup/integration before build if foundational
   - bug/critical before enhancements
   - lower issue number as tiebreaker

6. Output:

```
## Next -- [repo] -- [date]

### Active Milestone: M[N]: [Name] ([X]% -- [closed]/[total])

### Recommended Next (unblocked, highest priority)
#[N] [title] ([type]) -- [why this is first]

### Also Unblocked (can run in parallel)
#[N] [title]
#[N] [title]

### Blocked
#[N] [title] -- waiting on #[N]

### Flags
[Issues with no milestone, no labels, missing DoD]

### Next Milestone Preview: M[N+1]: [Name]
[Not started -- unlocks when current milestone completes]
```

7. If no unblocked issues exist, flag the blocker and suggest resolving it first.

---

## 12. Action: Bug

**Available in:** Full + Light mode (different behavior)

### Info Gathering

1. If no description in args, ask: "Describe the bug -- what is happening vs. what should happen?"
2. Gather: repo (Full mode), milestone, severity (Critical/High/Low)

### Full Mode (Claude Code)

**Create GitHub issue** via `gh issue create`:

Title: `Bug: [concise description]`

Body:
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
- [ ] Failing test reproduces the bug -- committed before fix
- [ ] Fix makes the test pass
- [ ] Full test suite passes -- no regressions
- [ ] Error state now handled and tested
- [ ] Merged via PR -- issue closed on merge only

## Notes
[Additional context]
```

Labels: bug, severity (critical/high/low), feature label (F1/F2/etc.)
Assign to relevant milestone.

**AND create Notion board card** via `notion-create-pages`:
- Story: `Bug: [title]`
- Status: To Do
- Type: Bug
- Milestone: matching milestone
- GitHub Issue: URL of created GitHub issue

Confirm: "Bug #[N] created in GitHub and added to Notion board."

### Light Mode (Claude.ai / Desktop)

**Create Notion board card only** via `notion-create-pages`:
- Story: `Bug: [title]`
- Status: To Do
- Type: Bug
- Milestone: matching milestone
- Description: full bug details
- GitHub Issue: (empty)

Add note in Description: "GitHub issue pending -- create in Claude Code with `/pm bug`"

Confirm: "Bug added to Notion board. Create the GitHub issue in Claude Code when ready."

---

## 13. Action: Enhancement

**Available in:** Full + Light mode (same dual-write pattern as Bug)

### Info Gathering

1. If no description in args, ask: "Describe the enhancement -- what should change or be added, and why?"
2. Gather: repo (Full mode), change type (existing behavior / net-new), milestone, priority (High/Medium/Low)
3. If it does not fit an existing milestone, flag: may need new milestone or PRD update.

### Full Mode (Claude Code)

**Create GitHub issue** via `gh issue create`:

Title: `Enhancement: [concise description]`

Body:
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
- [ ] Failing test first, committed before implementation
- [ ] Implementation makes test pass
- [ ] Full test suite passes -- no regressions
- [ ] No commented-out code, no hardcoded values
- [ ] Merged via PR -- issue closed on merge only

## Notes
[Additional context]
```

Labels: enhancement, priority (high/medium/low), feature label
Assign to milestone.

**AND create Notion board card:**
- Story: `Enhancement: [title]`
- Status: To Do
- Type: Enhancement
- GitHub Issue: URL of created issue

Confirm: "Enhancement #[N] created in GitHub and added to Notion board."

### Light Mode

**Notion board card only** (same pattern as Bug light mode). Note "GitHub issue pending" in Description.

---

## 14. Action: Bughunt

**Available in:** Full mode only

### Step 1: Identify the Bug

**Option A -- GitHub issue number provided** (e.g. `#55`):
Fetch with `gh issue view`. Save state. Proceed.

**Option B -- No argument:**
List open bugs: `gh issue list --label bug --state open --sort created`
Let user pick one, or describe a new bug.

**Option C -- Description provided (no GitHub issue):**
Offer to create GitHub issue for tracking, or investigate without.

### Step 2: Gather Evidence

Ask progressively (not all at once):
1. Error output / stack trace?
2. Relevant logs?
3. Steps to reproduce? Intermittent?
4. Observability data (metrics, traces, alerts)?
5. Environment?
6. Recent changes / deploys?

**Save state.** Offer: "Evidence collected. Ready to investigate, or save & exit?"

### Step 3: Investigate

1. **Reproduce** locally (run tests, dev server)
2. **Trace** the code path through the codebase
3. **Form hypotheses** ranked by likelihood
4. **Test each hypothesis:**
   - Describe what you're checking and why
   - Rule in or out with clear reasoning
   - If using GitHub, add comment after each hypothesis
   - **Save state** after each. Offer: "Hypothesis [N] tested ([status]). Continue, or save & exit?"
5. Iterate if all ruled out -- ask for more context, broaden search

### Step 4: Root Cause Identified

1. Present finding: root cause, affected code, fix approach
2. **Save state.** Ask user:
   - **Fix it now** -- TDD: create branch, write failing test, implement fix
   - **Just document it** -- update GitHub issue with root cause
   - **Save & exit** -- save findings, resume later

3. If fixing (TDD):
   - Create branch, write failing test, commit. **Save state.**
   - Implement fix, commit. **Save state.**
   - Run full test suite
   - Add summary comment to GitHub issue

### Step 5: Wrap Up

1. Summarize findings
2. **Update Notion board card** -- set Status to Done (or In Progress if PR pending) via `notion-update-page`
3. Offer to create issues for related bugs found
4. **Delete state file**

### Key Rules

- Developer drives -- present findings, wait for decisions
- Evidence-based -- every hypothesis cites specific evidence
- Rule things out explicitly -- document what was checked
- TDD for fixes -- failing test first, no exceptions
- Save state often -- after every checkpoint
- GitHub is optional for tracking -- never force it
