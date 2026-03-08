# Technology Stack

**Project:** Signe -- Global Claude Code Agent Package
**Researched:** 2026-03-07
**Claude Code Version:** 2.1.71 (verified locally)

## Recommended Stack

Signe is not a traditional software project with npm dependencies. It is a **pure Claude Code configuration package** -- a structured collection of Markdown files with YAML frontmatter, JSON settings, and shell/Node.js hook scripts that live at `~/.claude/`. No build tools, no frameworks, no package.json beyond what Claude Code itself creates.

### Core Architecture: Command -> Agent -> Skill

| Layer | Location | Format | Purpose |
|-------|----------|--------|---------|
| Commands | `~/.claude/commands/signe/*.md` or `~/.claude/skills/signe-*/SKILL.md` | Markdown + YAML frontmatter | User-facing entry points (`/signe:research`, `/signe:plan`, etc.) |
| Agents | `~/.claude/agents/signe-*.md` | Markdown + YAML frontmatter | Specialized execution contexts (researcher, planner, designer, overseer) |
| Skills | `~/.claude/skills/signe-*/SKILL.md` | Markdown + YAML frontmatter | Reusable knowledge units preloaded into agents or invoked standalone |
| Hooks | `~/.claude/hooks/signe-*.js` | Node.js scripts (cross-platform) | Lifecycle automation, quality gates, context monitoring |
| Settings | `~/.claude/settings.json` | JSON | Permissions, hook registration, MCP server config |
| Memory | `~/.claude/agent-memory/signe-*/MEMORY.md` | Markdown | Persistent agent learning across sessions |
| Rules | `~/.claude/rules/*.md` | Markdown (optional `paths:` frontmatter) | Global behavioral constraints |

**Confidence: HIGH** -- Verified against official Claude Code documentation at code.claude.com (March 2026).

---

## File Formats & Frontmatter Specifications

### Agent Definition (`.claude/agents/<name>.md`)

Agents are the execution layer. Each agent file is Markdown with YAML frontmatter.

```yaml
---
name: signe-researcher                    # REQUIRED. Lowercase, hyphens only.
description: >-                           # REQUIRED. Guides automatic delegation.
  Deep-dive research agent for investigating
  technologies, patterns, and ecosystems.
  Use proactively when research is needed.
tools: Read, Grep, Glob, Bash, WebFetch, WebSearch  # Optional. Inherits all if omitted.
disallowedTools: Write, Edit              # Optional. Denylist (removed from inherited).
model: sonnet                             # Optional. sonnet|opus|haiku|inherit. Default: inherit.
permissionMode: default                   # Optional. default|acceptEdits|dontAsk|bypassPermissions|plan.
maxTurns: 50                              # Optional. Limits agentic loop iterations.
skills:                                   # Optional. Preloaded at startup (full content injected).
  - signe-research-methodology
  - signe-source-hierarchy
memory: user                              # Optional. user|project|local. Enables persistent learning.
background: false                         # Optional. true = always background. Default: false.
isolation: worktree                       # Optional. worktree = isolated git copy. Auto-cleaned.
hooks:                                    # Optional. Scoped to this agent's lifecycle.
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
---

You are Signe's research specialist. Your job is to...

[System prompt content in Markdown follows the frontmatter]
```

**Key details:**
- `name` max 64 characters, lowercase letters/numbers/hyphens only
- `description` max 1024 characters -- Claude uses this to decide when to delegate
- `tools` field is an allowlist; `disallowedTools` is a denylist removed from inherited tools
- `skills` injects FULL skill content at startup (not just made available for invocation)
- `memory: user` stores at `~/.claude/agent-memory/<agent-name>/` -- persists across all projects
- Subagents CANNOT spawn other subagents (architectural constraint)
- Agent receives only its own system prompt + environment details, NOT the full Claude Code system prompt
- Agent tool `Agent(subagent_type)` restricts which subagent types can be spawned (only for `--agent` main thread)

**Confidence: HIGH** -- All fields verified against code.claude.com/docs/en/sub-agents.

### Skill Definition (`.claude/skills/<name>/SKILL.md`)

Skills are reusable knowledge or task definitions. Two invocation patterns exist:

**Pattern 1 -- Agent Skills (Preloaded):** Listed in agent frontmatter `skills: [name]`. Full content injected at agent startup. Use for methodology, conventions, domain knowledge.

**Pattern 2 -- Standalone Skills (On-demand):** Invoked via `Skill(skill='name')` or `/name` slash command. Loaded only when relevant. Use for specific tasks.

