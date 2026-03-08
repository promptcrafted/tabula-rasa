# Project Research Summary

**Project:** Signe -- Global Claude Code Agent Package
**Domain:** AI Chief of Staff / Claude Code configuration package
**Researched:** 2026-03-07
**Confidence:** HIGH

## Executive Summary

Signe is a pure Claude Code configuration package -- no frameworks, no dependencies, no build tools. It lives entirely at `~/.claude/` as a collection of Markdown files with YAML frontmatter, Node.js hook scripts, and JSON settings. The architecture follows the native Command -> Agent -> Skill three-tier hierarchy where skills serve as entry points (slash commands), agents are specialized subagent workers, and the main Signe orchestrator chains them into coherent workflows (research -> plan -> design -> oversee). Every component uses the `signe-` prefix to prevent name collisions with project-level definitions. All agents use `memory: user` scope for cross-project persistence. Claude Code v2.1.71 confirmed locally with all required features available.

The recommended approach is to build bottom-up: foundation files first (CLAUDE.md, settings.json, rules), then core skills with methodology, then individual agents, then the orchestrator that ties them together, and finally GSD integration and hook-based quality gates. The single hardest architectural constraint is that subagents cannot spawn subagents -- Signe must be a flat orchestrator where the main thread owns all delegation. The second hardest constraint is context budget -- Signe's skills, rules, memory, and agent descriptions all compete for finite attention, and the "may or may not be relevant" disclaimer on CLAUDE.md content means instructions degrade under load.

The primary risk mitigation strategy is: use hooks for enforcement (deterministic, cannot be ignored), subagents for isolation (each gets its own 200K context window), and skills for lazy-loading (descriptions at startup, full content on invocation). Reserve CLAUDE.md and rules for guidance that can gracefully degrade. Budget total instruction count under 150 per session. Validate with `/context` command early and often.

## Stack Recommendations

Signe is not a software project with npm dependencies. It is a filesystem convention package using Claude Code's native extension points. See [STACK.md](./STACK.md) for full specification.

**Core technologies:**
- **Markdown + YAML frontmatter:** Agent definitions, skill definitions, rules, memory -- the sole configuration format for all Claude Code extensions
- **Node.js hook scripts:** Cross-platform lifecycle automation. Node.js is guaranteed on every Claude Code installation; bash/python are not. Use `JSON.parse(stdin)` pattern for all hooks
- **JSON settings:** `~/.claude/settings.json` for permissions, hook registration, and environment variables. Array-valued settings merge across scopes
- **MCP servers:** Already configured in Minta's environment (brave-search, tavily, exa, context7, arxiv, etc.). Signe inherits all user-configured MCP servers automatically -- no additional setup needed

**Critical version requirement:** Claude Code 2.1.71+ (verified locally). Agent frontmatter, skills system, and 17-event hook lifecycle all confirmed available.

**What NOT to use:** Custom CLI/binary, external databases, Python or bash hook scripts, `.claude/commands/` (deprecated in favor of skills), agents spawning agents, agent teams for sequential work, CLAUDE.md over 200 lines.

## Table Stakes Features

Features without which Signe provides no value over raw Claude Code usage. See [FEATURES.md](./FEATURES.md) for the complete landscape.

- **Global installation** at `~/.claude/` with Command -> Agent -> Skill architecture
- **Research mode** with multi-source search orchestration, source confidence scoring, iterative refinement, structured output with citations, and domain-specific research patterns
- **Planning mode** with goal decomposition, dependency mapping, requirements extraction from research output, milestone definition with acceptance criteria, and explicit scope management
- **Design mode** covering system architecture (component boundaries, data flow, API contracts), agent design (YAML generation, prompt engineering, tool scoping, skill packaging), and product design (user stories, feature scoping, experience mapping)
- **Oversight mode** with multi-lens code review, gap detection against plan, progress tracking, quality gate enforcement, and actionable feedback generation
- **Full workflow chaining** where output of each mode feeds input of the next
- **Native Claude Code memory** (MEMORY.md) with 200-line discipline and topic files for overflow

## Key Differentiators

What makes Signe special compared to basic Claude Code usage or other agent packages:

