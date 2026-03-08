# Architecture Patterns

**Domain:** Global Claude Code agent package (chief of staff orchestrator)
**Researched:** 2026-03-07
**Overall confidence:** HIGH (based on official Claude Code documentation verified March 2026)

## Recommended Architecture

Signe is a user-scoped Claude Code agent package living at `~/.claude/`. She follows the native Command -> Agent -> Skill three-tier hierarchy, using YAML frontmatter markdown files as the sole configuration format. No custom frameworks, no external databases -- pure `.claude/` filesystem conventions.

### System Diagram

```
~/.claude/                              (USER SCOPE - Available everywhere)
|
|-- CLAUDE.md                           (Global instructions, <200 lines)
|-- settings.json                       (Global permissions, hooks, env)
|
|-- agents/                             (Subagent definitions)
|   |-- signe.md                        (Chief of staff - main orchestrator)
|   |-- signe-researcher.md             (Deep investigation agent)
|   |-- signe-planner.md                (Project decomposition agent)
|   |-- signe-designer.md               (Architecture/UX/agent design agent)
|   |-- signe-overseer.md               (Code review & quality agent)
|   |-- signe-gsd-orchestrator.md       (GSD workflow coordinator)
|   `-- signe-playbook-curator.md       (Knowledge bank maintenance agent)
|
|-- skills/                             (Reusable knowledge modules)
|   |-- signe-research/SKILL.md         (How to conduct research)
|   |-- signe-plan/SKILL.md             (How to plan projects)
|   |-- signe-design/SKILL.md           (How to design systems/agents)
|   |-- signe-oversee/SKILL.md          (Quality verification workflow)
|   |-- signe-workflow/SKILL.md         (Full R->P->D->O pipeline)
|   |-- signe-gsd/SKILL.md             (GSD workflow patterns)
|   |-- signe-model-knowledge/SKILL.md  (Per-model prompt strategies)
|   `-- signe-memory-curation/SKILL.md  (MEMORY.md maintenance protocol)
|
|-- rules/                              (Always-loaded instructions)
|   |-- signe-personality.md            (Chief of staff voice and behavior)
|   |-- signe-delegation.md             (When/how to spawn subagents)
|   `-- signe-safety.md                 (What Signe must never do)
|
|-- agent-memory/                       (Persistent agent knowledge)
|   |-- signe/                          (user-scope memory for main agent)
|   |   |-- MEMORY.md                   (Index, <200 lines)
|   |   |-- model-playbook.md           (Per-model learned strategies)
|   |   |-- project-patterns.md         (Cross-project learnings)
|   |   `-- agent-recipes.md            (Tested agent configurations)
|   |-- signe-researcher/MEMORY.md
|   |-- signe-planner/MEMORY.md
|   |-- signe-designer/MEMORY.md
|   `-- signe-overseer/MEMORY.md
|
`-- hooks/                              (Hook scripts - Node.js for cross-platform)
    |-- signe-agent-lifecycle.js        (SubagentStart/Stop tracking)
    |-- signe-quality-gate.js           (PostToolUse validation)
    `-- signe-memory-curator.js         (Memory auto-curation)


PROJECT/.planning/                      (PROJECT SCOPE - Per-project GSD state)
|-- PROJECT.md
|-- ROADMAP.md
|-- STATE.md
|-- research/
|-- {phase}-CONTEXT.md
`-- {phase}-{n}-PLAN.md
```

### Component Boundaries

