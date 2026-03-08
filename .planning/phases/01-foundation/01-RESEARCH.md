# Phase 1: Foundation - Research

**Researched:** 2026-03-07
**Domain:** Claude Code global agent package infrastructure (~/.claude/)
**Confidence:** HIGH

## Summary

Phase 1 establishes Signe's global installation skeleton at `~/.claude/`. This involves creating CLAUDE.md, merging into the existing settings.json, creating rules files, writing Node.js hook scripts for SubagentStart/SubagentStop, creating a test skill and agent to validate the Command -> Agent -> Skill architecture end-to-end, and establishing naming conventions with the `signe-` prefix.

The official Claude Code documentation (March 2026) provides clear, well-documented APIs for all components needed. Skills have absorbed commands -- a SKILL.md file at `~/.claude/skills/signe-test/SKILL.md` creates `/signe-test` as a slash command automatically. Agents are YAML frontmatter markdown files at `~/.claude/agents/`. Hooks are Node.js scripts configured in settings.json. Rules are `.md` files at `~/.claude/rules/`. All of these mechanisms are stable, well-documented, and proven by the existing GSD installation on this machine.

**Primary recommendation:** Build the minimum viable skeleton -- CLAUDE.md, settings.json merge, 2-3 rules files, one hook script (SubagentStart/Stop combined), one test skill, and one test agent. Validate end-to-end, then keep the test skill as a permanent diagnostic tool renamed `signe-health`.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Single `settings.json` -- add Signe's permission patterns (`Agent(signe-*)`, `Skill(signe-*)`) and hooks alongside existing GSD entries in the same file
- Shared hook lifecycle events -- GSD hooks listed first, Signe hooks after. Claude Code runs them in array order
- Signe agents (`signe-*`) completely ignore GSD agents (`gsd-*`). No awareness, no interaction. GSD integration comes in Phase 6
- File drop installation with manual `settings.json` merge. No install script. Signe's files are developed in this repo, then copied to `~/.claude/`
- Self-contained CLAUDE.md at `~/.claude/` -- no dependency on project-level CLAUDE.md files (e.g., `Projects/CLAUDE.md`)
- Hooks output to stdout only (captured by Claude Code session). No log files

### Claude's Discretion
- Invocation pattern -- Whether to use `/signe-research` (separate skills), `/signe research` (subcommand), or direct agent invocation
- Orchestrator invocability -- Whether signe.md is directly invocable alongside mode skills, or mode skills are the only entry points
- Model-invocation setting -- Whether `disable-model-invocation: true` should be set on Signe skills
- Model assignment -- Whether agents inherit the current model or specify cheaper models per role
- CLAUDE.md first 10 lines -- What goes in the critical opening lines
- Personality depth -- How prominent the chief of staff personality framing should be
- Rules file structure -- Number and organization of `.claude/rules/` overflow files
- Test skill design -- What the end-to-end validation skill should do
- Test skill retention -- Whether to keep the test skill as a permanent diagnostic or remove after validation
- Placeholder agents -- Whether to create stub files for all planned agents or only the minimum needed

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFRA-01 | Signe installs globally at `~/.claude/` and is available in any project folder without per-project config | Skills at `~/.claude/skills/` and agents at `~/.claude/agents/` are automatically available everywhere per official docs. Verified with existing GSD installation on this machine. |
| INFRA-02 | Signe follows Command -> Agent -> Skill architecture with skills as entry points, agents as specialists, and skills preloaded per agent | Official docs confirm: skills create `/slash-commands`, agents spawn via Agent tool, agents load skills via `skills:` frontmatter. Skills have absorbed commands. |
| INFRA-03 | All agent/skill/command names use `signe-` prefix to prevent collision with project-level definitions | Naming convention only -- no special API needed. GSD uses `gsd-` prefix successfully. |
| INFRA-04 | CLAUDE.md stays under 100 lines with critical instructions in the first 10 lines, splitting overflow into `.claude/rules/` files | Official docs recommend under 200 lines per file. Rules files in `.claude/rules/` are auto-loaded at session start. User-level rules at `~/.claude/rules/` load before project rules. |
| INFRA-05 | `settings.json` auto-approves `Agent(signe-*)` and `Skill(signe-*)` with explicit tool allowlists per agent | Official docs confirm `Agent(agent-name)` and `Skill(skill-name)` permission patterns. Wildcard `*` is supported for prefix matching with `Skill(signe-* *)`. Agent tool permissions use `Agent(signe-*)`. |
| INFRA-06 | Hook scripts use Node.js for cross-platform compatibility (Windows/macOS/Linux) | Official docs show hooks as shell commands. Node.js is guaranteed available. Existing GSD hooks on this machine prove the pattern works on Windows. stdin timeout guard pattern is established. |
| INFRA-07 | Signe uses native Claude Code memory (`memory: user`) with MEMORY.md under 200 lines and topic files for overflow | Official docs confirm `memory: user` creates `~/.claude/agent-memory/<agent-name>/` with MEMORY.md auto-loaded (first 200 lines). In Phase 1, only the memory directory structure needs to exist; actual memory content comes in later phases. |
| INFRA-10 | Signe orchestrator (`signe.md`) is a flat orchestrator -- all subagent spawning happens from the main thread only | Official docs explicitly state: "Subagents cannot spawn other subagents." The `Agent(agent_type)` tool restriction in `tools` field controls which agents can be spawned. Only agents running as main thread via `claude --agent` can spawn subagents. |
</phase_requirements>

