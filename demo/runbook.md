# Demo Runbook: VBI Development Workflow

**Estimated Duration:** 30-45 minutes
**Audience:** Engineering colleagues
**Goal:** Show the end-to-end workflow from PRD to structured, trackable project execution

---

## Pre-Demo Setup (Do This Before the Demo)

### 1. Create the Demo Repo

```bash
cd /path/to/claude/demo
./setup-demo-repo.sh
```

This creates an empty GitHub repo for the bootstrap to populate.

### 2. Copy the PRD into Notion

- Open `sample-prd.md` from this directory
- Create a new page in your Viewbridge PRDs database in Notion
- Copy the PRD content into the Notion page
- Set **Status** = `Approved`
- Set **GitHub Ready** = `false` (the demo will flip this)
- Note the PRD ID that Notion assigns

### 3. Verify Prerequisites

- [ ] Claude Code is open and working
- [ ] VBI commands are installed (`/vbi-` should autocomplete)
- [ ] Notion MCP is connected (test with a quick notion-search)
- [ ] GitHub CLI is authenticated (`gh auth status`)
- [ ] Demo repo exists and is empty
- [ ] Screen is shared / projected

### 4. Backup Plan

If Notion or GitHub has issues during the live demo, screenshots of expected output
are described at each step below. You can narrate through them if needed.

---

## Demo Flow

### Part 1: The Problem (2-3 minutes)

**What to say:**

> "Today I want to show you how I've been structuring my development workflow.
> The problem we all face: you get a PRD or feature spec, and the gap between
> 'approved document' and 'actually writing code' is where projects go sideways.
> Scope creep, unclear priorities, no test strategy, forgotten edge cases.
>
> I built a set of Claude Code commands that bridge that gap automatically.
> Let me show you with a real example — we're going to bootstrap an MCP server
> project that wraps internal APIs."

**No tools to run.** This is pure setup/context.

---

### Part 2: PRD Ready (`/vbi-prd-ready`) (3-5 minutes)

**What to say:**

> "The workflow starts in Notion. I write my PRD there — milestones, features,
> tech stack, acceptance criteria. Once the PRD is approved by stakeholders,
> I run this first command to signal it's ready for engineering."

**Run:**

```
/vbi-prd-ready PRD-DEMO-001
```

**What happens:**
- Claude searches Notion for the PRD
- Shows the PRD details and asks for confirmation
- Marks `GitHub Ready = true`

**Talking points:**
- "This is a gate — nothing gets bootstrapped until the PRD is explicitly approved AND marked ready"
- "It prevents premature work on PRDs that are still being refined"
- "The PRD stays in Notion as the source of truth — we don't duplicate it"

---

### Part 3: Bootstrap (`/vbi-bootstrap`) — THE MAIN EVENT (10-15 minutes)

**What to say:**

> "Now the magic. This single command reads the PRD and creates the entire
> GitHub project structure — milestones, issues, dependency map, and a
> CLAUDE.md file. Watch what it generates."

**Run:**

```
/vbi-bootstrap PRD-DEMO-001 [your-org]/mcp-api-wrapper-demo
```

**What happens (narrate as it runs):**

1. **Pre-flight check** — "It first verifies the PRD is approved and GitHub Ready"

2. **Milestones created** — "Three milestones from the PRD: Foundation, Core API Tools, Integration & Polish. Each has scope and timeline from the PRD."

   *Open GitHub and show the milestones tab*

3. **Issues created** — "This is where it gets interesting. Each milestone is decomposed into discrete, testable issues — 1 to 4 hours of work each."

   **Key things to point out:**
   - "Notice every build issue has a paired TEST issue — test is written first. This enforces TDD at the project planning level, not just as a suggestion."
   - "Each issue has acceptance criteria, a Definition of Done checklist, and explicit dependency declarations."
   - "Two labels on every issue: the type (setup, build, test) and the feature group (F1, F2, F3)."

   *Open 2-3 issues to show the structure*

4. **Dependency Map** — "This pinned issue shows the work phases. Phase 1 has no dependencies, so everything there can be parallelized. Phase 2 depends on Phase 1, and so on."

   *Open the dependency map issue*

5. **CLAUDE.md** — "Finally, it generates a CLAUDE.md at the repo root. This gives Claude Code project-specific context — build commands, architecture, patterns, and the Definition of Done. Every future Claude session in this repo starts with this context."

**Talking points:**
- "One command, maybe 60 seconds, and you have a fully structured project"
- "Every issue is traceable back to the PRD"
- "The TDD pairing is built into the structure, not left to developer discipline"
- "The dependency map prevents people from working on blocked items"

---

### Part 4: Daily Workflow Commands (5-7 minutes)

**What to say:**

