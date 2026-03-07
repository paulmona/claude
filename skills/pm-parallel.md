# pm-parallel

Quick reference for parallel development rules and file ownership conventions.
Use this when planning parallel work or when multiple agents work simultaneously,
or preload it into agent definitions to enforce file conflict prevention.

## Usage
/pm-parallel

No arguments. Outputs the parallel development rules for reference.

## Core Rule

When multiple agents work in parallel (worktrees or teams), they MUST NOT modify the same files.

## File Ownership

- Before starting work, check which files your issue is allowed to create/modify (listed in the issue description under "Files")
- If you need to modify a file owned by another issue, you are blocked by that issue — do not proceed
- Shared infrastructure files (server.js, database.js, app.js) are modified ONLY by the scaffolding issue in Phase 1

## Architecture Rules for Conflict Prevention

- **Server routes:** Add new files in `src/routes/` — the server auto-loads them. Do NOT modify `src/server.js` directly unless you are the scaffolding issue.
- **Client-side JS:** Add feature-specific files in `public/js/` — they are loaded by the HTML shell. Do NOT modify `public/app.js` unless you are the scaffolding issue.
- **Styles:** Add feature-specific CSS files in `public/css/` — they are loaded by the HTML shell. Do NOT modify `public/css/base.css` unless you are the scaffolding issue.
- **Tests:** Each issue creates its own test file. NEVER modify another issue's test file.

## Modular Architecture Patterns

Prefer modular architecture (Option A) over sequential dependency (Option B):

### Option A — Modular Architecture (preferred)

The scaffolding issue creates an extensible pattern (route loader, plugin system, barrel file),
and subsequent issues add NEW files that are auto-discovered.

Examples:
- Server routes: scaffolding creates `src/routes/` with auto-loader. Each endpoint issue creates its own file (`src/routes/generate.js`, `src/routes/nps.js`).
- Styles: scaffolding creates `public/css/base.css` and index.html loads all CSS files from `public/css/`. Feature issues create feature-specific CSS.
- Client JS: scaffolding creates a module loader. Feature issues create `public/js/form.js`, `public/js/tripcard.js`, etc.

### Option B — Sequential Dependency (fallback)

If modular architecture is not feasible, issues that modify the same file MUST be in different
dependency phases (never parallel). The dependency map must reflect this.

## Issue File Boundaries

Every issue should list its file boundaries in the description:

```
## Files (ownership for parallel development)
- Creates: src/routes/generate.js, test/routes/generate.test.js
- Modifies: (none — uses auto-loaded route pattern)
```

Issues that modify the same file as another issue must declare it, and the dependency map
must serialize them.

## Phase Rules

- **The scaffolding issue is always Phase 1 and runs alone** if it creates shared infrastructure
- Issues in the same phase can run concurrently — they must not touch the same files
- Test files are never shared — each issue creates its own
