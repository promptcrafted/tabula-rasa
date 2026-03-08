# Phase 6: Workflow + GSD Integration - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Signe chains all modes into coherent end-to-end workflows (research -> plan -> design -> oversee), orchestrates GSD in project subfolders with cross-contamination prevention, and operates as a proactive chief of staff with maker-checker loops and mode-aware context handoffs. Creating new mode agents or modifying existing mode agents' core functionality is out of scope — this phase wires together what already exists.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion (Defer to Research)
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Workflow chaining mechanism** — How the research -> plan -> design -> oversee pipeline works concretely. Whether signe.md spawns agents sequentially and passes output between them. Whether the user triggers `/signe` and it runs all four modes or a subset. How output from one mode is formatted as input for the next. What happens when a mode fails mid-chain. Partial runs (e.g., research -> plan only). Entry/exit points in the pipeline
- **GSD orchestration model** — How Signe "sits above" GSD. Whether Signe invokes GSD slash commands, directly manages `.planning/` directories, or uses another approach. How cross-contamination is prevented between projects (hooks, path validation, scoping). What "runs GSD in project subfolders" means concretely. How Signe knows which project folder to target
- **Context handoff format** — What mode-aware handoff documents look like when transitioning between workflow stages. How they are tailored per receiving mode (e.g., research output formatted differently for planner vs designer). Where handoffs are stored (ephemeral in conversation vs persisted as files). Whether handoffs are structured Markdown, JSON, or conversation context
- **Maker-checker iteration** — How design-then-review cycles work end-to-end (CHST-04). Whether loops are auto-triggered after design or user-initiated. Maximum iteration rounds before escalating. How quality gate verdicts from the overseer feed back into the producing agent. Integration with existing quality gate pass/warn/fail levels from Phase 5
- **Proactive chief of staff behaviors** — How risk identification (CHST-01), milestone summaries (CHST-02), and next action recommendations (CHST-03) are implemented. Whether these are triggered by hooks, inline in the orchestrator, or via dedicated logic in signe.md. What triggers proactive behavior (state changes, workflow stage transitions, user idle periods)
- **signe.md orchestrator updates** — How the orchestrator evolves from "spawn individual agents" to "chain workflows". Whether the orchestrator gains new sections, skills, or behavioral patterns. How the "Coming Soon" `/signe` entry becomes functional
- **Deployment and integration** — What changes to settings.json, CLAUDE.md, rules files, and hooks are needed. Whether new skills are created (e.g., `/signe` as a workflow skill) or existing skills are extended

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User explicitly wants the researcher to determine best practices from the reference repo (claude-code-best-practice) and Claude Code official documentation, consistent with the Phase 1, 2, 4, and 5 approach.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `signe/agents/signe.md`: Orchestrator (104 lines) — already has behavioral guidelines for proactive behavior and maker-checker loops, "Coming Soon" `/signe` entry for Phase 6
- `signe/agents/signe-researcher.md`: Multi-source research agent with 3-round iteration and preset routing
- `signe/agents/signe-planner.md`: Goal decomposition agent (no web tools, 30 maxTurns)
- `signe/agents/signe-designer.md`: Four-preset design agent (architecture, UI/UX, agent, product)
- `signe/agents/signe-overseer.md`: Multi-lens review agent with quality gate verdicts (PASS/WARN/FAIL)
- `signe/skills/signe-*/SKILL.md`: Five skills all using `context: fork` pattern — reference for new `/signe` skill
- `signe/rules/signe-delegation.md`: Delegation table and decision tree — needs Phase 6 routing updates
- `signe/rules/signe-safety.md`: Safety constraints including "GSD files off-limits" rule that needs Phase 6 revision
- `signe/hooks/signe-lifecycle.js`: SubagentStart/Stop hook with debug mode — potential integration point for workflow tracking

### Established Patterns
- Skills use `context: fork` to isolate subagent from main conversation
- Agent definitions use YAML frontmatter (name, description, tools, model, memory, maxTurns, permissionMode)
- `model: inherit` across all agents — never changed through 5 phases
- Flat orchestration enforced — only signe.md spawns subagents
- Self-contained agent prompts — subagents only receive their system prompt
- Direct cp deployment to `~/.claude/`
- Preset auto-detection from query keywords (researcher, designer patterns)
- Quality gate: PASS (no critical/high + >80%), WARN (no critical + high or 50-80%), FAIL (any critical or <50%)

### Integration Points
- `signe/agents/signe.md` — Major updates: workflow chaining logic, GSD awareness, proactive behaviors
- `signe/skills/` — Likely new `signe/SKILL.md` or `signe-workflow/SKILL.md` for `/signe` entry point
- `signe/rules/signe-delegation.md` — Phase 6 routing updates, `/signe` workflow entry
- `signe/rules/signe-safety.md` — Revise "GSD files off-limits" constraint for controlled GSD integration
- `signe/CLAUDE.md` — Mode table: `/signe` moves from (Phase 6) to Available
- `~/.claude/settings.json` — Any new permission patterns for GSD integration
- `~/.claude/` — Deployment target (file drop, settings merge)

### Research Flags to Resolve
- "GSD cross-contamination prevention needs validation in Phase 6" (STATE.md)
- "Context handoff patterns need measurement" (STATE.md, originally flagged Phase 3)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 06-workflow-gsd-integration*
*Context gathered: 2026-03-08*
