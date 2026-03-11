# Action: Bughunt

**Available in:** Full mode only

Read `shared.md` for resume state schema before starting. Check for existing state in `.claude/pm-state.json`.

---

## Step 1: Identify the Bug

**Option A -- GitHub issue number provided** (e.g. `#55`):
Fetch with `gh issue view`. Save state. Proceed.

**Option B -- No argument:**
List open bugs: `gh issue list --label bug --state open --sort created`
Let user pick one, or describe a new bug.

**Option C -- Description provided (no GitHub issue):**
Offer to create GitHub issue for tracking, or investigate without.

---

## Step 2: Gather Evidence

Ask progressively (not all at once):
1. Error output / stack trace?
2. Relevant logs?
3. Steps to reproduce? Intermittent?
4. Observability data (metrics, traces, alerts)?
5. Environment?
6. Recent changes / deploys?

**Save state.** Offer: "Evidence collected. Ready to investigate, or save & exit?"

---

## Step 3: Investigate

1. **Reproduce** locally (run tests, dev server)
2. **Trace** the code path through the codebase
3. **Form hypotheses** ranked by likelihood
4. **Test each hypothesis:**
   - Describe what you're checking and why
   - Rule in or out with clear reasoning
   - If using GitHub, add comment after each hypothesis
   - **Save state** after each. Offer: "Hypothesis [N] tested ([status]). Continue, or save & exit?"
5. Iterate if all ruled out -- ask for more context, broaden search

---

## Step 4: Root Cause Identified

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

---

## Step 5: Wrap Up

1. Summarize findings
2. **Update Notion board card** -- set Status to Done (or In Progress if PR pending) via `notion-update-page`
3. Offer to create issues for related bugs found
4. **Delete state file**

---

## Key Rules

- Developer drives -- present findings, wait for decisions
- Evidence-based -- every hypothesis cites specific evidence
- Rule things out explicitly -- document what was checked
- TDD for fixes -- failing test first, no exceptions
- Save state often -- after every checkpoint
- GitHub is optional for tracking -- never force it
