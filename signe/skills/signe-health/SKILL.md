---
name: signe-health
description: Validate Signe installation -- check files, test agent spawning, verify permissions
context: fork
agent: signe-test-agent
disable-model-invocation: false
---

## Signe Health Check

Validate the Signe installation at ~/.claude/ by running these checks:

### 1. Required Files
Use Glob to verify each of these paths exists:
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/signe.md`
- `~/.claude/agents/signe-test-agent.md`
- `~/.claude/skills/signe-health/SKILL.md`
- `~/.claude/rules/signe-personality.md`
- `~/.claude/rules/signe-delegation.md`
- `~/.claude/rules/signe-safety.md`
- `~/.claude/hooks/signe-lifecycle.js`

### 2. Agent Memory
Use Glob to check if `~/.claude/agent-memory/signe/MEMORY.md` exists.

### 3. YAML Validation
Read `~/.claude/agents/signe.md` and confirm:
- It has YAML frontmatter (starts with `---`)
- Frontmatter contains `name: signe`
- Frontmatter contains `Agent(signe-*)` in tools field

### 4. Report
Output a structured health report:

=== Signe Health Report ===
Files:     [X/8 passed]
Memory:    [OK/MISSING]
Agent:     [OK] (this report proves spawning works)
Settings:  [Check: no permission prompts appeared]
Overall:   [HEALTHY/DEGRADED/BROKEN]

HEALTHY = all files present + memory exists
DEGRADED = some files missing but agent spawning works
BROKEN = critical files missing

$ARGUMENTS
