# Chief of Staff Agent System

You have access to a chief of staff agent who manages research, planning, design, and oversight workflows. The agent delegates to specialized subagents and builds a persistent playbook of validated patterns.

**Delegation rule:** When invoking workflows, use the designated skills: `/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`. For multi-mode workflows, invoke `/signe` directly.

**Critical constraint:** All subagent spawning happens from the main thread only. Subagents CANNOT spawn other subagents. The orchestrator delegates sequentially from the top level.

See `~/.claude/rules/signe-*.md` for detailed behavioral rules.

## Available Modes

| Mode | Skill | Description | Status |
|------|-------|-------------|--------|
| Health | `/signe-health` | Validate installation, test agent spawning | Available |
| Research | `/signe-research` | Multi-source investigation with confidence scoring | Available |
| Planning | `/signe-plan` | Goal decomposition with dependency mapping | Available |
| Design | `/signe-design` | Four presets: architecture, UI/UX, agent, product | Available |
| Oversight | `/signe-oversee` | Code review, quality gates, progress tracking | Available |
| Full workflow | `/signe` | Chain research -> plan -> design -> oversee | Available |

## Tool Preferences

The agent system uses all available MCP tools in the environment. It does not bring its own tools -- it leverages whatever is installed. Configure your MCP servers below and the agents will automatically use them for research, documentation lookup, and other tasks.

## Your MCP Tools

<!-- List your installed MCP tools here so agents know what is available. -->
<!-- Example entries: -->
<!-- - **brave-search** -- Web search via Brave API -->
<!-- - **context7** -- Live, version-specific library documentation -->
<!-- - **github-mcp** -- GitHub PRs, issues, Actions -->

## Your Projects

<!-- Describe your project folders here so agents understand your workspace. -->
<!-- Example entries: -->
<!-- - **my-app/** -- React SaaS application with Node.js backend -->
<!-- - **ml-experiments/** -- Python ML training scripts and notebooks -->

## Memory

The agent accumulates cross-project knowledge in `~/.claude/agent-memory/signe/`. This includes validated patterns, model-specific best practices, and workflow optimizations discovered across sessions. Memory uses `user` scope for persistence across all projects.

## File Conventions

All agent files use the `signe-` prefix:
- Agents: `signe-*.md`
- Skills: `signe-*/SKILL.md`
- Rules: `signe-*.md`
- Hooks: `signe-*.js`

This prevents collision with project-level or other global definitions.
