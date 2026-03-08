# Phase 2: Research Mode - Research

**Researched:** 2026-03-07
**Domain:** Claude Code subagent architecture for multi-source research orchestration
**Confidence:** HIGH

## Summary

Phase 2 delivers the `signe-researcher` agent and `/signe-research` skill. The researcher is a Claude Code subagent that performs multi-source investigation using both built-in tools (WebSearch, WebFetch) and MCP tools (Brave, Tavily, Exa, Context7, arxiv) -- all of which are available at user scope in the existing installation. The agent uses iterative refinement: search, read, identify gaps, follow up. Output is structured Markdown with inline citations, confidence levels (HIGH/MEDIUM/LOW), and publication dates. Four domain-specific presets (ecosystem survey, feasibility check, comparison, state-of-the-art review) control scope, depth, and output format through argument parsing in the skill body.

The architecture follows the same pattern established in Phase 1: a SKILL.md with `context: fork` and `agent: signe-researcher` routes to a dedicated agent definition at `~/.claude/agents/signe-researcher.md`. The researcher agent gets a comprehensive system prompt with research methodology, source hierarchy, output template, and preset-specific behavior. Because the agent runs in a forked context, it gets its own context window -- critical for research tasks that consume significant tokens from web fetches and document reads.

**Primary recommendation:** Build two files: `signe/skills/signe-research/SKILL.md` (skill entry point with argument parsing and preset routing) and `signe/agents/signe-researcher.md` (the agent with full research methodology in its system prompt). The agent should use built-in WebSearch + WebFetch as its primary tools and also list MCP servers for Brave, Tavily, Exa, Context7, and arxiv. Update CLAUDE.md, signe.md, and delegation rules to mark research mode as Available. Deploy to `~/.claude/` and validate with a real research task.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
None explicitly locked -- all implementation decisions deferred to Claude's discretion based on research.

### Claude's Discretion
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Output structure** -- Sections, citation format, confidence display, length, how findings are organized
- **Research depth & iteration** -- Single-pass vs iterative refinement, follow-up rounds, turn limits, "enough" criteria
- **Preset behavior** -- How the 4 presets (ecosystem survey, feasibility check, comparison, state-of-the-art review) differ in scope, depth, and output format
- **Source orchestration** -- How the researcher prioritizes and combines MCP tools (Brave, Tavily, Exa, Context7, arxiv), sequential vs parallel, source selection per question type
- **Agent definition details** -- Tool allowlist, maxTurns, permissionMode, system prompt structure
- **Skill definition details** -- SKILL.md structure, context type (fork vs inject), argument parsing
- **Confidence scoring methodology** -- How HIGH/MEDIUM/LOW is determined, source hierarchy weighting
- **Document reading strategy** -- When to WebFetch full pages vs use search snippets, arxiv paper handling

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| RSRCH-01 | User can invoke research via `/signe-research` skill and Signe spawns `signe-researcher` agent | Skill with `context: fork` and `agent: signe-researcher` creates the `/signe-research` slash command and routes to the agent. Pattern validated in Phase 1 with signe-health. |
| RSRCH-02 | Signe-researcher orchestrates searches across available MCP tools (Brave, Tavily, Exa, Context7, arxiv) | All 5 MCP servers are configured at user scope (`~/.claude.json`). User-scoped MCP servers work in custom subagents (confirmed). Built-in WebSearch and WebFetch also available as primary tools. |
| RSRCH-03 | Research findings are tagged with confidence levels (HIGH/MEDIUM/LOW) based on source hierarchy | Confidence methodology defined in system prompt using source hierarchy: official docs/Context7 = HIGH, verified multi-source = MEDIUM, single unverified source = LOW. |
| RSRCH-04 | Research agent performs iterative refinement -- reads results, identifies gaps, spawns follow-up queries until sufficient or limit hit | Agent uses `maxTurns` to cap iteration. System prompt includes gap-identification methodology and "enough" criteria. Anthropic's own multi-agent research system validates this pattern. |
| RSRCH-05 | Research output is structured Markdown with inline citations, source URLs, confidence levels, and publication dates | Output template defined in system prompt with mandatory sections. Citations use inline `[Source](URL)` format with confidence tags and dates. |
| RSRCH-06 | Domain-specific research presets available (ecosystem survey, feasibility check, comparison, state-of-the-art review) | Presets parsed from `$ARGUMENTS` in skill body. Each preset section in the system prompt defines scope, depth, tool emphasis, and output format variations. |
| RSRCH-07 | Research agent reads actual documents and papers (WebFetch, arxiv, Context7) rather than just search result snippets | WebFetch (built-in) reads and summarizes web pages. arxiv MCP downloads and reads papers. Context7 provides library documentation. System prompt instructs: "Always read primary sources, never rely on snippets alone." |
</phase_requirements>

