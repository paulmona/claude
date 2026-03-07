---
description: Quick reference of all PM skills — run this when you're about to do something and want to check if there's a skill for it
user_invocable: true
---

# /pm-help — PM Skills Quick Reference

Print the table below exactly as-is.

---

## What are you trying to do?

| I want to…                                        | Run this       | What it does                                                                                   |
|---------------------------------------------------|----------------|------------------------------------------------------------------------------------------------|
| **Plan a new product**                            | `/pm-create-prd` | Guided interview → saves a PRD to Notion                                                     |
| **Plan the technical approach**                   | `/pm-create-trd` | Reads a PRD → creates a TRD with architecture, tools, milestones, and dependency map          |
| **Mark a PRD ready for dev**                      | `/pm-prd-ready`  | Marks a Notion PRD as "GitHub Ready" so it can be bootstrapped                                |
| **Set up a GitHub project from a PRD**            | `/pm-bootstrap`  | PRD + TRD → milestones, issues, labels, dependency map, and CLAUDE.md in GitHub               |
| **Find out what to work on next**                 | `/pm-next`       | Analyzes issues, dependencies, and priorities → recommends the highest-priority unblocked work |
| **Run multiple issues in parallel with agents**   | `/pm-team`       | Validates unblocked issues, checks file conflicts, spawns one agent per issue in worktrees     |
| **Check project health**                          | `/pm-status`     | Milestone progress, blocked issues, open bugs, label hygiene — a project health dashboard      |
| **Report a bug**                                  | `/pm-bug`        | Creates a bug issue with correct labels, milestone, and DoD checklist                          |
| **Request an enhancement**                        | `/pm-enhancement`| Creates an enhancement issue with correct labels, milestone, and DoD checklist                 |
| **Investigate a bug**                             | `/pm-bughunt`    | Root-cause analysis with optional GitHub issue tracking                                        |
| **Review the Definition of Done**                 | `/pm-dod`        | TDD workflow + 13-item DoD checklist — quick reference before opening a PR                     |
| **Review git/GitHub conventions**                 | `/pm-git-workflow`| Branch naming, commit format, PR rules, label system                                          |
| **Review parallel dev rules**                     | `/pm-parallel`   | File ownership, modular architecture patterns, phase rules                                     |
| **See this help again**                           | `/pm-help`       | You're looking at it                                                                           |

## Typical Workflow

```
/pm-create-prd          ← define the product
/pm-create-trd          ← define the technical approach
/pm-prd-ready           ← mark it ready
/pm-bootstrap           ← set up GitHub project
/pm-next                ← pick first issue
  ... build ...
/pm-team                ← hand off parallel work to agents
/pm-status              ← check progress
/pm-bug or /pm-enhancement  ← track issues as they arise
/pm-bughunt             ← investigate problems
```

## Reference Skills (also preloaded into agents)

`/pm-dod`, `/pm-git-workflow`, and `/pm-parallel` are quick references you can pull up anytime. They're also preloaded into `pm-issue-worker` agents so every agent follows the same rules.
