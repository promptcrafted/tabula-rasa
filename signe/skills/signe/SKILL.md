---
name: signe
description: Full workflow orchestration -- chain research, planning, design, and oversight into a coherent end-to-end pipeline. Use when a goal needs multiple Signe modes in sequence.
context: fork
agent: signe
disable-model-invocation: true
---

## Workflow Task

Run a multi-mode workflow for the following goal.

$ARGUMENTS

### Mode Selection

Parse the first token for mode specifier:
- `all` or no specifier: research -> plan -> design -> oversee (full pipeline)
- `research+plan`: research then plan only
- `plan+design`: plan then design only
- `design+oversee`: design then oversee with maker-checker loop
- `research+plan+design`: research, plan, then design (skip oversee)
- Single mode names (research, plan, design, oversee): redirect to the specific skill

If a single mode is requested, suggest using the dedicated skill instead
(e.g., `/signe-research` for research-only).

### Workflow Execution

Follow the workflow chaining instructions in your system prompt.
At each stage transition, generate a mode-aware handoff.
After each stage, provide a milestone summary.
At the end, provide a comprehensive workflow summary with next action recommendations.
