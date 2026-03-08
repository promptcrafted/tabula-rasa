# Requirements: Signe

**Defined:** 2026-03-07
**Core Value:** Signe must chain research → plan → design → oversee in a single coherent workflow, delegating to specialized subagents she designs, tests, and validates herself.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Infrastructure

- [ ] **INFRA-01**: Signe installs globally at `~/.claude/` and is available in any project folder without per-project config
- [ ] **INFRA-02**: Signe follows Command → Agent → Skill architecture with skills as entry points, agents as specialists, and skills preloaded per agent
- [ ] **INFRA-03**: All agent/skill/command names use `signe-` prefix to prevent collision with project-level definitions
- [ ] **INFRA-04**: CLAUDE.md stays under 100 lines with critical instructions in the first 10 lines, splitting overflow into `.claude/rules/` files
- [ ] **INFRA-05**: `settings.json` auto-approves `Agent(signe-*)` and `Skill(signe-*)` with explicit tool allowlists per agent
- [ ] **INFRA-06**: Hook scripts use Node.js for cross-platform compatibility (Windows/macOS/Linux)
- [ ] **INFRA-07**: Signe uses native Claude Code memory (`memory: user`) with MEMORY.md under 200 lines and topic files for overflow
- [ ] **INFRA-08**: Full workflow chaining — output of each mode (research → plan → design → oversee) feeds input of the next
- [ ] **INFRA-09**: GSD workflows run in project subfolders (e.g., `project/.planning/`) to prevent cross-contamination between projects
- [ ] **INFRA-10**: Signe orchestrator (`signe.md`) is a flat orchestrator — all subagent spawning happens from the main thread only

### Research Mode

- [ ] **RSRCH-01**: User can invoke research via `/signe-research` skill and Signe spawns `signe-researcher` agent
- [ ] **RSRCH-02**: Signe-researcher orchestrates parallel searches across available MCP tools (Brave, Tavily, Exa, Context7, arxiv)
- [ ] **RSRCH-03**: Research findings are tagged with confidence levels (HIGH/MEDIUM/LOW) based on source hierarchy (official docs > verified search > unverified)
- [ ] **RSRCH-04**: Research agent performs iterative refinement — reads results, identifies gaps, spawns follow-up queries until sufficient or limit hit
- [ ] **RSRCH-05**: Research output is structured Markdown with inline citations, source URLs, confidence levels, and publication dates
- [ ] **RSRCH-06**: Domain-specific research presets available (ecosystem survey, feasibility check, comparison, state-of-the-art review)
- [ ] **RSRCH-07**: Research agent reads actual documents and papers (WebFetch, arxiv, Context7) rather than just search result snippets

### Planning Mode

- [ ] **PLAN-01**: User can invoke planning via `/signe-plan` skill and Signe spawns `signe-planner` agent
- [ ] **PLAN-02**: Planner decomposes high-level goals into ordered phases with dependencies, deliverables, and rationale
- [ ] **PLAN-03**: Planner maps explicit dependencies between tasks ("Phase B requires Phase A output")
- [ ] **PLAN-04**: Planner extracts requirements from research output (FEATURES.md, STACK.md, PITFALLS.md) when available
- [ ] **PLAN-05**: Each milestone has specific, verifiable acceptance criteria
- [ ] **PLAN-06**: Planner provides explicit rationale for phase ordering based on dependencies, risk, and value
- [ ] **PLAN-07**: Every plan explicitly states what is in scope and out of scope with reasoning

### Design Mode — System Architecture

- [ ] **ARCH-01**: User can invoke system design via `/signe-design` skill (architecture preset) and Signe spawns `signe-designer` agent
- [ ] **ARCH-02**: Designer defines component boundaries (name, responsibility, interface, dependencies) for each system component
- [ ] **ARCH-03**: Designer documents data flow (input → processing → output) for each major flow with format/protocol notes
- [ ] **ARCH-04**: Designer specifies API contracts (input types, output types, error cases, versioning) for each component boundary
- [ ] **ARCH-05**: Designer produces technology decision records (ADRs) with decision, context, alternatives, rationale, consequences
- [ ] **ARCH-06**: Designer specifies file/folder structure with purpose annotations

### Design Mode — UI/UX

- [ ] **UIUX-01**: User can invoke UI/UX design via `/signe-design` skill (UI/UX preset)
- [ ] **UIUX-02**: Designer maps user flows (entry point → decision points → outcomes) for each major user journey
- [ ] **UIUX-03**: Designer specifies component hierarchy (atomic → composite → page-level) with props/variants
- [ ] **UIUX-04**: Designer generates wireframes (HTML or detailed text specs) for key screens
- [ ] **UIUX-05**: Designer specifies accessibility requirements (WCAG level, keyboard nav, screen reader) per component