## Discretion Decisions: Research Recommendations

These recommendations address each deferred decision from CONTEXT.md with evidence from official documentation and the reference repository.

### 1. Invocation Pattern: Use Separate Skills (`/signe-research`, `/signe-plan`, etc.)

**Recommendation:** Separate skill files, one per mode. `/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`.

**Evidence:**
- Claude Code skills have absorbed commands. A SKILL.md at `~/.claude/skills/signe-research/SKILL.md` automatically creates the `/signe-research` slash command (HIGH confidence, official docs).
- The reference repo uses this pattern: separate commands per workflow, each routing to a specific agent.
- The GSD installation on this machine uses this pattern: `/gsd:plan-phase`, `/gsd:research-phase`, etc., each with its own command file.
- Subcommand patterns (`/signe research`) are not natively supported -- Claude Code creates slash commands from skill names, not from arguments. You would need a single `/signe` skill that parses arguments, which adds unnecessary complexity.
- Direct agent invocation (asking Claude to "use the signe-researcher agent") works but is less discoverable than slash commands and relies on Claude's automatic delegation, which is inconsistent.

**Confidence:** HIGH -- directly verified against official docs and existing working patterns on this machine.

### 2. Orchestrator Invocability: signe.md is Directly Invocable AND Mode Skills Exist

**Recommendation:** `signe.md` should be directly invocable via `/signe` or by asking Claude to "use Signe." Mode skills (`/signe-research`, etc.) should also exist as convenience entry points that set the `agent` field to route through signe.md or directly to the mode agent.

**Evidence:**
- Official docs: Users can ask Claude to use a specific agent by name ("Use the code-reviewer subagent to..."). The `description` field drives auto-delegation.
- For single-mode tasks, `/signe-research` is more ergonomic than `/signe` followed by explaining what you want.
- For multi-mode workflows (research -> plan -> design), invoking `/signe` directly makes more sense as the orchestrator handles the chaining.
- Mode skills should use `context: fork` and `agent: signe-researcher` (or the mode agent directly) to spawn in an isolated context.

**Implementation:**
- `~/.claude/agents/signe.md` -- main orchestrator, invocable by name or via `/signe` skill
- `~/.claude/skills/signe/SKILL.md` -- convenience entry point for multi-mode workflows, `context: fork`, `agent: signe`
- `~/.claude/skills/signe-research/SKILL.md` -- mode entry point, `context: fork`, `agent: signe-researcher`
- (etc. for plan, design, oversee -- these are Phase 2-5 deliverables)

**For Phase 1:** Only create the `/signe-health` test skill and the minimal `signe.md` orchestrator stub. Do NOT create mode skills or mode agents yet.

**Confidence:** HIGH

### 3. Model-Invocation Setting: `disable-model-invocation: true` for Mode Skills

**Recommendation:** Set `disable-model-invocation: true` on all mode skills (`/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`) and the main `/signe` skill. Keep `disable-model-invocation: false` (default) or omit it for the test/health skill.

**Evidence:**
- Official docs: "Use for workflows with side effects or that you want to control timing, like `/commit`, `/deploy`."
- Signe's mode skills initiate multi-turn, expensive workflows. You do not want Claude auto-triggering a full research cycle because your prompt happened to mention investigation.
- The test/health skill is lightweight and safe to auto-invoke if Claude decides it is relevant.
- With `disable-model-invocation: true`, descriptions are NOT loaded into context, saving context budget.

**Confidence:** HIGH

### 4. Model Assignment: Inherit for All Agents (Phase 1)

**Recommendation:** Use `model: inherit` (the default) for all agents in Phase 1. Defer model-specific assignment to Phase 5 when the playbook exists.

