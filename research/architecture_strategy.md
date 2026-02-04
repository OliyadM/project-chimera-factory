# Domain Architecture Strategy – Day 1

## Chosen Agent Pattern
Hierarchical Swarm (Planner → Worker Swarm → Judge)

Justification:
- Matches SRS FastRender / Swarm pattern
- High parallelism for influencer workflow (trend → script → video → publish → engage)
- Judge layer provides quality control and HITL escalation
- Better governance & traceability than Sequential Chain or flat swarm
- Supports self-healing and OCC

## Human-in-the-Loop Placement
Located in the Judge layer (safety layer).

Workflow:
- Judge evaluates confidence, brand alignment, risk
- High-confidence → auto-publish
- Low-confidence / sensitive / high-risk → escalate to human (Approve / Reject / Edit)

Reason: Management by Exception — maximizes autonomy while protecting brand and compliance.

## Database for high-velocity video metadata
NoSQL (MongoDB or equivalent document store)

Justification:
- Semi-structured, evolving data (timestamps, tags, captions, engagement metrics)
- High write velocity during generation & interaction
- Flexible schema + horizontal scaling
- Complements Weaviate (vectors), Redis (cache), PostgreSQL (transactional)

## Other Decisions
- MCP as universal external bridge
- Kubernetes for auto-scaling during viral events
- Tiered LLMs: frontier for planning/judging, fast for routine
- Future-proof OpenClaw integration (publish status/availability)