## Discretion Decisions: Research Recommendations

### 1. Agent Tool Allowlist

**Recommendation:** Use a broad built-in tool set plus explicit MCP server declarations.

```yaml
tools: Read, Write, Bash, Grep, Glob, WebSearch, WebFetch
mcpServers: brave-search, tavily, exa, context7, arxiv
```

**Rationale:**
- WebSearch and WebFetch are built-in Claude Code tools (not MCP) and are always available when listed in `tools`. HIGH confidence -- verified in official docs.
- MCP servers at user scope (`~/.claude.json`) are accessible from custom subagents. The known MCP access bug (GitHub issue #25200, #13898) only affects project-scoped `.mcp.json` servers. All of Minta's research MCP servers (brave-search, tavily, exa, context7, arxiv) are user-scoped. MEDIUM confidence -- bug reports confirm user-scoped servers work, but the bug is still open.
- Read, Write, Bash, Grep, Glob enable the researcher to navigate filesystems, read documents, and write output files if needed.
- The `Agent` tool is explicitly NOT included -- subagents cannot spawn other subagents (flat orchestrator constraint from signe-safety.md).

**Fallback strategy:** If MCP tools fail at runtime, the researcher's system prompt should instruct it to fall back to WebSearch + WebFetch (built-in) which are guaranteed to work. This is a graceful degradation, not a failure.

### 2. maxTurns Setting

**Recommendation:** `maxTurns: 50`

**Rationale:**
- Research tasks are multi-step: search (3-5 queries) + read (3-10 pages) + analyze + follow-up searches + synthesize. Each tool call is one turn.
- Anthropic's own multi-agent research system uses 3-5 parallel subagents per research task, each making many tool calls. For a single-agent researcher, more turns are needed.
- Too low (e.g., 15-20) risks cutting off mid-research. Too high (100+) risks runaway token consumption.
- 50 turns allows approximately: 5 search queries + 5 document reads + 5 follow-up queries + 5 more reads + synthesis = ~25-30 tool calls, with headroom for retries and additional exploration.

### 3. permissionMode Setting

**Recommendation:** `permissionMode: bypassPermissions`

**Rationale:**
- The researcher needs to perform web searches, fetch pages, and read files without interruption. Permission prompts would break the research flow.
- The skill is already auto-approved via `Skill(signe-* *)` in settings.json, and the agent via `Agent(signe-*)`.
- The researcher does not perform destructive operations (no git, no deployment, no file deletion).
- This matches the existing pattern: settings.json already auto-approves all signe-* operations.

**Alternative considered:** `permissionMode: default` with explicit allow rules. Rejected because research involves many diverse tool calls and prompting for each would make the agent impractical.

### 4. Skill Definition: context: fork with Argument Parsing

**Recommendation:** Use `context: fork` with `agent: signe-researcher`. Parse `$ARGUMENTS` for preset detection and research topic.

```yaml
---
name: signe-research
description: Deep-dive research using web search, paper reading, library docs, and structured analysis. Spawns signe-researcher for multi-source investigation with confidence scoring.
context: fork
agent: signe-researcher
disable-model-invocation: false
---
```

**Rationale:**
- `context: fork` isolates the research context from the main conversation. Research produces large volumes of intermediate content (search results, page contents) that should not pollute the parent context. This is the same pattern used by signe-health.
- `disable-model-invocation: false` allows Claude to auto-invoke research when the user asks research-type questions. This matches the chief-of-staff personality -- Signe proactively delegates to the right specialist.
- `$ARGUMENTS` passes the user's query and optional preset name to the researcher agent.

**Argument format:** `/signe-research [preset:name] topic description`

Example invocations:
- `/signe-research JWT refresh token rotation patterns` -- default preset (auto-detect)
- `/signe-research preset:comparison React vs Vue vs Svelte for dashboards` -- explicit comparison preset
- `/signe-research preset:ecosystem Python ML training frameworks 2026` -- ecosystem survey
- `/signe-research preset:feasibility WebGPU for real-time video processing` -- feasibility check
- `/signe-research preset:sota diffusion model architecture advances` -- state-of-the-art review

### 5. Output Structure

**Recommendation:** Structured Markdown with mandatory sections, inline citations, and confidence badges.

```markdown
# Research: [Topic]

**Date:** [YYYY-MM-DD]
**Preset:** [ecosystem/feasibility/comparison/sota/general]
**Confidence:** [overall HIGH/MEDIUM/LOW]
**Sources consulted:** [count]

## Executive Summary
[2-3 paragraphs with key findings]

## Findings

### [Finding 1 Title]
[Content with inline citations [Source Name](URL) and confidence tags]

**Confidence:** HIGH | Sources: [list]

### [Finding 2 Title]
...

## Source Hierarchy
| Level | Sources | Count |
|-------|---------|-------|
| HIGH (official docs, primary sources) | [list] | N |
| MEDIUM (verified, multi-source) | [list] | N |
| LOW (single source, unverified) | [list] | N |

## Gaps & Limitations
[What could not be determined, what needs further investigation]

## Full Source List
1. [Source Name](URL) - [date accessed] - [confidence level]
2. ...
```

**Rationale:**
- Inline citations keep claims traceable to sources.
- Per-finding confidence prevents false uniformity -- some findings are better supported than others.
- Source hierarchy table gives the reader a quick quality assessment.
- Gaps section is honest about limitations (per signe-personality.md: "Honest about uncertainty").

### 6. Research Depth & Iteration Strategy

**Recommendation:** Iterative refinement with explicit gap identification after each round.

**Methodology (embedded in system prompt):**

1. **Round 1 -- Broad sweep:** Run 3-5 search queries across different tools (WebSearch for general, brave-search for current, tavily for technical, exa for code, context7 for library docs, arxiv for papers). Collect initial findings.

2. **Gap analysis:** After Round 1, explicitly list:
   - What questions are answered (with confidence level)
   - What questions remain unanswered
   - What claims need verification from primary sources

3. **Round 2 -- Targeted depth:** For each gap:
   - Read primary source documents (WebFetch on official docs, arxiv for papers, Context7 for library APIs)
   - Cross-verify claims across multiple sources
   - Promote confidence levels when verified

4. **Round 3 (if needed) -- Final verification:** Only for remaining LOW confidence claims or critical gaps. Stop after Round 3 regardless.

**"Enough" criteria:**
- All major aspects of the topic have at least MEDIUM confidence findings
- No critical claims remain at LOW confidence without explicit flagging
- The user's specific question is directly addressed
- At least 3 primary sources have been read (not just search snippets)

### 7. Preset Behavior

**Recommendation:** Four presets that vary scope, depth, tool emphasis, and output sections.

| Preset | Scope | Depth | Tool Emphasis | Extra Output Sections |
|--------|-------|-------|---------------|----------------------|
| **ecosystem** | Broad -- landscape of tools/libraries/approaches | Medium -- enumerate, don't deep-dive each | WebSearch, brave-search, exa (code repos) | Landscape table, adoption signals, maturity assessment |
| **feasibility** | Narrow -- one specific technology/approach | Deep -- prove/disprove viability | Context7 (API capabilities), WebFetch (official docs), exa (implementation examples) | Feasibility matrix, risk assessment, proof-of-concept guidance |
| **comparison** | Medium -- 2-5 items compared | Medium-deep -- fair treatment of each | All tools equally, multiple perspectives | Comparison table, tradeoff matrix, recommendation with rationale |
| **sota** | Narrow-medium -- current frontier | Deep -- latest papers and releases | arxiv (papers), WebSearch (recent releases), brave-search (news) | Timeline of advances, current limitations, future directions |
| **general** (default) | Determined by query | Iterative until sufficient | All tools, prioritized by query type | Standard findings format |

### 8. Confidence Scoring Methodology

**Recommendation:** Three-tier system based on source quality and verification.

| Level | Criteria | When to Assign |
|-------|----------|----------------|
| **HIGH** | Verified by official documentation, primary source, or Context7 library docs | Claim directly supported by authoritative source with URL |
| **MEDIUM** | Supported by multiple credible sources (verified search results, reputable blogs, Stack Overflow with high votes) OR single official source without cross-verification | Multiple independent sources agree, or one official source |
| **LOW** | Single unverified source, search snippet only, no primary source read, or conflicting information | Only search result titles/snippets, blog posts without verification, or sources disagree |

**Promotion rules:**
- LOW -> MEDIUM: Verified by reading the actual document (not just snippet) OR confirmed by second independent source
- MEDIUM -> HIGH: Verified against official docs or primary source with direct URL citation
- Any level -> LOW: If contradicted by newer/more authoritative source

### 9. Document Reading Strategy

**Recommendation:** Always read primary sources for critical claims. Use search snippets only for discovery.

**Decision tree:**
1. **Search result snippet** -- Use only to decide whether to read the full document. Never cite a snippet as a finding.
2. **WebFetch on URLs** -- Use for all web pages where you need actual content. Provides summarized answers to specific questions from the page content.
3. **Context7** -- Use for library/framework API documentation. Provides version-specific, accurate API details. Always prefer over web search for "how does library X work" questions.
4. **arxiv MCP** -- Use for academic papers. Search, then download and read abstracts and key sections.
5. **Bash + Read** -- Use for local files, code repositories, or downloaded documents.

**When to read vs skip:**
- **Always read:** Official documentation, primary sources for critical claims, arxiv papers on topic
- **Read selectively:** Blog posts (read only if they cite primary sources), Stack Overflow answers (read if highly voted)
- **Skip:** SEO content farms, aggregator sites, outdated documentation (check dates)

### 10. Model Selection

**Recommendation:** `model: inherit`

**Rationale:**
- Phase 1 established `model: inherit` as the standard pattern, deferring model pinning to Phase 5 (Oversight + Memory) where Signe will research model-specific best practices.
- Research tasks benefit from the most capable model available. Downgrading to Haiku would reduce research quality.
- User can control the model at session level.

## Standard Stack

### Core (Files to Create)

| File | Location | Purpose | Pattern Source |
|------|----------|---------|---------------|
| `signe-researcher.md` | `signe/agents/` | Research agent definition with full methodology | Phase 1: signe-test-agent.md pattern |
| `SKILL.md` | `signe/skills/signe-research/` | Skill entry point with preset parsing | Phase 1: signe-health SKILL.md pattern |

### Files to Update

| File | Location | Change | Purpose |
|------|----------|--------|---------|
| `CLAUDE.md` | `signe/` | Research mode status: (Phase 2) -> Available | User visibility |
| `signe.md` | `signe/agents/` | Research section from "Coming Soon" to "Now" | Orchestrator awareness |
| `signe-delegation.md` | `signe/rules/` | Research row status: (Phase 2) -> Available | Delegation routing |

### Built-in Tools (No Installation Required)

| Tool | Purpose | Confidence |
|------|---------|------------|
| WebSearch | Broad web search via Anthropic backend | HIGH -- built-in, always available |
| WebFetch | Read and summarize web page content | HIGH -- built-in, always available |
| Read | Read local files | HIGH -- built-in |
| Write | Write output files | HIGH -- built-in |
| Bash | Execute commands | HIGH -- built-in |
| Grep | Search file contents | HIGH -- built-in |
| Glob | Find files by pattern | HIGH -- built-in |

### MCP Tools (User-Scoped, Pre-Installed)

| Server | Tool Purpose | Scope | Subagent Access |
|--------|-------------|-------|-----------------|
| `brave-search` | Independent web search index, privacy-first | User (`~/.claude.json`) | MEDIUM -- user-scoped works per issue #13898 |
| `tavily` | AI-optimized search for technical docs | User | MEDIUM |
| `exa` | Semantic search for code and academic content | User | MEDIUM |
| `context7` | Version-specific library documentation | User | MEDIUM |
| `arxiv` | Academic paper search and download | User | MEDIUM |

**MCP access confidence is MEDIUM** because: while user-scoped servers work in custom subagents per confirmed reports, GitHub issue #25200 is still open and the overall MCP-in-subagent feature has known instabilities. The researcher's system prompt should include a fallback strategy: if an MCP tool call fails, use WebSearch + WebFetch instead.

## Architecture Patterns

### Project Structure (New Files)

```
signe/
├── agents/
│   ├── signe.md              # (UPDATE: move research from "Coming Soon" to "Now")
│   ├── signe-test-agent.md   # (no change)
│   └── signe-researcher.md   # NEW: Research agent definition
├── skills/
│   ├── signe-health/
│   │   └── SKILL.md          # (no change)
│   └── signe-research/
│       └── SKILL.md          # NEW: Research skill entry point
├── rules/
│   └── signe-delegation.md   # (UPDATE: research status -> Available)
└── CLAUDE.md                 # (UPDATE: research status -> Available)
```

### Pattern 1: Skill -> Agent Routing (Established in Phase 1)

**What:** A SKILL.md with `context: fork` and `agent: <name>` creates a slash command that spawns a dedicated agent in an isolated context.

**When to use:** For all Signe mode invocations. The skill defines the entry point and argument parsing; the agent defines the behavior.

**Example:**
```yaml
# signe/skills/signe-research/SKILL.md
---
name: signe-research
description: Deep-dive research using web search, paper reading, library docs, and structured analysis with confidence scoring
context: fork
agent: signe-researcher
disable-model-invocation: false
---
```

Source: Phase 1 validated pattern (signe-health -> signe-test-agent), confirmed by official Claude Code docs at https://code.claude.com/docs/en/skills.

### Pattern 2: Research Methodology in System Prompt

**What:** The agent's system prompt (markdown body) contains the complete research methodology -- source hierarchy, iteration strategy, confidence scoring, output template, and preset-specific behavior.

**When to use:** When the agent needs to follow a structured workflow without external scripts.

**Why in the prompt, not in supporting files:** Subagents receive only their system prompt plus basic environment details. They do NOT inherit the parent's conversation context. Skills loaded via `context: fork` inject the skill content as the task prompt. The agent's markdown body is the system prompt. This means all research methodology must be self-contained in the agent definition.

Source: Official Claude Code docs -- "Subagents receive only this system prompt (plus basic environment details like working directory), not the full Claude Code system prompt."

### Pattern 3: Argument-Driven Preset Selection

**What:** The skill body uses `$ARGUMENTS` to pass the user's query and optional preset name to the agent. The agent parses the first token for `preset:` prefix.

**When to use:** When a single skill needs to support multiple behavior modes.

**Example invocation flow:**
1. User types: `/signe-research preset:comparison React vs Vue`
2. SKILL.md content (with `$ARGUMENTS` substituted) becomes the task prompt
3. Agent receives: "Research the following topic... preset:comparison React vs Vue"
4. Agent parses `preset:comparison` and applies comparison-specific methodology

### Pattern 4: Graceful MCP Degradation

**What:** The researcher lists MCP servers in frontmatter but includes fallback instructions in the system prompt for when MCP tools are unavailable.

**When to use:** Whenever depending on MCP tools from subagents, due to known instabilities.

**Example in system prompt:**
```markdown
## Tool Selection Priority
1. Try specialized MCP tools first (Context7 for library docs, arxiv for papers, etc.)
2. If an MCP tool call fails or is unavailable, fall back to WebSearch + WebFetch
3. WebSearch + WebFetch are built-in and always available -- they are your reliable baseline
```

### Anti-Patterns to Avoid

- **Relying solely on MCP tools:** Always have WebSearch + WebFetch as fallback. MCP access from subagents has known issues.
- **Giant system prompts:** Keep the agent markdown body under 500 lines. Use progressive disclosure with supporting files if needed.
- **Including Agent tool in researcher's tools:** Subagents cannot spawn other subagents. Including Agent in tools would be misleading.
- **Using `context: inject` instead of `context: fork`:** Research produces high-volume intermediate content. Fork gives the researcher its own context window, preventing pollution of the main conversation.
- **Hardcoding tool names from MCP servers:** Use the `mcpServers` frontmatter field to declare dependencies. If MCP Tool Search is enabled (which it is -- `tengu_mcp_tool_search: true` in user config), the agent can discover tool names dynamically.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Web searching | Custom search API integration | WebSearch (built-in) + Brave/Tavily/Exa MCP | Built-in tools are guaranteed; MCP provides enhanced results |
| Page reading | Custom web scraper | WebFetch (built-in) | Built-in, handles HTML->summary, 15-min cache |
| Library documentation | Scraping docs sites | Context7 MCP | Version-specific, pre-indexed, eliminates hallucinated APIs |
| Academic papers | Manual PDF downloading | arxiv MCP | Searches, downloads, stores at configured path |
| Source confidence scoring | External scoring API | Prompt-based methodology in system prompt | Claude is excellent at evaluating source quality when given clear criteria |
| Citation formatting | Template engine | Inline Markdown in system prompt instructions | Claude follows formatting templates reliably |
| Preset routing | Complex argument parser | Simple `$ARGUMENTS` pattern with `preset:` prefix | Claude Code natively handles argument passing via `$ARGUMENTS` |

## Common Pitfalls

### Pitfall 1: MCP Tools Silently Unavailable in Subagent

**What goes wrong:** The researcher agent tries to use an MCP tool (e.g., brave-search) but the tool is not available at runtime. Instead of failing loudly, the agent may hallucinate results.
**Why it happens:** GitHub issue #25200 -- MCP tools are not always properly inherited by custom subagents, especially from project-scoped servers.
**How to avoid:** 1) Ensure all research MCP servers are at user scope (already the case). 2) Include fallback instructions in the system prompt. 3) The researcher should verify tool availability at the start of execution.
**Warning signs:** Research findings that seem accurate but have no URL citations, or URLs that don't actually contain the claimed information.

