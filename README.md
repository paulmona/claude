# claude-skills

Custom Claude Code slash commands for Viewbridge AI development workflows.
All commands are prefixed with `vbi-` to identify them as Viewbridge commands.

## Installation

### As a Claude Code Plugin (recommended)
Inside any Claude Code session:
```
/plugin marketplace add https://github.com/paulmona/claude-skills
```

### Manual Install
```bash
cp commands/* ~/.claude/commands/
```

---

## Commands

### Project Setup

| Command | Usage | What it does |
|---|---|---|
| `/vbi-prd-ready` | `/vbi-prd-ready PRD-002` | Marks a Notion PRD as GitHub Ready |
| `/vbi-bootstrap` | `/vbi-bootstrap PRD-002 paulmona/my-repo` | Full project bootstrap: PRD → Milestones → Issues → Dependency Map → CLAUDE.md |

### Daily Development

| Command | Usage | What it does |
|---|---|---|
| `/vbi-bug` | `/vbi-bug "description"` | Creates a labeled bug issue in GitHub with DoD checklist |
| `/vbi-enhancement` | `/vbi-enhancement "description"` | Creates a labeled enhancement issue in GitHub with DoD checklist |
| `/vbi-next` | `/vbi-next paulmona/my-repo` | Reads GitHub state, recommends highest-priority unblocked work |
| `/vbi-status` | `/vbi-status paulmona/my-repo` | Milestone progress, open bugs, blocked issues, health summary |

---

## Standards

All commands embed the Viewbridge Definition of Done:

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