**Evidence:**
- Official docs: "If not specified, defaults to `inherit` (uses the same model as the main conversation)."
- The user is running Opus 4.6 in this session. All of Signe's specialist agents (researcher, planner, designer, overseer) perform complex tasks that benefit from the strongest available model.
- Cost optimization through cheaper models (Sonnet for research, Haiku for exploration) is a Phase 5 concern when the playbook has data on which models perform well for which tasks.
- Premature model pinning risks degraded output quality before we have empirical data.

**For Phase 1:** Simply omit the `model` field from agent frontmatter, defaulting to `inherit`.

**Confidence:** HIGH

### 5. CLAUDE.md First 10 Lines: Identity + Delegation Rule + Rules Import

**Recommendation:** The first 10 lines should contain: (1) identity statement, (2) delegation rule, (3) flat orchestration constraint, (4) rules import reference.

**Proposed content:**

```markdown
# Signe -- Chief of Staff

You have access to Signe, a chief of staff agent who manages research, planning, design, and oversight workflows. She delegates to specialized subagents and builds a persistent playbook of what works.

**Delegation rule:** When invoking Signe workflows, use the designated skills: `/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`. For multi-mode workflows, invoke `/signe` directly.

**Critical constraint:** All subagent spawning happens from the main thread only. Subagents CANNOT spawn other subagents. Signe orchestrates sequentially from the top level.

See `.claude/rules/signe-*.md` for detailed behavioral rules.
```

**Evidence:**
- Official docs: "Files over 200 lines reduce adherence." The target is under 100 lines per INFRA-04.
- Official docs: "The more specific and concise your instructions, the more consistently Claude follows them."
- The identity + delegation rule pattern ensures Claude knows Signe exists and how to invoke her from the very first lines.
- The `@import` syntax can reference rules files, but explicit mention is clearer.
- Remaining lines (10-100) will contain: available mode descriptions, tool preferences, and references to rules files.

**Confidence:** HIGH

### 6. Personality Depth: Minimal in CLAUDE.md, Detailed in Rules File

**Recommendation:** CLAUDE.md uses minimal personality framing (1-2 lines: "chief of staff who manages..."). Full personality and behavioral guidelines live in `~/.claude/rules/signe-personality.md`.

**Evidence:**
- CLAUDE.md is loaded into EVERY session, even ones where Signe is not invoked. Heavy personality text wastes context.
- Rules files at `~/.claude/rules/` are also loaded every session, but they can be more detailed since they are modular and can be path-scoped if needed.
- The reference repo's RPI workflow uses focused agent prompts rather than heavy global personality framing.
- The personality should be most prominent in `signe.md` (the agent definition) where it forms the system prompt, not in the global CLAUDE.md.

**Implementation:**
- `CLAUDE.md`: "You have access to Signe, a chief of staff agent who manages research, planning, design, and oversight workflows."
- `~/.claude/rules/signe-personality.md`: Full personality guidelines (proactive risk identification, milestone summaries, maker-checker loops, etc.)
- `~/.claude/agents/signe.md` body: Detailed system prompt with full chief of staff personality.

**Confidence:** HIGH

### 7. Rules File Structure: Three Files

**Recommendation:** Three rules files for Phase 1:

| File | Purpose | Lines |
|------|---------|-------|
| `signe-personality.md` | Chief of staff behavioral guidelines, communication style, proactive behaviors | ~40-60 |
| `signe-delegation.md` | When and how to spawn subagents, delegation decision tree, anti-patterns | ~40-60 |
| `signe-safety.md` | What Signe must never do (no nested spawning, no autonomous execution beyond checkpoints, no over-delegation) | ~20-30 |

**Evidence:**
- Architecture research already proposed exactly these three files.
- Official docs: Rules files are loaded at session start. Each should cover one topic with a descriptive filename.
- Three focused files keep each under the 200-line recommendation while covering the key behavioral domains.
- User-level rules at `~/.claude/rules/` are loaded before project rules, which is correct for Signe's global scope.

**Confidence:** HIGH

### 8. Test Skill Design: `/signe-health` -- Environment Validation

**Recommendation:** Create a test skill named `signe-health` that validates the entire Signe installation is working correctly.

**What it does:**
1. Verifies all expected files exist (`CLAUDE.md`, `settings.json`, rules files, agent files, hook scripts)
2. Spawns the `signe-test-agent` subagent (a minimal agent with `tools: Read, Glob` and `memory: user`)
3. The test agent reads a known file and returns structured output confirming: agent spawning works, tool access works, memory directory exists
4. Reports results as a structured health check

