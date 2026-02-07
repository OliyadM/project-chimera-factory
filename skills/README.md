# Project Chimera – Agent Skills: Runtime Capabilities

This document defines the reusable runtime skills (functions/scripts) that the Chimera Autonomous Influencer Agent can call. Skills are distinct from MCP Servers (external bridges like database connectors) – they are internal, self-contained capabilities that the agent invokes for specific tasks.

Skills must adhere to Spec-Driven Development: all I/O contracts are traceable to `specs/technical.md` API schemas and `specs/functional.md` user stories. Implementation logic is NOT included here – this is the interface blueprint for AI agents to fill in later. At least 5 critical skills are defined to cover the core workflow (trend discovery, content generation, engagement, economic agency, collaboration).

## Skill Design Principles
- **Input/Output**: Strict JSON schemas for predictability and testability.
- **Traceability**: Each skill logs invocation via MCP Sense.
- **Error Handling**: All skills return "confidence" score and "error" field if failed.
- **Swarm Integration**: Skills are callable by Worker Swarm in parallel.
- **Dependencies**: Use MCP for external calls (e.g., API fetches).
- **Security**: No direct access to wallets or publishing – escalate to Judge layer.

---

## 1. skill_fetch_current_trends

**Purpose**  
Implements "Perception & Trend Discovery" user stories (`specs/functional.md` section 2.1). Fetches real-time trending topics/hashtags relevant to the agent's niche from social platforms.

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to discover current trending topics and hashtags in my assigned niche and target platforms so that I can create timely, relevant, and high-engagement content."

**Technical Contract**: Implements `TrendDiscoveryResult` schema from `specs/technical.md` section 2.1.

**MCP Dependencies**: 
- `trend_fetch_mcp` (external API bridge to TikTok, YouTube, Instagram, X, MoltBook)

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "FetchTrendsInput",
  "type": "object",
  "required": ["niche", "platforms"],
  "properties": {
    "niche": { 
      "type": "string", 
      "minLength": 1, 
      "description": "Agent's content niche (e.g., 'fitness motivation', 'tech reviews')" 
    },
    "platforms": { 
      "type": "array", 
      "items": { 
        "enum": ["tiktok", "youtube_shorts", "instagram_reels", "x", "moltbook", "openclaw"] 
      }, 
      "minItems": 1 
    },
    "limit": { 
      "type": "integer", 
      "minimum": 1, 
      "maximum": 20, 
      "default": 10,
      "description": "Maximum number of trends to return"
    },
    "since_time": { 
      "type": "string", 
      "format": "date-time", 
      "description": "Optional: Only fetch trends after this timestamp"
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "FetchTrendsOutput",
  "type": "object",
  "required": ["trends", "timestamp", "confidence"],
  "properties": {
    "trends": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["topic", "hashtag", "velocity_score", "category"],
        "properties": {
          "topic": { "type": "string", "minLength": 1 },
          "hashtag": { "type": "string", "pattern": "^#[A-Za-z0-9_]+" },
          "velocity_score": { 
            "type": "number", 
            "minimum": 0,
            "description": "Trend momentum score (higher = faster growing)"
          },
          "category": { 
            "enum": ["viral", "emerging", "niche", "evergreen"],
            "description": "Trend classification"
          },
          "related_keywords": { 
            "type": "array", 
            "items": { "type": "string" },
            "description": "Associated search terms"
          },
          "volume_24h": { 
            "type": "integer",
            "description": "Number of posts in last 24 hours"
          }
        }
      }
    },
    "timestamp": { "type": "string", "format": "date-time" },
    "source_platform": { 
      "enum": ["tiktok", "youtube", "instagram", "x", "moltbook", "openclaw"] 
    },
    "confidence": { 
      "type": "number", 
      "minimum": 0, 
      "maximum": 1,
      "description": "Confidence in trend data quality (0.0-1.0)"
    },
    "error": { 
      "type": "string", 
      "description": "Error message if fetch failed (null on success)"
    }
  }
}
```

**Example Usage**:
```json
// Input
{
  "niche": "fitness motivation",
  "platforms": ["tiktok", "youtube_shorts"],
  "limit": 5,
  "since_time": "2026-02-07T00:00:00Z"
}

