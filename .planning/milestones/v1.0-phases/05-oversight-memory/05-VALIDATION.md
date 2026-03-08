---
phase: 5
slug: oversight-memory
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual validation (Claude Code agent package — no automated test framework) |
| **Config file** | None — validation is behavioral/functional |
| **Quick run command** | `claude -p "invoke /signe-oversee on the signe project"` |
| **Full suite command** | Manual invocation of each capability (5 lenses, plan gap, progress, quality gate) |
| **Estimated runtime** | ~3-5 minutes per manual validation |

---

## Sampling Rate

- **After every task commit:** Manual invocation of modified capability
- **After every plan wave:** Full review of completed agent definition against requirements
- **Before `/gsd:verify-work`:** Human validation of all OVRS and METH requirements end-to-end
- **Max feedback latency:** ~60 seconds (agent spawn + review)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | OVRS-01 | manual (e2e) | Invoke `/signe-oversee`, verify agent spawns | ❌ W0 | ⬜ pending |
| 05-01-02 | 01 | 1 | OVRS-02 | manual (e2e) | Invoke full review, check 5 lens sections | ❌ W0 | ⬜ pending |
| 05-01-03 | 01 | 1 | OVRS-03 | manual (e2e) | Invoke with plan scope, check gap report | ❌ W0 | ⬜ pending |
| 05-01-04 | 01 | 1 | OVRS-04 | manual (e2e) | Invoke with progress scope, check summary | ❌ W0 | ⬜ pending |
| 05-01-05 | 01 | 1 | OVRS-05 | manual (e2e) | Invoke with gate scope, check verdict | ❌ W0 | ⬜ pending |
| 05-01-06 | 01 | 1 | OVRS-06 | manual (e2e) | Check finding has file, line, severity, fix | ❌ W0 | ⬜ pending |
| 05-02-01 | 02 | 2 | METH-01 | manual (behavioral) | Ask Signe to create agent, verify research step | ❌ W0 | ⬜ pending |
| 05-02-02 | 02 | 2 | METH-02 | manual (behavioral) | Check designed agent uses structured methodology | ❌ W0 | ⬜ pending |
| 05-02-03 | 02 | 2 | METH-03 | manual (behavioral) | Ask Signe to test agent, verify sample task | ❌ W0 | ⬜ pending |
| 05-02-04 | 02 | 2 | METH-04 | manual (behavioral) | Verify validation step with concrete criteria | ❌ W0 | ⬜ pending |
| 05-02-05 | 02 | 2 | METH-05 | manual (behavioral) | Check agent-recipes.md for banked entry | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `signe/agents/signe-overseer.md` — the main agent definition (does not exist yet)
- [ ] `signe/skills/signe-oversee/SKILL.md` — the skill entry point (does not exist yet)
- [ ] `~/.claude/agent-memory/signe/agent-recipes.md` — methodology playbook topic file (does not exist yet)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Multi-lens code review produces 5 categorized sections | OVRS-02 | Agent output is conversational, not programmatically testable | Invoke `/signe-oversee` on a real project, verify security/performance/correctness/coverage/style sections present |
| Plan gap report includes file:line references | OVRS-03 | Requires real plan + implementation to compare | Create a plan, implement partially, invoke overseer, check gap table |
| Quality gate verdict (PASS/WARN/FAIL) | OVRS-05 | Verdict depends on real codebase analysis | Invoke quality gate, verify verdict is one of three levels |
| Research-before-design methodology | METH-01 | Behavioral — must observe Signe's process | Ask Signe to design a new agent, verify she researches first |
| Dry-run testing of new agents | METH-03 | Behavioral — must observe Signe spawning test agent | Ask Signe to test a new agent definition, verify sample task runs |
| Pattern banking in memory | METH-05 | Must verify file write + correct format | After methodology cycle, check agent-recipes.md for new entry |

---

## Validation Sign-Off

- [ ] All tasks have manual verification instructions
- [ ] Wave 0 covers all missing agent/skill files
- [ ] No automated test infrastructure needed (agent package, not software project)
- [ ] Feedback latency < 60s per manual check
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