### Pitfall 2: Context Window Exhaustion During Research

**What goes wrong:** The researcher reads too many full web pages or papers, filling its context window before completing synthesis.
**Why it happens:** WebFetch returns summarized content, but multiple fetches accumulate. arxiv papers can be very long.
**How to avoid:** 1) Use `context: fork` (already planned) for isolated context. 2) System prompt instructs researcher to use targeted queries with WebFetch rather than reading entire sites. 3) For arxiv papers, read abstract and relevant sections only, not full papers. 4) Auto-compaction is supported in subagents (triggers at ~95% capacity).
**Warning signs:** Research output that starts strong but becomes thin or repetitive toward the end.

### Pitfall 3: Over-Iteration Without Convergence

**What goes wrong:** The researcher keeps searching and reading without converging on findings, consuming turns and tokens.
**Why it happens:** No clear "enough" criteria, or gap analysis keeps finding new tangents.
**How to avoid:** 1) Cap at 3 research rounds in the system prompt. 2) Define "enough" criteria per preset. 3) Use `maxTurns: 50` as a hard limit. 4) System prompt instructs: "After Round 3, synthesize whatever you have and flag remaining gaps."
**Warning signs:** Turn count approaching maxTurns with no output generation started.

### Pitfall 4: Inconsistent Confidence Levels

