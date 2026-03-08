# Requirements: tabula-rasa

**Defined:** 2026-03-08
**Core Value:** Chain research -> plan -> design -> oversee in a single coherent workflow, with a dynamic persona that self-personalizes to each user.

## v1.1 Requirements

Requirements for public release. Each maps to roadmap phases.

### Setup & Persona

- [ ] **SETUP-01**: User runs `/setup` and agent conducts conversational onboarding to learn about user and their work
- [ ] **SETUP-02**: Agent generates its own name, gender, and personality based on setup conversation
- [ ] **SETUP-03**: Agent persona persists in user-scope MEMORY.md and loads automatically every session
- [ ] **SETUP-04**: User can run `/setup` in a project folder to create a project-scoped persona that overrides global
- [ ] **SETUP-05**: User can run `/reset-persona` to wipe persona and re-run setup from scratch

### Packaging

- [ ] **PKG-01**: Install script (bash) clones repo and copies files to `~/.claude/` with conflict detection
- [ ] **PKG-02**: All personal paths, MCP configs, Obsidian/vexp/GSD-specific references scrubbed from source
- [ ] **PKG-03**: Hardcoded "Signe" identity replaced with dynamic persona references throughout agent prompts

### Documentation

- [ ] **DOC-01**: README.md with features overview, install instructions, mode examples
- [ ] **DOC-02**: User guide rewritten as generic guide with all modes documented

## Future Requirements

Deferred to v1.2+. Tracked but not in current roadmap.

### Advanced Intelligence

- **ADV-01**: Cross-project pattern recognition
- **ADV-02**: Model-aware prompt optimization
- **ADV-03**: Agent teams integration (pending Windows support)

### Advanced Memory

- **MEM-01**: Automatic memory curation via PostToolUse hooks
- **MEM-02**: Progressive knowledge distillation

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Prefix rename (signe-* -> generic) | High churn, low user value -- users don't see filenames |
| Uninstall script | Nice-to-have, add in v1.2 if requested |
| CONTRIBUTING.md | Premature unless contributors appear |
| npm/npx distribution | Git clone is simpler and sufficient for now |
| GUI or web dashboard | CLI agent only |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SETUP-01 | Phase 8 | Pending |
| SETUP-02 | Phase 8 | Pending |
| SETUP-03 | Phase 8 | Pending |
| SETUP-04 | Phase 8 | Pending |
| SETUP-05 | Phase 8 | Pending |
| PKG-01 | Phase 9 | Pending |
| PKG-02 | Phase 7 | Pending |
| PKG-03 | Phase 7 | Pending |
| DOC-01 | Phase 9 | Pending |
| DOC-02 | Phase 9 | Pending |

**Coverage:**
- v1.1 requirements: 10 total
- Mapped to phases: 10
- Unmapped: 0

---
*Requirements defined: 2026-03-08*
*Last updated: 2026-03-08 after roadmap creation*
