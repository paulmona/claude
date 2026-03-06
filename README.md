# claude-skills

Custom Claude Code slash commands for project management workflows.

## Installation

### As a Claude Code Plugin (recommended)
Inside any Claude Code session:
```
/plugin marketplace add https://github.com/paulmona/claude
```

### Manual Install
```bash
cp skills/* ~/.claude/commands/
```

---

## Skills

### Project Setup

| Skill | Usage | What it does |
|---|---|---|
| `/pm-prd-ready` | `/pm-prd-ready PRD-002` | Marks a Notion PRD as GitHub Ready |
| `/pm-bootstrap` | `/pm-bootstrap PRD-002 paulmona/my-repo` | Full project bootstrap: PRD + TRD → Milestones → Issues → Dependency Map → CLAUDE.md |

### Daily Development

| Skill | Usage | What it does |
|---|---|---|
| `/pm-bug` | `/pm-bug "description"` | Creates a labeled bug issue in GitHub with DoD checklist |
| `/pm-bughunt` | `/pm-bughunt #55` | Troubleshoot and root-cause a bug with structured investigation |
| `/pm-enhancement` | `/pm-enhancement "description"` | Creates a labeled enhancement issue in GitHub with DoD checklist |
| `/pm-next` | `/pm-next paulmona/my-repo` | Reads GitHub state, recommends highest-priority unblocked work |
| `/pm-status` | `/pm-status paulmona/my-repo` | Milestone progress, open bugs, blocked issues, health summary |

---

## Standards

All skills embed a Definition of Done:

- Failing test written first and committed before any implementation (TDD Red)
- Implementation written to make test pass (Green)
- Code refactored while keeping tests green
- Full test suite passes — no regressions
- Happy path: 100% test coverage
- Non-happy path: 100% target (edge cases can be lower, document exceptions)
- Error states: 100% — every error state handled AND tested, no exceptions
- No commented-out code
- No hardcoded values — config or constants only
- Every TODO references a GitHub issue number
- Functions are single-responsibility
- No issue = no work started, no exceptions
- Merged via PR — issue closed on merge only, not before
