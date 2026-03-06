# pm-bootstrap

Bootstrap a new project from an approved Notion PRD and its TRD into a fully structured GitHub project.
One atomic operation: PRD + TRD → Milestones → Issues → Dependency Map → CLAUDE.md

## Usage
/pm-bootstrap $ARGUMENTS

Arguments: PRD identifier and GitHub repo (e.g. "PRD-002 paulmona/my-repo")
If no arguments provided, ask for PRD first, then GitHub repo name.

---

## Resume Support

This command supports resuming from interruptions. State is saved to `.claude/bootstrap-state.json`
in the project directory after each completed step.

### On Start — Check for Existing State

Before running pre-flight checks, look for `.claude/bootstrap-state.json` in the current repo.
If found, read it and present a summary to the user:

```
Found bootstrap state for [Project Name]
   PRD:        [PRD identifier]
   Repo:       [repo]
   Milestones: [N] created
   Issues:     [N] created (last: #[N] — [title])
   Step:       [current step name]

   Resume from where you left off, or start fresh?
```

If the user chooses to resume:
1. **Sync with remote first** — always run `git fetch origin && git pull origin main` before doing anything else. The remote may have changed since the last session.
2. Then skip all completed steps and pick up from the saved checkpoint.

If the user chooses fresh, delete the state file and start from scratch.

### State File Format

```json
{
  "version": 1,
  "project_name": "Project Name",
  "prd_id": "PRD-002",
  "trd_id": "TRD page ID or null",
  "repo": "owner/repo",
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "current_step": "milestones|issues|dependency_map|claude_md|complete",
  "frontend": {
    "has_ui": true,
    "framework": "vanilla JS|React|Vue|Next.js|etc.",
    "design_source": "Figma|mockups|TRD wireframes|agent-generated|none",
    "design_reference": "URL or description",
    "styling": "Tailwind|CSS modules|styled-components|plain CSS|etc.",
    "responsive": true,
    "key_views": ["list of main pages/views"]
  },
  "milestones": {
    "completed": true,
    "created": ["M1: Name", "M2: Name"]
  },
  "issues": {
    "completed": false,
    "milestones_done": ["F1", "F2"],
    "milestones_pending": ["F3", "F4"],
    "last_issue_number": 21,
    "total_created": 21
  },
  "dependency_map": {
    "completed": false,
    "issue_number": null
  },
  "claude_md": {
    "completed": false
  }
}
```

### When to Save State

Save/update `.claude/bootstrap-state.json` after each of these checkpoints:
1. After ALL milestones are created (Step 1 complete)
2. After EACH milestone's issues are created and approved (during Step 2, per-milestone)
3. After the dependency map issue is created (Step 3 complete)
4. After CLAUDE.md is committed (Step 4 complete)

On final completion, update `current_step` to `"complete"` but keep the file.
It serves as a record of what was bootstrapped.

### Resuming Each Step

- **Resuming Step 1 (Milestones):** Check which milestones already exist in GitHub
  (`gh api repos/{owner}/{repo}/milestones`). Only create missing ones.
- **Resuming Step 2 (Issues):** Use `issues.milestones_done` to skip approved milestones.
  Start presenting from the first milestone in `milestones_pending`.
  Use `issues.last_issue_number` to set correct dependency references for new issues.
- **Resuming Step 3 (Dependency Map):** Check if a pinned issue with "Dependency Map" exists.
  If not, create it using all issues (both previously created and new).
- **Resuming Step 4 (CLAUDE.md):** Check if CLAUDE.md exists in the repo. If not, create it.

### User Can Pause Anytime

At each milestone review gate (Step 2), include a fourth option:
- **Approve** — Create all issues for this milestone as shown
- **Suggest changes** — User provides feedback; revise and re-present
- **Skip milestone** — Do not create issues for this milestone
- **Save & exit** — Save current progress and stop. User can resume later with `/pm-bootstrap`

When "Save & exit" is chosen, save state immediately and output:

```
Bootstrap progress saved for [Project Name]
   Issues created so far: [N]
   Milestones remaining:  [list]

   Run /pm-bootstrap in this repo to resume.
```

---

## Pre-flight Check

1. **Resolve the Notion PRD Database ID.**
   Check the project's `CLAUDE.md` for a `## Notion` section containing `PRD Database ID`.
   - If found, use it.
   - If CLAUDE.md doesn't exist yet or has no Notion section, ask the user:
     "What is your Notion PRD database ID? (You can find this in the database URL after notion.so/)"
   - Store the ID for use throughout bootstrap. It will be written into the generated CLAUDE.md in Step 4.

