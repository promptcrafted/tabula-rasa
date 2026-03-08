# Phase 8: Setup Workflow - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Conversational onboarding via `/setup` skill where the agent learns about the user and generates its own persona (name, gender, personality). Persona persists to MEMORY.md and loads automatically. Includes project-scoped persona override via `/setup` in a project folder, and `/reset-persona` to wipe and start fresh. The dynamic identity reading/fallback mechanism already exists from Phase 7 — this phase writes the persona.

</domain>

<decisions>
## Implementation Decisions

### Conversation flow
- Casual interview style — relaxed back-and-forth, feels like onboarding a new hire
- 5-8 questions total, not a rigid questionnaire
- Topics to cover: work domain (what you do, what kind of projects), communication style (blunt vs diplomatic, verbose vs terse), work habits (solo/team, iteration speed, planning style)
- Tool ecosystem is NOT asked about — agent discovers tools from environment naturally

### Name reveal
- Agent reveals its chosen name at the end of the conversation — culminating moment after all info gathered
- Not mid-conversation, not as a choice between options

### Name veto
- User can reject the name once and ask the agent to try again
- If rejected a second time, offer to let the user pick their own name
- Keeps "agent has agency" feel while giving user comfort

### Claude's Discretion
- Self-naming style — range of names and personalities the agent can generate (serious vs playful, cultural range, gender expression)
- Project-scoped persona — how /setup behaves inside a project folder, what overrides global vs what carries over
- Reset behavior — what /reset-persona wipes (name+personality vs learned preferences), whether it triggers re-setup automatically
- Question ordering and how to handle terse/short user answers
- Exact persona data structure written to MEMORY.md

</decisions>

<specifics>
## Specific Ideas

- The setup should feel like an onboarding conversation, not a form — each answer should influence the next question
- The name reveal is a moment — agent should present it with confidence ("Based on our conversation, I'm going to call myself [Name]") not timidly

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `~/.claude/agent-memory/signe/MEMORY.md`: Already auto-loaded by Claude Code via `memory: user` scope — persona writes here
- `signe.md` agent prompt: Already has persona loading logic ("If your MEMORY.md contains a persona definition, adopt that identity fully")
- `signe.md` already includes one-time /setup hint for new users

### Established Patterns
- Agent identity loaded from first lines of system prompt + MEMORY.md contents
- Skills live at `~/.claude/skills/{name}/SKILL.md` with YAML frontmatter
- All 5 agents use `memory: user` — persona in MEMORY.md is visible to all of them
- Flat orchestration — only signe.md spawns subagents

### Integration Points
- `/setup` skill needs to be created at `~/.claude/skills/signe-setup/SKILL.md`
- `/reset-persona` skill needs to be created (separate skill file)
- Persona written to `~/.claude/agent-memory/signe/MEMORY.md` — must not overwrite existing memory content (agent-recipes.md index, etc.)
- Project-scoped persona likely uses `~/.claude/projects/{project-hash}/MEMORY.md` or similar Claude Code native mechanism

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-setup-workflow*
*Context gathered: 2026-03-08*
