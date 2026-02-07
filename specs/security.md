# Project Chimera – Security Specification

This document defines the **complete security intent** for the Chimera system.  
It is traceable to `_meta.md` (constraints) and SRS (self-healing, governance, containment).  
All generated code and agents **must** implement these patterns or fail tests.

## 1. Authentication & Authorization (AuthN / AuthZ)

- **Orchestrator Dashboard**: OAuth2 + JWT tokens (via GitHub/Google login)
- **MCP Servers**: API key + HMAC signature per request
  - Keys rotated every 90 days
  - Scope-based: read-only for trend fetch, write for publish
- **Agent-to-Agent**: On-chain reputation + signed messages (via Coinbase AgentKit)
- **Internal Services**: JWT bearer tokens with short expiry (15 min)
- **Forbidden**: No anonymous access; all endpoints require auth except health-check

## 2. Secrets & Configuration Management

- **Storage**: Docker secrets or environment variables (never in code or git)
- **Loading**: Use MCP config or Vault-like secret manager
- **Rotation**: Automated via CI/CD (every 90 days or on breach)
- **No hard-coded keys**: Enforced via CI security scan

## 3. Rate Limiting & Quota Enforcement

- **Per Agent**: 100 API calls/hour (trend fetch + publish combined)
- **Per MCP Server**: Enforced at bridge level (e.g., 500 requests/hour global)
- **Implementation**: Redis-based sliding window (via MCP)
- **Response**: 429 Too Many Requests + retry-after header

## 4. Content Moderation & Safety Guardrails

- **Pipeline**:
  1. Generation: Content scored for toxicity/hate via MCP-moderation tool
  2. Judge Layer: Auto-approve if score < 0.2
  3. Escalation thresholds:
     - 0.2 – 0.5 → Judge review (AI re-evaluate)
     - 0.5 – 0.8 → Human review required
     - >0.8 → Block & log incident
  4. PII detection: Scan for names/emails; anonymize or escalate
- **Logging**: All moderation decisions logged to MCP Sense (black-box) with:
  - content_id
  - toxicity_score
  - decision (approve/reject/escalate)
  - reason
- **Forbidden**: No publishing without moderation pass

## 5. Agent Containment & Resource Limits

- **Execution**: Agents run in isolated Docker containers
  - CPU: 1 core
  - Memory: 512MB
  - Network: Egress only via MCP (no direct internet)
- **Forbidden Actions**:
  - Direct wallet signing without Judge approval
  - External API calls not via MCP
  - File system writes outside /tmp
- **Escalation Triggers**:
  - Confidence < 0.7
  - Policy violation detected
  - Resource overuse attempt

## 6. Logging & Auditability

- All major actions (skill calls, decisions, escalations) logged via MCP Sense
- Logs include: timestamp, agent_id, action, input/output hashes, confidence
- Retention: 90 days minimum; encrypted at rest

**Status**: Ratified. All implementations **must** adhere to these patterns or fail CI/security tests.