- **Subagent methodology:** research -> plan -> dry-run -> validate -> bank working patterns. No other agent package systematically tests prompts before deploying them
- **Agent playbook memory:** Persistent knowledge of what works per LLM model, getting better over time. Stored in `agent-memory/signe/model-playbook.md`
- **Proactive complexity management:** Chief of staff personality that surfaces risks, identifies blockers, summarizes status, and recommends next actions -- not a passive assistant
- **Maker-checker loops:** Design agent produces, review agent critiques, iterate until quality gate passes
- **Hooks-based quality gates:** Exit code 2 from hooks blocks task completion. Deterministic enforcement, not prompt-based
- **Mode-aware context handoff:** Structured handoff documents tailored to the receiving mode when transitioning between workflow stages
- **Progressive knowledge distillation:** Raw research -> structured findings -> actionable decisions -> validated patterns (three-stage memory evolution)

**Defer to v2+:** Agent teams integration (experimental), cross-project pattern recognition (let memory accumulate naturally), model-aware prompt optimization (requires testing data), UI/UX wireframe generation (most specialized, least critical)

## Architecture Overview

Signe follows a flat orchestration model dictated by Claude Code's constraint that subagents cannot spawn subagents. The main `signe.md` agent acts as the central coordinator, spawning specialized agents sequentially or in parallel depending on task dependencies. Each subagent gets its own context window, preventing the starvation that would occur if a single session ran all four modes. See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full system diagram.

**Component structure:**