**Skill definition:**
```yaml
---
name: signe-health
description: Validate Signe installation -- check all files exist, test agent spawning, verify permissions
context: fork
agent: signe-test-agent
---

## Signe Health Check

Run through each validation step and report results:

1. **File Check**: Use Glob to verify these paths exist:
   - ~/.claude/CLAUDE.md
   - ~/.claude/agents/signe.md
   - ~/.claude/rules/signe-personality.md
   - ~/.claude/rules/signe-delegation.md
   - ~/.claude/rules/signe-safety.md
   - ~/.claude/hooks/signe-lifecycle.js

2. **Agent Memory**: Verify ~/.claude/agent-memory/signe/ directory exists

3. **Read Test**: Read ~/.claude/agents/signe.md and confirm it contains valid YAML frontmatter

4. **Report**: Output a structured health report:
   - Files: [list with checkmark/x for each]
   - Agent spawning: OK (this report proves it)
   - Memory directory: OK/MISSING
   - Overall: HEALTHY / DEGRADED / BROKEN
```

**Evidence:**
- The `context: fork` + `agent:` pattern is officially documented and tested.
- Using a real agent (not just file checks) validates the full Command -> Agent -> Skill pipeline.
- The health check is self-proving: if it produces output, agent spawning works.

**Confidence:** HIGH

### 9. Test Skill Retention: Keep as Permanent Diagnostic (`/signe-health`)

**Recommendation:** Keep the test skill permanently, renamed to `signe-health`. It serves as a diagnostic tool for validating the installation after updates or environment changes.

**Evidence:**
- The skill is lightweight (no side effects, read-only agent, minimal context usage).
- Having a quick health check command is useful for debugging issues in future phases.
- The GSD installation has a similar pattern with `/gsd:health`.
- Cost is near zero since it only runs when explicitly invoked.

**Confidence:** HIGH

### 10. Placeholder Agents: Minimum Only (signe.md + signe-test-agent.md)

**Recommendation:** Create only two agent files in Phase 1:
1. `signe.md` -- Main orchestrator with full personality prompt but stub functionality (explains it is not yet implemented for mode-specific tasks)
2. `signe-test-agent.md` -- Minimal agent for health check validation

Do NOT create placeholder stubs for `signe-researcher.md`, `signe-planner.md`, `signe-designer.md`, `signe-overseer.md`, etc. Those are deliverables for their respective phases.

**Evidence:**
- Creating stub agents with empty or placeholder system prompts provides zero value -- Claude would try to use them and get poor results.
- Each mode agent requires a carefully designed system prompt, tool restrictions, and skill preloading. These are non-trivial Phase 2-5 deliverables.
- The orchestrator (`signe.md`) needs to exist in Phase 1 so the architecture is proven, but it should gracefully explain which modes are not yet available.
- Keeping the agents directory clean prevents confusion about what is actually functional.

**Confidence:** HIGH

## Standard Stack

### Core

| Component | Type | Purpose | Why Standard |
|-----------|------|---------|--------------|
| `~/.claude/CLAUDE.md` | Markdown | Global instructions, identity, delegation rules | Native Claude Code memory system, loaded every session |
| `~/.claude/settings.json` | JSON | Permissions, hooks, env vars | Native Claude Code configuration, merged with existing GSD settings |
| `~/.claude/agents/*.md` | YAML frontmatter MD | Subagent definitions | Native Claude Code agent system, proven by GSD |
| `~/.claude/skills/*/SKILL.md` | YAML frontmatter MD | Entry point skills and knowledge modules | Native Claude Code skill system, creates `/slash-commands` |
| `~/.claude/rules/*.md` | Markdown | Always-loaded behavioral instructions | Native Claude Code rules system, loaded before project rules |
| `~/.claude/hooks/*.js` | Node.js | Lifecycle automation scripts | Native Claude Code hooks system, cross-platform via Node.js |
| `~/.claude/agent-memory/*/` | Directory + MD | Persistent cross-session knowledge | Native Claude Code agent memory, `memory: user` scope |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| `context: fork` in skills | Run skill in isolated subagent context | When skill triggers expensive multi-turn workflows |
| `disable-model-invocation: true` | Prevent Claude auto-invoking a skill | For expensive workflow skills that should be user-triggered only |
| `memory: user` on agents | Persistent learning across projects | For all Signe agents that accumulate cross-project knowledge |
| `$CLAUDE_SKILL_DIR` substitution | Reference files relative to skill directory | When skills bundle supporting files |

## Architecture Patterns

### Recommended Directory Structure (Phase 1 Deliverables)

