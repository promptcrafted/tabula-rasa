# Phase 2: Research Mode - Context

**Gathered:** 2026-03-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can invoke `/signe-research` and Signe spawns a `signe-researcher` agent that performs multi-source investigation across available MCP tools (Brave, Tavily, Exa, Context7, arxiv). The researcher produces structured Markdown with inline citations, confidence levels, and iterative refinement. Domain-specific presets (ecosystem survey, feasibility check, comparison, state-of-the-art review) produce appropriately scoped output. Creating other mode agents (planner, designer, overseer) is out of scope.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion (Defer to Research)
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Output structure** — Sections, citation format, confidence display, length, how findings are organized
- **Research depth & iteration** — Single-pass vs iterative refinement, follow-up rounds, turn limits, "enough" criteria
- **Preset behavior** — How the 4 presets (ecosystem survey, feasibility check, comparison, state-of-the-art review) differ in scope, depth, and output format
- **Source orchestration** — How the researcher prioritizes and combines MCP tools (Brave, Tavily, Exa, Context7, arxiv), sequential vs parallel, source selection per question type
- **Agent definition details** — Tool allowlist, maxTurns, permissionMode, system prompt structure
- **Skill definition details** — SKILL.md structure, context type (fork vs inject), argument parsing
- **Confidence scoring methodology** — How HIGH/MEDIUM/LOW is determined, source hierarchy weighting
- **Document reading strategy** — When to WebFetch full pages vs use search snippets, arxiv paper handling

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User explicitly wants the researcher to determine best practices from the reference repo (claude-code-best-practice) and Claude Code official documentation, consistent with the Phase 1 approach.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `signe/CLAUDE.md`: 38-line identity file — already references `/signe-research` as Phase 2 mode
- `signe/agents/signe.md`: Orchestrator with `Agent(signe-*)` — will spawn `signe-researcher`
- `signe/rules/signe-delegation.md`: Delegation table maps `/signe-research` → `signe-researcher`
- `signe/skills/signe-health/SKILL.md`: Reference pattern for skill definition (context: fork, agent routing)
- `signe/agents/signe-test-agent.md`: Reference pattern for agent definition (YAML frontmatter, tool restrictions)
- `signe/settings-merge.json`: Already includes `Agent(signe-*)` and `Skill(signe-* *)` permissions

### Established Patterns
- Skills use `context: fork` to isolate subagent from main conversation
- Agent definitions use YAML frontmatter (name, description, tools, model, memory)
- `model: inherit` defers model pinning to Phase 5
- Flat orchestration enforced — signe-researcher cannot spawn sub-agents
- Hook scripts follow Node.js cross-platform pattern

### Integration Points
- `signe/skills/` — New `signe-research/SKILL.md` goes here
- `signe/agents/` — New `signe-researcher.md` goes here
- `signe/CLAUDE.md` — Mode table status updates from (Phase 2) to Available
- `signe/rules/signe-delegation.md` — Agent status updates from (Phase 2) to Available
- `~/.claude/` — Deployment target (file drop, settings merge)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-research-mode*
*Context gathered: 2026-03-07*
