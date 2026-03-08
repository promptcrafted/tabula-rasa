# Phase 7: Privacy Scrub & Dynamic Identity - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Remove all private/personal references from agent files that ship with tabula-rasa, and replace hardcoded "Signe" identity with a dynamic persona system that reads from MEMORY.md. The `/setup` workflow that writes persona is Phase 8 — this phase only builds the reading/fallback mechanism.

</domain>

<decisions>
## Implementation Decisions

### Privacy scrub scope
- Scrub Signe files (5 agents, 6 skills, 3 rules) AND global CLAUDE.md
- Remove: personal file paths (C:\Users\minta), usernames (alvdansen), MCP tool configs (Obsidian vault, vexp), project names (dimljus, girlypop)
- Replace with generic placeholders or remove entirely
- Ship a template CLAUDE.md that introduces the agent system, references rules/ files, and has placeholder sections for users to fill in
- Drop SIGNE-GUIDE.md — Phase 9 creates a proper user guide from scratch
- GSD files and plugins are NOT in scope (separate projects)

### Fallback identity
- Agent uses role only before /setup: "I'm your chief of staff agent" — no name
- Full chief-of-staff personality ships by default (proactive risk ID, milestone summaries, opinionated recommendations) — /setup customizes name/gender/style but core behaviors are always on
- One-time subtle hint on first interaction: "Tip: run /setup to personalize me" — never mentioned again after that
- Gender-neutral language in fallback: use "I", "me", "the agent" — no gendered pronouns until /setup

### Replacement strategy
- Agent prompt pattern: "You are a chief of staff agent. If a persona is defined in your MEMORY.md, adopt that name and personality."
- Persona stored in existing MEMORY.md at ~/.claude/agent-memory/ (already loaded automatically by Claude Code — zero new infrastructure)
- Third-person "Signe" references in rules/skills become role references: "The agent can read .planning/" instead of "Signe can read .planning/"
- No template variables or preprocessing — leverage Claude Code's native memory loading
- File prefix `signe-*` stays unchanged (explicitly out of scope per REQUIREMENTS.md)

### Claude's Discretion
- Best practice for how agent prompts reference persona (conditional text vs MEMORY.md instruction — lean toward what integrates cleanest with Claude Code's agent architecture)
- Exact wording of the one-time /setup hint
- How to handle edge cases in rules files where "Signe" appears in section headers vs body text
- Whether agent-memory/signe/ directory name needs renaming or can stay as-is

</decisions>

<specifics>
## Specific Ideas

- User said "whatever is best practice" for replacement strategy — prioritize the approach that works most naturally with Claude Code's existing features over clever engineering
- The product's value prop is the chief-of-staff personality — it must work fully even without /setup

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `~/.claude/agent-memory/signe/MEMORY.md`: Existing memory file with `memory: user` scope — natural home for persona config
- All 5 agent .md files use YAML frontmatter with `memory: user` — Claude Code auto-loads MEMORY.md contents

### Established Patterns
- Agent identity set in first line of system prompt: "You are Signe, a chief of staff agent"
- Third-person references in rules/*.md: "Signe can read...", "Signe must NEVER..."
- Skills reference "Signe" in descriptions and SKILL.md files
- `signe-` prefix used consistently across all files (agents, skills, rules, hooks)

### Integration Points
- 93 "Signe/signe" references across 9 agent files (signe.md: 24, signe-test-agent.md: 34)
- 3 rules files (signe-personality.md, signe-delegation.md, signe-safety.md) use "Signe" in behavioral instructions
- 6 skill SKILL.md files reference "Signe" in descriptions
- Global CLAUDE.md has personal MCP tool configs, project folder references, Obsidian vault paths

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 07-privacy-scrub-dynamic-identity*
*Context gathered: 2026-03-08*
