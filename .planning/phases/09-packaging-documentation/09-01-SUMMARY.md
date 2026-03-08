---
phase: 09-packaging-documentation
plan: 01
subsystem: packaging
tags: [install-script, bash, repo-structure, agent-packaging]

requires:
  - phase: 08-setup-workflow
    provides: setup agent, reset-persona skill, dynamic persona system
provides:
  - Top-level repo structure with agents/, skills/, rules/, templates/, hooks/
  - install.sh with conflict detection, backup, and CLAUDE.md protection
affects: [09-02, 09-03]

tech-stack:
  added: [bash-installer]
  patterns: [conflict-detection-with-backup, idempotent-install]

key-files:
  created:
    - install.sh
    - agents/signe.md
    - agents/signe-designer.md
    - agents/signe-overseer.md
    - agents/signe-planner.md
    - agents/signe-researcher.md
    - agents/signe-setup-agent.md
    - agents/signe-test-agent.md
    - rules/signe-delegation.md
    - rules/signe-personality.md
    - rules/signe-safety.md
    - skills/signe/SKILL.md
    - skills/signe-design/SKILL.md
    - skills/signe-health/SKILL.md
    - skills/signe-oversee/SKILL.md
    - skills/signe-plan/SKILL.md
    - skills/signe-research/SKILL.md
    - skills/signe-setup/SKILL.md
    - skills/signe-reset-persona/SKILL.md
    - templates/CLAUDE.md
    - hooks/signe-lifecycle.js
    - settings-merge.json
  modified: []

key-decisions:
  - "Source of truth is ~/.claude/ for all agent files (Phase 7-8 updated in place)"
  - "Hooks and settings-merge.json sourced from old signe/ dir (unchanged in Phase 7-8)"
  - "install.sh never auto-merges settings.json -- user must manually merge"

patterns-established:
  - "Repo mirrors ~/.claude/ layout: agents/, skills/, rules/, templates/, hooks/"
  - "Timestamped backup before overwrite: ~/.claude/backups/tabula-rasa-YYYYMMDD-HHMMSS/"

requirements-completed: [PKG-01]

duration: 2min
completed: 2026-03-08
---

# Phase 9 Plan 1: Repo Restructure and Install Script Summary

**Top-level repo structure with 21 synced agent files plus bash install script with conflict detection and timestamped backup**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-08T22:11:50Z
- **Completed:** 2026-03-08T22:13:44Z
- **Tasks:** 2
- **Files modified:** 25 (21 agent files created, old signe/ removed, install.sh created)

## Accomplishments
- Restructured repo from signe/ subdirectory to top-level agents/, skills/, rules/, templates/, hooks/
- Synced all 21 agent files from ~/.claude/ (the Phase 7-8 source of truth)
- Created install.sh with pre-flight checks, conflict detection, timestamped backup, and CLAUDE.md protection
- Removed stale v1.0 signe/ directory and review file

## Task Commits

Each task was committed atomically:

1. **Task 1: Restructure repo and sync agent files** - `f51003a` (feat)
2. **Task 2: Create install.sh with conflict detection** - `313c526` (feat)

## Files Created/Modified
- `agents/signe*.md` (7 files) - All agent definitions synced from ~/.claude/
- `skills/signe*/SKILL.md` (8 dirs) - All skill definitions synced from ~/.claude/
- `rules/signe-*.md` (3 files) - Delegation, personality, safety rules
- `templates/CLAUDE.md` - Template for new user CLAUDE.md
- `hooks/signe-lifecycle.js` - Subagent lifecycle hook
- `settings-merge.json` - Settings template for manual merge
- `install.sh` - One-command installer with backup and conflict detection

## Decisions Made
- Source of truth is ~/.claude/ for agents, skills, rules, and CLAUDE.md (Phase 7-8 updated these in place)
- Hooks and settings-merge.json sourced from old signe/ directory before deletion (unchanged in Phase 7-8)
- install.sh never auto-merges settings.json -- prints note for user to manually merge

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Repo is structured and ready for README.md (Plan 02) and user guide (Plan 03)
- install.sh is ready for end-to-end testing once documentation is complete

---
*Phase: 09-packaging-documentation*
*Completed: 2026-03-08*
