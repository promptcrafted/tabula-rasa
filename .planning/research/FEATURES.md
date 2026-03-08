# Feature Landscape

**Domain:** AI Chief of Staff Agent Package (Claude Code global agent)
**Researched:** 2026-03-07

## Table Stakes

Features users expect. Missing = Signe feels broken or pointless compared to just using Claude Code directly.

### Research Mode

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Multi-source web search orchestration | Deep research agents (OpenAI, Gemini, Perplexity) all do this. Users expect parallel searches across Brave, Tavily, Exa, Context7 | Med | Signe has all MCP tools available; the value is orchestrating them intelligently, not just calling one |
| Source confidence scoring | Every credible research tool attributes and ranks sources. Unattributed findings are useless | Low | Tag findings as HIGH/MEDIUM/LOW based on source hierarchy (official docs > verified search > unverified) |
| Iterative search refinement | Anthropic's own multi-agent research system uses multi-step search that adapts to findings. Single-pass search misses depth | Med | Lead agent reads results, identifies gaps, spawns follow-up queries. Loop until sufficient or limit hit |
| Structured output with citations | OpenAI Deep Research and Gemini Deep Research both produce structured reports with inline citations. Bare text without sources is unacceptable | Low | Markdown reports with source URLs, confidence levels, publication dates |
| Domain-specific research patterns | Different research tasks need different approaches (library evaluation vs architecture patterns vs market analysis) | Med | Pre-built research presets: ecosystem survey, feasibility check, comparison, state-of-the-art review |
| Paper and documentation crawling | Research agents must read actual docs and papers, not just search result snippets | Med | Use WebFetch for docs, arxiv MCP for papers, Context7 for library docs. Read and synthesize, don't just link |

### Planning Mode

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Goal decomposition into phases/milestones | Every project management tool does this. Planning without decomposition is just a wish list | Med | Break high-level goals into ordered phases with dependencies, deliverables, and rationale |
| Dependency mapping between tasks | Without dependencies, plans are flat lists. Users need to know what blocks what | Low | Explicit dependency graph: "Phase B requires Phase A output" |
| Requirements extraction from research | Planning mode must consume research output. If it ignores research findings, the pipeline is broken | Med | Parse FEATURES.md, STACK.md, PITFALLS.md etc. and translate into actionable requirements |
| Milestone definition with acceptance criteria | "Build auth" is not a milestone. "JWT auth with refresh tokens, tested, documented" is | Low | Each milestone gets specific, verifiable acceptance criteria |
| Phase ordering rationale | Users need to understand WHY this order, not just WHAT the order is. Decisions without reasoning are untrusted | Low | Explicit rationale for each ordering decision based on dependencies, risk, and value |
| Scope management (in/out of scope) | Scope creep is the primary planning failure mode. Explicit boundaries are essential | Low | Every plan document explicitly states what is in scope and what is not, with reasoning |

### Design Mode (System Architecture)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Component boundary definition | Architecture without boundaries is just a pile of code. Every architecture tool defines components | Med | Name, responsibility, interface, dependencies for each component |
| Data flow documentation | How data moves through the system is the most asked architecture question | Med | Input -> processing -> output for each major flow, with format/protocol notes |
| API contract specification | Components communicate through interfaces. Undefined interfaces cause integration hell | Med | Input types, output types, error cases, versioning for each boundary |
| Technology decision records | Architecture decisions without rationale get questioned and reversed. ADRs are industry standard | Low | Decision, context, alternatives considered, rationale, consequences |
| File/folder structure specification | Developers need to know where things go. Unspecified structure leads to inconsistency | Low | Explicit directory tree with purpose annotations |

### Design Mode (UI/UX)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| User flow mapping | UX without user flows is just decoration. Every UX process starts with flows | Med | Entry point -> decision points -> outcomes for each major user journey |
| Component hierarchy specification | Design systems require component structure. Without it, every developer makes different choices | Med | Atomic components -> composite -> page-level with props/variants |
| Wireframe generation or specification | Visual direction needs concrete artifacts, not just descriptions | High | Generate HTML wireframes (proven pattern in Claude Code ecosystem) or detailed text specs |
| Accessibility requirements | WCAG compliance is not optional in 2026. Missing accessibility is a liability | Low | WCAG level, keyboard nav requirements, screen reader requirements per component |