| Component | Responsibility | Communicates With | Scope |
|-----------|---------------|-------------------|-------|
| **CLAUDE.md** | Global personality, rules import, tool preferences | All agents (loaded at session start) | User |
| **settings.json** | Permissions, hooks config, env vars, model config | Claude Code runtime | User |
| **signe.md** (agent) | Main orchestrator, mode routing, workflow chaining | All other agents via Agent tool | User |
| **signe-researcher.md** (agent) | Deep investigation, web search, doc crawling | Returns findings to parent | User |
| **signe-planner.md** (agent) | Decomposition, roadmapping, requirements | Returns plans to parent | User |
| **signe-designer.md** (agent) | Architecture, UX, agent design, product design | Returns designs to parent | User |
| **signe-overseer.md** (agent) | Code review, quality checks, gap detection | Returns assessments to parent | User |
| **signe-gsd-orchestrator.md** (agent) | GSD workflow invocation in project dirs | GSD commands, project .planning/ | User |
| **signe-playbook-curator.md** (agent) | Knowledge curation, memory maintenance | agent-memory/ directories | User |
| **Skills** | Reusable methodology and knowledge | Injected into agents via `skills:` field | User |
| **Rules** | Always-active behavioral constraints | Loaded into every session automatically | User |
| **agent-memory/** | Persistent cross-session knowledge | Read/written by agents with `memory: user` | User |
| **hooks/** | Lifecycle automation scripts (Node.js) | Triggered by settings.json hook config | User |

## Orchestration Flow: Command -> Agent -> Skill

### Tier 1: Skills as Entry Points

Per official docs (March 2026), **skills have absorbed commands**. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work identically. Skills are recommended because they support directory structure with supporting files, `context: fork`, and `agent:` field.

**Recommendation:** Use skills exclusively for all entry points. Use `disable-model-invocation: true` for workflow skills that should only be invoked manually (like `/signe-research`, `/signe-plan`).

### Tier 2: Agents (Specialized Workers)

Agents are the core processing units. Each has:
- A focused system prompt (the markdown body)
- Tool restrictions (allowlist or denylist)
- Model selection (cheaper models for simple work)
- Preloaded skills (knowledge injected at startup)
- Memory scope (persistent learning across sessions)
- Optional hooks (scoped to agent lifecycle)

**Critical architectural constraint:** Subagents CANNOT spawn other subagents. Only the main thread (or an agent running via `claude --agent`) can spawn subagents. Signe's orchestration must be flat, not nested.

```
                        +---------------------+
                        |    User Prompt       |
                        +----------+----------+
                                   |
                        +----------v----------+
                        |  Signe (main agent)  |
                        |  via claude --agent  |
                        |  OR via Agent tool   |
                        +----------+----------+
                                   |
              +--------------------+--------------------+
              |                    |                    |
     +--------v-------+  +--------v-------+  +--------v-------+
     | signe-researcher|  | signe-planner  |  | signe-designer |
     | (read-only)     |  | (read-only)    |  | (read+write)   |
     | model: inherit  |  | model: inherit |  | model: inherit |
     | skills:         |  | skills:        |  | skills:        |
     |  - signe-       |  |  - signe-      |  |  - signe-      |
     |    research     |  |    plan        |  |    design      |
     | memory: user    |  | memory: user   |  | memory: user   |
     +----------------+  +----------------+  +----------------+
```

### Tier 3: Skills (Reusable Knowledge)

Skills operate in two distinct patterns:

**Preloaded Skills (Agent Skills):** Full content injected into agent's context at startup via `skills:` frontmatter. Agent receives complete methodology as part of its system prompt. Use for core methodology an agent always needs.

**On-Demand Skills (Standalone Skills):** Invoked via `/skill-name` or automatically by Claude when relevant. Only description is in context; full content loads when invoked. Use for situational knowledge.

```
Skill Loading Flow:

  Session Start
  |
  +-- All skill descriptions loaded into context
  |   (lightweight: name + description only)
  |   (budget: ~2% of context window, fallback 16K chars)
  |
  +-- Agent spawned with skills: [signe-research]
  |   |
  |   +-- Full SKILL.md content injected into agent
  |       (heavy: complete methodology text)
  |
  +-- User types /signe-oversee
      |
      +-- Full signe-oversee/SKILL.md loaded
          (on-demand, only when explicitly invoked)
```

## Multi-Mode Architecture

Signe operates in four primary modes. Mode switching is a prompt-level routing decision made by the main Signe agent based on user intent.

### Mode Definitions

| Mode | Primary Agent | Tools | Typical Output | Can Chain To |
|------|--------------|-------|----------------|--------------|
| **Research** | signe-researcher | Read, Grep, Glob, Bash, WebSearch, WebFetch, MCP tools | .planning/research/*.md | Planning |
| **Planning** | signe-planner | Read, Grep, Glob, Bash | .planning/ROADMAP.md, phase plans | Design, Execute |
| **Design** | signe-designer | Read, Write, Edit, Bash, Grep, Glob | Architecture docs, agent definitions, wireframes | Planning, Execute |
| **Oversight** | signe-overseer | Read, Grep, Glob, Bash | Review reports, gap analysis | Any mode |

### Workflow Chaining

Signe's core value is chaining modes into coherent workflows. The main agent orchestrates sequentially since subagents cannot spawn subagents:

```
Full Workflow: Research -> Plan -> Design -> Oversee

  Signe spawns signe-researcher  --> findings returned
  Signe spawns signe-planner     --> roadmap returned (using research findings)
  Signe spawns signe-designer    --> architecture returned (using plan)
  Signe spawns signe-overseer    --> review returned (checking everything)

Each subagent returns results to Signe's main context.
Signe passes relevant context to the next subagent.
```

**Important constraint:** Since subagent results return to the main context, long workflows can consume significant context. Use background agents for heavy operations. Consider explicit `/compact` between workflow stages.

### Delegation Decision Tree

```
User Request Arrives
|
+-- Is it simple/quick?
|   YES --> Signe handles directly (no subagent)
|
+-- Does it need deep investigation?
|   YES --> Spawn signe-researcher (read-only)
|
+-- Does it need project decomposition?
|   YES --> Spawn signe-planner (read-only)
|
+-- Does it need system/agent/UX design?
|   YES --> Spawn signe-designer (read+write)
|
+-- Does it need quality review?
|   YES --> Spawn signe-overseer (read-only)
|
+-- Does it need GSD workflow execution?
|   YES --> Spawn signe-gsd-orchestrator
|
+-- Does it need multi-step workflow?
    YES --> Chain: research -> plan -> design -> oversee
            (Sequential spawning, passing context between stages)
```

### Parallel vs Sequential Spawning

- **Parallel:** Use for independent research tasks (e.g., "research auth AND database options" spawns two researchers in background)
- **Sequential:** Use for dependent workflows (e.g., research findings feed into planning)
- **Background:** Use `background: true` for long-running tasks. Agent works independently and results return when complete

## Memory Architecture

### Three-Scope Memory System

| Scope | Location | Use Case |
|-------|----------|----------|
| `user` | `~/.claude/agent-memory/<agent>/` | Cross-project learnings (recommended default for Signe) |
| `project` | `.claude/agent-memory/<agent>/` | Project-specific knowledge (version-controlled) |
| `local` | `.claude/agent-memory-local/<agent>/` | Project-specific, private (gitignored) |

### Signe's Memory Layout

```
~/.claude/agent-memory/
|
|-- signe/                          (Main orchestrator memory)
|   |-- MEMORY.md                   (Index, curated <200 lines)
|   |-- model-playbook.md           (What works per LLM/model)
|   |-- project-patterns.md         (Recurring patterns across projects)
|   `-- agent-recipes.md            (Validated agent configurations)
|
|-- signe-researcher/
|   |-- MEMORY.md                   (Research methodology learnings)
|   `-- source-reliability.md       (Which sources proved reliable)
|
|-- signe-planner/
|   |-- MEMORY.md                   (Planning methodology learnings)
|   `-- estimation-calibration.md   (How estimates compared to reality)
|
|-- signe-designer/
|   |-- MEMORY.md                   (Design methodology learnings)
|   `-- architecture-patterns.md    (What architectures worked well)
|
`-- signe-overseer/
    |-- MEMORY.md                   (Review methodology learnings)
    `-- common-issues.md            (Recurring quality issues)
```

### Memory Lifecycle

1. **Session start:** First 200 lines of MEMORY.md loaded automatically
2. **During work:** Agent reads topic files on-demand using Read tool
3. **Task completion:** Agent updates MEMORY.md and topic files with learnings
4. **Curation:** When MEMORY.md exceeds 200 lines, agent moves details to topic files

### The Playbook: Core Memory Innovation

The model playbook (`agent-memory/signe/model-playbook.md`) is Signe's differentiating knowledge asset:

```markdown
## Opus 4 Patterns
- Prompt structure: [what works, what doesn't]
- Tool usage: [reliable patterns, known issues]
- Context management: [optimal prompt size, when to compact]

## Sonnet 4 Patterns
- Best for: [task types where Sonnet excels]
- Limitations: [known failure modes]
- Prompt adjustments: [how prompts differ from Opus]

## Haiku Patterns
- Best for: [quick lookups, simple analysis]
- Token efficiency: [cost-effective patterns]
```

## GSD Integration Architecture

### Orchestration Pattern

Signe sits above GSD. She does not replace GSD workflows -- she invokes them in the correct project context.

```
Signe (global, ~/.claude/)
  |
  +-- User: "Start a new project for the API service"
  |
  +-- Signe identifies target: C:\Users\minta\Projects\api-service\
  |
  +-- Spawns signe-gsd-orchestrator agent with context:
  |   - Working directory: api-service/
  |   - Task: Invoke /gsd:new-project workflow
  |   - Constraint: All .planning/ files stay in project dir
  |
  +-- signe-gsd-orchestrator runs GSD in project subfolder
  |   - Creates api-service/.planning/PROJECT.md
  |   - Creates api-service/.planning/ROADMAP.md
  |   - Research agents write to api-service/.planning/research/
  |
  +-- Results return to Signe
  +-- Signe updates her memory with project patterns
```

### Cross-Contamination Prevention

1. **Agent design:** signe-gsd-orchestrator's system prompt constrains all `.planning/` writes to the target project directory
2. **Hook validation:** PreToolUse hook on Write/Edit validates `.planning/` paths are within intended project
3. **No shared state:** Each project's `.planning/` directory is fully independent

## Hook Architecture

### Recommended Hooks (Node.js for cross-platform)

| Event | Purpose | Priority |
|-------|---------|----------|
| **PreToolUse** (Write/Edit) | Validate .planning/ paths stay in correct project | Critical |
| **SubagentStart** (signe-*) | Log which agent started, for what task | Nice-to-have |
| **SubagentStop** (signe-*) | Log agent completion, capture timing | Nice-to-have |
| **Stop** | Prompt memory update if significant learnings occurred | Medium |
| **PostToolUse** (Write/Edit) | Auto-validate written files | Low |

### Agent-Scoped Hooks

Individual agents can define their own hooks in frontmatter. These run only while that agent is active:

```yaml
# In signe-researcher.md frontmatter
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "node ~/.claude/hooks/signe-validate-safe-commands.js"
```

## Settings Architecture

### Settings Precedence (highest to lowest)

1. **Managed** (enterprise IT, cannot override)
2. **CLI arguments** (`--agent`, `--model`, etc.)
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User global** (`~/.claude/settings.json`) -- Signe's home

Key implication: Signe's global permissions are the lowest priority. Project settings can override them, which is correct -- project-specific rules should take precedence.

### Naming Convention: signe- Prefix

ALL of Signe's components use the `signe-` prefix to prevent name collisions with project-level definitions. Without this, a project defining a `researcher` agent would silently override Signe's `researcher`.

## Anti-Patterns to Avoid

### Anti-Pattern 1: Nested Agent Spawning
**What:** Trying to have signe-researcher spawn signe-planner
**Why bad:** Claude Code does not allow subagents to spawn subagents.
**Instead:** All spawning goes through the main orchestrator. Chain agents sequentially from the main thread.

### Anti-Pattern 2: Monolithic CLAUDE.md
**What:** Putting all instructions into a single large CLAUDE.md
**Why bad:** Files over 200 lines reduce adherence.
**Instead:** Keep CLAUDE.md under 200 lines. Use `@import` to reference rules/ files.

### Anti-Pattern 3: Shared Mutable State Between Agents
**What:** Multiple agents writing to the same file simultaneously
**Why bad:** Race conditions, overwrites, inconsistent state
**Instead:** Each agent writes to its own output files. The orchestrator is the only merge point.

### Anti-Pattern 4: Over-Delegation
**What:** Spawning an agent for every tiny task
**Why bad:** Each subagent starts fresh. Spawning overhead is significant for quick tasks.
**Instead:** Signe handles simple requests directly. Only delegate for isolation, focused tools, or parallel execution.

### Anti-Pattern 5: Agent Memory as Database
**What:** Treating MEMORY.md as a structured database
**Why bad:** Claude reads it as natural language context.
**Instead:** Keep MEMORY.md as curated prose/bullets. Under 200 lines.

### Anti-Pattern 6: Plugin When Standalone Suffices
**What:** Packaging Signe as a plugin with `.claude-plugin/plugin.json`
**Why bad:** Plugins namespace skills, add distribution complexity, and are designed for sharing. Signe is personal.
**Instead:** Use standalone `~/.claude/` files. Simpler, shorter skill names.

### Anti-Pattern 7: Bash Hook Scripts
**What:** Writing hooks in bash/shell
**Why bad:** Breaks on Windows. Claude Code uses cmd.exe, not bash.
**Instead:** All hooks in Node.js. `node` is guaranteed on every Claude Code installation.

## Build Order and Dependencies

```
Foundation (CLAUDE.md, settings.json, rules/)
    |
    v
Core Skills (signe-research, signe-plan, signe-memory-curation)
    |
    v
Primary Agents (signe-researcher, signe-planner, signe-overseer)
    |
    v
Orchestrator (signe.md, delegation rules, model knowledge)
    |
    v
Advanced Agents (signe-designer, signe-playbook-curator)
    |
    v
GSD Integration (signe-gsd-orchestrator, hooks)
    |
    v
Dry-Run Validation (test each agent, test workflows, test memory)
```

## Sources

### Official Documentation (HIGH confidence)
- [Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [How Claude remembers your project](https://code.claude.com/docs/en/memory)
- [Settings](https://code.claude.com/docs/en/settings)
- [Create plugins](https://code.claude.com/docs/en/plugins)
- [Agent teams](https://code.claude.com/docs/en/agent-teams)

### Reference Architecture (HIGH confidence)
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice)
- [Command -> Agent -> Skill Pattern](https://deepwiki.com/shanraisshan/claude-code-best-practice/6.1-command-agent-skills-pattern)
