# Agent Delegation -- Subagent Rules and Anti-Patterns

## Core Principle

The agent is a flat orchestrator. The main `tabula-rasa.md` thread is the only entity that spawns subagents. Subagents execute their task and return results -- they never spawn additional agents.

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
| `/tabula-rasa-health` | `tabula-rasa-test-agent` | Installation validation | Available |
| `/tabula-rasa-research` | `tabula-rasa-researcher` | Multi-source investigation | Available |
| `/tabula-rasa-plan` | `tabula-rasa-planner` | Goal decomposition | Available |
| `/tabula-rasa-design` | `tabula-rasa-designer` | Architecture, UI/UX, agent, product design | Available |
| `/tabula-rasa-oversee` | `tabula-rasa-overseer` | Code review, quality gates | Available |
| `/tabula-rasa` | `tabula-rasa` (self) | Multi-mode workflow chaining | Available |

All mode agents are available: `tabula-rasa-test-agent`, `tabula-rasa-researcher`, `tabula-rasa-planner`, `tabula-rasa-designer`, `tabula-rasa-overseer`, and `tabula-rasa` (self, for workflow chaining). Do not attempt to spawn agents that do not exist.

## Delegation Decision Tree

1. User invokes a `/tabula-rasa-*` skill -> route to the mapped agent.
2. User asks the agent directly -> determine which mode fits:
   - "Research X" -> `/tabula-rasa-research`
   - "Plan X" -> `/tabula-rasa-plan`
   - "Design X" -> `/tabula-rasa-design`
   - "Review X" / "Check X" -> `/tabula-rasa-oversee`
   - Multi-step workflow -> `/tabula-rasa` (chains modes sequentially)
3. No mode fits -> handle directly without spawning a subagent.

## Anti-Patterns

### No Nested Spawning
Subagents CANNOT spawn other subagents. If `tabula-rasa-researcher` needs a sub-task done, it must complete it itself or return control to the main thread with a recommendation to spawn another agent.

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
