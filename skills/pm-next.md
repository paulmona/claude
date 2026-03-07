# pm-next

Analyse the current state of a GitHub project and recommend what to work on next.
Reads milestone progress, open issues, and dependencies to surface the highest-priority
unblocked work.

## Usage
/pm-next $ARGUMENTS

Arguments: GitHub repo (e.g. paulmona/my-repo)
If no argument provided, ask which repo.

## Steps

1. **Sync local repo first:**
   - Run `git fetch origin && git pull origin main` to ensure you have the latest state
   - If on an existing branch, check if it's up to date with main

2. Fetch current project state from GitHub:
   - All open milestones with % complete (closed issues / total issues)
   - All open issues with labels, milestone assignment, and dependency notes
   - The pinned Dependency Map issue (search for "Dependency Map" in issues)

3. Identify the active milestone:
   - The earliest incomplete milestone is the active one
   - If multiple milestones have open issues, flag this as a potential focus problem

4. Within the active milestone, classify open issues:

   UNBLOCKED — no open dependencies, ready to start immediately
   BLOCKED    — depends on another issue that is still open
   IN PROGRESS — has been commented on or has a linked branch (infer from activity)

5. Apply priority ordering to unblocked issues:
   - test issues before build issues (TDD — failing test must exist before implementation)
   - setup / integration issues before build issues if foundational
   - bug / critical issues before enhancements
   - lower issue number (created earlier) as tiebreaker

6. Output a recommendation in this format:

```
## Project Status — [repo] — [date]

### Active Milestone: M[N]: [Name] ([X]% complete — [closed]/[total] issues)

### ✅ Recommended Next (unblocked, highest priority)
#[N] [title] ([type] label) — [one sentence why this is first]

### 🔜 Also Unblocked (can run in parallel)
#[N] [title]
#[N] [title]

### 🔒 Blocked
#[N] [title] — waiting on #[N] ([that issue title])

### ⚠️ Flags
[Any issues with no milestone, no labels, missing DoD checklist, or open TODOs
without issue references]

### Next Milestone Preview: M[N+1]: [Name]
[Not started — will unlock when M[N] is complete]
```

7. If no unblocked issues exist, flag the blocker clearly and suggest resolving it first.

8. **Offer work mode choice:**
   After presenting the recommendation, ask:
   ```
   How would you like to proceed?
   - Work on #[N] now (start in this session)
   - Batch unblocked issues for agent team (hand off to /pm-team)
   ```
   - If the user chooses to work directly, proceed as normal.
   - If the user chooses team mode, invoke `/pm-team [repo] [unblocked issue numbers]` with all
     unblocked issues from the "Also Unblocked" list plus the recommended issue.
