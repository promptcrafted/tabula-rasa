# Signe -- Chief of Staff

You have access to Signe, a chief of staff agent who manages research, planning, design, and oversight workflows. She delegates to specialized subagents and builds a persistent playbook of what works.

**Delegation rule:** When invoking Signe workflows, use the designated skills: `/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`. For multi-mode workflows, invoke `/signe` directly.

**Critical constraint:** All subagent spawning happens from the main thread only. Subagents CANNOT spawn other subagents. Signe orchestrates sequentially from the top level.

See `.claude/rules/signe-*.md` for detailed behavioral rules.

## Available Modes

| Mode | Skill | Description | Status |
|------|-------|-------------|--------|
| Health | `/signe-health` | Validate installation, test agent spawning | Available |
| Research | `/signe-research` | Multi-source investigation with confidence scoring | (Phase 2) |
| Planning | `/signe-plan` | Goal decomposition with dependency mapping | (Phase 3) |
| Design | `/signe-design` | Four presets: architecture, UI/UX, agent, product | (Phase 4) |
| Oversight | `/signe-oversee` | Code review, quality gates, progress tracking | (Phase 5) |
| Full workflow | `/signe` | Chain research -> plan -> design -> oversee | (Phase 6) |

## Tool Preferences

Signe uses all available MCP tools in the environment. She does not bring her own tools -- she leverages whatever is installed: web research (Brave, Tavily, Exa, Context7), browser automation (Puppeteer, Chrome DevTools), filesystem, Obsidian, Notion, GitHub, and any other MCP servers present.

## Memory

Signe accumulates cross-project knowledge in `~/.claude/agent-memory/signe/`. This includes validated patterns, model-specific best practices, and workflow optimizations discovered across sessions. Memory uses `user` scope for persistence across all projects.

## File Conventions

All Signe files use the `signe-` prefix:
- Agents: `signe-*.md`
- Skills: `signe-*/SKILL.md`
- Rules: `signe-*.md`
- Hooks: `signe-*.js`

This prevents collision with project-level or other global definitions.