```yaml
---
name: signe-research-methodology          # Optional. Uses directory name if omitted.
description: >-                           # Recommended. Claude uses this for auto-discovery.
  Research methodology for investigating
  technology ecosystems. Defines source
  hierarchy and confidence levels.
disable-model-invocation: true            # Optional. true = manual /name only. Default: false.
user-invocable: false                     # Optional. false = hidden from / menu. Default: true.
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch  # Optional. Tool restrictions when active.
model: sonnet                             # Optional. Model override when active.
context: fork                             # Optional. fork = runs in isolated subagent.
agent: Explore                            # Optional. Which agent type for context:fork. Default: general-purpose.
argument-hint: "[topic]"                  # Optional. Autocomplete hint for arguments.
hooks:                                    # Optional. Scoped to this skill's lifecycle.
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "validate.sh"
          once: true                      # Skills only: runs once then removed.
---

## Research Methodology

When researching a topic, follow this protocol:
1. ...

$ARGUMENTS    <!-- Replaced with user input -->
```

**Available substitutions:**
- `$ARGUMENTS` -- All arguments passed when invoking
- `$ARGUMENTS[N]` or `$N` -- Specific argument by 0-based index
- `${CLAUDE_SESSION_ID}` -- Current session ID
- `${CLAUDE_SKILL_DIR}` -- Directory containing the SKILL.md file
- `` !`command` `` -- Shell command output injected before Claude sees content (preprocessing)

**Skill directory structure:**
```
signe-research-methodology/
  SKILL.md           # Required -- main instructions
  reference.md       # Optional -- detailed docs loaded on demand
  templates/         # Optional -- templates for output
  scripts/           # Optional -- helper scripts
  examples/          # Optional -- example outputs
```

**Key design rules:**
- Keep SKILL.md under 500 lines. Move details to supporting files.
- Descriptions loaded into context at all times (budget: ~2% of context window, fallback 16K chars)
- `disable-model-invocation: true` for workflow skills with side effects (deploy, commit, send)
- `user-invocable: false` for background knowledge Claude should know but users shouldn't invoke
- When both a command (.claude/commands/) and skill share the same name, skill takes precedence

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/skills.

### Command Definition (Legacy pattern, still works)

Commands at `.claude/commands/<name>.md` create `/name` slash commands. They support the same frontmatter as skills. Skills are the recommended path forward -- commands are maintained for backward compatibility.

For Signe, **use skills exclusively** because:
1. Skills support directory structure with supporting files
2. Skills support `context: fork` for subagent execution
3. Skills support `agent:` field for agent type selection
4. The Command -> Agent -> Skill pattern uses skills as the entry point in current Claude Code

**Confidence: HIGH** -- Official docs state "Custom commands have been merged into skills."

---

## Hook System

### Lifecycle Events (17 events confirmed)

| Event | Fires | Matcher Input | Decision Control |
|-------|-------|---------------|------------------|
| `SessionStart` | Session begins/resumes | `startup\|resume\|clear\|compact` | No |
| `UserPromptSubmit` | User submits prompt | No matcher | Can modify prompt |
| `PreToolUse` | Before tool executes | Tool name | Can approve/deny/modify |
| `PermissionRequest` | Permission dialog shown | Tool name | Can auto-approve/deny |
| `PostToolUse` | After tool succeeds | Tool name | Can inject feedback |
| `PostToolUseFailure` | After tool fails | Tool name | Informational |
| `Notification` | Notification sent | Notification type | Informational |
| `SubagentStart` | Subagent spawned | Agent type name | Can block |
| `SubagentStop` | Subagent finishes | Agent type name | Informational |
| `Stop` | Claude finishes responding | No matcher | Can request continuation |
| `TeammateIdle` | Teammate going idle | No matcher | Can keep working (exit 2) |
| `TaskCompleted` | Task being marked done | No matcher | Can reject (exit 2) |
| `InstructionsLoaded` | CLAUDE.md/rules loaded | No matcher | Informational |
| `ConfigChange` | Config file changes | Config source | Informational |
| `WorktreeCreate` | Worktree being created | No matcher | Replaces default |
| `WorktreeRemove` | Worktree being removed | No matcher | Informational |
| `PreCompact` | Before context compaction | `manual\|auto` | Can inject summary |
| `SessionEnd` | Session terminates | Exit reason | Cleanup |

### Hook Handler Types

