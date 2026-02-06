# Project Chimera – Technical Specification
**API Contracts, Database Schema, Data Models, and Key Interfaces**

## 1. Purpose of this Document

This document defines the **technical contracts** that all downstream implementations (skills, agents, orchestrator, tests) must respect.

It includes:

- JSON schemas for major inputs/outputs (API-like contracts)
- Database schema with ER diagram (Mermaid)
- Data models for core entities
- Integration points with MCP and external systems

All contracts must remain consistent with `functional.md` user stories and `_meta.md` constraints.

## 2. API Contracts (JSON Schemas)

### 2.1 Trend Discovery Response (from trend fetching skill / external source via MCP)

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "TrendDiscoveryResult",
  "type": "object",
  "required": ["trends", "timestamp", "source_platform"],
  "properties": {
    "trends": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["topic", "hashtag", "velocity_score", "category"],
        "properties": {
          "topic": { "type": "string", "minLength": 1 },
          "hashtag": { "type": "string", "pattern": "^#[A-Za-z0-9_]+" },
          "velocity_score": { "type": "number", "minimum": 0 },
          "category": { "enum": ["viral", "emerging", "niche", "evergreen"] },
          "related_keywords": { "type": "array", "items": { "type": "string" } },
  ### 2.2 Content Brief (output from Planner → input to Worker Swarm)

  ```json
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "ContentBrief",
    "type": "object",
    "required": ["concept", "script_outline", "visual_style", "target_platforms", "confidence"],
    "properties": {
      "concept": { "type": "string", "minLength": 10 },
      "script_outline": {
        "type": "array",
        "items": { "type": "string" },
        "minItems": 3
      },
      "visual_style": {
        "type": "object",
        "properties": {
          "tone": { "enum": ["energetic", "calm", "humorous", "inspirational", "educational"] },
          "colors": { "type": "array", "items": { "type": "string" } },
          "duration_seconds": { "type": "integer", "minimum": 15, "maximum": 90 }
        }
      },
      "target_platforms": {
        "type": "array",
        "items": { "enum": ["youtube_shorts", "tiktok", "instagram_reels", "x"] }
      },
      "hashtags": { "type": "array", "items": { "type": "string" } },
      "cta": { "type": "string" },
      "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
      "source_trends": { "type": "array", "items": { "type": "string" } }
    }
  }
  ```

  ### 2.3 Judge Evaluation Input / Output

  ```json
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "JudgeEvaluation",
    "type": "object",
    "required": ["content_id", "final_decision", "confidence", "reasons"],
    "properties": {
      "content_id": { "type": "string" },
      "final_decision": {
        "enum": ["approve", "reject", "escalate_to_human", "edit"]
      },
      "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
      "reasons": { "type": "array", "items": { "type": "string" } },
      "policy_violations": { "type": "array", "items": { "type": "string" } },
      "suggested_edits": { "type": "string" }
    }
  }
  ```

  ## 3. Database Schema (Core Entities)

  ### 3.1 Main Metadata Store – NoSQL (MongoDB-like document store)

  Collection: content_metadata (high-velocity write)

  ```json
  {
    "_id": ObjectId,
    "agent_id": string,
    "content_id": string,
    "status": enum["draft", "judged", "published", "failed"],
    "platform_ids": { "tiktok": string, "youtube": string, "instagram": string, "x": string },
    "published_at": ISODate,
    "created_at": ISODate,
    "updated_at": ISODate,
    "trend_sources": [string],
    "engagement": {
      "views": number,
      "likes": number,
      "comments": number,
      "shares": number,
      "sentiment_score": number,
      "last_updated": ISODate
    },
    "thumbnail_url": string,
    "video_duration_sec": number,
    "confidence_at_publish": number,
    "judge_decision": string,
    "human_reviewed": boolean
  }
  ```

  ### 3.2 Complementary Stores

  - Weaviate – vector memory
    - Stores embeddings of content briefs, scripts, audience feedback for semantic retrieval
  - Redis – caching layer
    - Caches trend scores, recent performance, rate-limit states, short-lived session data
  - PostgreSQL – configuration & transactional data
    - Agent personas, brand rules, wallet addresses, global orchestration settings

  ### 3.3 ER Diagram (Mermaid)

  ```mermaid
  erDiagram
      AGENT ||--o{ CONTENT_METADATA : creates
      CONTENT_METADATA ||--o{ ENGAGEMENT_METRIC : has
      CONTENT_METADATA ||--o{ TREND_REFERENCE : inspired_by
      AGENT ||--|{ WALLET : owns
      CONTENT_METADATA {
          string content_id PK
          string agent_id FK
          string status
          json platform_ids
          datetime published_at
          json engagement
          number confidence
      }
      ENGAGEMENT_METRIC {
          string content_id FK
          datetime timestamp
          number views
          number likes
          number comments
          number sentiment
      }
      TREND_REFERENCE {
          string content_id FK
          string trend_topic
          string hashtag
          number velocity_score
      }
      WALLET {
          string agent_id FK
          string address
          string provider "Coinbase AgentKit"
      }
  ```

  ## 4. MCP Integration Points

  All external calls go through MCP servers:

  - `trend_fetch_mcp` → fetches trends from platforms
  - `publish_content_mcp` → posts to social platforms
  - `engagement_poll_mcp` → pulls comments/views
  - `openclaw_status_mcp` → publishes heartbeat & availability
  - `wallet_transaction_mcp` → signs & broadcasts micro-transactions

  ## 5. Version & Status

  Last updated: February 2025 (Day 2 – Technical Specification)

  Status: Ratified for test creation, skill interface definition, and future implementation

  All tests (test_trend_fetcher.py, test_skills_interface.py) must validate against these schemas and structures.

publish_content_mcp → posts to social platforms
engagement_poll_mcp → pulls comments/views
openclaw_status_mcp → publishes heartbeat & availability
wallet_transaction_mcp → signs & broadcasts micro-transactions

5. Version & Status
Last updated: February 2025 (Day 2 – Technical Specification)
Status: Ratified for test creation, skill interface definition, and future implementation
All tests (test_trend_fetcher.py, test_skills_interface.py) must validate against these schemas and structures.
text