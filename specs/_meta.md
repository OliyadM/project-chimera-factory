# Project Chimera – Meta Specification
**High-level vision, goals, constraints and non-functional requirements**

## 1. Project Vision & Strategic Objective

Project Chimera is building the infrastructure for **Autonomous AI Influencers** — persistent, goal-directed digital entities that independently:

- research social media trends
- generate platform-native content (text, images, short-form video)
- manage audience engagement
- perform economic actions (via Agentic Commerce)

The agents must operate with **high autonomy** while remaining **safe, traceable, brand-aligned** and compliant with regulations (EU AI Act, platform rules).

Long-term vision: a **scalable fleet** of thousands of agents managed via **fractal orchestration** (human Super-Orchestrator → AI Managers → Worker Swarms).

Core principle: move away from fragile prompt chains toward **robust, spec-driven engineering**.

## 2. Core Engineering Principles

| Principle                        | Description                                                                                   | Purpose for Chimera                                                            |
|----------------------------------|-----------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| Spec-Driven Development (SDD)    | No implementation until specification is ratified. Specs = source of truth                   | Prevents hallucination when agents later extend the system                     |
| Traceability (MCP Sense)         | IDE always connected to Tenx MCP Sense (black-box recorder)                                   | Enables auditing, debugging, proof of rigorous development                     |
| Skills vs. Tools separation      | Skills = agent runtime functions<br>MCP Servers = external bridges                            | Clean, replaceable, extensible agent capabilities                               |
| Git Hygiene                      | Commit frequently (≥2×/day), history shows evolving complexity                               | Supports auditability and parallel agent-based development                     |
| Test-Driven Definition           | Write failing tests first — they define correct behavior                                      | Creates clear targets for agent implementation                                 |

## 3. Key Constraints & Non-Functional Requirements

| Category                | Requirement                                                                                          | Rationale / Source                          |
|-------------------------|------------------------------------------------------------------------------------------------------|---------------------------------------------|
| Safety vs Autonomy      | Human review **only** at Judge layer (low confidence / high risk / policy violation)                 | Management by Exception, EU AI Act          |
| Scalability             | Design supports 1 → thousands of agents without linear human effort increase                         | Fractal orchestration (SRS)                 |
| Reliability             | Self-healing for common failures (timeouts, generation errors, rate limits)                         | SRS automated triage                        |
| Traceability            | All major decisions / generations logged via MCP                                                     | Challenge requirement + audit               |
| Economic Agency         | Agents receive non-custodial crypto wallets (Coinbase AgentKit)                                      | SRS Agentic Commerce                        |
| Ecosystem Integration   | Publish availability, niche, language, profile to OpenClaw network                                   | Challenge + OpenClaw vision                 |
| Development Discipline  | Repository enables AI swarm to implement remaining features with minimal human intervention         | Core challenge objective                    |

## 4. Selected Architectural Foundation

- **Orchestration**: Hierarchical Swarm (Planner → Worker Swarm → Judge)
- **Human-in-the-Loop**: Judge layer (escalation only)
- **Metadata Storage**: NoSQL (high-velocity video metadata) + Weaviate (vectors) + Redis (cache) + PostgreSQL (config)
- **External Bridge**: MCP (universal)
- **Future**: OpenClaw status publishing + Agentic Commerce

## 5. Document Status

**Last updated:** February 2025 (Day 2 kickoff)  
**Status:** Ratified foundation for all downstream specifications, skills definitions, tests and rules.

All other spec documents, skill contracts and tests **must** remain consistent with this meta specification.