| Type | Format | Use Case |
|------|--------|----------|
| `command` | Shell command, JSON on stdin, exit codes | Cross-platform scripts, file operations |
| `http` | POST to URL, JSON body, JSON response | External services, logging endpoints |
| `prompt` | Single-turn LLM evaluation | Yes/no decisions, content review |
| `agent` | Subagent with tool access | Complex validation requiring file reads |

### Hook Configuration Format (settings.json)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/signe-validate.js",
            "timeout": 30,
            "statusMessage": "Validating...",
            "async": false
          }
        ]
      }
    ],
    "SubagentStart": [
      {
        "matcher": "signe-.*",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/signe-agent-start.js"
          }
        ]
      }
    ]
  }
}
```

### Cross-Platform Scripting Strategy

**Use Node.js for all hooks.** Rationale:

1. Claude Code is built on Node.js -- guaranteed available on any system running it
2. `jq` is not guaranteed on Windows (required for bash JSON parsing)
3. Python may not be installed or may have version conflicts
4. Bash scripts break on Windows without WSL
5. Node.js handles JSON natively (`JSON.parse(stdin)`)

```javascript
// Hook script pattern: read JSON from stdin, process, output JSON
const chunks = [];
process.stdin.on('data', c => chunks.push(c));
process.stdin.on('end', () => {
  const input = JSON.parse(Buffer.concat(chunks).toString());
  // ... process input ...
  // Exit 0 = allow, Exit 2 = deny/block
  process.exit(0);
});
```

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/hooks. Node.js strategy validated by existing GSD hooks in Minta's setup.

---

## Memory System

### Three Scopes

| Scope | Location | Persistence | Use Case |
|-------|----------|-------------|----------|
| `user` | `~/.claude/agent-memory/<agent-name>/` | All projects, all sessions | Cross-project learnings (Signe's playbook) |
| `project` | `.claude/agent-memory/<agent-name>/` | Current project, shareable via git | Project-specific patterns |
| `local` | `.claude/agent-memory-local/<agent-name>/` | Current project, not shared | Personal project knowledge |

### MEMORY.md Mechanics

- First 200 lines loaded into system prompt at session start (hard limit)
- Topic files (`debugging.md`, `patterns.md`) loaded on demand via Read tool
- Agent auto-curates: moves details into topic files when MEMORY.md exceeds 200 lines
- Read, Write, Edit tools auto-enabled when memory is active
- Memory is machine-local (not synced across machines)
- All worktrees within same git repo share one auto memory directory

### For Signe: Use `memory: user` Everywhere

Every Signe agent should use `memory: user` because:
1. Signe is a global agent -- learnings should persist across all projects
2. User-scope memory lives at `~/.claude/agent-memory/<name>/` which is project-independent
3. Each agent maintains its own memory directory, building domain expertise over time
4. The playbook concept (learning what works for each model) requires cross-project persistence

### Auto Memory vs Agent Memory

- **Auto memory** (`~/.claude/projects/<project>/memory/MEMORY.md`): Claude's own session notes. Enabled by default.
- **Agent memory** (`~/.claude/agent-memory/<name>/`): Agent-specific persistent knowledge. Enabled via `memory:` frontmatter.

Both coexist. Signe agents use agent memory; the main Claude Code session uses auto memory independently.

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/memory and code.claude.com/docs/en/sub-agents.

---

## Settings Configuration

### Global Settings (`~/.claude/settings.json`)

Settings hierarchy (highest to lowest precedence):
1. **Managed settings** (cannot be overridden -- org policies)
2. **CLI arguments** (`--agent`, `--model`, etc.)
3. **Local project** (`.claude/settings.local.json`)
4. **Shared project** (`.claude/settings.json`)
5. **User settings** (`~/.claude/settings.json`)

Array-valued settings (allow, deny, filesystem.allowWrite) **merge across scopes** rather than replace.

### Recommended Global Settings for Signe

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(node ~/.claude/hooks/*)",
      "Agent(signe-*)",
      "Skill(signe-*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Read(~/.claude/.credentials.json)"
    ]
  },
  "hooks": {
    "SubagentStart": [
      {
        "matcher": "signe-.*",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/signe-agent-lifecycle.js"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "signe-.*",
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/hooks/signe-agent-lifecycle.js"
          }
        ]
      }
    ]
  },
  "autoUpdatesChannel": "latest"
}
```

### Key Settings Fields for Signe

