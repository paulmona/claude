# Action: Create TRD

**Available in:** Full + Light mode

Read `shared.md` for database schemas and resume state schema before starting.

Check for existing resume state in `.claude/pm-state.json` where `action` is `trd`. If state exists, show a recap of completed topics and their key points, then ask: "Resume from where you left off, or start fresh?" If resuming, skip Phase 0 (PRD reference is in state) and continue from the next unanswered topic. If starting fresh, delete the state file.

---

## Phase 0: Locate the PRD

- User specifies PRD (name, number, or link): use `notion-search` to find it
- Same conversation as PRD creation: use the page ID from that step
- Ambiguous: ask "Which PRD? Give me a name or number."

Fetch PRD content via `notion-fetch`. Extract: Overview, Goals, Non-Goals, User Stories, technical notes.

---

## Phase 1: Interview

**Opening:**
> "I've pulled up **[PRD Title]**. Let's build the technical plan. First: **what's the high-level technical approach?**"

Ask one topic at a time. Wait for answers before moving on. **Save state after each completed topic.**

**Interview sequence:**

1. **Technical Approach** -- Architecture? What are we building?
2. **Tool & Technology Decisions** -- Languages, frameworks, SDKs, APIs? Why each? (Table: Tool | Purpose | Rationale)
3. **Interface Mapping** -- Endpoints (API), components (UI), or contracts (service)
4. **Observability** -- Monitoring tool? For each PRD metric marked `*(requires instrumentation)*`: what signal captures it, what threshold? Key signals per domain. Alerting rules. If unsure, offer defaults.
5. **Milestones** -- How to phase this? M1 = smallest shippable thing. Push for 2-4 milestones. Observability must be its own milestone or explicitly in the final one.
6. **Stories per Milestone** -- Discrete tasks per milestone. 3-8 stories each. Each = one GitHub issue. Story IDs: S1, S2, S3... Keep atomic.
7. **Dependencies** -- Which stories block others?
8. **Risks & Constraints** -- Known blockers, platform limitations?
9. **Open Questions** -- Unresolved technical decisions?

**Tips:**
- If user provides OpenAPI spec or API docs, auto-generate interface mapping and suggest milestone/story breakdowns
- If unsure about milestones, suggest: M1 = scaffolding + core, M2 = secondary features, M3 = polish + stretch

---

## Phase 2: Draft & Confirm

Draft full TRD in Markdown. Show to user. Wait for approval.

**TRD sections:**
1. Summary
2. Architecture & Design Decisions (table + prose)
3. API/Interface Mapping
4. Observability (tooling, signals table, alerting, analytics)
5. Technical Milestones (with stories per milestone)
6. Dependency Map (phased)
7. Technical Risks & Constraints (table)
8. Open Technical Questions

---

## Phase 3: Save to Notion

**Step 1 -- Create TRD page** via `notion-create-pages`:
- Parent: PRD page ID (child page)
- Title: `TRD: {Feature Name}`
- Body: full TRD markdown

**Step 2 -- Update dashboard Quick Links** via `notion-fetch` + `notion-update-page`:
- Set TRD link in the Quick Links section of the dashboard page

---

## Error Handling

- PRD not found: "Can't find that PRD. Double-check the name or number?"
- User bails mid-interview: save state to `.claude/pm-state.json` with all completed topics and PRD reference. "Progress saved. Run `/pm trd` to pick up where you left off."
- Notion fails: show full TRD as Markdown
- No PRD exists: "Need a PRD first -- want to run `/pm create`?"
