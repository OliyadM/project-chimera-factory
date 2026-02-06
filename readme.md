# Project Chimera Factory

**Infrastructure for Autonomous AI Influencers**  
Spec-Driven Development • MCP-connected agents • Hierarchical Swarm orchestration • Agentic Commerce readiness  

This repository is the engineered "factory" for building reliable, scalable Autonomous Influencers — digital entities that research trends, generate content, manage engagement, and participate economically with minimal human intervention.

**Core Philosophy**  
- Specs are the single source of truth (Spec-Driven Development)  
- No implementation until specifications are ratified  
- Failing TDD tests define agent goals  
- Traceability via Tenx MCP Sense (always connected)  
- Git hygiene: commit early & often (min 2×/day), history shows evolving complexity  

## Repository Structure
project-chimera-factory/
├── .cursor/
│   └── rules.md                         # IDE agent rules: spec-first, traceability, safety & governance
├── .github/
│   └── workflows/
│       └── main.yml                     # CI/CD pipeline: runs tests, spec-check, governance on push/PR
├── research/
│   ├── notes.md                         # Insights from a16z, OpenClaw, MoltBook, SRS
│   ├── architecture_strategy.md         # Hierarchical Swarm, NoSQL DB, HITL at Judge layer
│   └── tooling_strategy.md              # Developer MCP servers vs runtime skills separation
├── specs/                               # Executable specifications – source of truth
│   ├── _meta.md                         # Vision, constraints, non-functional requirements
│   ├── functional.md                    # Agent user stories ("As an Agent, I need to...")
│   ├── technical.md                     # API contracts, JSON schemas, Mermaid ERD
│   ├── backend.md                       # Backend services, workflows, orchestration
│   ├── security.md                      # Auth, containment, guardrails, escalation
│   ├── acceptance_criteria.md           # Gherkin-style testable conditions
│   └── rule_creation.md                 # Blueprint for generating agent rules file
├── skills/                              # Runtime skills the agent invokes
│   └── README.md                        # 5 critical skills with detailed I/O JSON contracts
├── tests/                               # Failing TDD tests defining agent goals
│   ├── test_trend_fetcher.py            # Validates trend data structure vs spec
│   └── test_skills_interface.py         # Validates skill parameter contracts
├── Dockerfile                           # Full environment encapsulation
├── Makefile                             # Standardized commands: setup, test, docker-test, spec-check
├── mcp.json                             # MCP server configurations (developer & runtime)
├── pyproject.toml                       # Dependencies managed with uv
├── .gitignore
└── README.md


## Key Highlights

- **Specs/**: Full blueprint (vision → user stories → technical contracts → security → acceptance criteria)
- **Skills/**: 5 runtime capabilities with precise JSON I/O (fetch trends, generate brief, produce video, publish & monitor, economic transactions)
- **Tests/**: True TDD – intentionally failing tests that validate specs & skill interfaces
- **.cursor/rules.md**: Enforces spec-first behavior in IDE agent (Prime Directive, traceability, safety)
- **Makefile + Dockerfile**: Professional, reproducible environment (no "works on my machine")
- **CI Pipeline**: GitHub Actions runs tests + basic spec alignment check on every push
- **MCP**: Connected throughout for traceability (black-box flight recorder)

## Quick Setup & Commands

```bash
make setup        # Install dependencies (uv sync)
make test         # Run failing TDD tests (expected to fail)
make docker-test  # Build & run tests in Docker
make spec-check   # Basic check for spec references