| Field | Value | Why |
|-------|-------|-----|
| `permissions.allow` | `Agent(signe-*)`, `Skill(signe-*)` | Auto-approve Signe's agents and skills |
| `permissions.deny` | Dangerous operations | Protect system files |
| `hooks` | SubagentStart/Stop matchers | Lifecycle tracking for Signe agents |
| `env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `"1"` | Enable agent teams (still experimental) |
| `teammateMode` | `"in-process"` | Windows-compatible (tmux not available) |

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/settings.

---

## CLAUDE.md Instruction Files

### Structure for Signe

```
~/.claude/
  CLAUDE.md                           # Global user instructions (<200 lines)
  rules/
    signe-personality.md              # Chief of staff personality
    signe-delegation.md               # When/how to delegate to agents
    signe-memory-discipline.md        # Memory curation rules
```

### Rules with Path Scoping

Rules in `~/.claude/rules/` support `paths:` frontmatter for conditional loading:

```yaml
---
paths:
  - "**/.planning/**"
---

# Planning Context Rules
When working in .planning/ directories...
```

Rules without `paths:` load unconditionally at session start.

### Size Discipline

- CLAUDE.md: under 200 lines (hard recommendation from official docs)
- Rules files: no stated limit, but shorter = better adherence
- Skills: under 500 lines per SKILL.md (official recommendation)
- Memory: first 200 lines of MEMORY.md loaded (hard limit)

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/memory.

---

## Plugin System (Distribution Path)

### When to Consider Plugins

Signe starts as a direct `~/.claude/` installation. Plugins become relevant when:
- Distributing to other users
- Versioning releases
- Publishing to a marketplace

### Plugin Directory Structure

```
signe-plugin/
  .claude-plugin/
    plugin.json                       # Manifest: name, description, version, author
  agents/                            # Agent definitions
  skills/                            # Skill definitions
  commands/                          # Legacy command definitions
  hooks/
    hooks.json                       # Hook configuration
  .mcp.json                         # MCP server configurations
  settings.json                     # Default settings (only `agent` key supported)
```

### Key Plugin Rules
- Skill names get namespaced: `/signe:research` instead of `/research`
- Plugin components go at plugin root, NOT inside `.claude-plugin/`
- `settings.json` in plugins currently only supports the `agent` key
- Test locally with `claude --plugin-dir ./signe-plugin`

**Confidence: HIGH** -- Verified against code.claude.com/docs/en/plugins.

---

## MCP Server Integration

### Configuration for Global Agents

MCP servers for Signe agents can be specified in two places:

1. **Agent frontmatter `mcpServers:`** -- scoped to that agent
2. **User `.mcp.json`** or `~/.claude/.mcp.json` -- available globally

```yaml
# In agent frontmatter:
mcpServers:
  - brave-search          # Reference existing configured server
  - tavily                # Reference existing configured server
  - name: custom-server   # Inline definition
    command: node
    args: ["path/to/server.js"]
```

### Available MCP Tools (Minta's Environment)

Already configured and available to Signe agents:
- **Research:** brave-search, tavily, exa, context7, arxiv, youtube-transcript
- **Productivity:** Notion, slack, obsidian, github-mcp, linear, sentry
- **Utilities:** memory, filesystem, desktop-commander, puppeteer, chrome-devtools, pypi, e2b, docker-mcp, markitdown

No additional MCP setup needed -- Signe agents inherit all user-configured MCP servers automatically.

**Confidence: MEDIUM** -- MCP server inheritance confirmed in subagent docs. Specific `mcpServers` frontmatter syntax verified. Exact behavior of user-level MCP configs with subagents needs validation during implementation.

---

## Agent Teams (Experimental)

### Status
Agent teams are **experimental and disabled by default** as of Claude Code 2.1.71. Enable with:
```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

### Relevance to Signe
Agent teams enable parallel research across multiple independent domains. However:
- Still experimental with known limitations (no session resumption, shutdown issues)
- Higher token cost (each teammate = separate context window)
- Windows limitations (tmux split panes not supported, use `in-process` mode)

**Recommendation:** Design Signe to work with subagents first. Agent teams can be layered on later as the feature stabilizes. The subagent pattern (delegate, get summary back) covers 90% of Signe's use cases.

**Confidence: MEDIUM** -- Feature is explicitly marked experimental by Anthropic.

---

## What NOT to Use

