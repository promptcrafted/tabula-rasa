---
phase: 1
slug: foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-07
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual validation via `/signe-health` skill |
| **Config file** | None — validation is built into the skill itself |
| **Quick run command** | `/signe-health` |
| **Full suite command** | `/signe-health` (single comprehensive check) |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `/signe-health`
- **After every plan wave:** Run `/signe-health`
- **Before `/gsd:verify-work`:** `/signe-health` must report HEALTHY
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | INFRA-01 | manual | Run `/signe-health` from two different project directories | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | INFRA-02 | smoke | `/signe-health` spawns `signe-test-agent` and gets structured output | ❌ W0 | ⬜ pending |
| 01-01-03 | 01 | 1 | INFRA-03 | manual | Visual inspection of file names for `signe-` prefix | N/A | ⬜ pending |
| 01-01-04 | 01 | 1 | INFRA-04 | manual | `wc -l ~/.claude/CLAUDE.md` and visual inspection of first 10 lines | N/A | ⬜ pending |
| 01-01-05 | 01 | 1 | INFRA-05 | smoke | `/signe-health` runs without permission prompts | ❌ W0 | ⬜ pending |
| 01-01-06 | 01 | 1 | INFRA-06 | smoke | `/signe-health` triggers SubagentStart/Stop, observe log output | ❌ W0 | ⬜ pending |
| 01-01-07 | 01 | 1 | INFRA-07 | smoke | `/signe-health` checks for agent-memory/signe/MEMORY.md | ❌ W0 | ⬜ pending |
| 01-01-08 | 01 | 1 | INFRA-10 | manual | Inspect signe.md frontmatter for flat orchestration constraint | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `signe-health/SKILL.md` — skill that validates entire installation (covers INFRA-01, INFRA-02, INFRA-05, INFRA-06, INFRA-07)
- [ ] `signe-test-agent.md` — minimal read-only agent spawned by signe-health
- No external test framework needed — the skill IS the test

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| `signe-` prefix on all files | INFRA-03 | Naming convention, not runtime behavior | List all signe-* files, verify no non-prefixed files |
| CLAUDE.md under 100 lines | INFRA-04 | Static file property | Run `wc -l ~/.claude/CLAUDE.md`, inspect first 10 lines |
| Flat orchestrator constraint | INFRA-10 | Design constraint in agent definition | Read signe.md, verify it documents no nested spawning |
| Global availability | INFRA-01 | Requires running from different directories | Run `/signe-health` from two different project folders |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
