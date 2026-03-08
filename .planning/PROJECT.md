# Signe

## What This Is

Signe is a globally-installed Claude Code agent package — a chief of staff AI assistant that lives at `~/.claude/` and is available in every project without per-project setup. She researches, plans, designs, oversees, and methodically manages subagents, building a persistent playbook of what works for each model and workflow she encounters. Built on the Command → Agent → Skill architecture from claude-code-best-practice.

## Core Value

Signe must be able to chain research → plan → design → oversee in a single coherent workflow, delegating to specialized subagents she designs, tests, and validates herself.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Global installation at `~/.claude/` — available in any project folder without per-project config
- [ ] Chief of staff personality — manages complexity, surfaces what matters, shields from noise
- [ ] Research mode — deep-dive investigation using web search, paper reading, repo analysis, documentation crawling
- [ ] Planning mode — project decomposition, roadmaps, requirements definition, phase structuring
- [ ] Design mode (system architecture) — component boundaries, data flow, API design, infrastructure decisions
- [ ] Design mode (UI/UX direction) — wireframes, user flows, visual direction, component hierarchy
- [ ] Design mode (agent design) — creating new agents with tested prompts, tools, and workflows
- [ ] Design mode (product design) — feature scoping, user stories, experience mapping
- [ ] Oversight mode — code review, quality verification, gap detection, progress management
- [ ] GSD orchestration — sits above GSD, runs GSD workflows in project subfolders to avoid cross-contamination
- [ ] Subagent methodology — research model best practices → plan prompts → dry-run test → validate → bank knowledge
- [ ] Agent playbook memory — persists learned best practices per LLM/model across sessions via user-scope MEMORY.md
- [ ] Command → Agent → Skill architecture — entry points as commands, specialized agents with preloaded skills, standalone skills
- [ ] YAML frontmatter agent definitions — name, description, tools, model, permissionMode, maxTurns, skills, memory, hooks
- [ ] All tools available — web research (Brave, Tavily, Exa, Context7), browser (Playwright/Chrome DevTools), filesystem, all MCP tools in environment
- [ ] Full workflow chaining — research → plan → design → oversee as a single orchestrated flow
- [ ] Native Claude Code memory — user-scope MEMORY.md with 200-line discipline, auto-curation

### Out of Scope

- Per-project installation/scaffolding — Signe is global, not copied per project
- Custom CLI tool — pure `.claude/` structure following reference repo patterns
- Replacing vexp — Signe leverages vexp for codebase understanding, doesn't replace it
- Mobile/web interface — this is a Claude Code CLI agent, not a GUI application
- Training/fine-tuning models — Signe works with existing models, she doesn't train them

## Context

**Reference repo:** [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) by Shayan Rais — the definitive guide to Claude Code configuration. Key patterns extracted:

- **Command → Agent → Skill orchestration** — commands as entry points, agents with preloaded skills, standalone skills invoked on-demand
- **YAML frontmatter definitions** — agents, skills, commands all use structured frontmatter (name, description, tools, model, permissionMode, maxTurns, skills, memory, hooks, etc.)
- **Configuration hierarchy** — managed > CLI args > settings.local.json > settings.json > global settings.json; deny rules have highest safety precedence
- **Agent memory** — `memory: user|project|local` frontmatter; MEMORY.md with 200-line discipline; three scopes for different persistence needs
- **Hooks system** — 19 lifecycle events (PreToolUse, PostToolUse, SubagentStart, SubagentStop, etc.); cross-platform; supports agent-specific hooks
- **Two skill patterns** — Agent Skills (preloaded via `skills:` field, full content injected at startup) vs standalone Skills (invoked on-demand via Skill tool)
- **Settings.json** — granular permissions (allow/ask/deny with wildcards), spinner customization, auto-compact threshold, hook configuration
- **CLAUDE.md discipline** — under 200 lines per file, split into `.claude/rules/` for large instruction sets
- **RPI workflow** — Research → Plan → Implement with specialized agents (requirement-parser, product-manager, ux-designer, senior-software-engineer, technical-cto-advisor, code-reviewer, constitutional-validator, documentation-analyst-writer)

**Existing environment (Minta's setup):**
- GSD workflows for project management (will be orchestrated by Signe in subfolders)
- vexp for codebase indexing and context-aware code search
- Full MCP tool suite: Brave, Tavily, Exa, Context7, Playwright, Chrome DevTools, Obsidian, Notion, Slack, GitHub, memory graph, and more
- Obsidian vault for notes and research
- Multiple project folders under `C:\Users\minta\Projects\`

**Earlier agent concept:** Signe is an evolution of a previous agent idea — same name (she/her), expanded scope and methodology.

## Constraints

- **Architecture**: Must follow Command → Agent → Skill pattern from reference repo — no custom frameworks
- **Location**: Must live at `~/.claude/` (global scope) — not per-project
- **Memory**: Must use native Claude Code agent memory (`memory: user`) — no external databases
- **CLAUDE.md size**: Each instruction file must stay under 200 lines — split into rules/ files as needed
- **Subagent design**: Must follow research → plan → dry-run → validate methodology — no untested agents deployed
- **GSD integration**: GSD must run in project subfolders (e.g., `project/.planning/`) to avoid cross-contamination between projects
- **Platform**: Windows 11 (Minta's environment) — hooks/scripts must be cross-platform compatible

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Global install at ~/.claude/ | Available everywhere without per-project setup; follows Claude Code's native global scope | — Pending |
| Command → Agent → Skill architecture | Proven pattern from reference repo; separates concerns cleanly | — Pending |
| User-scope MEMORY.md for agent knowledge | Native Claude Code feature; persists across sessions; 200-line discipline prevents bloat | — Pending |
| Dry-run testing for new subagents | Ensures quality before deploying; validates prompts work with specific models | — Pending |
| GSD in subfolders | Prevents cross-contamination between different project roadmaps | — Pending |
| Chief of staff personality | User preference; Signe manages complexity rather than just executing tasks | — Pending |

---
*Last updated: 2026-03-07 after initialization*
