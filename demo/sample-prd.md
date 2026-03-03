# PRD: Internal API MCP Server

**PRD ID:** PRD-DEMO-001
**Status:** Approved
**GitHub Ready:** false
**Author:** [Presenter Name]
**Date:** [Demo Date]

---

## Overview

Build a Model Context Protocol (MCP) server that wraps our internal REST APIs, enabling AI assistants (Claude Desktop, Claude Code, custom agents) to securely interact with company systems through natural language.

### Problem Statement

Engineers and PMs currently context-switch between multiple internal tools (ticketing, user management, analytics dashboards) to gather information during development and planning. There is no unified AI-accessible interface to query these systems.

### Solution

An MCP server that exposes internal APIs as MCP tools, allowing AI assistants to fetch data, run queries, and perform read operations against internal systems — with proper authentication and audit logging.

### Tech Stack

- **Runtime:** Node.js 20+ with TypeScript
- **MCP SDK:** @modelcontextprotocol/sdk
- **Transport:** stdio (local) and SSE (remote)
- **Auth:** Service account tokens with per-tool scoping
- **Testing:** Vitest
- **Linting:** ESLint + Prettier

---

## Milestone 1: Foundation and Core Infrastructure

**Scope:** Set up the MCP server skeleton, project scaffolding, authentication layer, and CI pipeline. By the end of this milestone, the server starts, authenticates, and responds to MCP handshake — with zero tools implemented.

### Features

- **F1: Project Scaffolding** — Initialize TypeScript project with MCP SDK, configure build pipeline, set up Vitest, ESLint, Prettier, and create initial directory structure (`src/`, `src/tools/`, `src/auth/`, `src/config/`).
- **F2: MCP Server Skeleton** — Implement base MCP server using `@modelcontextprotocol/sdk` with stdio transport. Server must start, respond to `initialize` and `tools/list` requests, and return an empty tool list.
- **F3: Authentication Layer** — Create an auth module that validates service account tokens from environment variables. Each tool registration must declare required scopes. Unauthorized calls return MCP error responses, never raw API errors.
- **F4: CI Pipeline** — GitHub Actions workflow: lint, type-check, test on every PR. Block merge if any step fails. Coverage reporting to PR comments.

---

## Milestone 2: Core API Tools

**Scope:** Implement MCP tools wrapping the three highest-value internal APIs. Each tool follows a consistent pattern: input validation, auth check, API call, response formatting. All tools are read-only in this milestone.

### Features

- **F5: User Lookup Tool** — `lookup_user` tool that queries the internal user/employee directory API. Accepts email, name, or employee ID. Returns structured user profile (name, team, role, manager, location). Handles not-found and ambiguous matches gracefully.
- **F6: Ticket Search Tool** — `search_tickets` tool that queries the internal ticketing system API. Accepts filters: assignee, status, priority, date range, keyword. Returns ticket list with ID, title, status, assignee, and priority. Supports pagination via cursor.
- **F7: Analytics Query Tool** — `query_metrics` tool that queries the internal analytics/metrics API. Accepts metric name, time range, and optional dimensions. Returns formatted data tables. Validates metric names against an allowed-list to prevent arbitrary queries.

---

## Milestone 3: Integration, Polish, and Documentation

**Scope:** Add SSE transport for remote usage, implement audit logging, write user-facing documentation, and perform end-to-end integration testing.

### Features

- **F8: SSE Transport** — Add Server-Sent Events transport alongside stdio. Configure via environment variable (`TRANSPORT=stdio|sse`). SSE mode binds to configurable port with health check endpoint.
- **F9: Audit Logging** — Log every tool invocation: timestamp, tool name, caller identity (from auth token), input parameters (redacted where sensitive), success/failure, response time. Structured JSON logs to stdout, compatible with log aggregation.
- **F10: Documentation and Setup Guide** — README with: installation, configuration (env vars), Claude Desktop integration steps (`claude_desktop_config.json`), available tools reference, troubleshooting. Include example prompts demonstrating each tool.
- **F11: End-to-End Integration Tests** — Integration test suite that spins up the MCP server, connects as a client, authenticates, and exercises each tool against mock API responses. Covers happy path, auth failures, API errors, and malformed input.

---

## Non-Functional Requirements

- **Security:** No raw API credentials in tool responses. All tokens from environment variables, never hardcoded. Audit log captures all access.
- **Performance:** Tool responses within 2 seconds for standard queries.
- **Error Handling:** Every tool returns structured MCP errors. No stack traces or internal details leak to the client.

---

## Success Criteria

1. Claude Desktop can connect to the MCP server and list all available tools
2. Each tool returns accurate, well-formatted results from internal APIs
3. Unauthorized tool calls are rejected with clear error messages
4. Full test suite passes with >90% coverage
5. A new engineer can set up and use the server within 15 minutes using the documentation