```
~/.claude/
|-- CLAUDE.md                          # Global instructions (<100 lines)
|-- settings.json                      # Merged: GSD + Signe permissions/hooks
|
|-- agents/
|   |-- gsd-*.md                       # (existing, untouched)
|   |-- signe.md                       # Main orchestrator (stub for Phase 1)
|   `-- signe-test-agent.md            # Health check validation agent
|
|-- skills/
|   `-- signe-health/
|       `-- SKILL.md                   # Installation health check
|
|-- rules/
|   |-- signe-personality.md           # Chief of staff behavioral guidelines
|   |-- signe-delegation.md            # Delegation rules and anti-patterns
|   `-- signe-safety.md               # Safety constraints
|
|-- hooks/
|   |-- gsd-*.js                       # (existing, untouched)
|   `-- signe-lifecycle.js             # SubagentStart/Stop logging
|
`-- agent-memory/
    `-- signe/
        `-- MEMORY.md                  # Initial empty memory index
```

### Pattern 1: Skill as Entry Point with Agent Fork

**What:** Skill creates a slash command that spawns a specific agent in an isolated context.
**When to use:** For expensive multi-turn workflows that should not pollute the main conversation.

```yaml
# Source: Official Claude Code docs (https://code.claude.com/docs/en/skills)
---
name: signe-health
description: Validate Signe installation health
context: fork
agent: signe-test-agent
disable-model-invocation: false
---

## Health Check Instructions
[skill body becomes the task prompt for the agent]
```

### Pattern 2: Agent Definition with Tool Restrictions and Memory

**What:** YAML frontmatter markdown file defining a specialized subagent.
**When to use:** For each specialized worker in the system.

```yaml
# Source: Official Claude Code docs (https://code.claude.com/docs/en/sub-agents)
---
name: signe-test-agent
description: Minimal validation agent for health checks. Read-only, verifies Signe installation.
tools: Read, Glob, Grep
model: inherit
memory: user
---

You are Signe's health check agent. Your job is to verify the Signe installation
is complete and functional.

[detailed instructions in markdown body]
```

### Pattern 3: Hook Script with stdin Timeout Guard (Windows-safe)

**What:** Node.js hook script that reads JSON from stdin with a timeout guard to prevent hanging on Windows.
**When to use:** For all hook scripts.

```javascript
// Source: Existing GSD hooks on this machine (proven pattern)
#!/usr/bin/env node
const stdinTimeout = setTimeout(() => process.exit(0), 3000);
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    // Process hook data...
    const agentType = data.agent_type;
    const agentId = data.agent_id;
    const event = data.hook_event_name;

    // Output to stdout (captured by Claude Code session)
    if (agentType && agentType.startsWith('signe-')) {
      console.log(`[Signe] ${event}: ${agentType} (${agentId})`);
    }
  } catch (e) {
    // Silent fail -- don't break the session
  }
});
```

### Pattern 4: Settings.json Merge with Existing GSD Configuration

**What:** Add Signe's permission patterns and hook entries alongside existing GSD entries.
**When to use:** During installation.

```json
{
  "permissions": {
    "allow": [
      "Agent(signe-*)",
      "Skill(signe-* *)"
    ]
  },
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "node \"C:/Users/minta/.claude/hooks/gsd-check-update.js\"" }] }
    ],
    "PostToolUse": [
      { "hooks": [{ "type": "command", "command": "node \"C:/Users/minta/.claude/hooks/gsd-context-monitor.js\"" }] }
    ],
    "SubagentStart": [
      {
        "matcher": "signe-.*",
        "hooks": [{ "type": "command", "command": "node \"C:/Users/minta/.claude/hooks/signe-lifecycle.js\"" }]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "signe-.*",
        "hooks": [{ "type": "command", "command": "node \"C:/Users/minta/.claude/hooks/signe-lifecycle.js\"" }]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "node \"C:/Users/minta/.claude/hooks/gsd-statusline.js\""
  },
  "autoUpdatesChannel": "latest",
  "effortLevel": "high"
}
```

### Anti-Patterns to Avoid

- **Creating mode agents too early:** Do not create signe-researcher.md, signe-planner.md, etc. in Phase 1. Each requires a carefully designed system prompt and is a Phase 2-5 deliverable. Placeholder stubs will be invoked by Claude and produce poor results.
- **Putting personality in CLAUDE.md:** Heavy personality text in CLAUDE.md wastes context in every session, including ones where Signe is not invoked. Keep personality in the agent's system prompt and a focused rules file.
- **Using bash hook scripts:** Breaks on Windows. Claude Code uses cmd.exe, not bash. All hooks must be Node.js.
- **Creating `/signe` as a unified entry point with argument parsing:** Unnecessary complexity. Separate skills are more discoverable and map cleanly to the agent architecture.
- **Setting model to cheaper models prematurely:** Without empirical data, model pinning risks degraded output quality. Use `inherit` until the playbook has data.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Slash command creation | Custom CLI entry points or alias scripts | SKILL.md files at `~/.claude/skills/` | Claude Code automatically creates `/skill-name` commands |
| Permission management | Custom permission checking logic | `settings.json` permission patterns with `allow`/`deny` | Native Claude Code permission system handles scope merging |
| Agent spawning | Custom spawn orchestration | Agent tool with YAML frontmatter agent files | Native Claude Code Agent tool manages context, permissions, and lifecycle |
| Cross-session memory | Custom file-based memory system | `memory: user` frontmatter + agent-memory directory | Native MEMORY.md system with 200-line auto-loading |
| Hook lifecycle management | Custom event system | settings.json hook configuration | Claude Code manages hook execution, stdin/stdout, timeouts |
| Install script | Automated file copying and settings merge | Manual file drop + manual settings.json merge | User explicitly decided: no install script in Phase 1 |

