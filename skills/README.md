# Project Chimera – Agent Skills: Runtime Capabilities

This document defines the reusable runtime skills (functions/scripts) that the Chimera Autonomous Influencer Agent can call. Skills are distinct from MCP Servers (external bridges like database connectors) – they are internal, self-contained capabilities that the agent invokes for specific tasks.

Skills must adhere to Spec-Driven Development: all I/O contracts are traceable to specs/technical.md API schemas and specs/functional.md user stories. Implementation logic is NOT included here – this is the interface blueprint for AI agents to fill in later. At least 5 critical skills are defined to cover the core workflow (trend discovery, content generation, engagement, economic agency, collaboration).

## Skill Design Principles
- **Input/Output**: Strict JSON schemas for predictability and testability.
- **Traceability**: Each skill logs invocation via MCP Sense.
- **Error Handling**: All skills return "confidence" score and "error" field if failed.
- **Swarm Integration**: Skills are callable by Worker Swarm in parallel.
- **Dependencies**: Use MCP for external calls (e.g., API fetches).
- **Security**: No direct access to wallets or publishing – escalate to Judge layer.

## 1. skill_fetch_current_trends
**Purpose**: Implements "Perception & Trend Discovery" user stories (specs/functional.md). Fetches real-time trends from social platforms to inform content planning.

**Input** (JSON schema, linked to specs/technical.md TrendDiscoveryResult):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["niche", "platforms"],
  "properties": {
    "niche": { "type": "string", "minLength": 1, "description": "Agent's niche (e.g., 'fitness motivation')" },
    "platforms": { "type": "array", "items": { "enum": ["tiktok", "youtube_shorts", "instagram_reels", "x", "moltbook"] }, "minItems": 1 },
    "limit": { "type": "integer", "minimum": 1, "maximum": 20, "default": 10 },
    "since_time": { "type": "string", "format": "date-time", "description": "Optional start time for trends" }
  }
}
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["trends", "timestamp", "confidence"],
  "properties": {
    "trends": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["topic", "hashtag", "velocity_score"],
        "properties": {
          "topic": { "type": "string" },
          "hashtag": { "type": "string" },
          "velocity_score": { "type": "number", "minimum": 0 },
          "category": { "enum": ["viral", "emerging", "niche"] },
          "related_keywords": { "type": "array", "items": { "type": "string" } },
          "volume_24h": { "type": "integer" }
        }
      }
    },
    "timestamp": { "type": "string", "format": "date-time" },
    "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
    "error": { "type": "string", "description": "Optional error message" }
  }
}
# Project Chimera – Agent Skills  
Runtime Capabilities for the Autonomous Influencer Agent

This document defines the reusable runtime **skills** that the Chimera Agent can call during execution.  
Skills are distinct from MCP Servers (external bridges like database or API connectors).  
They are self-contained, reusable function interfaces that the agent invokes for specific capabilities.

## Design Principles
- All skills **must** follow the JSON schemas defined in `specs/technical.md`.
- Every skill returns a `confidence` score (0.0–1.0) and an optional `error` field.
- Invocation is logged via MCP Sense for traceability.
- Skills are designed to be called by Worker Swarms in parallel.
- No direct publishing or wallet actions — must go through Judge layer approval.
- At least 5 critical skills are defined to cover the full influencer lifecycle.

## 1. skill_fetch_current_trends
**Purpose**  
Implements trend discovery from functional stories. Fetches real-time trending topics/hashtags relevant to the agent's niche.

**Input** (JSON)
```json
{
  "niche": "fitness motivation",
  "platforms": ["tiktok", "youtube_shorts", "instagram_reels"],
  "limit": 10,
  "since_time": "2026-02-01T00:00:00Z"   
}