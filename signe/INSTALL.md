# Signe Installation

1. Copy all files from `signe/` to `~/.claude/`:
   - `agents/signe.md` and `agents/signe-test-agent.md` -> `~/.claude/agents/`
   - `rules/signe-*.md` -> `~/.claude/rules/`
   - `hooks/signe-lifecycle.js` -> `~/.claude/hooks/`
   - `skills/signe-health/` -> `~/.claude/skills/signe-health/`
   - `agent-memory/signe/` -> `~/.claude/agent-memory/signe/`
   - `CLAUDE.md` -> `~/.claude/CLAUDE.md`

2. Replace `~/.claude/settings.json` with `signe/settings-merge.json` (rename to `settings.json`).
   This file preserves all existing GSD entries and adds Signe's permission patterns and hooks.

3. Verify: run `/signe-health` from any project directory.