**Key insight:** Every component of Signe's infrastructure uses native Claude Code APIs. There is zero custom framework code. The entire "codebase" is markdown files, JSON configuration, and Node.js hook scripts.

## Common Pitfalls

### Pitfall 1: settings.json Array Overwrite Instead of Merge
**What goes wrong:** Replacing the entire `hooks` object when adding Signe's hooks, destroying existing GSD hook configuration.
**Why it happens:** JSON does not support partial updates -- you must preserve existing array entries.
**How to avoid:** Read the existing settings.json, add Signe entries to the existing arrays, write the complete merged result. NEVER replace the hooks object wholesale.
**Warning signs:** GSD statusline disappears, session start hooks stop running.

### Pitfall 2: Permission Pattern Syntax Errors
**What goes wrong:** Using `Agent(signe*)` instead of `Agent(signe-*)` or `Skill(signe-research)` instead of `Skill(signe-research *)` for prefix matching with arguments.
**Why it happens:** Subtle syntax differences between Agent and Skill permission patterns.
**How to avoid:** Test permission patterns by running `/signe-health` and verifying no permission prompts appear. Agent patterns use `Agent(name-pattern)`. Skill patterns with arguments need `Skill(name *)` with a space and wildcard.
**Warning signs:** Permission prompts appearing when invoking Signe skills/agents.

### Pitfall 3: Hook stdin Hanging on Windows
**What goes wrong:** Hook script waits indefinitely for stdin, causing Claude Code to kill it after timeout and report "hook error."
**Why it happens:** On Windows with Git Bash, stdin pipe behavior differs from Unix. The pipe may not close cleanly.
**How to avoid:** Always include the 3-second stdin timeout guard pattern (see Pattern 3 above). This is proven by GSD hooks on this exact machine.
**Warning signs:** "Hook error" messages in Claude Code output. Hooks taking 10+ seconds.

### Pitfall 4: CLAUDE.md Too Large or Too Generic
**What goes wrong:** Claude ignores instructions because they are too verbose or too vague.
**Why it happens:** CLAUDE.md is context, not enforced configuration. Longer and vaguer content reduces adherence.
**How to avoid:** Keep under 100 lines per INFRA-04. Use specific, verifiable instructions. Move detailed content to rules files.
**Warning signs:** Claude not following delegation rules, not using Signe when expected.

### Pitfall 5: SubagentStart Cannot Block
**What goes wrong:** Trying to use SubagentStart hook to prevent agent creation.
**Why it happens:** Misunderstanding the hook's capabilities.
**How to avoid:** SubagentStart hooks can only inject context (additionalContext), not block. If blocking is needed, use permissions.deny rules instead.
**Warning signs:** Exit code 2 from SubagentStart hook does NOT block -- it only shows stderr to user.

### Pitfall 6: Skills Description Budget Exhaustion
**What goes wrong:** Too many skills consume the description budget (2% of context window), causing some skills to be excluded from context.
**Why it happens:** Each skill's description is loaded into context so Claude knows what is available.
**How to avoid:** Keep descriptions concise. Use `disable-model-invocation: true` on expensive skills to exclude them from the description budget entirely. In Phase 1, only one skill exists, so this is not a concern yet.
**Warning signs:** `/context` command shows warning about excluded skills.

## Code Examples

### Complete settings.json Merge (Phase 1)

```json
// Source: Official Claude Code settings docs + existing GSD settings on this machine
{
  "permissions": {
    "allow": [
      "Agent(signe-*)",
      "Skill(signe-* *)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"C:/Users/minta/.claude/hooks/gsd-check-update.js\""
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"C:/Users/minta/.claude/hooks/gsd-context-monitor.js\""
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
            "command": "node \"C:/Users/minta/.claude/hooks/signe-lifecycle.js\""
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
            "command": "node \"C:/Users/minta/.claude/hooks/signe-lifecycle.js\""
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "node \"C:/Users/minta/.claude/hooks/gsd-statusline.js\""
  },
  "autoUpdatesChannel": "latest",
  "effortLevel": "high"
}
```

