# pm-create-trd

Create a Technical Requirements Document (TRD) from an existing PRD and save it as a child page of that PRD in Notion. The TRD covers the how — architecture, tool decisions, technical milestones, implementation stories, and dependency mapping. This is the document that feeds directly into /pm-bootstrap to generate GitHub milestones and issues.

## Usage
/pm-create-trd $ARGUMENTS

Arguments: PRD name, number, or Notion link (e.g. "PRD-009", "Operational Assessment Tool")
If no argument provided, ask which PRD to create the TRD for.

---

## Notion Target

- **PRDs database ID**: Read from `~/.claude/notion-config.json` (key: `prd_database_id`). If the file doesn't exist or the key is missing, ask the user for their Notion PRD database ID and create/update the file.
- **TRD page title format**: `TRD: {Feature Name}`
- **TRD page parent**: The PRD page that this TRD belongs to (child page in Notion)

## TRD Structure

Every TRD must contain these sections in order:

1. **Summary** — One paragraph restating the product goal (pulled from PRD) and the technical approach.
2. **Architecture & Design Decisions** — Table: Tool/Technology | Purpose | Rationale. Plus prose on key architectural choices.
3. **API / Interface Mapping** — If wrapping an API: endpoint-to-tool mapping table. If building a service: interface contracts. If building a UI: component breakdown. Adapt to the project type.
4. **Observability** — How the system will be monitored in production. Covers: tracing/logging/metrics strategy, key signals per domain with thresholds, alerting rules, tooling decision, and explicit mapping of each signal back to a PRD success metric marked "*(requires instrumentation)*".
5. **Technical Milestones** — Numbered milestones (M1, M2, ...), each with scope, technical stories, and acceptance criteria. These map to epics in GitHub. Observability must appear as its own milestone (or be explicitly embedded in the final milestone) — it is not optional and not an afterthought.
6. **Implementation Stories** — Under each milestone, specific implementable tasks. Each story should be atomic enough to be a single GitHub issue. Format: `[STORY-ID] [Title] — [Description]. Depends on: [story IDs or "none"]`
7. **Dependency Map** — A clear ordering of which stories block which. Can be prose, a list, or a mermaid diagram.
8. **Technical Risks & Constraints** — Known blockers, limitations, or risks. Include workarounds where known.
9. **Open Technical Questions** — Unresolved technical decisions.

---

## Workflow

### Phase 0: Locate the PRD

Before starting the interview, identify which PRD this TRD is for.

**If the user specifies a PRD** (by name, number, or link):
- Use notion-search to find the PRD in the database (ID from `~/.claude/notion-config.json`).
- If multiple matches, list them and ask which one.

**If the user just came from pm-create-prd** (same conversation):
- Use the PRD page ID from the earlier creation step.

**If ambiguous:**
> "Which PRD should I create the TRD for? Give me a name or number (like PRD-009)."

Once found, use notion-fetch to get the full PRD content. Extract: Overview, Goals, Non-Goals, User Stories, and any technical notes the user mentioned during the PRD interview.

---

### Phase 1: Interview

The interview is more technical than the PRD interview. The user may have already provided significant technical context. Use what's available and fill gaps.

**Opening message:**

> "I've pulled up **[PRD Title]** from Notion. Let's build the technical plan. I'll walk through architecture, implementation breakdown, and dependencies. First: **what's the high-level technical approach?** (e.g., TypeScript MCP server, React app, API wrapper, etc.)"

**Interview sequence** (one at a time, adapt based on answers):

1. **Technical Approach** — What's the architecture? What are we building?
2. **Tool & Technology Decisions** — What languages, frameworks, SDKs, APIs, platforms? Why each one?
3. **Interface Mapping** — If wrapping an API: walk through the endpoints/features to expose. If building a UI: key components. If a service: contracts and integrations.
4. **Observability** — How will this system be monitored in production? Ask:
   - What tool will you use for tracing/metrics/logging? (Datadog, Grafana, CloudWatch, etc.)
   - For each PRD success metric marked "*(requires instrumentation)*", what signal captures it and what's the threshold?
   - What are the key per-domain signals? (error rate, p95 latency, queue depth, throughput)
   - What alerts need to fire, at what threshold, and who gets paged?
   - If the user is unsure, suggest a default: "A common pattern is: distributed tracing with a correlation ID on every request, a custom metric per domain (error rate + latency), and alerts at 2x normal baseline. Does that fit?"
5. **Milestones** — How would you phase this? What's M1 (smallest shippable thing)? Push for 2–4 milestones. Remind the user that Observability should be its own milestone (or the final one) — not scattered across others.
6. **Stories per Milestone** — For each milestone, what are the discrete tasks? Aim for 3–8 stories per milestone. Each should be a single PR / GitHub issue.
7. **Dependencies** — Which stories block others? What has to come first?
8. **Risks & Constraints** — Any known blockers? Platform limitations? External dependencies?
9. **Open Questions** — Anything unresolved technically?