### Design Mode (Agent Design)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| YAML frontmatter agent definition generation | This is literally how Claude Code agents work. Cannot design agents without producing valid definitions | Low | Generate complete agent YAML: name, description, tools, model, permissionMode, maxTurns, skills, memory |
| Prompt engineering with structured methodology | Ad-hoc prompts fail. Reference repo shows Claude A designs, Claude B tests | Med | Role definition, context injection, output format, guardrails, examples |
| Tool selection and permission scoping | Agents need the right tools and nothing more. Over-permissioned agents waste tokens and create risk | Low | Explicit tool list per agent, permission rules, MCP server assignment |
| Skill packaging | Reusable knowledge/workflows that load on demand. Without skills, every agent starts from zero | Med | Markdown skill files with frontmatter, placed in correct directories |

### Design Mode (Product)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| User story generation | Product design without user stories is engineering without purpose | Low | "As a [persona], I want [action] so that [value]" with acceptance criteria |
| Feature scoping and prioritization | Product design must decide what to build first. Unprioritized lists are not product design | Med | MoSCoW or similar, with rationale for each priority level |
| Experience mapping | How does the user's experience flow across features? Isolated features feel disconnected | Med | End-to-end journey across features with emotional/functional milestones |

### Oversight Mode

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Code review with multi-lens analysis | Single-pass review misses categories. Specialist agents are the pattern | High | Security, performance, correctness, test coverage, style as separate review lenses |
| Gap detection against plan | If oversight can't compare implementation to plan, it's just code review, not project oversight | Med | Compare actual code/files against milestone acceptance criteria |
| Progress tracking | Oversight must answer "where are we?" not just "is this code good?" | Med | Track completed vs remaining milestones, flag blockers, estimate remaining work |
| Quality gate enforcement | Oversight without enforcement is just opinion. Gates must pass/fail with criteria | Med | Define quality gates per phase, check them, block progress on failure |
| Actionable feedback generation | "This code is bad" is not actionable. Specific file, line, issue, severity, and recommended fix for every finding | Low | Concrete, implementable feedback |

### Core Infrastructure

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Global installation at ~/.claude/ | The entire value proposition. Without global install, Signe is just another per-project config | Low | Commands, agents, skills, rules all at user scope. Available in any project folder |
| Command -> Agent -> Skill architecture | Proven pattern from reference repo. Separates entry points, specialists, and reusable knowledge cleanly | Med | Skills as entry points, agents as execution, skills as knowledge |
| Full workflow chaining (research -> plan -> design -> oversee) | Signe's core value is coherent pipelines, not isolated modes. Without chaining, she's 4 separate tools | High | Output of each mode feeds input of next. Context carries across the pipeline |
| GSD orchestration in subfolders | Prevents cross-contamination between projects. Without subfolder isolation, multi-project use breaks | Med | Run GSD workflows in project/.planning/ directories, not at global scope |
| Native Claude Code memory (MEMORY.md) | Claude Code has this built in. Not using it means losing cross-session learning | Low | User-scope MEMORY.md with 200-line discipline, topic files for overflow |

## Differentiators

Features that set Signe apart from basic Claude Code usage or other agent packages.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Subagent methodology (research -> plan -> dry-run -> validate -> bank) | No other agent package systematically tests prompts before deploying them | High | Research best practices for the model/task, draft prompt, test in sandbox, validate output, bank working patterns |
| Agent playbook memory | Persistent knowledge of what works per LLM model. Signe gets better over time | Med | Store validated agent patterns with model, success rate, failure modes in MEMORY.md topic files |
| Proactive complexity management (chief of staff personality) | Basic assistants wait for instructions. A chief of staff surfaces what matters, shields from noise | Med | Signe proactively identifies risks, surfaces blockers, summarizes status, recommends next actions |
| Cross-project pattern recognition | Global installation means Signe sees patterns across ALL projects | Med | Recognize when a problem in project A was solved in project B |
| Parallel subagent research with competing hypotheses | Multiple agents investigate different angles, challenge each other | High | Spawn 3-5 research subagents with different investigation angles, synthesize findings |
| Maker-checker loops for design outputs | Design outputs validated by separate checker agent before delivery | Med | Design agent produces, review agent critiques, iterate until quality gate passes |
| Mode-aware context handoff | When transitioning modes, Signe summarizes what matters for the next mode's specific needs | Med | Structured handoff document tailored to the receiving mode |
| Progressive knowledge distillation | Raw research -> structured findings -> actionable decisions -> validated patterns | Med | Three-stage memory evolution: Storage, Reflection, Experience |
| Hooks-based quality gates | Use Claude Code's hook system for deterministic enforcement | Med | Exit code 2 from hooks blocks task completion. Deterministic, not prompt-based |

