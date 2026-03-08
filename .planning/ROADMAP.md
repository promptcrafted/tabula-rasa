# Roadmap: Signe

## Overview

Signe is built bottom-up: foundation files and naming conventions first, then individual specialist modes (research, planning, design, oversight) each validating the Command -> Agent -> Skill architecture, and finally workflow integration that chains all modes together with GSD orchestration and chief-of-staff personality. Each phase delivers a coherent, independently verifiable capability. The flat orchestrator constraint (no nested subagent spawning) shapes every phase -- the main `signe.md` thread owns all delegation.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation** - Global installation skeleton with CLAUDE.md, settings.json, rules, hooks, and naming conventions (completed 2026-03-08)
- [ ] **Phase 2: Research Mode** - Multi-source research agent with confidence scoring, iterative refinement, and structured output
- [ ] **Phase 3: Planning Mode** - Goal decomposition agent with dependency mapping, requirements extraction, and scope management
- [ ] **Phase 4: Design Modes** - Four design presets (architecture, UI/UX, agent, product) under a single design skill
- [ ] **Phase 5: Oversight + Memory** - Code review agent with quality gates, progress tracking, and subagent methodology with persistent playbook
- [ ] **Phase 6: Workflow + GSD Integration** - Full workflow chaining, GSD orchestration, maker-checker loops, and chief-of-staff behaviors

## Phase Details

### Phase 1: Foundation
**Goal**: Signe is globally installed at `~/.claude/` with working infrastructure that all subsequent agents and skills build on
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04, INFRA-05, INFRA-06, INFRA-07, INFRA-10
**Success Criteria** (what must be TRUE):
  1. Running any `signe-` skill from any project folder resolves to the global `~/.claude/` installation without per-project setup
  2. A test skill invocation spawns a subagent that can read files and return structured output, confirming Command -> Agent -> Skill architecture works end-to-end
  3. `settings.json` auto-approves `Agent(signe-*)` and `Skill(signe-*)` patterns without manual permission prompts
  4. Hook scripts (Node.js) execute on SubagentStart/Stop lifecycle events and produce observable log output on Windows
  5. CLAUDE.md is under 100 lines with critical instructions in the first 10 lines, and overflow lives in `.claude/rules/` files
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md -- Core identity and rules: CLAUDE.md, rules files, lifecycle hook, memory directory
- [x] 01-02-PLAN.md -- Agents and settings: signe.md orchestrator, signe-test-agent, merged settings.json
- [x] 01-03-PLAN.md -- Health check skill and end-to-end deployment validation

### Phase 2: Research Mode
**Goal**: Users can invoke deep-dive research that orchestrates multiple sources, scores confidence, and produces structured findings
**Depends on**: Phase 1
**Requirements**: RSRCH-01, RSRCH-02, RSRCH-03, RSRCH-04, RSRCH-05, RSRCH-06, RSRCH-07
**Success Criteria** (what must be TRUE):
  1. User invokes `/signe-research` and Signe spawns `signe-researcher` agent that performs multi-source search across available MCP tools (Brave, Tavily, Exa, Context7, arxiv)
  2. Research output is structured Markdown with inline citations, source URLs, confidence levels (HIGH/MEDIUM/LOW), and publication dates
  3. Researcher performs iterative refinement -- reads initial results, identifies gaps, runs follow-up queries until topic is covered or turn limit is hit
  4. Domain-specific presets (ecosystem survey, feasibility check, comparison, state-of-the-art review) produce appropriately scoped output
  5. Researcher reads actual documents via WebFetch/arxiv/Context7 rather than relying only on search result snippets
**Plans**: 2 plans

Plans:
- [x] 02-01-PLAN.md -- Research agent and skill: signe-researcher.md with full methodology, signe-research SKILL.md with preset routing
- [ ] 02-02-PLAN.md -- Integration, deployment, and end-to-end validation: update CLAUDE.md/signe.md/delegation, deploy to ~/.claude/, human-verify

### Phase 3: Planning Mode
**Goal**: Users can invoke structured planning that decomposes goals into ordered, dependency-aware phases with verifiable acceptance criteria
**Depends on**: Phase 2
**Requirements**: PLAN-01, PLAN-02, PLAN-03, PLAN-04, PLAN-05, PLAN-06, PLAN-07
**Success Criteria** (what must be TRUE):
  1. User invokes `/signe-plan` and Signe spawns `signe-planner` agent that produces a phased decomposition with dependencies and rationale
  2. When research output exists (FEATURES.md, STACK.md, PITFALLS.md), planner extracts and incorporates requirements from it automatically
  3. Each milestone in the plan has specific, verifiable acceptance criteria -- not vague goals
  4. Every plan explicitly states what is in scope and out of scope with reasoning for each boundary
  5. Phase ordering includes explicit rationale based on dependencies, risk, and value delivery
