# tabula-rasa User Guide

Complete reference for all modes, setup, and persona features.

## Overview

tabula-rasa is a chief of staff agent system for Claude Code. It installs into `~/.claude/` and provides five specialist modes -- research, planning, design, oversight, and full pipeline chaining -- each backed by a dedicated subagent.

**Architecture:** Flat orchestrator. The main agent (`signe.md`) is the only entity that spawns subagents. Subagents execute their task and return results -- they never spawn additional agents. This eliminates coordination complexity and keeps workflows predictable.

**Modes relate to each other:** Each mode can be used independently, or chained together via `/signe` (the full pipeline). A typical chain: research a topic, plan the implementation, design the architecture, then oversee the code review.

**Memory:** The agent uses `MEMORY.md` with user scope to persist knowledge across sessions. It remembers your preferences, project context, and accumulated patterns.

## Installation

### Prerequisites

- **Claude Code CLI** -- install from [docs.anthropic.com](https://docs.anthropic.com/en/docs/claude-code)
- **bash** -- native on macOS/Linux; use Git Bash on Windows (included with [Git for Windows](https://git-scm.com/downloads))
- Run `claude` at least once to initialize `~/.claude/`

### Install

```bash
git clone https://github.com/your-username/tabula-rasa.git
cd tabula-rasa
bash install.sh
```

### What the script does

1. **Pre-flight checks:** Verifies Claude Code CLI is installed and `~/.claude/` exists
2. **Conflict detection:** If any target files already exist, backs them up to `~/.claude/backups/tabula-rasa-YYYYMMDD-HHMMSS/`
3. **Copies files:**
   - `agents/signe*.md` (7 agent definitions)
   - `skills/signe*/SKILL.md` (8 skill directories)
   - `rules/signe-*.md` (3 rule files)
   - `hooks/signe-lifecycle.js` (subagent lifecycle hook)
4. **CLAUDE.md handling:** Installs template only if no `~/.claude/CLAUDE.md` exists. Never overwrites your existing file.
5. **Creates** `~/.claude/agent-memory/signe/` directory for persona storage

### settings.json

The install script does **not** auto-merge `settings.json`. Review `settings-merge.json` in the repo and manually merge any needed entries into `~/.claude/settings.json`.

### Verify installation

Start Claude Code and run:

```
/signe-health
```

This spawns a read-only test agent that validates file presence and reports any issues.

## Setup and Persona

### First-time setup

After installation, start Claude Code and run:

```
/setup
```

The agent starts a conversational interview to learn about you:

- **Work domain:** What you build, languages you use, team structure
- **Communication style:** Concise vs. detailed, proactive vs. reactive, level of formality
- **Habits:** How you prefer to work, what annoys you, what you value in a collaborator

### Persona generation

Based on your answers, the agent generates its own identity:

- **Name:** Picks a name that fits the relationship (you can veto up to twice -- after two vetoes, you choose the name)
- **Personality:** Selects traits that complement your working style
- **Communication style:** Calibrates formality, detail level, and proactiveness to your preferences

### Persona storage

The persona is stored at:

```
~/.claude/agent-memory/signe/MEMORY.md
```

The Persona section is placed at the top of `MEMORY.md` so it loads within the first 200 lines of context. It loads automatically every session -- you do not need to re-run `/setup`.

### How subagents inherit persona

Subagents receive persona context through their task prompt. The main orchestrator includes relevant persona details when delegating, so specialist agents maintain a consistent personality.

## Modes

### Research

**Multi-source investigation with confidence scoring.**

```
/signe-research
```

**Example prompts:**

- `/signe-research` Compare WebSocket vs SSE for real-time notifications in a Django app
- `/signe-research` What are the security implications of storing JWTs in localStorage vs httpOnly cookies?

**What to expect:** The agent consults multiple sources (web search, documentation, papers), cross-references findings, and produces a structured report with:

- Sources consulted (with links)
- Key findings organized in tables or bullet points
- A confidence-rated recommendation (HIGH / MEDIUM / LOW)
- Risks and trade-offs

Typical turn budget: 50 turns.

### Planning

**Goal decomposition with dependency mapping.**

```
/signe-plan
```

**Example prompts:**

- `/signe-plan` Break down migrating our monolith auth service to a separate microservice
- `/signe-plan` Plan the v2 API redesign -- we need backward compatibility

**What to expect:** The agent decomposes your goal into phases with dependency ordering. Output includes:

- Phase breakdown with concrete tasks
- Dependency graph between tasks
- Risk identification per phase
- Estimated complexity ratings
- Recommended execution order

Typical turn budget: 30 turns.

### Design

**Architecture, UI/UX, agent, or product design with four presets.**

```
/signe-design
```

**Presets:**

| Preset | Use when |
|--------|----------|
| Architecture | Designing system components, APIs, data models |
| UI/UX | Designing user interfaces, flows, interactions |
| Agent | Designing AI agent prompts, tools, workflows |
| Product | Designing features, roadmaps, user stories |

The agent auto-detects the appropriate preset from your prompt, or you can specify it explicitly.

**Example prompts:**

- `/signe-design` Design the database schema for a multi-tenant SaaS billing system
- `/signe-design` Design the onboarding flow for our mobile app (UI/UX)

**What to expect:** Structured design document with diagrams (text-based), trade-off analysis, and implementation recommendations. The agent follows a maker-checker approach -- treats its first draft as a starting point and iterates.

Typical turn budget: 40 turns.

### Oversight

**Code review, quality gates, and progress tracking.**

```
/signe-oversee
```

**Example prompts:**

- `/signe-oversee` Review the auth middleware changes in the last 3 commits
- `/signe-oversee` Check our test coverage gaps in the payment module

**What to expect:** The agent reviews through five lenses:

1. Correctness -- does the code do what it claims?
2. Security -- are there vulnerabilities?
3. Performance -- any bottlenecks or scaling concerns?
4. Maintainability -- is the code readable and well-structured?
5. Testing -- are edge cases covered?

Output includes specific file paths, line numbers, and concrete suggestions. The agent is intentionally critical -- it flags issues rather than approving everything.

Typical turn budget: 40 turns.

### Full Pipeline

**Chain all modes into a single workflow.**

```
/signe
```

**Example prompts:**

- `/signe` I need to add real-time collaboration to our document editor. Research the options, plan the implementation, design the architecture, then review what we have so far.
- `/signe` We are migrating from REST to GraphQL. Full analysis and plan.

**What to expect:** The agent chains modes sequentially:

1. **Research** the topic or problem space
2. **Plan** the implementation based on research findings
3. **Design** the architecture based on the plan
4. **Oversee** existing code or the proposed changes

Each stage builds on the previous. The agent provides milestone summaries between stages and surfaces any concerns before proceeding. You can intervene at any stage.

## Persona Customization

### Project-scoped persona

Run `/setup` inside a project directory to create a persona specific to that project:

```
cd my-project
claude
> /setup
```

The project persona overrides the global persona when you are working in that project directory. The global persona continues to apply everywhere else.

### Resetting persona

Use `/reset-persona` to start over. Three modes:

| Mode | Command | What it resets |
|------|---------|----------------|
| Global only (default) | `/reset-persona` | Global persona in `~/.claude/agent-memory/signe/MEMORY.md` |
| Project only | `/reset-persona project` | Project-scoped persona only |
| All | `/reset-persona all` | Both global and project personas |

Reset removes only the Persona sections from `MEMORY.md` -- all other accumulated knowledge (patterns, project context) is preserved.

After resetting, run `/setup` again to create a new persona.

## Troubleshooting

### Validation

Run `/signe-health` to check that all files are installed correctly. The health check agent verifies:

- Agent files present in `~/.claude/agents/`
- Skill directories present in `~/.claude/skills/`
- Rule files present in `~/.claude/rules/`
- Hook file present in `~/.claude/hooks/`
- Memory directory exists at `~/.claude/agent-memory/signe/`

### Common issues

**Agent not responding or modes not available**
- Re-run `bash install.sh` from the repo directory
- Check that `~/.claude/agents/signe.md` exists
- Verify with `/signe-health`

**Persona not loading**
- Check that `~/.claude/agent-memory/signe/MEMORY.md` exists and has a Persona section
- Re-run `/setup` if the file is empty or missing

**MCP tools not available for research**
- Configure your MCP tools in `~/.claude/CLAUDE.md` under the MCP Tools section
- tabula-rasa uses whatever tools are in your environment -- it does not bring its own

**Settings not applied**
- Review `settings-merge.json` in the repo
- Manually merge needed entries into `~/.claude/settings.json`

### File conventions

All tabula-rasa files use the `signe-` prefix:

| Type | Location | Pattern |
|------|----------|---------|
| Agents | `~/.claude/agents/` | `signe*.md` |
| Skills | `~/.claude/skills/` | `signe*/SKILL.md` |
| Rules | `~/.claude/rules/` | `signe-*.md` |
| Hooks | `~/.claude/hooks/` | `signe-lifecycle.js` |
| Memory | `~/.claude/agent-memory/` | `signe/MEMORY.md` |

This prevents collision with your other Claude Code agents and skills.

---

*tabula-rasa -- Your AI chief of staff for Claude Code*
