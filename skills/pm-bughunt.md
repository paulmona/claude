# pm-bughunt

Troubleshoot and root-cause a bug. Optionally integrates with GitHub Issues for tracking investigation progress.

## Usage
/pm-bughunt $ARGUMENTS

Arguments: A GitHub issue number (e.g. "#55"), a bug description, or omit to browse bugs from GitHub.

---

## Resume Support

This skill supports resuming from interruptions. State is saved to `.claude/bughunt-state.json`.

### On Start — Check for Existing State

Before doing anything, look for `.claude/bughunt-state.json`. If found, present a summary:

```
Found bughunt investigation in progress:
  Bug: [#N or description]
  Step: [identify / gather_evidence / investigate / root_cause / fixing]
  Hypotheses tested: N (M ruled out, K confirmed, J inconclusive)
  Evidence collected: [summary]
  Branch: [branch name if fix in progress]

  Resume investigation, or start fresh?
```

### State File Format

```json
{
  "version": 1,
  "started_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "bug_source": "github|description|none",
  "github_issue": "#N or null",
  "description": "bug description",
  "current_step": "identify|gather_evidence|investigate|root_cause|fixing",
  "evidence": {
    "error_output": "...",
    "logs": "...",
    "reproduction_steps": "...",
    "environment": "...",
    "recent_changes": "..."
  },
  "hypotheses": [
    {
      "description": "...",
      "evidence_for": "...",
      "status": "untested|ruled_out|confirmed|inconclusive"
    }
  ],
  "root_cause": null,
  "fix": {
    "branch": null,
    "step": "not_started|red|green|complete"
  }
}
```

### When to Save State

Save after each of these checkpoints:
1. After bug is identified (Step 1 complete)
2. After evidence is gathered (Step 2 complete)
3. After each hypothesis is tested (during Step 3)
4. After root cause is identified (Step 4)
5. After each TDD phase if fixing (during Step 4)

### Pause Points

At each of these moments, offer the developer: **"Continue, or save & exit?"**
- After gathering evidence (before investigation starts)
- After each hypothesis is tested
- After root cause is confirmed (before deciding fix approach)
- After each TDD phase if fixing (Red, Green)
- When blocked or need more info

When "Save & exit" is chosen, save state and output:
```
Investigation paused — progress saved.
  Bug: [#N or description]
  Step: [current step]
  Hypotheses: N tested, [root cause status]
Run `/pm-bughunt` to resume.
```

---

## Steps

### Step 1: Identify the Bug

**Option A — GitHub issue number provided** (e.g. `#55`):
1. Fetch the issue with `gh issue view` to get full details
2. **Save state.** Proceed to Step 2

**Option B — No argument, use GitHub**:
1. Determine the repo from the current working directory or CLAUDE.md
2. Search for open bugs: `gh issue list --label bug --state open --sort created`
3. Present the list to the developer with issue number, summary, and labels
4. Let them pick one, or offer: "Or describe a new bug to investigate without GitHub"
5. **Save state.** Proceed to Step 2

**Option C — Bug description provided (no GitHub issue)**:
1. Confirm: "Want me to create a GitHub issue for this to track the investigation, or just dive in without GitHub?"
2. If yes to GitHub, create the bug using `gh issue create` with the bug label
3. **Save state.** Proceed to Step 2

### Step 2: Gather Evidence

Ask the developer for any available diagnostic information:

1. **Error output**: "Do you have an error message, stack trace, or exception?"
2. **Logs**: "Any relevant log output?"
3. **Reproduction steps**: "Can you describe the steps to reproduce, or is it intermittent?"
4. **Observability data**: "Any metrics, traces, or monitoring alerts?"
5. **Environment**: "Where does this happen?"
6. **Recent changes**: "Did this start after a recent deploy or code change?"

Don't ask all at once — start with the most relevant. **Save state** after evidence is gathered. Offer: "Evidence collected. Ready to investigate, or save & exit?"

### Step 3: Investigate

1. **Reproduce** — try to reproduce locally (run tests, check dev server)
2. **Trace the code path** — follow the bug through the codebase
3. **Form hypotheses** — propose likely causes ranked by likelihood
4. **Test hypotheses** — for each, starting with most likely:
   - Describe what you're checking and why
   - Rule in or rule out with clear reasoning
   - If using GitHub, add a comment after each hypothesis
   - **Save state** after each hypothesis. Offer: "Hypothesis [N] tested ([status]). Continue, or save & exit?"
5. **Iterate** if all ruled out — ask for more context, broaden search

### Step 4: Root Cause Identified

1. **Present the finding** with root cause, affected code, and fix approach
2. **Save state.** Ask the developer:
   - **Fix it now** — pair on the fix following TDD
   - **Just document it** — update the GitHub issue with root cause
   - **Assign to a team** — create a Claude Code team
   - **Save & exit** — save findings and resume later

3. **If fixing now** (TDD):
   - Create branch, write failing test, commit. **Save state.** Offer: "Red phase done. Continue, or save & exit?"
   - Implement fix, commit. **Save state.**
   - Run full test suite
   - If using GitHub, add summary comment

4. **If using GitHub**, add root cause analysis comment

### Step 5: Wrap Up

1. Summarize findings
2. Close GitHub issue only if merged via PR
3. Offer to create issues for related bugs found
4. **Delete the state file**

## Key Rules

- **Developer drives** — present findings, wait for decisions
- **Evidence-based** — every hypothesis cites specific evidence
- **Rule things out explicitly** — document what was checked
- **GitHub is optional** — never force it
- **TDD for fixes** — failing test first, no exceptions
- **Keep GitHub updated** — add investigation comments
- **Repo from context** — determine from cwd or CLAUDE.md
- **Save state often** — save after every checkpoint, offer save & exit at break points