**Tips for the interview:**
- If the user provides an OpenAPI spec, uploaded file, or API docs — use them to auto-generate the interface mapping and suggest milestone/story breakdowns.
- If the user is unsure about milestones, suggest: "M1 = scaffolding + core functionality, M2 = secondary features, M3 = polish + stretch goals."
- Story IDs should be simple sequential: `S1`, `S2`, `S3`, etc.
- Keep stories atomic — if a story has "and" in it, it's probably two stories.

---

### Phase 2: Draft & Confirm

Draft the full TRD content in Markdown. Show it to the user with:

> "Here's your draft TRD. Take a look — any sections you want to adjust before I save it to Notion as a child of **[PRD Title]**?"

Present the draft clearly. Wait for approval or edits. Apply any requested changes.

---

### Phase 3: Save to Notion

After the user confirms:

**Step 1 — Create the TRD page** using notion-create-pages:
- **Parent page ID**: The PRD's Notion page ID (makes the TRD a child page of the PRD)
- **Title**: `TRD: {Feature Name}`
- **Body**: Full TRD content in Markdown (see content format below)

**Step 2 — Update the PRD page to reference the TRD.**
Use notion-fetch to get the PRD page, then notion-update-page to add a link to the TRD at the top of the PRD body or as a page property (if the database has a TRD property).

**Content format (body of the TRD page):**
```markdown
## Summary
{One paragraph: product goal from PRD + technical approach}

---

## Architecture & Design Decisions

| Tool / Technology | Purpose | Rationale |
| --- | --- | --- |
| {tool} | {purpose} | {rationale} |

### Key Architectural Decisions
{Prose on major design choices, trade-offs made, and alternatives rejected}

---

## API / Interface Mapping

### {Section name — e.g. REST Endpoints, Component Breakdown}

| {Col 1} | {Col 2} | {Col 3} | {Col 4} |
| --- | --- | --- | --- |
| {value} | {value} | {value} | {value} |

---

## Observability

**Tooling:** {e.g. Datadog APM, CloudWatch, Grafana + Prometheus}

**Tracing & Logging Strategy:**
{How requests are traced across the system. What correlation ID is used. What structured log fields are emitted on every event.}

**Key Signals:**

| Domain / Component | Signal | Threshold | Alert? | Maps to PRD Metric |
| --- | --- | --- | --- | --- |
| {domain} | {metric name} | {threshold} | {Yes/No} | {PRD success metric or —} |

**Alerting Rules:**
- {Alert name} — fires when {condition}. Notifies {who/channel}.

**Analytics / Audit Trail:**
{How raw event data is stored for historical analysis, compliance, or debugging.}

---

## Technical Milestones

### M1: {Name}
**Scope:** {what's included}

**Stories:**
- **S1: {Title}** — {Description}. Depends on: none.
- **S2: {Title}** — {Description}. Depends on: S1.

**Acceptance Criteria:** {How you know M1 is done}

### M2: {Name}
**Scope:** {what's included}

**Stories:**
- **S3: {Title}** — {Description}. Depends on: S1.

**Acceptance Criteria:** {How you know M2 is done}

---

## Dependency Map

### Phase 1 (No dependencies)
- S1: {Title}

### Phase 2 (Requires Phase 1)
- S2: {Title} (depends: S1)
- S3: {Title} (depends: S1)

### Phase 3 (Requires Phase 2)
- S4: {Title} (depends: S2, S3)

---

## Technical Risks & Constraints

| Risk | Severity | Mitigation |
| --- | --- | --- |
| {risk} | {P0/High/Medium/Low} | {mitigation} |

---

## Open Technical Questions
- **{Question label}:** {Question body}
```

**After saving**, respond with:
> "**TRD: [Feature Name]** has been saved as a child page of **[PRD Title]** in Notion. [link]
>
> Next steps:
> - Review the TRD in Notion alongside the PRD.
> - When both are solid, run **/pm-prd-ready** to mark the PRD as GitHub Ready.
> - Then run **/pm-bootstrap** to generate GitHub milestones and issues with the dependency map wired up."

---

## Error Handling

- If the PRD can't be found in Notion: "I couldn't find that PRD. Can you double-check the name or number?"
- If the user bails mid-interview: "No problem — want me to save what we have so you can finish it later?"
- If Notion save fails: Show the full TRD content as Markdown so nothing is lost.
- If the user hasn't created a PRD yet: "Looks like we need a PRD first — want to run **/pm-create-prd** to set that up?"
