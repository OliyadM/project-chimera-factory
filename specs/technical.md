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
          "volume_24h": { "type": "integer" }
        }
      },
      "minItems": 1
    },
    "timestamp": { "type": "string", "format": "date-time" },
    "source_platform": { "enum": ["tiktok", "youtube", "instagram", "x", "moltbook", "openclaw"] },
    "confidence": { "type": "number", "minimum": 0, "maximum": 1 }
  }
}
2.2 Content Brief (output from Planner → input to Worker Swarm)
JSON{
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
2.3 Judge Evaluation Input / Output
JSON{
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
3. Database Schema (Core Entities)
3.1 Main Metadata Store – NoSQL (MongoDB-like document store)
Collection: content_metadata (high-velocity write)
JSON{
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
3.2 Complementary Stores

Weaviate – vector memory (embeddings of briefs, scripts, feedback)
Redis – caching (trend scores, rate limits, sessions)
PostgreSQL – transactional data (agent personas, brand rules, wallet addresses)

3.3 ER Diagram (Mermaid)
#mermaid-diagram-mermaid-ab6cn6p{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;fill:#ccc;}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#mermaid-diagram-mermaid-ab6cn6p .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#mermaid-diagram-mermaid-ab6cn6p .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#mermaid-diagram-mermaid-ab6cn6p .error-icon{fill:#a44141;}#mermaid-diagram-mermaid-ab6cn6p .error-text{fill:#ddd;stroke:#ddd;}#mermaid-diagram-mermaid-ab6cn6p .edge-thickness-normal{stroke-width:1px;}#mermaid-diagram-mermaid-ab6cn6p .edge-thickness-thick{stroke-width:3.5px;}#mermaid-diagram-mermaid-ab6cn6p .edge-pattern-solid{stroke-dasharray:0;}#mermaid-diagram-mermaid-ab6cn6p .edge-thickness-invisible{stroke-width:0;fill:none;}#mermaid-diagram-mermaid-ab6cn6p .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-diagram-mermaid-ab6cn6p .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-diagram-mermaid-ab6cn6p .marker{fill:lightgrey;stroke:lightgrey;}#mermaid-diagram-mermaid-ab6cn6p .marker.cross{stroke:lightgrey;}#mermaid-diagram-mermaid-ab6cn6p svg{font-family:"trebuchet ms",verdana,arial,sans-serif;font-size:16px;}#mermaid-diagram-mermaid-ab6cn6p p{margin:0;}#mermaid-diagram-mermaid-ab6cn6p .entityBox{fill:#1f2020;stroke:#ccc;}#mermaid-diagram-mermaid-ab6cn6p .relationshipLabelBox{fill:hsl(20, 1.5873015873%, 12.3529411765%);opacity:0.7;background-color:hsl(20, 1.5873015873%, 12.3529411765%);}#mermaid-diagram-mermaid-ab6cn6p .relationshipLabelBox rect{opacity:0.5;}#mermaid-diagram-mermaid-ab6cn6p .labelBkg{background-color:rgba(32.0000000001, 31.3333333334, 31.0000000001, 0.5);}#mermaid-diagram-mermaid-ab6cn6p .edgeLabel .label{fill:#ccc;font-size:14px;}#mermaid-diagram-mermaid-ab6cn6p .label{font-family:"trebuchet ms",verdana,arial,sans-serif;color:#ccc;}#mermaid-diagram-mermaid-ab6cn6p .edge-pattern-dashed{stroke-dasharray:8,8;}#mermaid-diagram-mermaid-ab6cn6p .node rect,#mermaid-diagram-mermaid-ab6cn6p .node circle,#mermaid-diagram-mermaid-ab6cn6p .node ellipse,#mermaid-diagram-mermaid-ab6cn6p .node polygon{fill:#1f2020;stroke:#ccc;stroke-width:1px;}#mermaid-diagram-mermaid-ab6cn6p .relationshipLine{stroke:lightgrey;stroke-width:1;fill:none;}#mermaid-diagram-mermaid-ab6cn6p .marker{fill:none!important;stroke:lightgrey!important;stroke-width:1;}#mermaid-diagram-mermaid-ab6cn6p :root{--mermaid-font-family:"trebuchet ms",verdana,arial,sans-serif;}createshasinspired_byownsAGENTCONTENT_METADATAstringcontent_idPKstringagent_idFKstringstatusjsonplatform_idsdatetimepublished_atjsonengagementnumberconfidenceENGAGEMENT_METRICstringcontent_idFKdatetimetimestampnumberviewsnumberlikesnumbercommentsnumbersentimentTREND_REFERENCEstringcontent_idFKstringtrend_topicstringhashtagnumbervelocity_scoreWALLETstringagent_idFKstringaddressstringproviderCoinbase AgentKit
4. MCP Integration Points
All external calls go through MCP servers:

trend_fetch_mcp → fetches trends from platforms
publish_content_mcp → posts to social platforms
engagement_poll_mcp → pulls comments/views
openclaw_status_mcp → publishes heartbeat & availability
wallet_transaction_mcp → signs & broadcasts micro-transactions

5. Data Lifecycle & Migration Strategy (Added to address feedback)

Ingestion: Real-time via MCP (trends, engagement, publishing callbacks) – high-velocity write to NoSQL
Transformation: Normalize incoming data to defined schemas on write (handled by MCP-db bridge or skill)
Storage: Partition by agent_id + date range; TTL on transient data (e.g., raw engagement expires after 90 days)
Retrieval:
Semantic/vector search via Weaviate
Fast caching via Redis
Transactional queries via PostgreSQL

Migration Strategy:
Use scripted, versioned migrations via MCP-db-migrate capability (similar to Alembic or Flyway)
All migrations must be backward-compatible
Schema version stored in document metadata (schema_version: "1.0")
Automated migration testing in CI before apply

Backup & Disaster Recovery:
Daily snapshots of NoSQL (MongoDB Atlas-style) and PostgreSQL
Point-in-time recovery enabled
Cross-region replication for critical data

Data Retention & Cleanup:
Raw engagement: 90 days
Published content metadata: indefinite (or per agent policy)
PII anonymized on ingestion; deleted after 30 days


Status: Ratified for test creation, skill interface definition, and future implementation
All tests (test_trend_fetcher.py, test_skills_interface.py) must validate against these schemas and structures.