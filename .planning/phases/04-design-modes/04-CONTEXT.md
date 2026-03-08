# Phase 4: Design Modes - Context

**Gathered:** 2026-03-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can invoke `/signe-design` and Signe spawns a `signe-designer` agent that operates in one of four presets: architecture, UI/UX, agent design, or product design. Each preset produces structured deliverables appropriate to its domain. A single agent handles all four presets via routing (consistent with signe-researcher pattern). Creating other mode agents (overseer) or workflow chaining is out of scope.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion (Defer to Research)
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Agent architecture** — Single signe-designer agent with preset routing (decided). Research determines: prompt structure, how to organize four methodologies within one agent definition, approximate line count, methodology separation strategy
- **Tool access per preset** — Whether all presets share one tool allowlist or the skill/agent differentiates tools per preset. Which MCP servers each preset needs (e.g., UI/UX may need Figma/browser tools, architecture needs filesystem, agent design needs file read/write)
- **Output deliverables per preset** — What artifacts each preset produces:
  - Architecture: component boundaries, data flow (Mermaid?), API contracts, ADRs, file/folder structure
  - UI/UX: user flow maps, component hierarchy, wireframes (HTML? text specs?), accessibility requirements
  - Agent: YAML frontmatter definitions, structured prompts, tool allowlists, packaged skills
  - Product: user stories with acceptance criteria, MoSCoW prioritization, experience maps
- **Preset routing** — Whether to reuse researcher's auto-detect pattern (keyword matching), require explicit `preset:` prefix, or hybrid approach. The four design presets are more distinct from each other than research presets
- **Skill definition** — SKILL.md structure, context type (fork expected), argument parsing, preset validation
- **Agent definition details** — maxTurns, permissionMode, system prompt structure, memory usage
- **Methodology per preset** — How each preset's design process works (phases, iteration, output checkpoints)
- **Cross-preset consistency** — Common design principles shared across all four presets vs fully independent methodologies

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User explicitly wants the researcher to determine best practices from the reference repo (claude-code-best-practice) and Claude Code official documentation, consistent with the Phase 1, 2, and 3 approach.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `signe/agents/signe-researcher.md`: Reference pattern for preset-routing agent (245 lines, 4 presets + auto-detect, 3-round iteration)
- `signe/agents/signe-planner.md`: Reference pattern for internal-knowledge agent (no web tools, 30 maxTurns)
- `signe/agents/signe.md`: Orchestrator — already references `/signe-design` as Phase 4 with four preset descriptions
- `signe/skills/signe-research/SKILL.md`: Reference pattern for skill with preset passthrough (`$ARGUMENTS`, context: fork)
- `signe/skills/signe-plan/SKILL.md`: Reference pattern for simpler skill (no presets)
- `signe/rules/signe-delegation.md`: Delegation table maps `/signe-design` -> `signe-designer` (status: Phase 4)

### Established Patterns
- Skills use `context: fork` to isolate subagent from main conversation
- Agent definitions use YAML frontmatter (name, description, tools, model, memory, maxTurns, permissionMode)
- `model: inherit` defers model pinning to Phase 5
- Preset auto-detection from query keywords (researcher pattern)
- Self-contained agent prompts — subagents only receive their system prompt
- Flat orchestration enforced — signe-designer cannot spawn sub-agents
- MCP graceful degradation: try specialized tools first, fall back to general tools
- Direct cp deployment to `~/.claude/`

### Integration Points
- `signe/skills/` — New `signe-design/SKILL.md` goes here
- `signe/agents/` — New `signe-designer.md` goes here
- `signe/CLAUDE.md` — Mode table status updates from (Phase 4) to Available
- `signe/rules/signe-delegation.md` — Agent status updates from (Phase 4) to Available, phase note updated
- `signe/agents/signe.md` — "Coming Soon" section updated to show design as available
- `~/.claude/` — Deployment target (file drop, settings merge)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-design-modes*
*Context gathered: 2026-03-07*