## Anti-Features

Features to explicitly NOT build.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| Custom CLI tool or framework | Must use pure Claude Code ~/.claude/ structure. Custom CLIs add maintenance burden | Use native commands, agents, skills, and CLAUDE.md |
| External database for memory | Must use native MEMORY.md. External DBs add infrastructure | Use MEMORY.md with 200-line discipline and topic files |
| GUI or web interface | CLI agent only. GUIs require hosting, maintenance | All interaction through Claude Code CLI |
| Per-project installation or scaffolding | Signe is global by design. Per-project copies create version drift | Everything at ~/.claude/ user scope |
| Replacing vexp or other project tools | Signe orchestrates, she doesn't replace | Leverage vexp for codebase understanding, MCP tools for search |
| Autonomous execution without checkpoints | Fully autonomous agents that run 30+ minutes are expensive and risky | Explicit checkpoint/approval gates. Short bursts with human review |
| Nested agent teams | Claude Code does not support nested teams | Keep coordination hierarchy flat |
| Model training or fine-tuning | Out of scope per PROJECT.md | Bank prompt patterns as knowledge, not model weights |
| Over-parallelization (>5 subagents) | Diminishing returns. Coordination overhead exceeds benefit | 3-5 subagents maximum for research |
| Generic role agents ("QA Engineer", "Backend Dev") | Generic roles produce generic output | Feature-specific agents with concrete context |

## Feature Dependencies

```
Global installation (~/.claude/)
  -> Command -> Agent -> Skill architecture
    -> Research mode (standalone)
    -> Planning mode (can consume research output)
      -> Design mode - system architecture (consumes plan)
      -> Design mode - UI/UX (consumes plan + system arch)
      -> Design mode - agent design (consumes plan)
      -> Design mode - product (consumes plan)
    -> Oversight mode (compares implementation to plan)
  -> Native Claude Code memory (MEMORY.md)
    -> Agent playbook memory (builds on MEMORY.md)
    -> Cross-project pattern recognition (builds on memory)
  -> Subagent methodology
    -> Agent design mode (uses methodology to create agents)
    -> Maker-checker loops (applies methodology to design output)
  -> GSD orchestration in subfolders
    -> Full workflow chaining (chains across GSD phases)
  -> Hooks-based quality gates
    -> Quality gate enforcement in oversight
```

## MVP Recommendation

Build in this order based on dependencies and value:

**Phase 1: Foundation + Research**
1. Global installation at ~/.claude/ -- everything depends on this
2. Command -> Agent -> Skill architecture -- the structural pattern
3. Native Claude Code memory (MEMORY.md) -- cross-session learning
4. Research mode (all table-stakes features) -- most independently valuable mode
5. Structured output with citations -- research is useless without attribution

**Phase 2: Planning + Agent Design**
6. Planning mode (consumes research output) -- converts research into actionable plans
7. Design mode: agent design -- enables the subagent methodology
8. Subagent methodology (research -> plan -> dry-run -> validate -> bank)

**Phase 3: Design Modes**
9. Design mode: system architecture -- consumes plans
10. Design mode: product -- consumes plans
11. Design mode: UI/UX -- most specialized, least critical for early value

**Phase 4: Oversight + Polish**
12. Oversight mode (code review, gap detection, progress tracking)
13. Full workflow chaining -- connects all modes
14. GSD orchestration in subfolders
15. Hooks-based quality gates

**Defer:**
- Agent teams integration: experimental, known limitations, high token cost
- Model-aware prompt optimization: requires extensive testing data
- Cross-project pattern recognition: let Signe learn naturally first

## Sources

- [Claude Code Skills](https://code.claude.com/docs/en/skills) -- Skill invocation patterns
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents) -- Agent capability boundaries
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) -- Experimental status confirmed
- [Command -> Agent -> Skill Pattern](https://deepwiki.com/shanraisshan/claude-code-best-practice/6.1-command-agent-skills-pattern) -- Architecture reference
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) -- Reference repo
