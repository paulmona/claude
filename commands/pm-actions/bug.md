# Action: Bug

**Available in:** Full + Light mode (different behavior)

Read `shared.md` for Bug Report Template and Bug DoD before starting.

---

## Info Gathering

1. If no description in args, ask: "Describe the bug -- what is happening vs. what should happen?"
2. Gather: repo (Full mode), milestone, severity (Critical/High/Low)

---

## Full Mode (Claude Code)

**Create GitHub issue** via `gh issue create`:
- Title: `Bug: [concise description]`
- Body: use Bug Report Template from `shared.md`
- Labels: bug, severity (critical/high/low), feature label (F1/F2/etc.)
- Assign to relevant milestone

**AND create Notion board card** via `notion-create-pages`:
- Story: `Bug: [title]`
- Status: To Do
- Type: Bug
- Milestone: matching milestone
- GitHub Issue: URL of created GitHub issue

Confirm: "Bug #[N] created in GitHub and added to Notion board."

---

## Light Mode (Claude.ai / Desktop)

**Create Notion board card only** via `notion-create-pages`:
- Story: `Bug: [title]`
- Status: To Do
- Type: Bug
- Milestone: matching milestone
- Description: full bug details
- GitHub Issue: (empty)

Add note in Description: "GitHub issue pending -- create in Claude Code with `/pm bug`"

Confirm: "Bug added to Notion board. Create the GitHub issue in Claude Code when ready."
