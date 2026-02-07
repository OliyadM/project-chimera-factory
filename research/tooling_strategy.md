# Project Chimera – Tooling & Skills Strategy

This document defines the tooling strategy for both **development** (by the FDE Trainee) and **runtime** (by the Chimera Agent).  
It strictly separates **Developer Tools (MCP servers)** from **Runtime Skills** (agent capabilities), as required by Task 2.3.

## 1. Developer Tools (MCP Servers)  
These are MCP servers that assist **you** (the engineer) during development. They are configured in `mcp.json` and connected to the IDE at all times for traceability.

| MCP Server Name       | Type         | Endpoint / Config                     | Capabilities                              | Purpose / Usage in Development                          |
|-----------------------|--------------|---------------------------------------|-------------------------------------------|----------------------------------------------------------|
| git-mcp               | Developer    | git://local-repo                      | commit, push, branch, log                 | Git hygiene (2×/day commits), swarm-ready branching      |
| filesystem-mcp        | Developer    | local-fs                              | read, write, mkdir                        | File editing, spec creation, repo management             |
| ide-log-mcp           | Developer    | tenx-mcp-sense                        | log_thinking, query_history               | Black-box traceability (MCP Sense always connected)     |
| db-setup-mcp          | Developer    | mongo-local or postgres-local         | connect, schema_apply, migrate            | Local DB testing, migration prototyping                  |

**Configuration note**: All developer MCPs are defined in `mcp.json` with auth and limits.  
They are **not** used by the runtime agent — only for human engineering tasks.

## 2. Runtime Skills (Agent Capabilities)  
These are the reusable functions the Chimera Agent calls during execution (defined in `skills/README.md`).  
They are **not** MCP servers — they are internal capabilities that may use MCP for external calls.

| Skill Name                     | Purpose (from functional.md)              | Input/Output Contract Location                  | Dependencies / Notes                                      |
|--------------------------------|-------------------------------------------|-------------------------------------------------|------------------------------------------------------------|
| skill_fetch_current_trends     | Discover real-time trends                 | skills/README.md → Section 1                    | Uses trend-fetch-mcp for external API calls                |
| skill_generate_content_brief   | Create detailed content plans             | skills/README.md → Section 2                    | Uses trend data from skill_fetch_current_trends            |
| skill_produce_short_video      | Generate short-form video asset           | skills/README.md → Section 3                    | May use external generation APIs via MCP                   |
| skill_publish_and_monitor      | Publish content & monitor engagement      | skills/README.md → Section 4                    | Requires Judge approval; uses publish-mcp & engagement-poll-mcp |
| skill_handle_economic_transaction | Manage micro-transactions & collaborations | skills/README.md → Section 5                    | Uses wallet-mcp (Coinbase AgentKit integration)            |

**Runtime strategy**:
- Skills are discoverable via `skills/README.md`
- All external interactions go through MCP servers (no direct API calls)
- Skills return confidence scores and errors for Judge evaluation
- Tests in `tests/test_skills_interface.py` validate input/output contracts

## 3. Separation & Rationale
- **Developer MCPs** → Tools for the human engineer (you) to build and maintain the repo
- **Runtime Skills** → Capabilities the autonomous agent uses to perform its influencer tasks
- This separation prevents tool confusion, enables scalability, and aligns with SRS MCP usage (universal bridge for external world)

## 4. Validation & Future-Proofing
- All developer MCPs are configured in `mcp.json` and connected via IDE
- Runtime skills are interface-only (contracts defined, logic future work)
- CI pipeline (`.github/workflows/main.yml`) enforces spec alignment

**Status**: Ratified. All tooling decisions are traceable to this document.