### Design Mode — Agent Design

- [ ] **AGNT-01**: User can invoke agent design via `/signe-design` skill (agent preset)
- [ ] **AGNT-02**: Designer generates complete YAML frontmatter agent definitions (name, description, tools, model, permissionMode, maxTurns, skills, memory, hooks)
- [ ] **AGNT-03**: Designer applies structured prompt engineering methodology (role definition, context injection, output format, guardrails, examples)
- [ ] **AGNT-04**: Designer selects appropriate tools and scopes permissions per agent (explicit allowlists, disallowedTools)
- [ ] **AGNT-05**: Designer packages reusable knowledge as skills with proper frontmatter and directory placement

### Design Mode — Product

- [ ] **PROD-01**: User can invoke product design via `/signe-design` skill (product preset)
- [ ] **PROD-02**: Designer generates user stories ("As a [persona], I want [action] so that [value]") with acceptance criteria
- [ ] **PROD-03**: Designer scopes and prioritizes features (MoSCoW or similar) with rationale for each priority level
- [ ] **PROD-04**: Designer maps end-to-end user experience across features with functional milestones

### Oversight Mode

- [ ] **OVRS-01**: User can invoke oversight via `/signe-oversee` skill and Signe spawns `signe-overseer` agent
- [ ] **OVRS-02**: Overseer performs multi-lens code review (security, performance, correctness, test coverage, style as separate passes)
- [ ] **OVRS-03**: Overseer compares implementation against plan acceptance criteria and flags gaps
- [ ] **OVRS-04**: Overseer tracks progress (completed vs remaining milestones, blockers, remaining work estimate)
- [ ] **OVRS-05**: Overseer enforces quality gates per phase — pass/fail with criteria, blocks progress on failure
- [ ] **OVRS-06**: Overseer produces actionable feedback (specific file, line, issue, severity, recommended fix)

### Subagent Methodology

- [ ] **METH-01**: Signe researches best practices for each model/agent type before designing prompts
- [ ] **METH-02**: Signe drafts agent prompts following structured methodology (not ad-hoc)
- [ ] **METH-03**: Signe dry-run tests new agents with sample tasks and evaluates output quality
- [ ] **METH-04**: Signe validates tested agents against quality criteria before banking as working patterns
- [ ] **METH-05**: Signe banks validated agent patterns in MEMORY.md topic files (model, task type, prompt pattern, success/failure notes)

### Chief of Staff Personality

- [ ] **CHST-01**: Signe proactively identifies risks and surfaces blockers without being asked
- [ ] **CHST-02**: Signe summarizes project status at natural milestones
- [ ] **CHST-03**: Signe recommends next actions based on current project state
- [ ] **CHST-04**: Signe uses maker-checker loops — design agent produces, review agent critiques, iterate until quality gate passes
- [ ] **CHST-05**: Signe generates mode-aware context handoff documents when transitioning between workflow stages

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Advanced Intelligence

- **ADV-01**: Cross-project pattern recognition (recognizing when problem in project A was solved in project B)
- **ADV-02**: Model-aware prompt optimization (adapting prompts based on accumulated model-specific knowledge)
- **ADV-03**: Agent teams integration (when experimental flag is removed and Windows support improves)

### Advanced Memory

- **MEM-01**: Automatic memory curation via PostToolUse hooks
- **MEM-02**: Progressive knowledge distillation (raw research → structured findings → actionable decisions → validated patterns)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Custom CLI tool or framework | Must use pure Claude Code `~/.claude/` structure per reference repo best practices |
| External database for memory | Must use native MEMORY.md per Claude Code conventions |
| GUI or web interface | CLI agent only — GUIs require hosting, maintenance |
| Per-project installation | Signe is global by design — per-project copies create version drift |
| Replacing vexp | Signe orchestrates, she doesn't replace existing tools |
| Autonomous execution without checkpoints | Expensive and risky — explicit checkpoint/approval gates required |
| Nested agent spawning | Claude Code does not support subagents spawning subagents |
| Model training or fine-tuning | Out of scope — bank prompt patterns as knowledge, not model weights |
| Over-parallelization (>5 subagents) | Diminishing returns — coordination overhead exceeds benefit |
| Generic role agents | Generic roles produce generic output — use feature-specific agents with concrete context |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| (To be populated by roadmapper) | | |

**Coverage:**
- v1 requirements: 48 total
- Mapped to phases: 0
- Unmapped: 48

---
*Requirements defined: 2026-03-07*
*Last updated: 2026-03-07 after initial definition*