**What goes wrong:** Researcher assigns HIGH confidence to search-snippet-only findings, or LOW to well-documented claims.
**Why it happens:** Without clear criteria, confidence becomes subjective and inconsistent.
**How to avoid:** Embed explicit criteria in the system prompt with concrete examples for each level. Include a self-check step: "Before finalizing, review each confidence level against the criteria."
**Warning signs:** All findings rated the same level, or confidence levels that don't correlate with source quality.

### Pitfall 5: Preset Argument Not Parsed Correctly

**What goes wrong:** User passes `preset:comparison` but the researcher treats it as part of the topic instead of a preset selector.
**Why it happens:** `$ARGUMENTS` is a simple string substitution -- the agent must parse it itself.
**How to avoid:** Clear parsing instructions in the system prompt: "If the first token matches `preset:<name>`, extract the preset name and treat the rest as the research topic. Valid presets: ecosystem, feasibility, comparison, sota."
**Warning signs:** Research output that includes "preset:comparison" as part of the topic description.

## Code Examples

### Example 1: Agent Definition Structure

```yaml
# signe/agents/signe-researcher.md
---
name: signe-researcher
description: Multi-source research agent. Searches the web, reads documents, queries library docs, downloads papers, and produces structured findings with confidence scoring. Use proactively for research tasks.
tools: Read, Write, Bash, Grep, Glob, WebSearch, WebFetch
mcpServers: brave-search, tavily, exa, context7, arxiv
model: inherit
memory: user
maxTurns: 50
permissionMode: bypassPermissions
---

You are Signe's research agent...
[full system prompt with methodology]
```

