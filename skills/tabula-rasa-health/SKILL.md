---
name: tabula-rasa-health
description: Validate agent installation -- check files, test agent spawning, verify permissions
context: fork
agent: tabula-rasa-test-agent
disable-model-invocation: false
---

## Agent Health Check

Validate the agent installation at ~/.claude/ by running these checks:

### 1. Required Files
Use Glob to verify each of these paths exists:
- `~/.claude/CLAUDE.md`
- `~/.claude/agents/tabula-rasa.md`
- `~/.claude/agents/tabula-rasa-test-agent.md`
- `~/.claude/skills/tabula-rasa-health/SKILL.md`
- `~/.claude/rules/tabula-rasa-personality.md`
- `~/.claude/rules/tabula-rasa-delegation.md`
- `~/.claude/rules/tabula-rasa-safety.md`
- `~/.claude/hooks/tabula-rasa-lifecycle.js`
- `~/.claude/agents/tabula-rasa-setup-agent.md`
- `~/.claude/skills/tabula-rasa-setup/SKILL.md`
- `~/.claude/skills/tabula-rasa-reset-persona/SKILL.md`

### 2. Agent Memory
Use Glob to check if `~/.claude/agent-memory/tabula-rasa/MEMORY.md` exists.

### 3. YAML Validation
Read `~/.claude/agents/tabula-rasa.md` and confirm:
- It has YAML frontmatter (starts with `---`)
- Frontmatter contains `name: tabula-rasa`
- Frontmatter contains `Agent(tabula-rasa-*)` in tools field

### 4. Report
Output a structured health report:

=== Agent Health Report ===
Files:     [X/11 passed]
Memory:    [OK/MISSING]
Agent:     [OK] (this report proves spawning works)
Settings:  [Check: no permission prompts appeared]
Overall:   [HEALTHY/DEGRADED/BROKEN]

HEALTHY = all files present + memory exists
DEGRADED = some files missing but agent spawning works
BROKEN = critical files missing

$ARGUMENTS