// Output
{
  "trends": [
    {
      "topic": "75 Hard Challenge",
      "hashtag": "#75hard",
      "velocity_score": 8.7,
      "category": "viral",
      "related_keywords": ["fitness", "discipline", "transformation"],
      "volume_24h": 45000
    },
    {
      "topic": "Morning Routine Optimization",
      "hashtag": "#morningroutine",
      "velocity_score": 6.2,
      "category": "emerging",
      "related_keywords": ["productivity", "wellness", "habits"],
      "volume_24h": 12000
    }
  ],
  "timestamp": "2026-02-07T12:00:00Z",
  "source_platform": "tiktok",
  "confidence": 0.92,
  "error": null
}
```

**Acceptance Criteria** (from `specs/acceptance_criteria.md` section 1):
- Trends array contains at least 1 item (if available)
- Each trend has required fields: topic, hashtag, velocity_score, category
- Confidence ≥ 0.8 for successful fetch
- Output validates against TrendDiscoveryResult schema

---

## 2. skill_generate_content_brief

**Purpose**  
Implements "Content Planning & Ideation" user stories (`specs/functional.md` section 2.2). Generates multiple content ideas and detailed briefs based on discovered trends, agent persona, and past performance.

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to generate multiple content ideas based on discovered trends, my persona, and past performance so that I can select the most promising concept before investing in production."
- "As an Autonomous Influencer Agent, I need to create a detailed content brief (script outline, visual style, tone, CTA, hashtags) so that downstream worker agents have precise instructions for generation."

**Technical Contract**: Implements `ContentBrief` schema from `specs/technical.md` section 2.2.

**MCP Dependencies**: None (internal LLM-based generation)

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "GenerateBriefInput",
  "type": "object",
  "required": ["trends_data", "persona", "max_ideas"],
  "properties": {
    "trends_data": {
      "type": "object",
      "description": "Output from skill_fetch_current_trends",
      "required": ["trends"],
      "properties": {
        "trends": { "type": "array" }
      }
    },
    "persona": {
      "type": "object",
      "required": ["tone", "target_audience", "brand_values"],
      "properties": {
        "tone": { 
          "enum": ["energetic", "calm", "humorous", "inspirational", "educational"],
          "description": "Agent's content personality"
        },
        "target_audience": { 
          "type": "string",
          "description": "Primary audience demographic (e.g., 'Gen Z fitness enthusiasts')"
        },
        "brand_values": { 
          "type": "array", 
          "items": { "type": "string" },
          "description": "Core values to maintain (e.g., ['authenticity', 'positivity'])"
        }
      }
    },
    "max_ideas": { 
      "type": "integer", 
      "minimum": 1, 
      "maximum": 10,
      "default": 3,
      "description": "Number of content briefs to generate"
    },
    "past_performance": {
      "type": "object",
      "description": "Optional: Historical engagement data to inform ideation",
      "properties": {
        "top_performing_topics": { "type": "array", "items": { "type": "string" } },
        "avg_engagement_rate": { "type": "number" }
      }
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "GenerateBriefOutput",
  "type": "object",
  "required": ["briefs", "timestamp", "confidence"],
  "properties": {
    "briefs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["concept", "script_outline", "visual_style", "target_platforms", "confidence"],
        "properties": {
          "concept": { 
            "type": "string", 
            "minLength": 10,
            "description": "High-level content idea"
          },
          "script_outline": {
            "type": "array",
            "items": { "type": "string" },
            "minItems": 3,
            "description": "Ordered list of script beats/scenes"
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
          "hashtags": { 
            "type": "array", 
            "items": { "type": "string" },
            "description": "Recommended hashtags for distribution"
          },
          "cta": { 
            "type": "string",
            "description": "Call-to-action (e.g., 'Follow for more tips')"
          },
          "confidence": { 
            "type": "number", 
            "minimum": 0, 
            "maximum": 1,
            "description": "Confidence in brief quality"
          },
          "source_trends": { 
            "type": "array", 
            "items": { "type": "string" },
            "description": "Trend topics that inspired this brief"
          }
        }
      }
    },
    "timestamp": { "type": "string", "format": "date-time" },
    "confidence": { 
      "type": "number", 
      "minimum": 0, 
      "maximum": 1,
      "description": "Overall confidence in brief set quality"
    },
    "error": { "type": "string" }
  }
}
```

