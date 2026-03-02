# vbi-bug

Create a bug report as a GitHub Issue with correct labels, milestone assignment, and DoD checklist.

## Usage
/vbi-bug $ARGUMENTS

Arguments: Description of the bug (e.g. "Lead scoring returns null when company size is missing")
If no argument provided, ask the user to describe the bug.

## Steps

1. If no $ARGUMENTS, ask: "Describe the bug — what is happening vs. what should happen?"

2. Ask for the following if not clear from the description:
   - Which repo? (if not obvious from current context)
   - Which milestone is this related to? (fetch open milestones from GitHub and present list)
   - Severity: Critical (blocks all work) / High (blocks a feature) / Low (cosmetic or edge case)

3. Create a GitHub Issue with this structure:

### Title
Bug: [concise description of what is wrong]

### Body
```
## Bug Report

## What is happening
[Current behaviour — what the system does]

## What should happen
[Expected behaviour — what the system should do]

## Steps to Reproduce
1. [Step]
2. [Step]
3. [Step]

## Environment
[Relevant context — browser, OS, version, data state]

## Definition of Done
- [ ] Failing test written first that reproduces the bug — committed before any fix
- [ ] Fix implemented to make the test pass
- [ ] Full test suite passes — no regressions
- [ ] Error state that caused bug is now handled and tested
- [ ] No hardcoded values introduced in fix
- [ ] No commented-out code
- [ ] Every TODO references a GitHub issue number
- [ ] Merged via PR — issue closed on merge only

## Notes
[Any additional context, screenshots, logs]
```

4. Apply labels:
   - Type: bug
   - Severity: critical / high / low (create label if it does not exist)
   - Feature label F1/F2/F3 matching the affected milestone

5. Assign to the relevant milestone.

6. Confirm: "Bug #[N] created: [title]. Run /vbi-next [repo] to see if this affects current priorities."
