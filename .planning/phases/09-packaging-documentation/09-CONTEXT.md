# Phase 9: Packaging & Documentation - Context

**Gathered:** 2026-03-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Make tabula-rasa installable from GitHub with clear documentation for new users. Deliverables: bash install script with conflict detection, README.md for repo landing page, and user guide covering all 5 modes + setup workflow. No new agent features — packaging and documenting what exists.

</domain>

<decisions>
## Implementation Decisions

### Claude's Discretion

User granted full discretion on all areas. The following decisions are Claude's recommendations based on project context, prior phases, and best practices for CLI agent packaging.

#### Install script behavior
- Single `install.sh` bash script at repo root
- Pre-flight checks: verify Claude Code is installed (`claude --version`), verify `~/.claude/` exists
- Copy strategy: agents/, skills/signe*/, rules/signe-*.md, template CLAUDE.md, agent-memory/signe/ directory structure
- Conflict detection: if any target file already exists, show diff summary and ask user to confirm overwrite (backup originals to `~/.claude/backups/tabula-rasa-{timestamp}/`)
- CLAUDE.md handling: only install template if no CLAUDE.md exists — never overwrite user's existing CLAUDE.md (offer to append agent section instead)
- Windows support: script uses bash (Git Bash available on Windows 11) — document Git Bash requirement for Windows users
- Idempotent: safe to re-run for updates — backs up then overwrites

#### README structure & tone
- Concise, developer-focused landing page — not a marketing site
- Structure: What is this (1 paragraph) -> Quick install -> What you get (5 modes, 1 line each) -> Setup walkthrough (the `/setup` moment) -> Examples -> License
- Tone: direct, slightly opinionated — matches the agent's own personality ("Your AI chief of staff")
- Show a single compelling example interaction (research or full pipeline) rather than exhaustive mode docs
- Link to user guide for full documentation
- No badges/shields initially — add later if community forms

#### User guide depth
- Separate `docs/guide.md` file, not inline in README
- Reference-style with short examples per mode, not tutorial-style walkthrough
- Sections: Overview, Installation, Setup & Persona, Modes (research, plan, design, oversee, pipeline), Persona Customization, Troubleshooting
- Each mode section: 1-sentence description, invocation syntax, 1-2 example prompts, what to expect
- Document project-scoped persona and `/reset-persona`
- Keep under 500 lines — scannable, not exhaustive

#### Repo structure
- Mirror `~/.claude/` layout in the repo for clarity:
  ```
  tabula-rasa/
  ├── install.sh
  ├── README.md
  ├── docs/
  │   └── guide.md
  ├── agents/
  │   └── signe*.md
  ├── skills/
  │   └── signe*/SKILL.md
  ├── rules/
  │   └── signe-*.md
  └── templates/
      └── CLAUDE.md
  ```
- `templates/CLAUDE.md` is the template version (with placeholders) — install script copies it
- `agent-memory/` not in repo — created by install script (empty structure)
- `.gitignore`: no special needs (no build artifacts, no secrets)

</decisions>

<specifics>
## Specific Ideas

- Install script should mirror the pattern users expect from CLI tools (curl | bash or clone + run)
- The README "What is this" should land the concept in one paragraph — a chief of staff AI that personalizes itself to you
- User guide should be the doc you wish existed when you started — practical, not theoretical

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- 7 agent files in `~/.claude/agents/signe*.md` (signe.md, signe-designer.md, signe-overseer.md, signe-planner.md, signe-researcher.md, signe-test-agent.md, signe-setup-agent.md)
- 8 skill directories in `~/.claude/skills/signe*/` each containing SKILL.md
- 3 rules files in `~/.claude/rules/signe-*.md` (delegation, personality, safety)
- Template CLAUDE.md at `~/.claude/CLAUDE.md` (already scrubbed in Phase 7)
- GSD install pattern exists but uses Node.js/npm — this project should stay simpler (pure bash)

### Established Patterns
- `signe-` prefix on all files — consistent naming convention to document
- `memory: user` scope in all agent YAML frontmatter — key architectural detail for guide
- Flat orchestration model — important concept to explain in user guide
- Phase 7 scrubbed all personal references — source files are ready to ship as-is

### Integration Points
- Install script copies files into existing `~/.claude/` structure alongside user's other agents/skills
- Template CLAUDE.md must not conflict with user's existing global CLAUDE.md
- `~/.claude/agent-memory/signe/MEMORY.md` needs to exist (even empty) for persona system

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 09-packaging-documentation*
*Context gathered: 2026-03-08*