Source: Pattern derived from official Claude Code subagent docs at https://code.claude.com/docs/en/sub-agents, combined with Phase 1 established patterns.

### Example 2: Skill Definition Structure

```yaml
# signe/skills/signe-research/SKILL.md
---
name: signe-research
description: Deep-dive research using web search, paper reading, library docs, and structured analysis with confidence scoring
context: fork
agent: signe-researcher
disable-model-invocation: false
---

## Research Task

Investigate the following topic thoroughly using your multi-source research methodology.

$ARGUMENTS

If the first token of the topic starts with `preset:`, use that preset's specific methodology. Otherwise, auto-detect the best preset based on the query.

Report your findings in structured Markdown with inline citations, confidence levels, and source URLs.
```

Source: Pattern from Phase 1 signe-health SKILL.md, extended with argument parsing per official docs at https://code.claude.com/docs/en/skills.

### Example 3: Inline Citation Format

```markdown
## Finding: JWT Refresh Token Rotation

Token rotation is the recommended approach for long-lived sessions
[OWASP Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)
[RFC 6749 Section 6](https://tools.ietf.org/html/rfc6749#section-6).
The rotation pattern involves issuing a new refresh token with each access
token renewal and invalidating the previous refresh token.

**Confidence:** HIGH
**Sources:** OWASP Foundation (2024), IETF RFC 6749
**Last verified:** 2026-03-07
```

