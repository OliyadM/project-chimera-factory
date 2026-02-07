# Project Chimera Factory

**Infrastructure for Autonomous AI Influencers**  
Spec-Driven Development • MCP-connected agents • Hierarchical Swarm orchestration • Agentic Commerce readiness  

This repository is the engineered "factory" for building reliable, scalable Autonomous Influencers — persistent digital entities that research trends, generate content, manage engagement, and participate economically with minimal human intervention.

**Core Principles**
- **Spec-Driven Development (SDD)** — Specs are the single source of truth. No implementation code until ratified.
- **Traceability** — Tenx MCP Sense always connected (black-box flight recorder)
- **TDD First** — Failing tests define agent goals (empty slots)
- **Git Hygiene** — Commit early/often (min 2×/day), history tells evolving complexity
- **Agent-Ready** — Repository designed so AI swarms can build features with minimal human conflict

## Repository Structure
project-chimera-factory/
├── .cursor/
│   └── rules.md                          # IDE agent rules (spec-first, traceability, safety)
├── .github/
│   └── workflows/
│       └── main.yml                      # CI/CD pipeline (tests, spec-check, governance)
├── research/
│   ├── notes.md                          # Insights from a16z, OpenClaw, MoltBook, SRS
│   ├── architecture_strategy.md          # Hierarchical Swarm, NoSQL, HITL placement
│   └── tooling_strategy.md               # Developer MCP servers vs runtime skills
├── specs/                                # Executable specifications – source of truth
│   ├── _meta.md                          # Vision, constraints, non-functional
│   ├── functional.md                     # Agent user stories
│   ├── technical.md                      # API contracts, schemas, ERD, lifecycle
│   ├── backend.md                        # Backend services & workflows
│   ├── security.md                       # Auth, rate limits, moderation pipeline
│   └── acceptance_criteria.md            # Gherkin scenarios (happy path, edge, failure)
├── skills/                               # Runtime skills the agent invokes
│   └── README.md                         # 5 skills with detailed I/O JSON contracts
├── tests/                                # Failing TDD tests defining goals
│   ├── test_trend_fetcher.py             # Validates trend schema
│   └── test_skills_interface.py          # Validates skill contracts
├── Dockerfile                            # Environment encapsulation
├── Makefile                              # Standardized commands (setup, test, docker-test)
├── mcp.json                              # MCP server configs (developer + runtime tools)
├── pyproject.toml                        # Dependencies (uv)
├── .gitignore
└── README.md

## Quick Setup & Commands

```bash
make setup          # Install dependencies (uv sync)
make test           # Run failing TDD tests (expected to fail)
make docker-test    # Build & run tests in Docker
make spec-check     # Check for spec references

Key Highlights

Specs/: Full blueprint (vision → stories → contracts → security → acceptance)
Skills/: 5 runtime capabilities (fetch trends, generate brief, produce video, publish & monitor, economic transactions)
Tests/: True TDD – intentionally failing tests validating specs & skills
.cursor/rules.md: Enforces spec-first behavior in IDE agent
Makefile + Dockerfile: Professional, reproducible environment
CI Pipeline: GitHub Actions runs tests + spec-check on every push
MCP: Configured for developer tools and runtime bridges (trend, publish, wallet, moderation)

Architectural Decisions (ADRs)

NoSQL for metadata — Chosen for high-velocity writes, semi-structured data (SRS, architecture_strategy.md)
Hierarchical Swarm — For parallelism, self-healing, embedded governance (SRS 1.2, Day 1 decision)
MCP as universal bridge — Decouples agents from changing APIs (SRS breakthrough pattern)
Failing TDD first — Defines empty slots for AI agents (challenge requirement)

Contributing

Always reference specs/ first — follow .cursor/rules.md
Commit often with descriptive messages
Run make test before push (TDD must fail until implemented)
PRs must pass CI (tests + spec-check)
New features start with updated specs/ and acceptance criteria