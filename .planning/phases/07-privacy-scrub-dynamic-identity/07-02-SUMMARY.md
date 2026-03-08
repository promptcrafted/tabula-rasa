---
phase: 07-privacy-scrub-dynamic-identity
plan: 02
subsystem: packaging
tags: [dynamic-identity, persona, agent-files, public-release]

# Dependency graph
requires:
  - phase: 07-01
    provides: "Scrubbed agent files free of personal references"
provides:
  - "Dynamic persona loading from MEMORY.md in main orchestrator"
  - "Role-only fallback identity across all agent/rule/skill files"
  - "One-time /setup hint for new users"
  - "Gender-neutral language throughout all agent files"
affects: [08-setup-command, 09-docs]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dynamic persona loading from MEMORY.md with role-only fallback"
    - "Subagents inherit persona from task context, not hardcoded identity"
    - "One-time /setup hint pattern for first interaction"

key-files:
  created: []
  modified:
    - "~/.claude/agents/signe.md"
    - "~/.claude/agents/signe-designer.md"
    - "~/.claude/agents/signe-overseer.md"
    - "~/.claude/agents/signe-planner.md"
    - "~/.claude/agents/signe-researcher.md"
    - "~/.claude/agents/signe-test-agent.md"
    - "~/.claude/rules/signe-personality.md"
    - "~/.claude/rules/signe-delegation.md"
    - "~/.claude/rules/signe-safety.md"
    - "~/.claude/skills/signe/SKILL.md"
    - "~/.claude/skills/signe-health/SKILL.md"

key-decisions:
  - "Main orchestrator loads persona from MEMORY.md, falls back to role-only with gender-neutral language"
  - "Subagents accept persona from task context rather than having their own persona logic"
  - "One-time /setup hint embedded in main orchestrator system prompt only"
  - "Replaced 'Signe' with 'The agent' in rules, 'the chief of staff agent' in descriptions"

patterns-established:
  - "Dynamic persona: MEMORY.md persona definition -> adopt identity; no persona -> role-only"
  - "Subagent persona inheritance: persona passed via task prompt context, not hardcoded"

requirements-completed: [PKG-03]

# Metrics
duration: 3min
completed: 2026-03-08
---

# Phase 7 Plan 02: Dynamic Identity Summary

**Replaced all hardcoded "Signe" identity with dynamic persona loading from MEMORY.md, role-only fallback, and /setup hint across 11 agent/rule/skill files**

## Performance

- **Duration:** 3 min
- **Started:** 2026-03-08T21:10:23Z
- **Completed:** 2026-03-08T21:13:44Z
- **Tasks:** 2
- **Files modified:** 11

## Accomplishments
- Main orchestrator (signe.md) now loads persona from MEMORY.md, falls back to role-only identity with gender-neutral language
- One-time /setup hint added for first interaction with users who have no persona defined
- All 5 subagent files updated with persona inheritance from task context
- All 3 rules files updated to use "The agent" instead of "Signe" identity references
- Skill description files updated to remove identity references while preserving signe- filename prefixes

## Task Commits

Files modified are outside the project git repo (~/.claude/), so per-task commits are not applicable within scale-research. Changes were applied directly to the user-global agent files.

1. **Task 1: Replace identity in all agent system prompts** - N/A (external files)
2. **Task 2: Replace identity in rules, skills, and CLAUDE.md** - N/A (external files)

## Files Created/Modified
- `~/.claude/agents/signe.md` - Dynamic persona loading from MEMORY.md, /setup hint, role-only fallback
- `~/.claude/agents/signe-designer.md` - Persona inheritance from task context, role-only fallback
- `~/.claude/agents/signe-overseer.md` - Persona inheritance from task context, role-only fallback, replaced "Signe's maker-checker"
- `~/.claude/agents/signe-planner.md` - Persona inheritance from task context, role-only fallback
- `~/.claude/agents/signe-researcher.md` - Persona inheritance from task context, role-only fallback
- `~/.claude/agents/signe-test-agent.md` - Persona inheritance, updated health report header and description
- `~/.claude/rules/signe-personality.md` - "The agent" replaces "Signe", gender-neutral pronouns
- `~/.claude/rules/signe-delegation.md` - "The agent" replaces "Signe" in core principle and decision tree
- `~/.claude/rules/signe-safety.md` - "The agent" replaces "Signe" in all constraint headers and body text
- `~/.claude/skills/signe/SKILL.md` - Removed "Signe modes" from description
- `~/.claude/skills/signe-health/SKILL.md` - "Agent" replaces "Signe" in description and health report headers

## Decisions Made
- Used "The agent" as the standard replacement for "Signe" in rules and safety constraints -- consistent, professional, role-focused
- Subagents inherit persona from task prompt context rather than having their own MEMORY.md logic -- keeps persona management centralized in the orchestrator
- /setup hint placed only in main orchestrator, not subagents -- subagents are never directly invoked by users
- Preserved all signe- filename prefixes throughout -- these are filesystem identifiers, not persona

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Updated signe-health SKILL.md identity references**
- **Found during:** Task 2 (rules/skills audit)
- **Issue:** signe-health/SKILL.md had "Signe" in description, section header, and health report template -- these are identity references, not filename prefixes, but were not explicitly listed in the plan
- **Fix:** Replaced "Validate Signe installation" with "Validate agent installation", "Signe Health Check" with "Agent Health Check", "Signe Health Report" with "Agent Health Report"
- **Files modified:** ~/.claude/skills/signe-health/SKILL.md
- **Verification:** grep confirms zero remaining Signe identity references

**2. [Rule 2 - Missing Critical] Updated signe/SKILL.md description**
- **Found during:** Task 2 (skills audit)
- **Issue:** Main skill SKILL.md description referenced "multiple Signe modes" -- identity reference in description text
- **Fix:** Changed to "multiple agent modes"
- **Files modified:** ~/.claude/skills/signe/SKILL.md
- **Verification:** grep confirms zero remaining Signe identity references

---

**Total deviations:** 2 auto-fixed (2 missing critical)
**Impact on plan:** Both fixes necessary for complete identity replacement. No scope creep.

## Issues Encountered
- Agent files live at ~/.claude/ which is outside the project git repo (scale-research). Per-task git commits could not be created for the actual file changes. This is a structural limitation of the project layout, not an execution error.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All agent files now use dynamic persona system -- ready for /setup command implementation (Phase 8)
- MEMORY.md persona format needs to be defined when /setup is built
- Chief-of-staff personality ships as default behavior, not gated behind /setup

---
*Phase: 07-privacy-scrub-dynamic-identity*
*Completed: 2026-03-08*
