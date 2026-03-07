# pm-dod

Quick reference for the Definition of Done checklist and TDD workflow.
Use this to review your work before opening a PR, or preload it into agent definitions
so agents always have the DoD available.

## Usage
/pm-dod

No arguments. Outputs the full DoD checklist and TDD workflow for reference.

## TDD Workflow — No Exceptions

All work follows Red-Green-Refactor:

1. **Red** — Write the failing test first. Commit it. It must fail before any implementation.
2. **Green** — Write minimum code to make the test pass.
3. **Refactor** — Clean up while keeping tests green.

## Definition of Done Checklist

An issue is done when ALL of the following are true:

- [ ] Failing test written first and committed before any implementation
- [ ] Implementation written to make test pass (Green)
- [ ] Code refactored while keeping tests green
- [ ] Full test suite passes — no regressions
- [ ] Happy path: 100% test coverage
- [ ] Non-happy path: 100% target (edge cases can be lower, document exceptions)
- [ ] Error states: 100% — every error state handled AND tested, no exceptions
- [ ] No commented-out code
- [ ] No hardcoded values — config or constants only
- [ ] Every TODO references a GitHub issue number
- [ ] Functions are single-responsibility
- [ ] No issue = no work started, no exceptions
- [ ] Merged via PR — issue closed on merge only, not before

## How to Use This Checklist

1. **Before opening a PR:** Walk through every item. If any item is unchecked, the work is not done.
2. **During code review:** Use this as the review rubric. Reject PRs that skip items.
3. **When an agent is working an issue:** The agent should self-check against this list before creating the PR.

## Common Failures

- Skipping the Red step — writing implementation before the test exists
- Committing commented-out code "for later"
- Hardcoding values that should be config (URLs, ports, thresholds)
- TODOs without issue references (creates invisible tech debt)
- Closing issues before the PR is merged
