# pm-create-prd

Create a new PRD through a guided conversational interview and save it to Notion in the PRDs database. This is the product-focused PRD skill; it intentionally excludes technical implementation details (tools, architecture, milestones) which belong in a TRD created via the pm-create-trd skill.

## Usage
/pm-create-prd $ARGUMENTS

Arguments: Optional — a brief description of the feature or product (e.g. "Operational Assessment Tool")
If no argument provided, the interview will start from scratch.

---

## Notion Target

- **PRDs database ID**: Read from the project's `CLAUDE.md` under the `## Notion` section (key: `PRD Database ID`). If not found, ask the user for it.
- **PRD page title format**: `PRD-{NNN}: {Feature Name}`
- **PRD numbering**: Determined by querying existing pages in the database; increment the highest found number by 1.

## PRD Structure

Every PRD must contain these sections in order:

1. **Metadata** — Status, Priority, Category, Owner (set as Notion page properties)
2. **Overview** — What is this? One paragraph elevator pitch.
3. **Problem Statement** — What problem does this solve, and for whom?
4. **Goals** — Bulleted list of what success looks like.
5. **Non-Goals** — Explicit scope exclusions to prevent scope creep.
6. **User Stories** — As a [role], I want [action] so that [outcome]. These are product-level stories that map to epics in the downstream engineering workflow.
7. **Success Metrics** — Quantifiable outcomes that define done, rendered as a table.
8. **Stakeholders & Ownership** — Who owns this? Who are the key stakeholders? Rendered as a table.
9. **Open Questions** — Unresolved decisions that need answers before or during implementation.

### What does NOT belong in the PRD

The following sections belong in the **TRD** (Technical Requirements Document), created via the `pm-create-trd` skill after the PRD is finalized:

- Tool/technology decisions and rationale
- Architecture and design choices
- Technical milestones and implementation phases
- Technical acceptance criteria
- Dependency maps between implementation tasks
- API/endpoint mappings
- Observability tooling, instrumentation strategy, and alerting thresholds

**On observability:** The PRD defines *what* must be measurable (e.g. "p95 latency < 500ms", "zero duplicate deliveries"). The TRD defines *how* those signals will be captured, what tool will be used, and what alerts will fire. If a success metric can only be verified in production, flag it with "*(requires instrumentation)*" so the TRD author knows to define the measurement strategy.

If the user starts providing technical details during the interview, acknowledge them and note that they'll be captured in the TRD phase. Don't ignore the information — just don't put it in the PRD.

---

## Workflow

### Phase 1: Interview

Start with a warm intro, then ask for information **one topic at a time** (not a giant wall of questions). Wait for answers before moving on. Use follow-up questions to get depth.

**Opening message:**

> "Let's build your PRD. I'll walk you through the product requirements — what we're building and why. Technical details like architecture and tooling will go into a TRD afterward. First: **what's the one-line pitch for this product or feature?**"

**Interview sequence** (one at a time, adapt based on answers):

1. **Name & Pitch** — What are we calling this? What's the elevator pitch?
2. **Problem** — What problem does this solve? Who experiences it? How painful is it today?
3. **Goals** — If this ships perfectly, what's true? (Push for 3–6 specific goals)
4. **Non-Goals** — What are you explicitly NOT doing? (Help them think: what might people assume is in scope?)
5. **Users & Stories** — Who uses this? Walk through 2–5 user stories. These should be product-level — they'll become epics in GitHub.
6. **Success Metrics** — How will you know this worked? Push for quantifiable outcomes. For any metric that can only be verified in production (latency, error rates, throughput, queue depth), note that it requires instrumentation — the TRD will define how it's measured.
7. **Stakeholders** — Who owns this? Who needs to be consulted or informed?
8. **Open Questions** — Anything unresolved? Decisions that need to be made?
9. **Category & Priority** — Is this Internal Ops, Client Demo, or GTM? P0/P1/P2?

**Tips for the interview:**
- Be conversational, not form-like.
- If the user gives a thin answer, probe: "Can you say more about that?" or "What does that look like in practice?"
- Infer the PRD number by querying the Notion database using notion-search and finding the highest PRD-NNN title.

**Coaching: Keep the PRD sounding like a PRD.**
This is critical. Users — especially technical users — will naturally drift into implementation details. Your job is to gently redirect them. The PRD captures **what** and **why**. The TRD captures **how**.

When the user provides something that sounds technical, reframe it as a product requirement or redirect it:

| User says... | Coach them to... |
|---|---|
| "We'll use TypeScript and the MCP SDK" | "Good — that's a tool decision for the TRD. For the PRD, what matters is the product goal: customers can use the API from AI coding tools." |
| "It needs to support npm install" | "That's a packaging detail for the TRD. For the PRD: the product must install seamlessly into the customer's development environment." |
| "The API has 12 endpoints across 4 groups" | "Great context for the TRD. For the PRD, we'd say: full coverage of the non-deprecated API surface." |
| "We need OAuth 2.1 with PKCE" | "OAuth is a great long-term goal — for the PRD, let's frame it as: enabling public self-serve access without local setup." |
| "M1 is scaffolding, M2 is messaging endpoints" | "Implementation milestones belong in the TRD. For the PRD, let's define success metrics and user outcomes instead." |

**The general rule:** If a statement describes a specific technology, architecture, implementation phase, packaging format, or endpoint mapping, it belongs in the TRD. If it describes a user need, a business outcome, a product constraint, or a success measure, it belongs in the PRD.

When redirecting, always acknowledge the input positively — "That's great context, the TRD will capture that" — so the user doesn't feel shut down.

**Coaching: Drawing out detail from thin answers.**

Techniques for getting depth:
- **The "what does that look like" probe:** When someone says "we need better integration," ask "What does that look like in practice?"
- **The "who specifically" probe:** When someone says "our customers need this," ask "Which customers?"
- **The "how bad is it" probe:** "How painful is this today? Are we losing customers over it?"
- **The "say more" nudge:** Simply "Can you say more about that?" works surprisingly well.
- **The "give me an example" probe:** Forces specificity.
- **The "what if we don't" probe:** Reveals priority and urgency.
- **The "how will you know" probe:** For vague success metrics, push for a specific number.
- **The "what might people assume" probe:** For non-goals, catches scope creep early.

**Flag production-only metrics for instrumentation.** When a success metric can only be verified by watching live production behaviour — latency percentiles, error rates, message delivery guarantees, queue depths — add "*(requires instrumentation)*" next to it. Example: "p95 response latency < 5s *(requires instrumentation)*".

---

### Phase 2: Draft & Confirm

Once you have enough information, draft the full PRD content in Markdown. Show it to the user with:

> "Here's your draft PRD. Take a look — any sections you want to adjust before I save it to Notion?"

Present the draft clearly. Wait for approval or edits. Apply any requested changes.

---

### Phase 3: Save to Notion

After the user confirms:

**Step 1 — Determine the next PRD number.**
Use notion-search to query the PRDs database (ID from CLAUDE.md). Parse all page titles for the pattern `PRD-NNN`. Find the highest number and increment by 1. If no PRDs exist yet, start at `PRD-001`.

**Step 2 — Create the PRD page** using notion-create-pages:
- **Parent database ID**: (from CLAUDE.md)
- **Title**: `PRD-{NNN}: {Feature Name}`
- **Properties** (set as Notion page properties where supported):
  - Status: Draft
  - Priority: {P0 - Now / P1 - Next / P2 - Later}
  - Category: {Internal Ops / Client Demo / GTM}
  - Owner: {Owner name}
  - GitHub Ready: false

**Page body content (Markdown):**
```markdown
## Overview
{paragraph}

## Problem Statement
{paragraph}

## Goals
- {goal 1}
- {goal 2}

## Non-Goals
- {non-goal 1}

---

## User Stories
- As a **{role}**, I want {action} so that {outcome}.

---

## Success Metrics

| Metric | Target |
| --- | --- |
| {metric name} | {target value} |

## Stakeholders & Ownership

| Role | Person |
| --- | --- |
| {role} | {name} |

## Open Questions
- **{Question label}:** {Question body}
```

**After saving**, respond with:
> "**[PRD Title]** has been saved to Notion. [link]
>
> Next steps:
> - Review it in Notion and update Status to 'In Review' when ready.
> - When the product requirements are solid, run **/pm-create-trd** to generate the Technical Requirements Document. The TRD will be saved as a sub-page of this PRD in Notion.
> - After the TRD is complete, run **/pm-prd-ready** to mark it as GitHub Ready, then **/pm-bootstrap** to generate GitHub milestones and issues."

---

## Error Handling

- If the user bails mid-interview: "No problem — want me to save what we have as a Draft so you can finish it later?"
- If Notion save fails: Show the full PRD content as Markdown so nothing is lost, and suggest copy-pasting manually.
- If unsure which Category/Priority: default to `Internal Ops` / `P1 - Next` and mention what was assumed.
- If no existing PRDs found in the database: start PRD numbering at `PRD-001`.
