# VBI Workflow Demo

An interactive demo of the Viewbridge AI development workflow — from PRD to structured, trackable project execution using Claude Code custom commands.

## What This Demonstrates

A complete software development lifecycle powered by Claude Code slash commands and Notion:

```
 PLANNING                          BOOTSTRAP                         DAILY DEV
┌──────────────────┐    ┌─────────────────────────────┐    ┌──────────────────────┐
│ Claude AI/Desktop│    │ /vbi-prd-ready              │    │ /vbi-next            │
│ + Notion         │───▶│ /vbi-bootstrap              │───▶│ /vbi-bug             │
│ = Approved PRD   │    │ PRD → Milestones → Issues   │    │ /vbi-enhancement     │
│                  │    │    → Dep Map → CLAUDE.md     │    │ /vbi-status          │
└──────────────────┘    └─────────────────────────────┘    └──────────────────────┘
```

**One command** reads an approved PRD from Notion and creates:
- GitHub Milestones matching PRD phases
- Decomposed, testable issues with TDD pairing (test before build)
- A dependency map showing work phases and parallelization
- A CLAUDE.md giving Claude Code project-specific context

## Prerequisites

Before running the demo, ensure you have:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and working
- [GitHub CLI](https://cli.github.com/) authenticated (`gh auth status`)
- [Notion MCP](https://github.com/makenotion/notion-mcp-server) connected to Claude Code
- VBI commands installed — see [paulmona/claude](https://github.com/paulmona/claude) for installation
- A Notion workspace with a PRDs database

## Quick Start

### 1. Create the demo target repo

The bootstrap command needs an empty GitHub repo to populate with milestones and issues:

```bash
./demo/setup-demo-repo.sh
```

This creates `mcp-api-wrapper-demo` (or pass a custom name: `./demo/setup-demo-repo.sh my-demo-project`).

### 2. Load the sample PRD into Notion

1. Open [demo/sample-prd.md](demo/sample-prd.md)
2. Create a new page in your Notion PRDs database
3. Paste the PRD content
4. Set **Status** = `Approved`, **GitHub Ready** = `false`
5. Note the PRD ID that Notion assigns

### 3. Run the demo

Open Claude Code and run these commands in sequence:

```
/vbi-prd-ready PRD-DEMO-001
```
Marks the PRD as GitHub Ready — this is the gate before bootstrap.

```
/vbi-bootstrap PRD-DEMO-001 yourorg/mcp-api-wrapper-demo
```
Reads the PRD from Notion, creates milestones, issues, dependency map, and CLAUDE.md.

```
/vbi-next yourorg/mcp-api-wrapper-demo
```
Analyzes project state and recommends the highest-priority unblocked work.

```
/vbi-status yourorg/mcp-api-wrapper-demo
```
Shows milestone progress, open bugs, blocked issues, and health flags.

### 4. Reset for another run

```bash
./demo/reset-demo.sh yourorg/mcp-api-wrapper-demo
```

Then set **GitHub Ready** back to `false` on the Notion PRD.

## Demo Runbook

For a guided walkthrough with talking points, timing, Q&A prep, and backup plans, see [demo/runbook.md](demo/runbook.md).

## Commands Reference

These commands are maintained in [paulmona/claude](https://github.com/paulmona/claude):

| Command | What It Does |
|---------|-------------|
| `/vbi-prd-ready` | Marks a Notion PRD as GitHub Ready (gate before bootstrap) |
| `/vbi-bootstrap` | Full project bootstrap: PRD → Milestones → Issues → Dep Map → CLAUDE.md |
| `/vbi-next` | Reads GitHub state, recommends highest-priority unblocked work |
| `/vbi-status` | Milestone progress, open bugs, blocked issues, health summary |
| `/vbi-bug` | Creates a labeled bug issue with DoD checklist |
| `/vbi-enhancement` | Creates a labeled enhancement issue with DoD checklist |

## Repo Structure

```
workflow-demo/
├── README.md               ← You are here
└── demo/
    ├── runbook.md           ← Step-by-step demo guide with talking points
    ├── sample-prd.md        ← Sample PRD for the MCP API wrapper project
    ├── setup-demo-repo.sh   ← Creates the target GitHub repo for bootstrap
    └── reset-demo.sh        ← Cleans up milestones/issues for re-running
```

## The Sample Project

The included sample PRD describes an **Internal API MCP Server** — a Model Context Protocol server that wraps internal REST APIs. It has:

- **3 milestones**: Foundation, Core API Tools, Integration & Polish
- **11 features**: From project scaffolding to end-to-end integration tests
- A realistic tech stack: Node.js, TypeScript, Vitest, MCP SDK

This is a realistic project that showcases all aspects of the bootstrap workflow without being too large to demonstrate in 30-45 minutes.