**Example Usage**:
```json
// Input
{
  "trends_data": {
    "trends": [
      { "topic": "75 Hard Challenge", "hashtag": "#75hard", "velocity_score": 8.7 }
    ]
  },
  "persona": {
    "tone": "inspirational",
    "target_audience": "Gen Z fitness enthusiasts",
    "brand_values": ["authenticity", "discipline", "growth"]
  },
  "max_ideas": 2
}

// Output
{
  "briefs": [
    {
      "concept": "Day 1 of 75 Hard: Why I'm Starting This Journey",
      "script_outline": [
        "Hook: Show exhausted but determined face",
        "Explain 75 Hard rules (2 workouts, diet, water, reading, progress pic)",
        "Share personal 'why' - building mental toughness",
        "CTA: Join me on this journey"
      ],
      "visual_style": {
        "tone": "inspirational",
        "colors": ["#FF6B35", "#004E89"],
        "duration_seconds": 60
      },
      "target_platforms": ["tiktok", "instagram_reels"],
      "hashtags": ["#75hard", "#fitnessmotivation", "#mentaltoughness"],
      "cta": "Follow for daily updates!",
      "confidence": 0.88,
      "source_trends": ["75 Hard Challenge"]
    }
  ],
  "timestamp": "2026-02-07T12:15:00Z",
  "confidence": 0.85,
  "error": null
}
```

**Acceptance Criteria** (from `specs/acceptance_criteria.md` section 2):
- Briefs array has length ≤ max_ideas
- Each brief has concept, script_outline (≥3 items), visual_style, hashtags, cta
- Confidence ≥ 0.75 for valid briefs
- Output validates against ContentBrief schema

---

## 3. skill_produce_short_video

**Purpose**  
Implements "Media Generation & Editing" user stories (`specs/functional.md` section 2.3). Generates or sources short-form video assets (clips, voice-over, captions, thumbnails) based on content brief.

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to generate or source short-form video assets so that I can produce platform-native content ready for publishing."
- "As an Autonomous Influencer Agent, I need to apply brand-aligned editing rules (watermark, color grading, music style, length limits) so that all published content maintains consistent identity and quality."

**Technical Contract**: Custom schema (video production output).

