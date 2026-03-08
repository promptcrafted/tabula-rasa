# Phase 5: Oversight + Memory - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can invoke `/signe-oversee` and Signe spawns a `signe-overseer` agent that performs multi-lens code review (security, performance, correctness, test coverage, style), compares implementation against plan acceptance criteria, tracks progress, and enforces quality gates. Signe also gains a subagent methodology: research model best practices before designing agents, dry-run test with sample tasks, validate output quality, and bank validated patterns in persistent memory. Workflow chaining and GSD integration are out of scope (Phase 6).

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion (Defer to Research)
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Review lenses & depth** — How the 5 review lenses (security, performance, correctness, test coverage, style) are organized. Whether all lenses run every time or are selectable. How deep each lens goes. Output format for findings (file, line, issue, severity, recommended fix per OVRS-06)
- **Plan comparison mechanism** — How the overseer finds and reads plan acceptance criteria (OVRS-03). Gap report format. How to match implementation artifacts to plan expectations
- **Quality gates & enforcement** — What constitutes pass/fail per phase (OVRS-05). Severity levels. Whether failure blocks progression or warns. How quality criteria are defined
- **Progress tracking** — How the overseer tracks completed vs remaining milestones (OVRS-04). Blocker detection. Remaining work estimation approach
- **Methodology trigger & flow** — When the research->design->test->validate->bank cycle happens (METH-01 through METH-04). Whether user-initiated or automatic. How dry-run testing works for new agents. What "validate output quality" means concretely
- **Playbook/memory structure** — How validated patterns are stored in MEMORY.md topic files (METH-05). Organization scheme (by model, task type, or agent). What metadata each pattern entry captures (model, task type, prompt pattern, success/failure notes)
- **Model pinning strategy** — Phase 1 deferred model assignment to Phase 5. Whether agents should specify models (e.g., cheaper models for review tasks) or keep `model: inherit`. Whether different agents benefit from different models
- **Agent definition details** — maxTurns, permissionMode, tool allowlist, system prompt structure for signe-overseer. Which MCP servers the overseer needs (filesystem tools for reading code, possibly GitHub for PR context)
- **Skill definition** — SKILL.md structure for signe-oversee, context type (fork expected), argument parsing, review scope specification
- **Overseer output format** — How review results are structured. Whether findings are written to files or returned inline. Summary vs detailed output modes

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User explicitly wants the researcher to determine best practices from the reference repo (claude-code-best-practice) and Claude Code official documentation, consistent with the Phase 1, 2, and 4 approach.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `signe/agents/signe-researcher.md`: Reference pattern for multi-methodology agent (245 lines, 4 presets + auto-detect, 3-round iteration)
- `signe/agents/signe-designer.md`: Reference pattern for preset-routing agent (19K, 4 presets with isolated methodologies)
- `signe/agents/signe-planner.md`: Reference pattern for internal-knowledge agent (no web tools, 30 maxTurns)
- `signe/agents/signe.md`: Orchestrator — already references `/signe-oversee` as Phase 5 with behavioral guidelines for maker-checker loops
- `signe/skills/signe-research/SKILL.md`: Reference pattern for skill with argument passthrough (`$ARGUMENTS`, context: fork)
- `signe/skills/signe-design/SKILL.md`: Reference pattern for skill with preset routing
- `signe/rules/signe-delegation.md`: Delegation table maps `/signe-oversee` -> `signe-overseer` (status: Phase 5)
- `~/.claude/agent-memory/signe/MEMORY.md`: Empty memory file — ready for methodology patterns

### Established Patterns
- Skills use `context: fork` to isolate subagent from main conversation
- Agent definitions use YAML frontmatter (name, description, tools, model, memory, maxTurns, permissionMode)
- `model: inherit` used across all agents — Phase 5 decides whether to change this
- Self-contained agent prompts — subagents only receive their system prompt
- Flat orchestration enforced — signe-overseer cannot spawn sub-agents
- MCP graceful degradation: try specialized tools first, fall back to general tools
- Direct cp deployment to `~/.claude/`
- Preset auto-detection from query keywords (researcher pattern, designer pattern)

### Integration Points
- `signe/skills/` — New `signe-oversee/SKILL.md` goes here
- `signe/agents/` — New `signe-overseer.md` goes here
- `signe/CLAUDE.md` — Mode table status updates from (Phase 5) to Available
- `signe/rules/signe-delegation.md` — Agent status updates from (Phase 5) to Available, phase note updated
- `signe/agents/signe.md` — "Coming Soon" section updated to show oversee as available
- `~/.claude/agent-memory/signe/MEMORY.md` — Methodology patterns banked here
- `~/.claude/` — Deployment target (file drop, settings merge)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-oversight-memory*
*Context gathered: 2026-03-08*
