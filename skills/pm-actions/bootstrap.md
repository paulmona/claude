# Action: Bootstrap

**Available in:** Full mode only (requires Bash + `gh` CLI)

Read `shared.md` for database schemas, issue body template, and resume state schema before starting.

Check for existing resume state in `.claude/pm-state.json`.

---

## Pre-flight

1. Resolve Notion PRD Database ID from config
2. Fetch PRD from Notion. Confirm Status=Approved and GitHub Ready=true. If not, stop: "Run `/pm ready` first."
3. Fetch TRD (child page of PRD). If no TRD found, warn and offer to continue with PRD only.
4. Determine GitHub repo from project CLAUDE.md or ask user.

**Frontend interview** (if project has UI) -- ask if not answered in PRD/TRD:
- Has frontend? (web/mobile/CLI/API-only)
- Framework? (React, Vue, Next.js, Flutter, vanilla JS, etc.)
- Existing designs? (Figma, mockups, TRD wireframes, generate from requirements, none)
- Styling approach? (Tailwind, CSS modules, plain CSS, component library)
- Responsive/mobile-friendly?
- Main pages/views?

5. Confirm: "Ready to bootstrap **[Project Name]** into **[repo]**. This will populate the Notion board, create GitHub milestones + issues, cross-link everything, and update the dashboard. Confirm?"

---

## Step 1: Populate Notion Project Board

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

---

## Step 2: Create GitHub Milestones

For each TRD milestone, create via `gh api`:
- Title: `M[N]: [Milestone Name]`
- Description: milestone scope from TRD

**Frontend milestone rule:** If `has_ui=true`, verify milestones cover full stack. If no explicit frontend integration milestone, create one.

**Save state** after milestones created.

---

## Step 3: Create GitHub Issues

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

Use the Issue Body Template from `shared.md` for each issue.

**After creating each issue**, update the corresponding Notion board card with the GitHub Issue URL via `notion-update-page`.

**Save state** after each milestone's issues are created.

---

## Step 4: Update Dashboard

Update the dashboard page milestone progress table with actual counts from GitHub.

---

## Step 5: Create Dependency Map

Create a pinned GitHub issue titled `Dependency Map -- [Project Name]` with phased issue list. Pin it.

---

## Step 6: Generate/Update CLAUDE.md

If no project CLAUDE.md exists, generate one with:
- Build & run commands (from TRD tech stack)
- Architecture overview (from TRD)
- Notion section with all IDs (PRD Database ID, PRD Page ID, Dashboard Page ID, Project Board Data Source ID)
- Frontend section (if applicable)
- Git workflow rules (branch naming, TDD, PR-only merges)
- Parallel development file ownership rules

Commit: `"Add CLAUDE.md (#[first issue number])"`

**Save state** with `current_step: "complete"`.

---

## Completion Summary

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
