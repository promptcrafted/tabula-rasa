# Phase 1: Foundation - Context

**Gathered:** 2026-03-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Signe is globally installed at `~/.claude/` with working infrastructure: CLAUDE.md, settings.json, rules files, hooks (Node.js), and naming conventions (`signe-` prefix). All subsequent agents and skills build on this skeleton. No mode-specific agents (researcher, planner, etc.) are implemented — only the minimum needed to prove the Command -> Agent -> Skill architecture works end-to-end.

</domain>

<decisions>
## Implementation Decisions

### GSD Coexistence
- Single `settings.json` — add Signe's permission patterns (`Agent(signe-*)`, `Skill(signe-*)`) and hooks alongside existing GSD entries in the same file
- Shared hook lifecycle events — GSD hooks listed first, Signe hooks after. Claude Code runs them in array order
- Signe agents (`signe-*`) completely ignore GSD agents (`gsd-*`). No awareness, no interaction. GSD integration comes in Phase 6
- File drop installation with manual `settings.json` merge. No install script. Signe's files are developed in this repo, then copied to `~/.claude/`

### CLAUDE.md Structure
- Self-contained CLAUDE.md at `~/.claude/` — no dependency on project-level CLAUDE.md files (e.g., `Projects/CLAUDE.md`)

### Hook Output
- Hooks output to stdout only (captured by Claude Code session). No log files

### Claude's Discretion (Defer to Research)
The following areas were explicitly deferred to the researcher to determine based on reference repo patterns and Claude Code best practices:

- **Invocation pattern** — Whether to use `/signe-research` (separate skills), `/signe research` (subcommand), or direct agent invocation. Research should determine from reference repo
- **Orchestrator invocability** — Whether signe.md is directly invocable alongside mode skills, or mode skills are the only entry points
- **Model-invocation setting** — Whether `disable-model-invocation: true` should be set on Signe skills
- **Model assignment** — Whether agents inherit the current model or specify cheaper models per role
- **CLAUDE.md first 10 lines** — What goes in the critical opening lines (identity, delegation rules, tool preferences)
- **Personality depth** — How prominent the chief of staff personality framing should be (prominent vs minimal)
- **Rules file structure** — Number and organization of `.claude/rules/` overflow files
- **Test skill design** — What the end-to-end validation skill should do
- **Test skill retention** — Whether to keep the test skill as a permanent diagnostic or remove after validation
- **Placeholder agents** — Whether to create stub files for all planned agents or only the minimum needed

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches. User explicitly wants the researcher to determine best practices from the reference repo (claude-code-best-practice) and Claude Code official documentation.

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `~/.claude/settings.json`: Existing GSD hook configuration (SessionStart, PostToolUse, statusLine) — Signe's entries merge into this
- `~/.claude/hooks/gsd-*.js`: Three Node.js hook scripts — pattern reference for Signe's hook implementation
- `~/.claude/agents/gsd-*.md`: 12 GSD agent definitions — naming convention reference (but Signe ignores them functionally)

### Established Patterns
- All hooks are Node.js (cross-platform compatible with Windows)
- Hook scripts live at `~/.claude/hooks/` with descriptive filenames
- Agents use `.md` files with YAML frontmatter in `~/.claude/agents/`
- settings.json uses hooks array format with `type: "command"` entries

### Integration Points
- `~/.claude/settings.json` — Signe adds permission allow patterns and hook entries
- `~/.claude/agents/` — Signe adds `signe-*.md` agent files alongside `gsd-*.md`
- `~/.claude/hooks/` — Signe adds `signe-*.js` hook scripts alongside `gsd-*.js`
- `~/.claude/skills/` — New directory for Signe's skill definitions (does not exist yet)
- `~/.claude/rules/` — New directory for Signe's rules files (does not exist yet)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-03-07*
