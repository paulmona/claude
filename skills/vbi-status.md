# vbi-status

Generate a health summary of a GitHub project — milestone progress, blocked issues,
open bugs, and overall project state.

## Usage
/vbi-status $ARGUMENTS

Arguments: GitHub repo (e.g. paulmona/my-repo)
If no argument provided, ask which repo.

## Steps

1. Fetch from GitHub:
   - All milestones (open and recently closed)
   - All open issues with labels and milestone assignment
   - All closed issues (for velocity calculation)
   - The pinned Dependency Map issue

2. Calculate per-milestone:
   - % complete = closed issues / total issues
   - Open issue count by type (bug, build, test, integration, enhancement)
   - Blocked issue count
   - Any issues with missing labels or missing milestone assignment

3. Output a status report in this format:

```
## Project Status — [repo] — [date]

### Milestones

| Milestone | Progress | Open | Bugs | Blocked | Status |
|---|---|---|---|---|---|
| M1: [Name] | 100% | 0 | 0 | 0 | ✅ Complete |
| M2: [Name] | 60% (6/10) | 4 | 1 | 1 | 🔄 Active |
| M3: [Name] | 0% | 8 | 0 | 0 | ⏳ Not started |

### Open Bugs
#[N] [title] — [milestone] — [severity label]
#[N] [title] — [milestone] — [severity label]
(None if no open bugs)

### Blocked Issues
#[N] [title] — waiting on #[N] ([reason])
(None if nothing blocked)

### ⚠️ Health Flags
- [N] issues have no milestone assigned
- [N] issues have no type label
- [N] issues have TODOs without issue references (list them)
- [N] issues missing DoD checklist
(None if project is clean)

### Velocity
Closed in last 7 days: [N] issues
Closed in last 30 days: [N] issues
Estimated completion of M[N] at current pace: [date estimate or "insufficient data"]
```

4. Close with a one-line summary:
   "Overall: [Green / Yellow / Red] — [one sentence assessment]"

   Green  = Active milestone on track, no critical bugs, no systemic blockers
   Yellow = Minor blockers or bugs present, progress continuing
   Red    = Critical bugs open, milestone blocked, or no progress in 7+ days
