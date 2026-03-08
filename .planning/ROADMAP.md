# Roadmap: tabula-rasa

## Milestones

- ✅ **v1.0 Signe** -- Phases 1-6 (shipped 2026-03-08)
- 🚧 **v1.1 Public Release** -- Phases 7-9 (in progress)

## Phases

<details>
<summary>v1.0 Signe (Phases 1-6) -- SHIPPED 2026-03-08</summary>

- [x] Phase 1: Foundation (3/3 plans) -- completed 2026-03-08
- [x] Phase 2: Research Mode (2/2 plans) -- completed 2026-03-08
- [x] Phase 3: Planning Mode (2/2 plans) -- completed 2026-03-08
- [x] Phase 4: Design Modes (2/2 plans) -- completed 2026-03-08
- [x] Phase 5: Oversight + Memory (4/4 plans) -- completed 2026-03-08
- [x] Phase 6: Workflow + GSD Integration (2/2 plans) -- completed 2026-03-08

</details>

### v1.1 Public Release

- [ ] **Phase 7: Privacy Scrub & Dynamic Identity** - Remove private references and replace hardcoded Signe identity with dynamic persona system
- [ ] **Phase 8: Setup Workflow** - Conversational onboarding where agent learns user context and self-personalizes
- [ ] **Phase 9: Packaging & Documentation** - Install script, README, and user guide for public release

## Phase Details

### Phase 7: Privacy Scrub & Dynamic Identity
**Goal**: Codebase is clean of all private references and supports dynamic persona instead of hardcoded "Signe"
**Depends on**: Phase 6 (v1.0 complete)
**Requirements**: PKG-02, PKG-03
**Success Criteria** (what must be TRUE):
  1. No personal file paths, MCP API keys, Obsidian vault references, or vexp-specific content remain in any agent file
  2. All agent prompts, rules, and skills reference the persona dynamically (from MEMORY.md or persona config) rather than using "Signe" literally
  3. Agent loads without errors after identity replacement -- all 5 modes and pipeline chaining still function
  4. A fresh user with no persona set sees generic/placeholder identity rather than "Signe"
**Plans**: TBD

Plans:
- [ ] 07-01: Privacy scrub -- audit and remove all personal/private references
- [ ] 07-02: Dynamic identity system -- replace hardcoded Signe with persona-aware references

### Phase 8: Setup Workflow
**Goal**: New users experience conversational onboarding that creates a personalized agent identity
**Depends on**: Phase 7 (dynamic identity system must exist for setup to write into it)
**Requirements**: SETUP-01, SETUP-02, SETUP-03, SETUP-04, SETUP-05
**Success Criteria** (what must be TRUE):
  1. User runs `/setup` and agent asks about their work, preferences, and how they want their chief of staff to behave
  2. Agent generates a name, gender, and personality for itself based on the conversation and persists it to user-scope MEMORY.md
  3. On next session start, agent loads its persona automatically and uses the chosen name/personality throughout all interactions
  4. User runs `/setup` inside a project folder and gets a project-scoped persona that overrides the global one for that project
  5. User runs `/reset-persona` and persona is wiped, returning agent to pre-setup state ready for fresh onboarding
**Plans**: TBD

Plans:
- [ ] 08-01: Core setup skill and persona persistence
- [ ] 08-02: Project-scoped persona override and reset workflow

### Phase 9: Packaging & Documentation
**Goal**: Project is installable from GitHub with clear documentation for new users
**Depends on**: Phase 7 (scrubbed source), Phase 8 (setup workflow to document)
**Requirements**: PKG-01, DOC-01, DOC-02
**Success Criteria** (what must be TRUE):
  1. User clones repo, runs install script, and has a working agent at `~/.claude/` with conflict detection for existing files
  2. README.md on the repo landing page explains what the agent is, how to install it, and shows examples of each mode
  3. User guide documents all 5 modes with usage examples, the setup workflow, and persona customization
**Plans**: TBD

Plans:
- [ ] 09-01: Install script with conflict detection
- [ ] 09-02: README and user guide

## Progress

**Execution Order:** Phase 7 -> Phase 8 -> Phase 9

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Foundation | v1.0 | 3/3 | Complete | 2026-03-08 |
| 2. Research Mode | v1.0 | 2/2 | Complete | 2026-03-08 |
| 3. Planning Mode | v1.0 | 2/2 | Complete | 2026-03-08 |
| 4. Design Modes | v1.0 | 2/2 | Complete | 2026-03-08 |
| 5. Oversight + Memory | v1.0 | 4/4 | Complete | 2026-03-08 |
| 6. Workflow + GSD Integration | v1.0 | 2/2 | Complete | 2026-03-08 |
| 7. Privacy Scrub & Dynamic Identity | v1.1 | 0/2 | Not started | - |
| 8. Setup Workflow | v1.1 | 0/2 | Not started | - |
| 9. Packaging & Documentation | v1.1 | 0/2 | Not started | - |