| Anti-Pattern | Why Not | Use Instead |
|-------------|---------|-------------|
| Custom CLI/binary | Claude Code is the runtime; adding a CLI adds complexity | Pure .claude/ configuration files |
| External databases for memory | Claude Code has native memory; external DBs add dependencies | `memory: user` in agent frontmatter |
| Python hook scripts | Not guaranteed on Windows; version conflicts | Node.js (guaranteed by Claude Code) |
| Bash hook scripts | Break on Windows without WSL | Node.js |
| `.claude/commands/` for new entry points | Deprecated in favor of skills | `.claude/skills/<name>/SKILL.md` |
| Agents spawning agents | Architectural constraint: subagents cannot spawn subagents | Commands/skills orchestrate, agents execute |
| `context: fork` without instructions | Subagent receives guidelines but no task, returns nothing | Only use `context: fork` with explicit task content |
| Agent teams for sequential work | Coordination overhead exceeds benefit | Single session or subagent chaining |
| CLAUDE.md over 200 lines | Reduces adherence; consumes context budget | Split into `~/.claude/rules/` files |
| Too many skills | Descriptions exceed context budget (~2% of window) | Use `disable-model-invocation: true` for rarely-used skills |

---

## Directory Structure (Target)

```
~/.claude/
  CLAUDE.md                                    # Global instructions (<200 lines)
  settings.json                                # Permissions, hooks, env vars
  rules/
    signe-personality.md                       # Chief of staff personality
    signe-delegation.md                        # Delegation rules
    signe-memory-discipline.md                 # Memory curation rules
  agents/
    signe-orchestrator.md                      # Main orchestrator agent
    signe-researcher.md                        # Research specialist
    signe-planner.md                           # Planning specialist
    signe-designer.md                          # Design specialist (arch/UI/agent/product)
    signe-overseer.md                          # Oversight/review specialist
    signe-agent-designer.md                    # Agent creation specialist
  skills/
    signe-research/
      SKILL.md                                 # /signe-research entry point
      methodology.md                           # Research methodology reference
      source-hierarchy.md                      # Source ranking reference
    signe-plan/
      SKILL.md                                 # /signe-plan entry point
      templates/                               # Planning templates
    signe-design/
      SKILL.md                                 # /signe-design entry point
    signe-oversee/
      SKILL.md                                 # /signe-oversee entry point
    signe-workflow/
      SKILL.md                                 # /signe-workflow (full R->P->D->O chain)
    signe-agent-design/
      SKILL.md                                 # Agent creation skill
      templates/                               # Agent template files
  hooks/
    signe-agent-lifecycle.js                   # SubagentStart/Stop tracking
    signe-quality-gate.js                      # PostToolUse validation
    signe-memory-curator.js                    # Memory auto-curation
  agent-memory/
    signe-orchestrator/
      MEMORY.md                                # Orchestrator's persistent knowledge
    signe-researcher/
      MEMORY.md                                # Researcher's persistent knowledge
    signe-planner/
      MEMORY.md                                # Planner's persistent knowledge
    signe-designer/
      MEMORY.md                                # Designer's persistent knowledge
    signe-overseer/
      MEMORY.md                                # Overseer's persistent knowledge
    signe-agent-designer/
      MEMORY.md                                # Agent designer's persistent knowledge
```

**Confidence: HIGH** -- Directory structure follows official documentation patterns verified across all sources.

---

## Sources

### Official Documentation (HIGH confidence)
- [Claude Code Skills](https://code.claude.com/docs/en/skills) -- Skill definition format, frontmatter, invocation control
- [Claude Code Hooks](https://code.claude.com/docs/en/hooks) -- All 17 lifecycle events, configuration schema, handler types
- [Claude Code Settings](https://code.claude.com/docs/en/settings) -- Complete settings.json specification, hierarchy
- [Claude Code Memory](https://code.claude.com/docs/en/memory) -- CLAUDE.md, auto memory, scopes, 200-line limit
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents) -- Agent frontmatter, built-in agents, memory, hooks
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins) -- Plugin structure, distribution, marketplace
- [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) -- Experimental multi-agent coordination

### Community Reference (MEDIUM confidence)
- [Command -> Agent -> Skill Pattern](https://deepwiki.com/shanraisshan/claude-code-best-practice/6.1-command-agent-skills-pattern) -- Orchestration pattern deep dive
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) -- Reference repo by Shayan Rais
- [Claude Agent Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/) -- First principles analysis

### Local Verification
- Claude Code v2.1.71 confirmed via `claude --version`
- Existing GSD agent package at `~/.claude/` inspected for structural patterns
- Existing `~/.claude/settings.json` with hooks confirmed working