2. Fetch the PRD from Notion using notion-search against the database ID, then notion-fetch to get full content.
   Confirm Status = Approved and GitHub Ready = true before proceeding.
   If not approved, stop and tell the user to run /pm-prd-ready first.

3. Fetch the TRD from Notion. The TRD is a child page of the PRD.
   Use notion-search or navigate the PRD's child pages to find the TRD.
   If no TRD is found, warn the user: "No TRD found as a child page of this PRD.
   Technical details in issues and CLAUDE.md will be inferred from the PRD only.
   Continue anyway?" If user declines, stop.

4. **Frontend & UI Requirements Interview** — Before decomposing into milestones, determine
   whether this project has a user-facing frontend. Ask the user these questions (skip any
   that are already answered in the PRD or TRD):

   a. **"Does this project have a user-facing frontend (web app, mobile, CLI, API-only)?"**
      - If API-only or CLI with no UI, record `has_ui: false` and skip remaining UI questions.
      - If yes, continue.

   b. **"What frontend framework or approach? (e.g. React, Vue, Next.js, vanilla HTML/JS, etc.)"**
      - Record the answer. If the TRD specifies a tech stack, confirm it with the user.

   c. **"Are there existing designs, mockups, or wireframes?"**
      - Options: Figma file, uploaded mockups, wireframe descriptions in the TRD,
        "generate basic UI from requirements", or "no design yet — will need a design phase"
      - If Figma or mockups exist, ask for the URL/location so it can be referenced in issues.
      - If "no design yet", flag this: a design/wireframe task should be created in the first milestone.

   d. **"What CSS/styling approach? (e.g. Tailwind, CSS modules, plain CSS, component library like shadcn)"**

   e. **"Does the app need to be responsive / mobile-friendly?"**

   f. **"What are the main pages or views?"** — Get a list of the key screens/routes
      (e.g. "input form page, results page, shared trip view, admin dashboard").
      Cross-reference with the PRD user stories — every user-facing story implies a view.

   g. **"Are there any UI assets that need to be sourced? (icons, images, fonts, logos)"**
      - If yes, create a human-labeled task for asset sourcing in the first milestone.

   Store all answers in the bootstrap state under `frontend`. These answers inform:
   - Milestone decomposition (ensures a frontend integration milestone or stories exist)
   - Issue creation (every backend module that renders UI gets a paired frontend wiring issue)
   - CLAUDE.md generation (frontend section with framework, build commands, component patterns)
   - Dependency map (frontend integration issues depend on their backend modules)

5. Confirm with user:
   "Ready to bootstrap [Project Name] into [repo] using PRD + TRD. This will create
   Milestones, Issues, a Dependency Map, and CLAUDE.md. Confirm?"

---

## Step 1: Create GitHub Milestones

For each numbered milestone section in the PRD, create a GitHub Milestone:

Title:       M[N]: [Milestone Name]
Description: [Milestone scope copied from PRD]
Due date:    Set if timeline specified in PRD, otherwise leave blank

**Frontend Milestone Rule:** If the project has a frontend (`has_ui: true`), verify that the
milestones cover the **full stack** — not just backend logic. Apply these checks:

1. **Every milestone that produces user-visible output MUST include frontend issues.**
   If a TRD milestone describes a UI component (form, card, dashboard, modal), the milestone
   must include issues for both the logic module AND the frontend view that renders it.

2. **If no milestone explicitly covers frontend integration/assembly**, create one:
   - Title: "Frontend Integration & UI Assembly"
   - Description: "Wire all backend modules to the frontend UI. Includes page layout,
     routing, component rendering, form handling, API endpoint proxying, and end-to-end
     user flow testing."
   - This milestone depends on all feature milestones and contains the issues that connect
     tested logic modules to actual browser-rendered UI.

3. **Scaffolding milestone must include frontend scaffolding** — not just backend setup.
   The project scaffolding issue should create the HTML shell, CSS framework setup,
   client-side JS entry point, and any build tooling (bundler, dev server hot reload).

---

## Step 2: Create GitHub Issues

For each milestone, decompose into discrete issues using both the PRD (what to build)
and the TRD (how to build it). Each issue must be:
- A single testable unit of work
- Completable in 1-4 hours of focused work
- Clear pass/fail outcome
- Informed by TRD technical constraints (data models, API contracts, infrastructure requirements)

Issue title format: [Imperative verb] [specific noun]
Good: "Write failing tests for lead scoring algorithm"
Good: "Implement lead scoring algorithm to pass tests"
Bad:  "Work on scoring" (too vague)
Bad:  "Various setup tasks" (too broad)

