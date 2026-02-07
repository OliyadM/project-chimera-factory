# Project Chimera – Acceptance Criteria

This document defines clear, testable conditions for when each major feature or capability is "done".  
All criteria are written in Gherkin (Given-When-Then) format for readability and automation potential.  
They are traceable to:
- `specs/functional.md` (user stories)
- `specs/technical.md` (schemas/contracts)
- `skills/README.md` (skill interfaces)

## 1. Trend Discovery (skill_fetch_current_trends)

**Scenario: Successful trend fetch with valid input**  
Given an agent with niche "fitness motivation" and platforms ["tiktok", "youtube_shorts"]  
When skill_fetch_current_trends is called with valid input  
Then  
- trends array contains at least 1 item  
- each trend has "topic", "hashtag", "velocity_score"  
- confidence ≥ 0.8  
- output validates against TrendDiscoveryResult schema in specs/technical.md  

**Scenario: No trends available**  
Given no trends match the niche in the last 24 hours  
When skill_fetch_current_trends is called  
Then  
- trends array is empty (allowed)  
- confidence < 0.5  
- error field is null or descriptive  

**Scenario: Invalid input (missing niche)**  
Given input missing required "niche" field  
When skill_fetch_current_trends is called  
Then  
- error field contains descriptive message  
- test in test_skills_interface.py fails  

## 2. Content Brief Generation (skill_generate_content_brief)

**Scenario: Generate multiple valid briefs**  
Given valid trends_data from skill_fetch_current_trends  
And persona "energetic fitness coach"  
When skill_generate_content_brief is called  
Then  
- briefs array has length ≤ max_ideas  
- each brief has concept, script_outline (≥3 items), visual_style, hashtags, cta  
- confidence ≥ 0.75  
- output validates against ContentBrief schema  

**Scenario: Low-quality trends input**  
Given trends_data with low velocity_scores  
When skill_generate_content_brief is called  
Then  
- confidence < 0.6  
- briefs array may be empty or contain warning  

## 3. Video Production (skill_produce_short_video)

**Scenario: Successful video generation**  
Given a valid content_brief with duration_seconds = 60  
When skill_produce_short_video is called  
Then  
- video_metadata.duration_sec matches brief  
- file_path and thumbnail_path are valid paths  
- confidence ≥ 0.8  

**Scenario: Brief exceeds max duration**  
Given brief with duration_seconds = 120 and max_duration_sec = 60  
When skill_produce_short_video is called  
Then  
- error returned  
- no video produced  

## 4. Publishing & Initial Monitoring (skill_publish_and_monitor)

**Scenario: Publish approved content**  
Given video_metadata from skill_produce_short_video and Judge approval  
When skill_publish_and_monitor is called  
Then  
- platform_ids returned for each requested platform  
- initial_engagement starts at 0  
- confidence ≥ 0.9  

**Scenario: Publish without approval**  
Given no Judge approval (confidence < 0.7)  
When skill_publish_and_monitor is called  
Then  
- error returned  
- no publish occurs  

## 5. Economic Transaction (skill_handle_economic_transaction)

**Scenario: Successful micro-payment**  
Given valid transaction_type "collaborate_fee" and amount 0.005  
When skill_handle_economic_transaction is called  
Then  
- transaction_id returned  
- new_balance updated  
- confidence ≥ 0.95  

**Scenario: Insufficient balance**  
Given amount > current balance  
When skill_handle_economic_transaction is called  
Then  
- error returned  
- no transaction occurs  

**Status**: Ratified. These criteria are ready for automated test generation and validation against specs.