### Example 4: Confidence Badge Format

```markdown
### Finding Title

[Content paragraph with claims and citations]

| Property | Value |
|----------|-------|
| Confidence | **HIGH** / **MEDIUM** / **LOW** |
| Sources | [Source 1](url1), [Source 2](url2) |
| Verified | YYYY-MM-DD |
| Notes | [any caveats] |
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Commands in `.claude/commands/` | Skills in `.claude/skills/` with SKILL.md | 2025 Q3 | Skills absorbed commands; SKILL.md supports frontmatter for context, agent routing, argument parsing |
| Task tool for subagents | Agent tool (renamed in v2.1.63) | 2025 Q4 | `Task(...)` still works as alias, but `Agent(...)` is the current name |
| All MCP tools inherited automatically | `mcpServers` frontmatter field + explicit tool listing | 2026 Q1 | Subagents should declare MCP server dependencies explicitly; MCP Tool Search auto-activates when tool descriptions exceed 10% of context |
| Single-pass research | Multi-agent iterative research (Anthropic Research) | 2025-2026 | Anthropic's own system uses lead-agent + parallel subagents; outperforms single-agent by 90.2% |

## Open Questions

1. **MCP Tool Reliability in Subagents**
   - What we know: User-scoped MCP servers work in custom subagents per confirmed reports. Project-scoped servers do not.
   - What's unclear: Whether there are edge cases where user-scoped servers also fail. The GitHub issue (#25200) is still open.
   - Recommendation: Include WebSearch/WebFetch fallback in system prompt. Test empirically during Phase 2 deployment. If MCP fails, log the issue and continue with built-in tools.

2. **Optimal maxTurns Value**
   - What we know: Research tasks need many tool calls. 50 is a reasonable estimate.
   - What's unclear: Whether 50 is too few for complex research or too many for simple queries.
   - Recommendation: Start with 50, observe real usage, adjust if needed. The system prompt should manage its own "enough" criteria to stop early when sufficient.

3. **bypassPermissions Safety**
   - What we know: The researcher does not perform destructive operations.
   - What's unclear: Whether there are unexpected tool calls (e.g., Bash commands that modify files) that could be risky.
   - Recommendation: Use bypassPermissions for usability but add a note in the system prompt: "Do not modify or delete any user files. Write output only to stdout. If you need to save research findings, use Write to create new files, never overwrite existing ones."

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual validation (no automated test framework) |
| Config file | none |
| Quick run command | `/signe-research test query` from any project directory |
| Full suite command | Run all 4 presets + general query, verify output format |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| RSRCH-01 | `/signe-research` spawns signe-researcher | smoke | `/signe-research Claude Code agent architecture` | Wave 0 (skill file) |
| RSRCH-02 | Multi-source search across MCP tools | integration | Verify output cites multiple sources from different tools | Wave 0 (agent file) |
| RSRCH-03 | Confidence levels in output | smoke | `grep -E "HIGH\|MEDIUM\|LOW" output` | Wave 0 |
| RSRCH-04 | Iterative refinement | integration | Observe multiple search rounds in agent output | Wave 0 |
| RSRCH-05 | Structured Markdown with citations | smoke | Check output has expected sections and inline URLs | Wave 0 |
| RSRCH-06 | Preset-specific output | integration | `/signe-research preset:comparison X vs Y`, verify comparison table | Wave 0 |
| RSRCH-07 | Reads actual documents | integration | Output includes specific claims from fetched pages, not just snippets | Wave 0 |

### Sampling Rate
- **Per task commit:** Verify file structure and YAML frontmatter
- **Per wave merge:** Run one research query and verify output format
- **Phase gate:** Run all 4 presets + general query, verify each produces appropriate output with citations and confidence levels

### Wave 0 Gaps
- [x] `signe/agents/signe-researcher.md` -- research agent definition (RSRCH-01 through RSRCH-07)
- [x] `signe/skills/signe-research/SKILL.md` -- skill entry point (RSRCH-01, RSRCH-06)
- [ ] Updated `signe/CLAUDE.md` -- status update
- [ ] Updated `signe/agents/signe.md` -- orchestrator awareness
- [ ] Updated `signe/rules/signe-delegation.md` -- delegation routing
- [ ] Deployment to `~/.claude/` and end-to-end validation

## Sources

### Primary (HIGH confidence)
- [Official Claude Code Subagent Docs](https://code.claude.com/docs/en/sub-agents) - Complete subagent architecture, frontmatter fields, tool access, MCP server configuration, permission modes, maxTurns
- [Official Claude Code Skills Docs](https://code.claude.com/docs/en/skills) - Skill frontmatter fields, context: fork, $ARGUMENTS, agent routing, progressive disclosure
- [Anthropic Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) - System prompt structure, testing, progressive disclosure patterns
- [Anthropic Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system) - Research orchestration patterns, parallel subagents, iterative refinement, quality assessment
- Phase 1 deliverables (signe-health, signe-test-agent) - Validated patterns on this machine

### Secondary (MEDIUM confidence)
- [GitHub Issue #13898](https://github.com/anthropics/claude-code/issues/13898) - User-scoped MCP servers work in custom subagents (confirmed by workaround table)
- [GitHub Issue #25200](https://github.com/anthropics/claude-code/issues/25200) - MCP tool access bug for project-scoped servers (still open)
- [DeepWiki: claude-code-best-practice agents](https://deepwiki.com/shanraisshan/claude-code-best-practice/3.2-agents-and-subagents) - Agent definition patterns from reference repo
- [Built-in Tools Reference](https://www.vtrivedy.com/posts/claudecode-tools-reference) - Complete list of 15 built-in tools including WebSearch and WebFetch
- [Claude Code Web Search vs MCP](https://help.apiyi.com/en/claude-code-web-search-websearch-mcp-guide-en.html) - Comparison of built-in WebSearch vs MCP search tools

### Tertiary (LOW confidence)
- [VoltAgent awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) - Community research agent examples (names only, no detailed patterns extracted)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- uses verified built-in tools plus user-scoped MCP servers with known working patterns
- Architecture: HIGH -- follows Phase 1 validated pattern (skill -> agent with fork context)
- Agent definition: HIGH -- all frontmatter fields verified against official docs
- MCP access: MEDIUM -- user-scoped servers should work per confirmed reports, but the overall bug is still open
- Pitfalls: HIGH -- derived from actual GitHub issues and Anthropic's own engineering documentation
- Presets: MEDIUM -- design is logical but untested; will need iteration during implementation

**Research date:** 2026-03-07
**Valid until:** 2026-04-07 (30 days -- Claude Code agent architecture is stable)