Note: For every build issue, create a paired test issue that is written FIRST.
The test issue must be the first commit on the branch — failing test before implementation.

### Frontend Issue Rules

When the project has a frontend (`has_ui: true`), apply these additional rules during
issue decomposition:

1. **Backend logic modules and frontend views are separate issues.**
   A "trip card" feature becomes at minimum:
   - Test issue: Write failing tests for trip card rendering logic
   - Build issue: Implement trip card rendering logic (returns HTML/data)
   - Build issue: Wire trip card to frontend page (DOM rendering, event handlers, styling)

   The logic module is testable in isolation (unit tests). The frontend wiring issue
   renders it in the actual browser UI with real HTML, CSS, and user interaction.

2. **Server endpoints are explicit issues.** If the frontend needs to call the backend
   (e.g. API proxy for third-party services, form submission endpoints), create explicit
   issues for each server endpoint:
   - "Implement POST /api/generate endpoint to proxy external API"
   - "Wire input form to POST /api/generate and render response"

3. **Page/view assembly issues exist for every user-facing page.** Each main view
   identified in the frontend interview gets an assembly issue:
   - "Build input form page with form fields, validation, and submit handler"
   - "Build results page with output card, action buttons, and share link"

4. **Styling and layout are NOT separate issues** unless the project has a designer
   providing specific designs. Basic styling is part of each frontend wiring issue.
   Only create a dedicated styling issue if there's a design system to implement or
   Figma mockups to match.

5. **End-to-end flow issues** — After all individual features are wired up, create
   integration issues that verify the full user flow works:
   - "Verify end-to-end flow: form submission through result rendering"

6. **Frontend scaffolding is an issue in the first milestone:**
   - "Set up frontend scaffolding (HTML shell, CSS framework, client-side JS entry point, dev server)"
   - This blocks all other frontend wiring issues.

### Parallel Development — File Conflict Prevention

When multiple agents work in parallel (via worktrees or teams), they MUST NOT modify the
same files. Apply these rules during issue decomposition to prevent merge conflicts:

1. **Shared files get a single owner issue.** If a file (e.g. `server.js`, `database.js`,
   `app.js`) needs changes from multiple issues, one of two approaches MUST be used:

   **Option A — Modular architecture (preferred):** The scaffolding issue creates an
   extensible pattern (e.g. a route loader, plugin system, or barrel file), and subsequent
   issues add NEW files that are auto-discovered. Examples:
   - Server routes: scaffolding creates `src/routes/` with auto-loader in server.js.
     Each endpoint issue creates `src/routes/generate.js`, `src/routes/nps.js`, etc.
   - Styles: scaffolding creates `public/css/base.css` and index.html loads all CSS files
     from `public/css/`. Feature issues create `public/css/form.css`, `public/css/tripcard.css`.
   - Client JS: scaffolding creates a module loader pattern. Feature issues create
     `public/js/form.js`, `public/js/tripcard.js`, etc.

   **Option B — Sequential dependency:** If modular architecture is not feasible for a
   file, issues that modify it MUST be in different dependency phases (never parallel).
   The dependency map must reflect this: two issues that touch the same file cannot be
   in the same phase.

2. **Each issue lists its file boundaries in the description.** Add a "Files" section
   to each issue description:
   ```
   ## Files (ownership for parallel development)
   - Creates: src/routes/generate.js, test/routes/generate.test.js
   - Modifies: (none — uses auto-loaded route pattern)
   ```
   Issues that need to modify the same file as another issue must declare it, and the
   dependency map must serialize them.

3. **Test files are never shared.** Each issue creates its own test file.
   Never modify another issue's test file.

4. **The scaffolding issue is always Phase 1 and runs alone** if it creates shared
   infrastructure (router, module loader, config). No other issue runs in parallel
   with scaffolding.

### Issue Review Gate

Before creating issues in GitHub, present them to the user for review ONE MILESTONE AT A TIME.
For each milestone, display a summary table of the planned issues:

```
### M[N]: [Milestone Name] — [X] issues planned

| #  | Title                                      | Type  | Labels              |
|----|--------------------------------------------|-------|---------------------|
| 1  | [Issue title]                              | test  | test, F1            |
| 2  | [Issue title]                              | build | build, F1           |
| 3  | [Issue title]                              | build | frontend, F1        |
| ...| ...                                        | ...   | ...                 |
```

Then ask the user to review with four options:
- **Approve** — Create all issues for this milestone as shown
- **Suggest changes** — User provides feedback; revise the issue list and re-present
- **Skip milestone** — Do not create issues for this milestone
- **Save & exit** — Save progress to `.claude/bootstrap-state.json` and stop. Resume later with `/pm-bootstrap`