### Complete Hook Script: signe-lifecycle.js

```javascript
#!/usr/bin/env node
// Signe Agent Lifecycle Hook
// Handles both SubagentStart and SubagentStop events
// Outputs to stdout (captured by Claude Code session)

const stdinTimeout = setTimeout(() => process.exit(0), 3000);
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const data = JSON.parse(input);
    const event = data.hook_event_name;
    const agentType = data.agent_type || 'unknown';
    const agentId = data.agent_id || 'unknown';

    // Only log signe-* agents (matcher handles this, but double-check)
    if (!agentType.startsWith('signe-')) {
      process.exit(0);
    }

    const timestamp = new Date().toISOString().slice(11, 19);

    if (event === 'SubagentStart') {
      console.log(`[Signe ${timestamp}] Started: ${agentType} (${agentId})`);
    } else if (event === 'SubagentStop') {
      console.log(`[Signe ${timestamp}] Stopped: ${agentType} (${agentId})`);
    }
  } catch (e) {
    // Silent fail -- don't break the session
  }
  process.exit(0);
});
```

### Complete Agent Definition: signe-test-agent.md

```markdown
---
name: signe-test-agent
description: Minimal validation agent for Signe health checks. Read-only, verifies installation completeness.
tools: Read, Glob, Grep
memory: user
---

You are Signe's health check agent. Your sole purpose is to validate that the Signe
installation at ~/.claude/ is complete and functional.

When invoked, perform these checks and report results:

1. **File Existence**: Use Glob to check for each expected file
2. **YAML Validation**: Read signe.md and confirm it has valid frontmatter
3. **Memory Directory**: Check if ~/.claude/agent-memory/signe/ exists
4. **Report Format**: Output a structured report with pass/fail for each check

Do not modify any files. This is a read-only diagnostic.
```

### Complete Skill Definition: signe-health/SKILL.md

