# Action: Enhancement

**Available in:** Full + Light mode (same dual-write pattern as Bug)

Read `shared.md` for Enhancement Request Template and Standard DoD before starting.

---

## Info Gathering

1. If no description in args, ask: "Describe the enhancement -- what should change or be added, and why?"
2. Gather: repo (Full mode), change type (existing behavior / net-new), milestone, priority (High/Medium/Low)
3. If it does not fit an existing milestone, flag: may need new milestone or PRD update.

---

## Full Mode (Claude Code)

**Create GitHub issue** via `gh issue create`:
- Title: `Enhancement: [concise description]`
- Body: use Enhancement Request Template from `shared.md`
- Labels: enhancement, priority (high/medium/low), feature label
- Assign to milestone

**AND create Notion board card** via `notion-create-pages`:
- Story: `Enhancement: [title]`
- Status: To Do
- Type: Enhancement
- GitHub Issue: URL of created issue

Confirm: "Enhancement #[N] created in GitHub and added to Notion board."

---

## Light Mode (Claude.ai / Desktop)

**Notion board card only** (same pattern as Bug light mode). Note "GitHub issue pending" in Description.

Confirm: "Enhancement added to Notion board. Create the GitHub issue in Claude Code when ready."