**Plans**: TBD

Plans:
- [ ] 03-01: TBD
- [ ] 03-02: TBD

### Phase 4: Design Modes
**Goal**: Users can invoke four design presets (system architecture, UI/UX, agent design, product design) through a single design skill, each producing structured deliverables
**Depends on**: Phase 3
**Requirements**: ARCH-01, ARCH-02, ARCH-03, ARCH-04, ARCH-05, ARCH-06, UIUX-01, UIUX-02, UIUX-03, UIUX-04, UIUX-05, AGNT-01, AGNT-02, AGNT-03, AGNT-04, AGNT-05, PROD-01, PROD-02, PROD-03, PROD-04
**Success Criteria** (what must be TRUE):
  1. User invokes `/signe-design` with an architecture preset and receives component boundaries, data flow diagrams, API contracts, ADRs, and file/folder structure specifications
  2. User invokes `/signe-design` with a UI/UX preset and receives user flow maps, component hierarchy, wireframes (HTML or text specs), and accessibility requirements
  3. User invokes `/signe-design` with an agent preset and receives complete YAML frontmatter agent definitions with structured prompts, tool allowlists, and packaged skills
  4. User invokes `/signe-design` with a product preset and receives user stories with acceptance criteria, prioritized feature list (MoSCoW), and end-to-end experience maps
  5. All four presets route through a single `/signe-design` skill entry point that spawns the `signe-designer` agent with preset-specific context
**Plans**: TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD
- [ ] 04-03: TBD
- [ ] 04-04: TBD

### Phase 5: Oversight + Memory
**Goal**: Users can invoke code review and quality verification that compares implementation against plans, and Signe systematically builds a persistent knowledge playbook from validated agent patterns
**Depends on**: Phase 4
**Requirements**: OVRS-01, OVRS-02, OVRS-03, OVRS-04, OVRS-05, OVRS-06, METH-01, METH-02, METH-03, METH-04, METH-05
**Success Criteria** (what must be TRUE):
  1. User invokes `/signe-oversee` and receives multi-lens code review with findings organized by security, performance, correctness, test coverage, and style
  2. Overseer compares implementation against plan acceptance criteria and produces a gap report with specific file/line references and severity levels
  3. Overseer tracks progress (completed vs remaining milestones, blockers, remaining work estimate) and enforces quality gates that block phase progression on failure
  4. Signe researches model best practices before designing new agent prompts, dry-run tests agents with sample tasks, and validates output quality before banking patterns
  5. Validated agent patterns are persisted in MEMORY.md topic files with model, task type, prompt pattern, and success/failure notes -- accessible across sessions
**Plans**: TBD

Plans:
- [ ] 05-01: TBD
- [ ] 05-02: TBD
- [ ] 05-03: TBD

### Phase 6: Workflow + GSD Integration
**Goal**: Signe chains all modes into coherent end-to-end workflows, orchestrates GSD in project subfolders, and operates as a proactive chief of staff
**Depends on**: Phase 5
**Requirements**: INFRA-08, INFRA-09, CHST-01, CHST-02, CHST-03, CHST-04, CHST-05
**Success Criteria** (what must be TRUE):
  1. User can run a full research -> plan -> design -> oversee pipeline where each mode's output feeds the next mode's input without manual handoff
  2. GSD workflows run in project subfolders (e.g., `project/.planning/`) and path validation hooks prevent cross-contamination between projects
  3. Signe proactively identifies risks, summarizes project status at milestones, and recommends next actions based on current state
  4. Maker-checker loops work end-to-end -- design agent produces, review agent critiques, and iteration continues until quality gate passes
  5. Mode-aware context handoff documents are generated when transitioning between workflow stages, tailored to the receiving mode
**Plans**: TBD

Plans:
- [ ] 06-01: TBD
- [ ] 06-02: TBD
- [ ] 06-03: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | Complete   | 2026-03-08 |
| 2. Research Mode | 0/2 | Not started | - |
| 3. Planning Mode | 0/2 | Not started | - |
| 4. Design Modes | 0/4 | Not started | - |
| 5. Oversight + Memory | 0/3 | Not started | - |
| 6. Workflow + GSD Integration | 0/3 | Not started | - |