```yaml
---
name: signe-health
description: Validate Signe installation -- check files, test agent spawning, verify permissions
context: fork
agent: signe-test-agent
---

## Signe Health Check

Validate the Signe installation at ~/.claude/ by checking:

1. **Required Files** (use Glob):
   - ~/.claude/CLAUDE.md
   - ~/.claude/agents/signe.md
   - ~/.claude/agents/signe-test-agent.md
   - ~/.claude/skills/signe-health/SKILL.md
   - ~/.claude/rules/signe-personality.md
   - ~/.claude/rules/signe-delegation.md
   - ~/.claude/rules/signe-safety.md
   - ~/.claude/hooks/signe-lifecycle.js

2. **Agent Memory** (use Glob):
   - ~/.claude/agent-memory/signe/MEMORY.md

3. **YAML Validation** (use Read):
   - Read ~/.claude/agents/signe.md, confirm frontmatter contains `name: signe`

4. **Report**:
   ```
   === Signe Health Report ===
   Files:     [X/Y passed]
   Memory:    [OK/MISSING]
   Agent:     [OK] (this report proves spawning works)
   Hooks:     [File exists: OK/MISSING]
   Overall:   [HEALTHY/DEGRADED/BROKEN]
   ```

$ARGUMENTS
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `.claude/commands/*.md` for entry points | `.claude/skills/*/SKILL.md` (skills absorbed commands) | Current (March 2026) | Skills are the recommended approach; commands still work as aliases |
| `Task` tool name for subagents | `Agent` tool name (renamed in v2.1.63) | v2.1.63 | Both work, but `Agent` is the current name. Existing `Task(...)` references in settings still work |
| Manual agent creation only | `/agents` interactive command + manual | Current | Interactive UI for creating/managing agents, but manual files still work |
| No skill `context` field | `context: fork` for isolated execution | Current | Skills can now run in forked subagent context |
| No agent `isolation` field | `isolation: worktree` for git worktree isolation | Current | Agents can run in isolated git worktrees |
| No agent `background` field | `background: true` for concurrent execution | Current | Agents can run concurrently while user continues |

**Deprecated/outdated:**
- `Task` tool name: Renamed to `Agent` in v2.1.63. `Task(...)` still works as alias but `Agent(...)` is preferred.
- `.claude/commands/` directory: Still works but `.claude/skills/` is recommended. Skills have additional features (supporting files, context fork, agent field).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual validation via `/signe-health` skill |
| Config file | None -- validation is built into the skill itself |
| Quick run command | `/signe-health` |
| Full suite command | `/signe-health` (single comprehensive check) |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| INFRA-01 | Global availability -- skill resolves from any project folder | manual | Run `/signe-health` from two different project directories | Wave 0 |
| INFRA-02 | Command -> Agent -> Skill architecture works | smoke | `/signe-health` spawns `signe-test-agent` and gets structured output | Wave 0 |
| INFRA-03 | `signe-` prefix on all components | manual | Visual inspection of file names | N/A |
| INFRA-04 | CLAUDE.md under 100 lines, first 10 lines critical | manual | `wc -l ~/.claude/CLAUDE.md` and visual inspection | N/A |
| INFRA-05 | Auto-approve Agent(signe-*) and Skill(signe-*) | smoke | `/signe-health` runs without permission prompts | Wave 0 |
| INFRA-06 | Node.js hooks execute on SubagentStart/Stop | smoke | `/signe-health` triggers SubagentStart/Stop, observe log output | Wave 0 |
| INFRA-07 | Memory directory exists with MEMORY.md | smoke | `/signe-health` checks for agent-memory/signe/MEMORY.md | Wave 0 |
| INFRA-10 | Flat orchestrator -- signe.md defines Agent tool restrictions | manual | Inspect signe.md frontmatter for `tools: Agent(...)` pattern | N/A |

### Sampling Rate
- **Per task commit:** `/signe-health` run after each wave of file changes
- **Per wave merge:** Full `/signe-health` run
- **Phase gate:** `/signe-health` reports HEALTHY from at least two different project directories

### Wave 0 Gaps
- [x] `/signe-health` skill -- covers INFRA-01, INFRA-02, INFRA-05, INFRA-06, INFRA-07
- [x] `signe-test-agent` agent -- required by `/signe-health`
- No external test framework needed -- the skill IS the test

## Open Questions

1. **Permission pattern for Skill wildcard with arguments**
   - What we know: `Agent(signe-*)` works for agent patterns. `Skill(signe-research *)` is the documented pattern for skills with arguments.
   - What's unclear: Whether `Skill(signe-*)` alone (without trailing ` *`) is sufficient, or if the space+wildcard is needed for auto-approving skill invocations with arguments.
   - Recommendation: Use `Skill(signe-* *)` to be safe. Verify empirically when `/signe-health` is first run.

2. **SubagentStart hook stdout visibility**
   - What we know: SubagentStart can return `additionalContext` via JSON output. Plain stdout from hooks is only shown in verbose mode (Ctrl+O) for most events.
   - What's unclear: Whether `console.log` output from SubagentStart hooks is visible to the user by default or only in verbose mode.
   - Recommendation: Start with `console.log` output. If not visible, explore using `additionalContext` in the JSON response instead. The user decided stdout-only (no log files).

3. **CLAUDE.md coexistence with existing global CLAUDE.md**
   - What we know: There is currently NO `~/.claude/CLAUDE.md` file on this machine. The `settings.json` and `settings.local.json` exist but no CLAUDE.md.
   - What's unclear: Nothing -- this is actually resolved. Signe's CLAUDE.md will be the first and only global CLAUDE.md.
   - Recommendation: Create `~/.claude/CLAUDE.md` fresh. No merge needed.

## Sources

### Primary (HIGH confidence)
- [Official Claude Code: Sub-agents](https://code.claude.com/docs/en/sub-agents) - Full agent configuration, frontmatter fields, tools, memory, hooks, permission modes
- [Official Claude Code: Skills](https://code.claude.com/docs/en/skills) - Skill creation, frontmatter, context fork, disable-model-invocation, description budget
- [Official Claude Code: Hooks Reference](https://code.claude.com/docs/en/hooks) - All 17 lifecycle events, configuration schema, SubagentStart/SubagentStop input/output, exit codes
- [Official Claude Code: Memory](https://code.claude.com/docs/en/memory) - CLAUDE.md, rules files, auto memory, agent memory, 200-line discipline
- [Official Claude Code: Settings](https://code.claude.com/docs/en/settings) - Permission patterns, settings merge, Agent/Skill permission syntax
- Existing GSD installation at `~/.claude/` - Proven patterns for agents, hooks, commands on Windows 11

### Secondary (MEDIUM confidence)
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) - Reference architecture for Command -> Agent -> Skill pattern
- Architecture research at `.planning/research/ARCHITECTURE.md` - Prior analysis of the full system design

### Tertiary (LOW confidence)
- None -- all findings verified against primary sources

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - All components are native Claude Code APIs, verified against official docs (March 2026)
- Architecture: HIGH - Directory structure and patterns verified against official docs and existing GSD installation
- Pitfalls: HIGH - Pitfalls 1, 3, 4 observed directly in existing GSD hooks on this machine; pitfalls 2, 5, 6 from official docs
- Discretion decisions: HIGH - All 10 recommendations backed by official docs and/or existing proven patterns

**Research date:** 2026-03-07
**Valid until:** 2026-04-07 (30 days -- stable APIs, no fast-moving dependencies)
