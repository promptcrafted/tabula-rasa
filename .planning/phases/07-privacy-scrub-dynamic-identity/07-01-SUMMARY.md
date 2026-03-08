---
phase: 07-privacy-scrub-dynamic-identity
plan: 01
subsystem: packaging
tags: [privacy, scrub, agent-files, template, public-release]

# Dependency graph
requires: []
provides:
  - "Scrubbed agent/rule/skill files free of personal references"
  - "Template CLAUDE.md with placeholder sections for user customization"
  - "SIGNE-GUIDE.md removed (Phase 9 creates proper user guide)"
affects: [07-02, 09-privacy-scrub-dynamic-identity]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Generic MCP tool category references instead of specific tool names"
    - "Placeholder sections with HTML comments for user customization"

key-files:
  created: []
  modified:
    - "~/.claude/agents/signe.md"
    - "~/.claude/agents/signe-designer.md"
    - "~/.claude/agents/signe-researcher.md"
    - "~/.claude/agents/signe-test-agent.md"
    - "~/.claude/CLAUDE.md"

key-decisions:
  - "Replaced specific MCP tool names (brave-search, tavily, exa, context7, arxiv) with generic category references (web search MCP tools, library docs tools, academic tools)"
  - "Template CLAUDE.md uses HTML comment placeholders for user customization sections"
  - "Updated signe-test-agent file counts after SIGNE-GUIDE.md removal (20->19 files)"
  - "Kept example MCP tool names in HTML comments as instructional placeholders in template CLAUDE.md"

patterns-established:
  - "MCP tool references in agent files use generic categories, not specific tool names"

requirements-completed: [PKG-02]

# Metrics
duration: 2min
completed: 2026-03-08
---

# Phase 7 Plan 01: Privacy Scrub Summary

**Removed all personal references (paths, usernames, project names, MCP configs) from 15 agent/rule/skill files and replaced CLAUDE.md with a clean user-customizable template**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-08T21:05:35Z
- **Completed:** 2026-03-08T21:07:59Z
- **Tasks:** 2
- **Files modified:** 5 (plus 1 deleted)

## Accomplishments
- Scrubbed all MCP-specific tool references from signe.md, signe-designer.md, and signe-researcher.md (replaced specific tool names with generic categories)
- Replaced CLAUDE.md with a clean template containing placeholder sections for users to fill in their own MCP tools and projects
- Deleted SIGNE-GUIDE.md (Phase 9 will create a proper user guide)
- Updated signe-test-agent.md health check counts to reflect SIGNE-GUIDE.md removal

## Task Commits

Files modified are outside the project git repo (~/.claude/), so per-task commits are not applicable within scale-research. Changes were applied directly to the user-global agent files.

1. **Task 1: Audit and scrub all agent, rule, and skill files** - N/A (external files)
2. **Task 2: Replace CLAUDE.md with template and delete SIGNE-GUIDE.md** - N/A (external files)

## Files Created/Modified
- `~/.claude/agents/signe.md` - Removed specific MCP tool enumeration (Brave, Tavily, Exa, Context7, Obsidian)
- `~/.claude/agents/signe-designer.md` - Cleared mcpServers frontmatter (was: brave-search, context7, exa)
- `~/.claude/agents/signe-researcher.md` - Replaced all specific MCP tool references with generic categories throughout methodology sections
- `~/.claude/agents/signe-test-agent.md` - Updated file counts from 20 to 19, removed SIGNE-GUIDE.md from checklist
- `~/.claude/CLAUDE.md` - Complete rewrite as clean template with placeholder sections
- `~/.claude/SIGNE-GUIDE.md` - Deleted

## Decisions Made
- Replaced specific MCP tool names with generic category references (e.g., "brave-search" becomes "web search MCP tools") to keep agent methodology intact while removing user-specific tool configurations
- Template CLAUDE.md uses HTML comment placeholders (<!-- -->) for user customization sections rather than blank sections, providing instructional examples
- Kept mcpServers as empty array `[]` in designer and researcher frontmatter rather than removing the field entirely, preserving the schema for users to fill in

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Updated signe-test-agent health check counts**
- **Found during:** Task 1 (agent file audit)
- **Issue:** signe-test-agent.md referenced SIGNE-GUIDE.md in its health check file list (20 files). Since Task 2 deletes that file, the health check would report a false failure.
- **Fix:** Removed SIGNE-GUIDE.md from the checklist, updated count from 20 to 19
- **Files modified:** ~/.claude/agents/signe-test-agent.md
- **Verification:** File counts consistent with actual file inventory after SIGNE-GUIDE.md deletion

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Necessary to keep health check accurate after guide deletion. No scope creep.

## Issues Encountered
- Agent files live at ~/.claude/ which is outside the project git repo (scale-research). Per-task git commits could not be created for the actual file changes. This is a structural limitation of the project layout, not an execution error.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All agent files scrubbed clean of personal references
- Template CLAUDE.md ready for user customization
- Plan 02 (dynamic identity) can proceed -- "Signe" name references were intentionally preserved per plan instructions

---
*Phase: 07-privacy-scrub-dynamic-identity*
*Completed: 2026-03-08*