If the user suggests changes, apply the feedback, re-present the updated table, and ask again.
Only create issues in GitHub after the user approves each milestone.
This ensures the user has full control over issue scope and content before anything is created.

### Issue Body Template

```
## Story
As a [role], I want [action] so that [outcome].

## Context
[1-2 sentences: why this matters and where it fits in the milestone]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

## Definition of Done
- [ ] Failing test written first and committed before any implementation
- [ ] Implementation written to make test pass (Green)
- [ ] Code refactored while keeping tests green
- [ ] Full test suite passes — no regressions
- [ ] Happy path: 100% test coverage
- [ ] Non-happy path: 100% target (edge cases can be lower, document exceptions)
- [ ] Error states: 100% — every error state handled AND tested, no exceptions
- [ ] No commented-out code
- [ ] No hardcoded values — config or constants only
- [ ] Every TODO references a GitHub issue number
- [ ] Functions are single-responsibility
- [ ] No issue = no work started, no exceptions
- [ ] Merged via PR — issue closed on merge only, not before

## Dependencies
- Blocked by: #[issue number] — [reason] (or "None")
- Blocks: #[issue number] — [reason] (or "None")

## Technical Details (from TRD)
[Relevant data models, API contracts, infrastructure requirements, or technical
constraints from the TRD that apply to this issue. Omit if TRD not available.]

## Frontend Details (if applicable)
[Page/view this renders in, component hierarchy, user interactions,
design reference (Figma link, mockup), responsive requirements.
Omit for backend-only issues.]

## Notes
[Tool references, links to PRD section, implementation hints]
```

### Labels

Apply two labels to every issue:

Type (pick one):
- setup       — Environment, config, scaffolding, account creation
- build       — Core feature implementation
- test        — Test writing, test infrastructure
- integration — Connecting two systems (API, webhook, CRM)
- frontend    — Frontend wiring, UI assembly, page building
- docs        — Documentation, CLAUDE.md, README
- bug         — Defect fixes
- chore       — Maintenance, dependency updates

Feature (pick one):
- F1, F2, F3... matching the PRD milestone/feature grouping

---

## Step 3: Create Dependency Map

Create a pinned GitHub Issue titled "Dependency Map — [Project Name]" with this structure:

```
## Dependency Map — [Project Name]
Generated from [PRD name] + [TRD name] on [date].
Issues in the same phase can run concurrently.
Technical dependencies sourced from TRD.

### Phase 1 — Foundation (no dependencies, fully parallelizable)
- #[N] [title]
- #[N] [title]

### Phase 2 — Core Build (requires Phase 1 complete)
- #[N] [title] (depends: #[N])
- #[N] [title] (depends: #[N], #[N])

### Phase 3 — Integration (requires Phase 2)
- #[N] [title] (depends: #[N])

### Phase N — Frontend Integration (requires all feature modules complete)
- #[N] [title] (depends: #[N], #[N])
[Frontend wiring and page assembly issues go in a late phase since they
depend on the backend logic modules being implemented and tested first.]

### Phase N+1 — End-to-End Validation
- #[N] [title]
```

Pin this issue in the GitHub repo.

---

## Step 4: Scaffold CLAUDE.md

Check if a CLAUDE.md exists at the repo root. If not, generate one using this template,
populated with project-specific content from the TRD (primary source for architecture,
tech stack, data models, and patterns) and the PRD (for milestones and feature context):

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Build & Run Commands