> "Once the project is bootstrapped, there are four commands I use day-to-day.
> Let me show you the two most important ones."

#### `/vbi-next` — What to Work on Next

**Run:**

```
/vbi-next [your-org]/mcp-api-wrapper-demo
```

**What happens:**
- Reads all milestones, issues, and the dependency map
- Identifies unblocked work in priority order
- Recommends the single highest-priority task

**Talking points:**
- "Test issues are prioritized before build issues — TDD is enforced in the workflow, not just the checklist"
- "Setup tasks come before build tasks"
- "It also shows what's parallelizable if you have multiple people"

#### `/vbi-status` — Project Health

**Run:**

```
/vbi-status [your-org]/mcp-api-wrapper-demo
```

**What happens:**
- Shows milestone progress percentages
- Lists open bugs and blocked issues
- Health flags (missing labels, unmilestoned issues, etc.)
- Velocity metrics

**Talking points:**
- "This is your standup in one command"
- "Health flags catch process drift — if someone creates an issue without a milestone or label, it gets flagged"
- "Velocity tracking helps with estimation over time"

#### Quick Mention: `/vbi-bug` and `/vbi-enhancement`

> "During development, if you find a bug or think of an enhancement, these
> commands create properly labeled, milestoned issues with the full DoD checklist.
> No more 'I'll file that later' — it takes 10 seconds."

---

### Part 5: The Full Picture (3-5 minutes)

**What to say:**

> "Let me zoom out. Here's what this gives you:"

Draw or show this flow:

```
┌─────────────────────────────────────────────────────┐
│                    PLANNING                          │
│  Claude Desktop/AI + Notion → Write & Approve PRD    │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                  BOOTSTRAP                           │
│  /vbi-prd-ready → /vbi-bootstrap                     │
│  PRD → Milestones → Issues → Deps → CLAUDE.md       │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│                DAILY DEVELOPMENT                     │
│  /vbi-next     → Pick highest-priority work          │
│  TDD cycle     → Red → Green → Refactor              │
│  /vbi-bug      → Log bugs as you find them           │
│  /vbi-enhance  → Log enhancements as you find them   │
│  /vbi-status   → Health check and velocity           │
└─────────────────────────────────────────────────────┘
```

**Talking points:**
- "PRD authoring happens with Claude AI — it's collaborative, iterative"
- "Bootstrap is atomic — one command, complete project structure"
- "Daily commands keep you on track without ceremony"
- "Everything is traceable: PRD → Milestone → Issue → Branch → PR → Merge"
- "The Definition of Done is embedded everywhere, not a wiki page nobody reads"

---

### Part 6: Q&A / Discussion (5-10 minutes)

**Common questions and answers:**

**Q: "What if the PRD changes after bootstrap?"**
> "Great question. You'd create new issues via /vbi-enhancement or manually,
> assign them to the right milestone, and the dependency map gets updated.
> The system doesn't fight change — it structures it."

**Q: "Does this only work with Notion?"**
> "The PRD-ready and bootstrap commands use Notion's MCP integration, but the
> daily commands (/vbi-next, /vbi-status, /vbi-bug) work purely with GitHub.
> You could adapt the bootstrap to read from any source."

**Q: "Isn't 100% error state coverage unrealistic?"**
> "It's aspirational as a default, but the DoD says 'document exceptions' for
> edge cases. The point is making coverage a conscious decision, not an
> afterthought. If you skip error handling, you write down why."

**Q: "How long does bootstrap actually take?"**
> "Typically under 2 minutes for a 3-milestone PRD. The time savings isn't
> just the issue creation — it's the consistency. Every project starts with
> the same structure, same standards, same traceability."

**Q: "Can I customize the commands?"**
> "Absolutely. They're markdown files in a commands directory. Change labels,
> modify the DoD, add new issue templates — they're fully editable."

---

## Post-Demo Cleanup

To reset the demo repo for next time:

```bash
cd /path/to/claude/demo
./reset-demo.sh [your-org]/mcp-api-wrapper-demo
```

Also reset the Notion PRD:
- Set **GitHub Ready** back to `false`

---

## Tips for a Smooth Demo

1. **Run it once yourself first** — Do the full flow end-to-end privately before demoing live
2. **Pre-expand the terminal** — Make sure font size is large enough for projection
3. **Have GitHub open in a browser** — Switch to the browser after each step to show the results visually
4. **Pause after bootstrap** — Let people absorb the generated issues before moving on. Open 2-3 issues to show the detail
5. **Keep the PRD simple** — The sample PRD has 3 milestones and 11 features. That's enough to show the pattern without overwhelming
6. **Have a backup** — If the live demo breaks, you can walk through pre-captured screenshots of each step
