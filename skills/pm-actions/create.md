# Action: Create Project (PRD)

**Available in:** Full + Light mode

Read `shared.md` for database schemas and resume state schema before starting.

Check for existing resume state in `.claude/pm-state.json` where `action` is `create`.

---

## Phase 1: Interview

**Resume check:** If state exists, show a recap of completed topics and their key points, then ask: "Resume from where you left off, or start fresh?" If resuming, skip to the next unanswered topic. If starting fresh, delete the state file.

Start warm. Ask one topic at a time. Wait for answers before moving on. **Save state after each completed topic.**

**Opening:**
> "Let's build your PRD. I'll walk you through the product requirements -- what we're building and why. Technical details like architecture and tooling will go into a TRD afterward. First: **what's the one-line pitch for this product or feature?**"

**Interview sequence:**

1. **Name & Pitch** -- What are we calling this? Elevator pitch?
2. **Problem** -- What problem? Who experiences it? How painful today?
3. **Goals** -- If this ships perfectly, what's true? (Push for 3-6 specific goals)
4. **Non-Goals** -- What are you explicitly NOT doing? (Help: "what might people assume is in scope?")
5. **Users & Stories** -- Who uses this? 2-5 user stories. Product-level, map to epics. Format: `As a [role], I want [action] so that [outcome].`
6. **Success Metrics** -- How will you know this worked? Push for quantifiable outcomes. Flag production-only metrics with `*(requires instrumentation)*`.
7. **Stakeholders** -- Who owns this? Who needs to be consulted or informed?
8. **Open Questions** -- Anything unresolved?
9. **Category & Priority** -- Internal Ops / Client Demo / GTM? P0 / P1 / P2?

**Coaching rules:**
- When user drifts into technical details, acknowledge and redirect: "Great context for the TRD. For the PRD, let's frame it as [product-level restatement]."
- Draw out thin answers: "What does that look like in practice?" / "Give me an example." / "How will you know it worked? Give me a number."
- Technology, architecture, implementation phases -> TRD. User needs, business outcomes, success measures -> PRD.

---

## Phase 2: Draft & Confirm

Draft full PRD in Markdown. Show to user:
> "Here's your draft PRD. Any sections to adjust before I save to Notion?"

Wait for approval. Apply edits.

---

## Phase 3: Save to Notion

**Step 1 -- Determine next PRD number.** Use `notion-search` to query PRDs database. Parse titles for `PRD-NNN`. Increment highest by 1. If none exist, start at `PRD-001`.

**Step 2 -- Create PRD page** via `notion-create-pages`:
- Parent: PRD Database ID (from config)
- Title: `PRD-{NNN}: {Feature Name}`
- Properties: Status=Draft, Priority={selected}, Category={selected}, GitHub Ready=false
- Body: full PRD markdown (Overview, Problem Statement, Goals, Non-Goals, User Stories, Success Metrics, Stakeholders & Ownership, Open Questions)

**Step 3 -- Create Project Status dashboard** via `notion-create-pages`:
- Parent: the PRD page ID (child page)
- Title: `Project Status: {Feature Name}`
- Body:

```markdown
## Milestone Progress

| Milestone | Total | Done | Open | Blocked | % Complete |
|---|---|---|---|---|---|
| (populated by bootstrap) | | | | | |

## Build Status

| Metric | Value |
|---|---|
| Total Stories | -- |
| Bugs Open | 0 |
| Velocity (7d) | -- |
| Health | -- |

## Quick Links

- **PRD:** [link to PRD page]
- **TRD:** (pending)
- **GitHub Repo:** (pending)
- **Dependency Map:** (pending)

## Story Board

(Project Board database will appear below)
```

**Step 4 -- Create Project Board database** via `notion-create-database`:
- Parent: dashboard page ID
- Title: `Project Board`
- Inline: true
- Schema: per shared.md Project Board Database schema

**Step 5 -- Update PRD page** via `notion-update-page`:
- Set Status Dashboard URL property to the dashboard page URL

---

## Error Handling

- User bails mid-interview: save state to `.claude/pm-state.json` with all completed topics. "Progress saved. Run `/pm create` to pick up where you left off."
- Notion save fails: show full PRD as Markdown so nothing is lost
- Category/Priority unclear: default to Internal Ops / P1 - Next, mention assumption
- No existing PRDs: start at PRD-001
