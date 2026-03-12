# Action: Status

**Available in:** Full + Light mode (different behavior)

---

## Full Mode (Claude Code)

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

---

## Light Mode (Claude.ai / Desktop)

1. Read dashboard from Notion via `notion-fetch` (Dashboard Page ID from config)
2. Present the milestone progress and build status tables from the dashboard
3. Note: "This is the last synced state. For live data, run `/pm status` in Claude Code."
