---
phase: 3
slug: planning-mode
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-07
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual end-to-end validation |
| **Config file** | None -- validation is human-driven invocation |
| **Quick run command** | `/signe-plan "Build a REST API for user management"` |
| **Full suite command** | Run quick command + verify output file structure |
| **Estimated runtime** | ~60 seconds (agent execution time) |

---

## Sampling Rate

- **After every task commit:** Verify file structure and frontmatter validity
- **After every plan wave:** Run `/signe-plan` with a real goal and inspect output
- **Before `/gsd:verify-work`:** Full end-to-end validation with output inspection
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 01 | 1 | PLAN-01 | manual | Invoke `/signe-plan "test goal"` and verify agent spawns | Wave 0 | ⬜ pending |
| 03-01-02 | 01 | 1 | PLAN-02, PLAN-03 | manual | Check output has Phases section with depends_on and rationale | Wave 0 | ⬜ pending |
| 03-01-03 | 01 | 1 | PLAN-04 | manual | Place `signe-research-*.md` in cwd, invoke planner, verify integration | Wave 0 | ⬜ pending |
| 03-01-04 | 01 | 1 | PLAN-05 | manual | Check each criterion is boolean YES/NO testable | Wave 0 | ⬜ pending |
| 03-01-05 | 01 | 1 | PLAN-06 | manual | Check phases have Ordering Rationale with deps/risk/value | Wave 0 | ⬜ pending |
| 03-01-06 | 01 | 1 | PLAN-07 | manual | Check In Scope and Out of Scope tables with Rationale | Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- No automated test infrastructure needed -- validation follows the same manual end-to-end pattern established in Phase 1 and Phase 2
- The deployment and validation plan handles live testing

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `/signe-plan` spawns signe-planner agent | PLAN-01 | Agent spawning requires live Claude Code session | Invoke from fresh session, verify agent runs |
| Planner reads research output | PLAN-04 | Requires real research files in working directory | Place signe-research-*.md, invoke planner, check recap |
| Acceptance criteria are verifiable | PLAN-05 | Quality judgment -- boolean testability is subjective | Review each criterion manually |
| Scope boundaries stated with reasoning | PLAN-07 | Requires human judgment on reasoning quality | Check In/Out of Scope tables |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