**MCP Dependencies**: 
- External video generation APIs (via MCP bridge)
- Asset storage (S3/CDN via MCP)

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ProduceVideoInput",
  "type": "object",
  "required": ["content_brief", "brand_rules"],
  "properties": {
    "content_brief": {
      "type": "object",
      "description": "Output from skill_generate_content_brief (single brief)",
      "required": ["concept", "script_outline", "visual_style"]
    },
    "brand_rules": {
      "type": "object",
      "required": ["watermark_url", "color_palette", "music_style"],
      "properties": {
        "watermark_url": { "type": "string", "format": "uri" },
        "color_palette": { "type": "array", "items": { "type": "string" } },
        "music_style": { "enum": ["upbeat", "chill", "epic", "none"] },
        "max_duration_sec": { "type": "integer", "minimum": 15, "maximum": 90 }
      }
    },
    "generation_mode": {
      "enum": ["ai_generated", "stock_footage", "hybrid"],
      "default": "hybrid",
      "description": "Video generation approach"
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ProduceVideoOutput",
  "type": "object",
  "required": ["video_metadata", "confidence"],
  "properties": {
    "video_metadata": {
      "type": "object",
      "required": ["content_id", "file_path", "thumbnail_path", "duration_sec"],
      "properties": {
        "content_id": { "type": "string", "format": "uuid" },
        "file_path": { "type": "string", "description": "Local or CDN path to video file" },
        "thumbnail_path": { "type": "string", "description": "Path to thumbnail image" },
        "duration_sec": { "type": "integer", "minimum": 15, "maximum": 90 },
        "resolution": { "type": "string", "pattern": "^\\d+x\\d+$", "example": "1080x1920" },
        "file_size_mb": { "type": "number" },
        "format": { "enum": ["mp4", "mov", "webm"] },
        "captions_embedded": { "type": "boolean" },
        "created_at": { "type": "string", "format": "date-time" }
      }
    },
    "confidence": { 
      "type": "number", 
      "minimum": 0, 
      "maximum": 1,
      "description": "Confidence in video quality and brief alignment"
    },
    "error": { "type": "string" }
  }
}
```

**Example Usage**:
```json
// Input
{
  "content_brief": {
    "concept": "Day 1 of 75 Hard",
    "script_outline": ["Hook", "Explain rules", "Share why", "CTA"],
    "visual_style": { "tone": "inspirational", "duration_seconds": 60 }
  },
  "brand_rules": {
    "watermark_url": "https://cdn.example.com/logo.png",
    "color_palette": ["#FF6B35", "#004E89"],
    "music_style": "upbeat",
    "max_duration_sec": 60
  },
  "generation_mode": "hybrid"
}

// Output
{
  "video_metadata": {
    "content_id": "550e8400-e29b-41d4-a716-446655440000",
    "file_path": "s3://chimera-content/videos/550e8400.mp4",
    "thumbnail_path": "s3://chimera-content/thumbnails/550e8400.jpg",
    "duration_sec": 58,
    "resolution": "1080x1920",
    "file_size_mb": 12.4,
    "format": "mp4",
    "captions_embedded": true,
    "created_at": "2026-02-07T12:30:00Z"
  },
  "confidence": 0.82,
  "error": null
}
```

**Acceptance Criteria** (from `specs/acceptance_criteria.md` section 3):
- video_metadata.duration_sec matches brief requirements
- file_path and thumbnail_path are valid
- Confidence ≥ 0.8 for successful generation
- Video adheres to brand_rules (watermark, colors, duration)

---

## 4. skill_publish_and_monitor

**Purpose**  
Implements "Publishing & Scheduling" and "Engagement & Community Management" user stories (`specs/functional.md` sections 2.4, 2.5). Publishes content to target platforms and initiates engagement monitoring.

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to select optimal posting time based on audience activity patterns and platform algorithms so that my content reaches maximum organic reach."
- "As an Autonomous Influencer Agent, I need to publish content across supported platforms so that I can distribute my message efficiently and gather cross-platform data."
- "As an Autonomous Influencer Agent, I need to monitor and respond to comments and messages in a persona-consistent, brand-safe way so that I build audience loyalty and increase retention."

**Technical Contract**: Custom schema (publishing output).

**MCP Dependencies**: 
- `publish_content_mcp` (posts to social platforms)
- `engagement_poll_mcp` (monitors comments/views)

**Security Note**: This skill REQUIRES Judge layer approval before execution (confidence > 0.7).

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PublishAndMonitorInput",
  "type": "object",
  "required": ["video_metadata", "content_brief", "target_platforms", "judge_approval"],
  "properties": {
    "video_metadata": {
      "type": "object",
      "description": "Output from skill_produce_short_video",
      "required": ["content_id", "file_path"]
    },
    "content_brief": {
      "type": "object",
      "description": "Original brief with hashtags and CTA",
      "required": ["hashtags", "cta"]
    },
    "target_platforms": {
      "type": "array",
      "items": { "enum": ["youtube_shorts", "tiktok", "instagram_reels", "x"] },
      "minItems": 1
    },
    "judge_approval": {
      "type": "object",
      "required": ["approved", "confidence", "decision"],
      "properties": {
        "approved": { "type": "boolean" },
        "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
        "decision": { "enum": ["approve", "reject", "escalate_to_human", "edit"] }
      }
    },
    "scheduling": {
      "type": "object",
      "properties": {
        "publish_time": { 
          "type": "string", 
          "format": "date-time",
          "description": "Optional: Schedule for future publish (default: immediate)"
        },
        "optimal_time_detection": { 
          "type": "boolean",
          "default": true,
          "description": "Auto-detect best posting time based on audience activity"
        }
      }
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PublishAndMonitorOutput",
  "type": "object",
  "required": ["platform_ids", "published_at", "initial_engagement", "confidence"],
  "properties": {
    "platform_ids": {
      "type": "object",
      "description": "Platform-specific post IDs",
      "properties": {
        "tiktok": { "type": "string" },
        "youtube": { "type": "string" },
        "instagram": { "type": "string" },
        "x": { "type": "string" }
      }
    },
    "published_at": { "type": "string", "format": "date-time" },
    "initial_engagement": {
      "type": "object",
      "properties": {
        "views": { "type": "integer", "default": 0 },
        "likes": { "type": "integer", "default": 0 },
        "comments": { "type": "integer", "default": 0 },
        "shares": { "type": "integer", "default": 0 }
      }
    },
    "monitoring_enabled": { 
      "type": "boolean",
      "description": "Whether engagement monitoring is active"
    },
    "confidence": { 
      "type": "number", 
      "minimum": 0, 
      "maximum": 1,
      "description": "Confidence in successful publish"
    },
    "error": { "type": "string" }
  }
}
```

**Example Usage**:
```json
// Input
{
  "video_metadata": {
    "content_id": "550e8400-e29b-41d4-a716-446655440000",
    "file_path": "s3://chimera-content/videos/550e8400.mp4"
  },
  "content_brief": {
    "hashtags": ["#75hard", "#fitnessmotivation"],
    "cta": "Follow for daily updates!"
  },
  "target_platforms": ["tiktok", "instagram_reels"],
  "judge_approval": {
    "approved": true,
    "confidence": 0.92,
    "decision": "approve"
  },
  "scheduling": {
    "optimal_time_detection": true
  }
}

// Output
{
  "platform_ids": {
    "tiktok": "7234567890123456789",
    "instagram": "C1a2B3c4D5e6F7g8H9i0"
  },
  "published_at": "2026-02-07T18:00:00Z",
  "initial_engagement": {
    "views": 0,
    "likes": 0,
    "comments": 0,
    "shares": 0
  },
  "monitoring_enabled": true,
  "confidence": 0.95,
  "error": null
}
```

**Acceptance Criteria** (from `specs/acceptance_criteria.md` section 4):
- platform_ids returned for each requested platform
- initial_engagement starts at 0
- Confidence ≥ 0.9 for successful publish
- Publish only occurs if judge_approval.approved = true

---

## 5. skill_handle_economic_transaction

**Purpose**  
Implements "Economic & Ecosystem Participation" user stories (`specs/functional.md` section 2.6). Manages micro-transactions and collaborations via Agentic Commerce (Coinbase AgentKit).

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to track revenue and costs associated with my content so that I can maintain a personal P&L statement."
- "As an Autonomous Influencer Agent, I need to evaluate and accept/reject collaboration proposals from other agents so that I can grow reach through strategic partnerships."

**Technical Contract**: Custom schema (economic transaction).

**MCP Dependencies**: 
- `wallet_transaction_mcp` (Coinbase AgentKit integration)

**Security Note**: This skill REQUIRES Judge layer approval (confidence > 0.9) and adheres to transaction limits from `specs/security.md`.

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "EconomicTransactionInput",
  "type": "object",
  "required": ["transaction_type", "amount", "currency", "judge_approval"],
  "properties": {
    "transaction_type": {
      "enum": ["collaborate_fee", "revenue_share", "tip", "bounty", "sponsorship"],
      "description": "Type of economic transaction"
    },
    "amount": { 
      "type": "number", 
      "minimum": 0,
      "maximum": 0.01,
      "description": "Transaction amount (max 0.01 ETH per transaction)"
    },
    "currency": { 
      "enum": ["ETH", "USDC", "BASE"],
      "default": "ETH"
    },
    "recipient_agent_id": {
      "type": "string",
      "format": "uuid",
      "description": "Target agent for outgoing transactions (null for incoming)"
    },
    "description": {
      "type": "string",
      "minLength": 5,
      "description": "Transaction purpose/memo"
    },
    "judge_approval": {
      "type": "object",
      "required": ["approved", "confidence"],
      "properties": {
        "approved": { "type": "boolean" },
        "confidence": { "type": "number", "minimum": 0, "maximum": 1 }
      }
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "EconomicTransactionOutput",
  "type": "object",
  "required": ["transaction_id", "status", "new_balance", "confidence"],
  "properties": {
    "transaction_id": { 
      "type": "string", 
      "format": "uuid",
      "description": "Unique transaction identifier"
    },
    "blockchain_hash": {
      "type": "string",
      "pattern": "^0x[a-fA-F0-9]{64}$",
      "description": "On-chain transaction hash"
    },
    "status": {
      "enum": ["pending", "confirmed", "failed"],
      "description": "Transaction status"
    },
    "new_balance": {
      "type": "object",
      "properties": {
        "ETH": { "type": "number" },
        "USDC": { "type": "number" },
        "BASE": { "type": "number" }
      }
    },
    "timestamp": { "type": "string", "format": "date-time" },
    "gas_fee": { 
      "type": "number",
      "description": "Transaction fee in ETH"
    },
    "confidence": { 
      "type": "number", 
      "minimum": 0, 
      "maximum": 1,
      "description": "Confidence in transaction success"
    },
    "error": { "type": "string" }
  }
}
```

**Example Usage**:
```json
// Input
{
  "transaction_type": "collaborate_fee",
  "amount": 0.005,
  "currency": "ETH",
  "recipient_agent_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "description": "Payment for cross-promotion collaboration",
  "judge_approval": {
    "approved": true,
    "confidence": 0.96
  }
}

// Output
{
  "transaction_id": "tx-550e8400-e29b-41d4-a716-446655440000",
  "blockchain_hash": "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
  "status": "confirmed",
  "new_balance": {
    "ETH": 0.045,
    "USDC": 100.0,
    "BASE": 0.0
  },
  "timestamp": "2026-02-07T12:45:00Z",
  "gas_fee": 0.0002,
  "confidence": 0.98,
  "error": null
}
```

**Acceptance Criteria** (from `specs/acceptance_criteria.md` section 5):
- transaction_id returned on successful transaction
- new_balance updated correctly
- Confidence ≥ 0.95 for successful transaction
- Transaction only occurs if judge_approval.approved = true
- Amount respects security limits (max 0.01 ETH per transaction, 0.05 ETH daily)

---

## 6. BONUS: skill_publish_openclaw_status

**Purpose**  
Implements OpenClaw integration (`specs/openclaw_integration.md` section 3.2). Publishes agent status and availability to OpenClaw network for discovery and collaboration.

**Functional Story Traceability**:
- "As an Autonomous Influencer Agent, I need to publish my availability, niche, language, and audience profile to the OpenClaw network so that other agents can discover and propose collaborations."

**Technical Contract**: Implements `OpenClawHeartbeat` schema from `specs/openclaw_integration.md`.

**MCP Dependencies**: 
- `openclaw_status_mcp` (OpenClaw network bridge)

**Input Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PublishOpenClawStatusInput",
  "type": "object",
  "required": ["agent_id", "status", "availability"],
  "properties": {
    "agent_id": { "type": "string", "format": "uuid" },
    "status": { 
      "enum": ["active", "idle", "busy", "maintenance", "offline"] 
    },
    "availability": {
      "type": "object",
      "required": ["open_to_collaborations", "capacity"],
      "properties": {
        "open_to_collaborations": { "type": "boolean" },
        "current_projects": { "type": "integer", "minimum": 0 },
        "capacity": { "type": "number", "minimum": 0, "maximum": 1 },
        "next_available": { "type": "string", "format": "date-time" }
      }
    },
    "recent_performance": {
      "type": "object",
      "properties": {
        "content_published_24h": { "type": "integer" },
        "avg_engagement_rate": { "type": "number" },
        "collaborations_active": { "type": "integer" }
      }
    }
  }
}
```

**Output Schema** (JSON):
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "PublishOpenClawStatusOutput",
  "type": "object",
  "required": ["heartbeat_id", "timestamp", "confirmed", "confidence"],
  "properties": {
    "heartbeat_id": { "type": "string", "format": "uuid" },
    "timestamp": { "type": "string", "format": "date-time" },
    "confirmed": { "type": "boolean" },
    "next_heartbeat_due": { 
      "type": "string", 
      "format": "date-time",
      "description": "When next heartbeat should be sent (4 hours from now)"
    },
    "confidence": { "type": "number", "minimum": 0, "maximum": 1 },
    "error": { "type": "string" }
  }
}
```

**Example Usage**:
```json
// Input
{
  "agent_id": "550e8400-e29b-41d4-a716-446655440000",
  "status": "active",
  "availability": {
    "open_to_collaborations": true,
    "current_projects": 2,
    "capacity": 0.7,
    "next_available": "2026-02-08T00:00:00Z"
  },
  "recent_performance": {
    "content_published_24h": 3,
    "avg_engagement_rate": 0.045,
    "collaborations_active": 1
  }
}

// Output
{
  "heartbeat_id": "hb-550e8400-e29b-41d4-a716-446655440000",
  "timestamp": "2026-02-07T12:00:00Z",
  "confirmed": true,
  "next_heartbeat_due": "2026-02-07T16:00:00Z",
  "confidence": 0.99,
  "error": null
}
```

**Acceptance Criteria**:
- Heartbeat confirmed by OpenClaw network
- next_heartbeat_due is 4 hours from timestamp
- Confidence ≥ 0.95 for successful publish
- Agent appears in OpenClaw directory within 5 minutes

---

## 7. Skill Execution Flow (Hierarchical Swarm)

The skills are designed to work within the Hierarchical Swarm architecture (`specs/_meta.md` section 4):

```
Planner Agent
  ↓
  1. skill_fetch_current_trends() → Discover trending topics
  ↓
  2. skill_generate_content_brief() → Create content ideas
  ↓
Worker Swarm (Parallel Execution)
  ↓
  3. skill_produce_short_video() → Generate video assets
  ↓
Judge Layer (Quality Control)
  ↓ (if confidence > 0.7)
  4. skill_publish_and_monitor() → Publish to platforms
  ↓
  5. skill_publish_openclaw_status() → Update availability
  ↓ (if collaboration opportunity)
  6. skill_handle_economic_transaction() → Process payments
```

**Key Principles**:
- Skills 1-3 can run autonomously (high confidence threshold)
- Skills 4-6 REQUIRE Judge approval (safety-critical)
- All skills log to MCP Sense for traceability
- Failures trigger self-healing retry logic (exponential backoff)

---

## 8. Testing & Validation

All skills must be validated against:
- **Input/Output Schemas**: JSON schema validation in `tests/test_skills_interface.py`
- **Acceptance Criteria**: Gherkin scenarios in `specs/acceptance_criteria.md`
- **Functional Requirements**: User stories in `specs/functional.md`
- **Technical Contracts**: API schemas in `specs/technical.md`

**Test Coverage Requirements**:
- Valid input → Expected output
- Invalid input → Descriptive error
- Edge cases (empty data, max limits, timeouts)
- Security checks (Judge approval, rate limits)

---

## 9. Document Status

**Last updated**: February 7, 2026 (Day 3 - Challenge Submission)  
**Status**: Ratified for Phase 1 implementation  
**Skills Defined**: 6 (5 required + 1 bonus OpenClaw integration)

All skills are interface-only (no implementation logic). Implementation will be completed by AI agent swarms following TDD approach with failing tests in `tests/` directory.

**Dependencies**:
- `specs/_meta.md` (architecture, principles)
- `specs/functional.md` (user stories)
- `specs/technical.md` (API contracts, schemas)
- `specs/security.md` (auth, rate limits, Judge approval)
- `specs/openclaw_integration.md` (agent-to-agent protocols)
- `specs/acceptance_criteria.md` (Gherkin test scenarios)
