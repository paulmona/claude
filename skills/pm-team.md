# pm-team

Orchestrate parallel agent work on multiple GitHub issues. Validates issues are unblocked,
checks for file ownership conflicts, and spawns `pm-issue-worker` agents in isolated worktrees.

## Usage
/pm-team $ARGUMENTS

Arguments: GitHub repo and issue numbers (e.g. "paulmona/my-repo #12 #13 #14")
If no arguments provided, ask for the repo, then fetch unblocked issues and let the user pick.

## Steps

1. **Sync and fetch project state:**
   - Run `git fetch origin && git pull origin main`
   - Fetch all specified issues from GitHub using `gh issue view`
   - Fetch the pinned Dependency Map issue (search for "Dependency Map")

2. **Validate each issue is unblocked:**
   - Parse the "Dependencies" section of each issue
   - Check that all blocking issues are closed
   - If any issue is blocked, report it and remove from the batch:
     ```
     ⚠️ Removing #14 from batch — blocked by #12 (still open)
     ```

3. **Check for file ownership conflicts:**
   - Parse the "Files" section of each issue
   - Compare file lists across all issues in the batch
   - If two issues modify the same file, they CANNOT run in parallel:
     ```
     ⚠️ Conflict: #12 and #13 both modify src/server.js
        These must run sequentially. Remove one from this batch.
     ```
   - Ask the user which to keep in this batch, or whether to run them sequentially

4. **Confirm the batch:**
   Present the validated batch to the user:
   ```
   ## Agent Team — [repo]

   Ready to spawn [N] agents in parallel:

   | Agent | Issue | Title | Files Created |
   |-------|-------|-------|---------------|
   | 1     | #12   | Write failing tests for... | test/scoring.test.js |
   | 2     | #13   | Implement scoring...       | src/scoring.js |
   | 3     | #15   | Wire scoring to frontend   | public/js/scoring.js |

   No file conflicts detected. All issues unblocked.

   Launch agents?
   ```

5. **Spawn agents:**
   For each validated issue, spawn a `pm-issue-worker` agent:
   - Each agent runs in an isolated worktree
   - Pass the issue number and repo as arguments
   - Agents work independently — no coordination needed after launch

6. **Monitor and report:**
   As agents complete, report their status:
   ```
   ## Team Results

   ✅ Agent 1 — #12 — PR created: #25
   ✅ Agent 2 — #13 — PR created: #26
   ❌ Agent 3 — #15 — Blocked: dependency on #13 not yet merged

   2/3 agents completed successfully.
   ```

## Rules

- Never spawn agents for issues in the same dependency phase if they touch the same files
- Always validate before spawning — catching conflicts after agents start wastes work
- If no Dependency Map issue exists, warn the user but allow proceeding (rely on issue-level dependency declarations)
- Maximum batch size: defer to the user's judgement, but flag if more than 5 agents are requested
- Each agent follows the full TDD workflow independently — they do not share state

## Without Arguments — Interactive Mode

If invoked without issue numbers:

1. Fetch all open issues in the active milestone
2. Classify as UNBLOCKED / BLOCKED / IN PROGRESS (same logic as `/pm-next`)
3. Present unblocked issues and let the user select which to include in the batch
4. Continue from Step 3 (file conflict check)
