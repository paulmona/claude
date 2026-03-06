# pm-enhancement

Create an enhancement request as a GitHub Issue with correct labels, milestone assignment, and DoD checklist.
Use for new features, changes to existing behaviour, or improvements discovered during development or testing.

## Usage
/pm-enhancement $ARGUMENTS

Arguments: Description of the enhancement (e.g. "Add email notification when assessment report is ready")
If no argument provided, ask the user to describe the enhancement.

## Resume Support

If `.claude/enhancement-state.json` exists on start, present the saved info:
```
Found enhancement draft in progress:
  Summary: [enhancement summary]
  Repo: [repo]
  Type: [change to existing / net-new]
  Milestone: [milestone or "not yet selected"]
  Priority: [priority or "not yet selected"]

  Resume and create this enhancement, or start fresh?
```

State is saved after info gathering (Step 2) so the user can pause before creation.
State file is deleted after the enhancement is created.

---

## Steps

1. If no $ARGUMENTS, ask: "Describe the enhancement — what should change or be added, and why?"

2. Ask for the following if not clear from the description:
   - Which repo? (if not obvious from current context)
   - Is this a change to existing behaviour or net-new functionality?
   - Which milestone does this belong to? (fetch open milestones from GitHub and present list)
     If it does not fit an existing milestone, flag this — it may need a new milestone or PRD update.
   - Priority: High (needed for milestone completion) / Medium (improves quality) / Low (nice to have)

   **Save state** after all info is gathered. Offer: "Ready to create the enhancement in GitHub, or save & exit to finish later?"

3. Create a GitHub Issue with this structure:

### Title
Enhancement: [concise description of what should change or be added]

### Body
```
## Enhancement Request

## Current Behaviour
[What happens today — or "N/A" if this is net-new]

## Proposed Behaviour
[What should happen after this change]

## Motivation
[Why this matters — what problem it solves or what it improves]

## Acceptance Criteria
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

## Definition of Done
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
- [ ] Merged via PR — issue closed on merge only

## Notes
[Any additional context, designs, or constraints]
```

4. Apply labels:
   - Type: enhancement
   - Priority: high / medium / low (create label if it does not exist)
   - Feature label F1/F2/F3 matching the affected milestone

5. Assign to the relevant milestone.

6. **Delete state file.** Confirm: "Enhancement #[N] created: [title]. Run /pm-next [repo] to see where it fits in current priorities."