\`\`\`bash
[exact command to install dependencies]
[exact command to run the project]
[exact command to run all tests]
[exact command to run a single test file]
[exact command to lint]
[exact command to run dev server with hot reload, if applicable]
\`\`\`

## Local Development Environment

### Prerequisites
[Tools, versions, install instructions — from TRD tech stack, fallback to PRD tool decisions]

### Setup
[Step-by-step first-time setup — from TRD environment requirements]

### Troubleshooting
[Common errors and fixes]

## Architecture

[Component hierarchy or description — from TRD system architecture section]

### Key Directories
[Map of directories and what lives in each — from TRD project structure]

### Data Models
[Core data models and schemas — from TRD data model section]

### Patterns
[Design patterns used in this project — from TRD technical decisions]

### Data Flow
[How data moves through the system — from TRD data flow / integration architecture]

### API Contracts
[Key API endpoints and contracts — from TRD API design section, if applicable]

## Frontend

[Include this section only if the project has a user-facing frontend (has_ui: true)]

### Framework & Tooling
[Frontend framework (React, Vue, vanilla JS, etc.), build tool, dev server]

### Component Structure
[How components/views are organized — from TRD or frontend interview answers]

### Pages / Views
[List of main pages/routes with brief description of each]

### Styling
[CSS approach — Tailwind, CSS modules, plain CSS, component library, etc.]

### Design Reference
[Link to Figma, mockups, or "agent-generated from requirements" if no designs exist]

### Frontend-Backend Integration
[How the frontend communicates with backend — REST endpoints, direct module imports,
client-side API calls, etc. Specify any proxy/middleware setup needed.]

## Notion

These IDs are used by pm-* skills to read and write PRDs and TRDs.

| Key | Value |
| --- | --- |
| PRD Database ID | [Notion database ID for the PRDs database] |
| PRD Page ID | [Notion page ID for this project's PRD] |
| TRD Page ID | [Notion page ID for this project's TRD, if applicable] |

## Parallel Development — File Conflict Prevention

When multiple agents work in parallel (worktrees or teams), they MUST NOT modify the same files.

### Architecture Rules
- **Server routes:** Add new files in `src/routes/` — the server auto-loads them. Do NOT modify `src/server.js` directly unless you are the scaffolding issue.
- **Client-side JS:** Add feature-specific files in `public/js/` — they are loaded by the HTML shell. Do NOT modify `public/app.js` unless you are the scaffolding issue.
- **Styles:** Add feature-specific CSS files in `public/css/` — they are loaded by the HTML shell. Do NOT modify `public/css/base.css` unless you are the scaffolding issue.
- **Tests:** Each issue creates its own test file. NEVER modify another issue's test file.

### File Ownership
- Before starting work, check which files your issue is allowed to create/modify (listed in the issue description under "Files")
- If you need to modify a file owned by another issue, you are blocked by that issue — do not proceed
- Shared infrastructure files (server.js, database.js, app.js) are modified ONLY by the scaffolding issue in Phase 1

## Git Workflow — MANDATORY

- **NEVER merge directly to main** — all changes go through Pull Requests, no exceptions
- **NEVER run `git merge` into main** — use `gh pr create` to open a PR, then merge via GitHub
- **NEVER run `gh pr merge`** — merging PRs is the developer's responsibility, not the agent's. The agent creates the PR and leaves it for human review.
- Feature branches are merged to main ONLY via approved PR — merged by the human developer
- If you catch yourself about to merge to main or merge a PR, STOP immediately
- When work is complete on a branch: push the branch, create a PR with `gh pr create`, and leave it for review
- Agents and subagents MUST follow this rule — include it in every agent prompt

### Staying Up to Date

- **Always sync before starting work** — run `git fetch origin && git pull origin main` before creating branches or starting any task
- **Always sync when resuming** — if resuming a session, fetch and pull main first. Remote may have changed since last session.
- **Check branch freshness** — before working on an existing branch, ensure it's up to date with main

## GitHub Workflow

- Milestones map to PRD milestone sections (M1, M2, M3...)
- Issues tagged by feature label (F1, F2, F3...) and type label
- Branch naming: feature/<issue-number>-short-description
- Commits reference issue numbers: Verb noun (#N)
- No issue = no work started, no exceptions
- Issues closed on merge only — never before

## Definition of Done

All work MUST follow TDD — no exceptions:

1. Red   — Write the failing test first. Commit it. It must fail before any implementation.
2. Green — Write minimum code to make the test pass.
3. Refactor — Clean up while keeping tests green.

An issue is done when ALL of the following are true:
- [ ] Failing test written first and committed before any implementation
- [ ] Implementation written to make test pass (Green)
- [ ] Code refactored while keeping tests green
- [ ] Full test suite passes — no regressions
- [ ] Happy path: 100% test coverage
- [ ] Non-happy path: 100% target (edge cases can be lower, document exceptions)
- [ ] Error states: 100% — every error state handled AND tested, no exceptions
- [ ] No commented-out code
- [ ] No hardcoded values — config or constants only
- [ ] Every TODO references a GitHub issue number
- [ ] Functions are single-responsibility
- [ ] No issue = no work started, no exceptions
- [ ] Merged via PR — issue closed on merge only, not before
```

Commit the CLAUDE.md to the repo root with message: "Add CLAUDE.md (#[first issue number])"

---

## Completion Summary

When all steps are done, output:

```
[Project Name] bootstrapped successfully

Milestones:  [N] created
Issues:      [N] created
Labels:      [N] applied
Dep Map:     Pinned as issue #[N]
CLAUDE.md:   [Created / Already existed]
Frontend:    [framework — or "No frontend"]

Next step: Run /pm-next [repo] to see what to work on first.
```
