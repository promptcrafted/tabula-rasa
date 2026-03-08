# Signe Delegation -- Subagent Rules and Anti-Patterns

## Core Principle

Signe is a flat orchestrator. The main `signe.md` thread is the only entity that spawns subagents. Subagents execute their task and return results -- they never spawn additional agents.

## When to Delegate

Spawn a subagent when:
- The task requires a focused, multi-turn workflow (research, planning, design, review).
- The task benefits from isolated context (fork) to avoid polluting the main conversation.
- The task maps to one of the defined mode agents below.

Do NOT delegate when:
- The task is a simple question answerable in 1-2 turns.
- The task requires real-time user interaction (back-and-forth conversation).
- No suitable mode agent exists for the task type.

## Skill-to-Agent Routing

| Skill | Agent | Purpose | Status |
|-------|-------|---------|--------|
| `/signe-health` | `signe-test-agent` | Installation validation | Available |
| `/signe-research` | `signe-researcher` | Multi-source investigation | Available |
| `/signe-plan` | `signe-planner` | Goal decomposition | (Phase 3) |
| `/signe-design` | `signe-designer` | Architecture, UI/UX, agent, product design | (Phase 4) |
| `/signe-oversee` | `signe-overseer` | Code review, quality gates | (Phase 5) |
| `/signe` | `signe` (self) | Multi-mode workflow chaining | (Phase 6) |

**Phase 2 note:** `signe-test-agent` and `signe-researcher` are available. All other mode agents (planner, designer, overseer) are future phase deliverables. Do not attempt to spawn agents that do not exist.

## Delegation Decision Tree

1. User invokes a `/signe-*` skill -> route to the mapped agent.
2. User asks Signe directly -> determine which mode fits:
   - "Research X" -> `/signe-research`
   - "Plan X" -> `/signe-plan`
   - "Design X" -> `/signe-design`
   - "Review X" / "Check X" -> `/signe-oversee`
   - Multi-step workflow -> `/signe` (chains modes sequentially)
3. No mode fits -> handle directly without spawning a subagent.

## Anti-Patterns

### No Nested Spawning
Subagents CANNOT spawn other subagents. If `signe-researcher` needs a sub-task done, it must complete it itself or return control to the main thread with a recommendation to spawn another agent.

### No Over-Delegation
Maximum 5 concurrent subagents at any time. If more parallelism is needed, queue tasks and process in batches.

### No Generic Role Agents
Never spawn a generic "helper" or "assistant" agent. Every agent must have:
- A specific task with concrete context
- An appropriate tool allowlist
- A clear done condition

### No Premature Agent Creation
Do not create stub agent files for modes that are not yet implemented. An agent definition without a tested, validated system prompt will produce poor results when Claude attempts to use it.

## Context Handoff

When delegating to a subagent:
- Provide the specific task, not a vague goal.
- Include relevant file paths and prior context.
- Specify the expected output format.
- Set a reasonable turn limit if the task is bounded.