1. **CLAUDE.md + rules/** -- Global personality, delegation rules, safety constraints. Loaded every session. Must stay under 100 lines each to mitigate instruction undermining
2. **settings.json** -- Permissions (auto-approve `Agent(signe-*)`, `Skill(signe-*)`), hook registration (SubagentStart/Stop lifecycle tracking), environment variables
3. **signe.md (orchestrator agent)** -- Main routing agent. Decides which specialist to spawn based on user intent. Chains multi-step workflows. Only component that spawns subagents
4. **Specialist agents** -- signe-researcher (read-only), signe-planner (read-only), signe-designer (read+write), signe-overseer (read-only). Each preloads only its relevant skills via `skills:` frontmatter
5. **Skills** -- Reusable methodology modules: signe-research, signe-plan, signe-design, signe-oversee, signe-workflow, signe-memory-curation, signe-model-knowledge, signe-gsd
6. **agent-memory/** -- User-scope persistent knowledge. Each agent has MEMORY.md (<200 lines) with topic files. Model playbook is the core differentiating knowledge asset
7. **hooks/** -- Node.js lifecycle scripts: PreToolUse for path validation, SubagentStart/Stop for tracking, Stop for memory curation prompts

**Build order (from ARCHITECTURE.md):**
Foundation (CLAUDE.md, settings, rules) -> Core Skills -> Primary Agents -> Orchestrator -> Advanced Agents -> GSD Integration -> Dry-Run Validation

## Critical Pitfalls

Top pitfalls that will cause failure if not addressed. See [PITFALLS.md](./PITFALLS.md) for the full list of 16 identified risks.

1. **Instruction undermining via "may or may not be relevant"** -- CLAUDE.md content is wrapped in a system disclaimer telling the model to treat it as optional. Instructions degrade over long sessions, especially after compaction. Prevention: keep files under 100 lines, front-load critical instructions in first 10 lines, use hooks for must-happen behavior, split into narrowly-scoped rules/ files.

2. **Instruction overload causes uniform degradation** -- Frontier models follow ~150-200 instructions consistently. A comprehensive agent package with 4 modes, 8+ agents, 10+ skills, memory, and workflow protocols can exceed this budget. Everything gets slightly worse with no single clear failure. Prevention: lazy-load skills (descriptions only at startup), preload only relevant skills per agent, budget total instructions under 150, audit with `/context`.

3. **Subagents cannot spawn subagents (flat architecture required)** -- Hard constraint. The "chief of staff delegates to specialist who delegates to sub-specialist" pattern is impossible. Prevention: flat orchestrator, all spawning from main thread, use skills (not subagents) for shared behavior that runs in caller's context.

4. **Context window starvation from system overhead** -- System prompt, tool definitions, MCP schemas, memory, skill descriptions consume 30-40K tokens before conversation starts. Multi-step workflows risk compaction mid-flow. Prevention: use subagents aggressively (each gets own 200K context), design workflows so each phase completes in a subagent returning concise summaries, audit overhead with `/context`.

5. **Permission escalation via bypassPermissions** -- If parent runs with bypass mode, ALL subagents inherit it and it cannot be overridden. Research agent that should be read-only gets full write access. Prevention: never run Signe with bypass, explicit tool allowlists on every agent, `disallowedTools` as belt-and-suspenders.

6. **Memory staleness** -- MEMORY.md accumulates stale data over sessions. First 200 lines hard limit means stale entries push out validated learnings. Prevention: explicit curation instructions, MEMORY.md as index with topic files for details, PostToolUse hook warning at 150 lines, date stamps and confidence levels on entries.

## Roadmap Implications

### Phase 1: Foundation

**Rationale:** Everything depends on this. CLAUDE.md, settings.json, rules, and naming conventions establish the environment that all subsequent components live in. Getting the instruction budget and hook infrastructure right here prevents cascading problems.

**Delivers:** Working `~/.claude/` skeleton with global instructions, permissions, hook scripts (Node.js), and `signe-` namespace convention.

**Features addressed:** Global installation, CLAUDE.md architecture, rules system, settings.json, hook infrastructure

**Pitfalls avoided:** #1 (instruction undermining), #7 (Windows hooks), #8 (name collisions), #14 (exit codes), #16 (additive CLAUDE.md)

### Phase 2: Research Mode

**Rationale:** Most independently valuable mode. No dependency on other modes. Exercises the full Agent -> Skill pattern, validates subagent spawning, and produces artifacts that downstream modes consume.

**Delivers:** Working `/signe-research` skill and `signe-researcher` agent with multi-source search, confidence scoring, iterative refinement, structured output.

**Features addressed:** All 6 research table stakes, Command -> Agent -> Skill validation, MCP tool orchestration

**Pitfalls avoided:** #3 (flat architecture), #5 (permission model -- read-only allowlist), #10 (description misuse)

### Phase 3: Planning + Design Modes

**Rationale:** Planning consumes research output. Design modes consume planning output. Grouping validates workflow chaining and context handoff.

**Delivers:** Working `/signe-plan` and `/signe-design` skills. Goal decomposition, dependency mapping, milestone definition. System architecture, agent design, product design.

**Features addressed:** All 6 planning table stakes, design table stakes (architecture, agent, product), workflow chaining

**Pitfalls avoided:** #2 (instruction overload -- each agent preloads only its skills), #6 (context starvation -- subagent isolation), #15 (result bloat)

### Phase 4: Oversight + Memory System

**Rationale:** Oversight requires completed implementations to review and plans to compare against. Memory curation needs agents generating data before it can be validated.

**Delivers:** Working `/signe-oversee` skill. Multi-lens code review, gap detection, progress tracking. Memory curation protocol and hooks. Agent playbook.

**Features addressed:** All 5 oversight table stakes, agent playbook memory, hooks-based quality gates

**Pitfalls avoided:** #4 (memory staleness), #9 (agent drift -- checkpoint hooks), #12 (non-determinism -- variance-tolerant evaluation)

### Phase 5: Workflow Integration + GSD

**Rationale:** Full pipeline chaining and GSD integration require all individual modes working and tested. This connects everything.

**Delivers:** Full R->P->D->O pipeline, GSD orchestrator, cross-contamination prevention, maker-checker loops, chief-of-staff experience.

**Features addressed:** Workflow chaining, GSD orchestration, maker-checker loops, proactive complexity management, subagent methodology

**Pitfalls avoided:** #11 (GSD cross-contamination -- path validation hooks), #9 (agent drift -- fresh subagent per phase)

### Phase Ordering Rationale

- Foundation first because every component depends on CLAUDE.md, settings, hooks, naming
- Research before Planning because planning consumes research output
- Planning and Design together because design consumes planning output and they share the chaining pattern
- Oversight after Design because it compares implementation to plan -- needs real artifacts
- GSD last because it orchestrates across all modes, touching every component

### Research Flags

**Needs deeper research during planning:**
- **Phase 2 (Research):** MCP server inheritance in subagents -- test empirically how user-level MCP configs interact with subagent tool restrictions
- **Phase 3 (Planning + Design):** Context handoff patterns -- measure how much context can be passed between sequential subagent invocations
- **Phase 5 (Workflow + GSD):** GSD cross-contamination prevention -- validate hooks across multiple simultaneous projects

**Standard patterns (skip deep research):**
- **Phase 1 (Foundation):** All patterns verified against official docs. Straightforward application of documented conventions.
- **Phase 4 (Oversight + Memory):** Memory system well-documented. Curation is application of documented 200-line limit and topic file architecture.

## Open Questions

1. **Optimal subagent return length:** Balance between concise summaries (saves main context) and detailed results (preserves nuance)? Needs empirical testing.
2. **Memory curation trigger:** Automatic (PostToolUse hook) or explicit (user invokes `/signe-curate`)? Auto-curation risks modifying memory at inopportune times.
3. **Model selection per agent:** Should researcher use Sonnet (cheaper) or inherit parent model? Cost vs quality tradeoff needs data.
4. **Parallel research agent count:** How many competing-hypothesis researchers before coordination overhead exceeds benefit? Literature suggests 3-5 but needs Signe-specific validation.
5. **Chief of staff proactivity level:** Too passive = no value over raw Claude Code. Too proactive = annoying. Tuning needed.
6. **Plugin conversion path:** If Signe is distributed to other users, converting from standalone `~/.claude/` to plugin requires namespace changes. Documented but not urgent.
7. **Agent teams readiness:** Experimental today with known limitations (no session resumption, shutdown issues, higher token cost). Monitor Anthropic releases. Architecture supports layering on later.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All file formats, frontmatter fields, hook events verified against official Claude Code docs (March 2026). v2.1.71 confirmed locally. |
| Features | HIGH | Table stakes from competitive analysis and official capabilities. Differentiators from PROJECT.md requirements. Dependency tree clear. |
| Architecture | HIGH | Flat orchestrator pattern, no-nesting constraint, skill loading, memory scopes all verified. Reference repo validates pattern. |
| Pitfalls | HIGH | 6 critical + 6 moderate + 4 minor pitfalls. Critical pitfalls verified via official docs and community reports. |

**Overall confidence:** HIGH

### Gaps to Address

- **MCP server inheritance in subagents:** Confirmed in docs, but specific configuration interaction needs empirical validation in Phase 2
- **Context window measurement:** Theoretical 30-40K system overhead needs validation with `/context` after full installation. May require adjusting skill count
- **Windows path handling:** All hooks use Node.js, but `~/.claude/` expansion and absolute vs relative paths need testing on Windows cmd.exe
- **Skill description budget:** Total descriptions must stay under ~2% of context window (~16K chars fallback). With 8+ skills, each description must be carefully budgeted

## Sources

### Primary (HIGH confidence)
- [Claude Code Skills](https://code.claude.com/docs/en/skills) -- Skill definition, frontmatter, invocation
- [Claude Code Hooks](https://code.claude.com/docs/en/hooks) -- 17 lifecycle events, handler types, exit codes
- [Claude Code Settings](https://code.claude.com/docs/en/settings) -- Hierarchy, array merging, permissions
- [Claude Code Memory](https://code.claude.com/docs/en/memory) -- CLAUDE.md, auto memory, 200-line limit, scopes
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents) -- Frontmatter, no-nesting, memory, hooks
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins) -- Plugin structure, namespacing
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) -- Experimental status, limitations

### Secondary (MEDIUM confidence)
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) -- Reference implementation
- [Command -> Agent -> Skill Pattern](https://deepwiki.com/shanraisshan/claude-code-best-practice/6.1-command-agent-skills-pattern) -- Architecture deep dive
- [Claude Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) -- First principles analysis

### Tertiary (LOW confidence)
- Agent drift research (general multi-agent systems) -- 42% task success reduction after ~73 interactions. Not Claude Code-specific.

---
*Research completed: 2026-03-07*
*Ready for roadmap: yes*
