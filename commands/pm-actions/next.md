# Action: Next

**Available in:** Full mode only

---

## Steps

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
