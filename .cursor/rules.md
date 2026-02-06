# Project Chimera – IDE Agent Rules
(For Cursor / Claude / Copilot in VS Code)

## Project Context
This is **Project Chimera**: an autonomous influencer factory using Spec-Driven Development, MCP-connected agents, Hierarchical Swarm orchestration (Planner → Worker Swarm → Judge), and Agentic Commerce.

The goal is a repository so well-specified that AI agents can build features with minimal human intervention.

## Prime Directive
- NEVER generate implementation code unless you first reference and quote the exact relevant section from the `specs/` folder.
- Order of reference: specs/_meta.md → specs/functional.md → specs/technical.md → other specs files.
- If the specification is missing, ambiguous, or conflicting: STOP and reply:  
  "Spec ambiguity or missing information detected. Please ratify the relevant file in specs/ before proceeding."

## Core Behavioral Rules
1. **Spec-First Thinking**  
   Always start your reasoning with: "Relevant spec reference: [file path and section]".  
   Only then plan or suggest code.

2. **Traceability & Explanation**  
   Before writing any code or change:  
   - Explain your plan step-by-step in comments.  
   - State how it aligns with specs and safety rules.

3. **Safety & Governance**  
   - Flag any potential brand/policy violation, EU AI Act risk, or low-confidence output (<0.7).  
   - Suggest escalation to Judge layer or human review when appropriate.  
   - Never suggest direct publishing, wallet transactions, or external calls without Judge approval.

4. **Ambiguity & Escalation**  
   - If user query is unclear or conflicts with specs: Ask for clarification referencing the spec.  
   - If risk is high (PII, security, policy): Escalate explicitly.

5. **Forbidden Actions**  
   - Do not bypass the swarm pattern or Judge layer.  
   - Do not generate code that ignores MCP for external interactions.  
   - Do not assume implementation details not in specs.

## Additional Guidelines
- Use modular, testable code patterns suitable for swarm parallelism.  
- Prefer open standards (MCP, Docker, JSON schemas).  
- Every major suggestion should be testable against existing failing tests in tests/.

This file is the governing context for all agent interactions in this repository.  
Last updated: February 6, 2026 (Day 3 submission).