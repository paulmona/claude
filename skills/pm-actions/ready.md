# Action: Mark Ready

**Available in:** Full + Light mode

---

## Steps

1. Find PRD via `notion-search` (by name/number from args, or list Approved PRDs not yet GitHub Ready)
2. Confirm Status = Approved. If not: "This PRD's status is [status]. Update it to Approved in Notion first."
3. Ask for the GitHub repo URL if not already in project CLAUDE.md. Save it to CLAUDE.md under `## GitHub`.
4. Confirm with user: "Ready to mark **[PRD name]** as GitHub Ready? This signals it's ready for bootstrap."
5. Use `notion-update-page` to set GitHub Ready = true
6. Update dashboard Quick Links with the GitHub repo URL via `notion-update-page`
7. Update dashboard status section if dashboard exists
8. Confirm and offer next step: "PRD marked GitHub Ready. Switch to Claude Code and run `/pm bootstrap` to create milestones and issues."
