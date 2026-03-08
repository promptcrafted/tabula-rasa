---
phase: 6
slug: workflow-gsd-integration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-08
---

# Phase 6 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual end-to-end validation (human-verified) |
| **Config file** | None — Signe is a prompt engineering project, not a code project |
| **Quick run command** | `/signe-health` |
| **Full suite command** | Manual: invoke `/signe all Build a simple REST API` and verify pipeline completes |
| **Estimated runtime** | ~5 minutes (full pipeline) |

---

## Sampling Rate

- **After every task commit:** Run `/signe-health`
- **After every plan wave:** Manual full pipeline test
- **Before `/gsd:verify-work`:** Human verification of all 7 requirements via end-to-end workflow
- **Max feedback latency:** ~30 seconds (health check)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 06-01-01 | 01 | 1 | INFRA-08 | e2e manual | `/signe all [test goal]` | N/A — Wave 0 | ⬜ pending |
| 06-01-02 | 01 | 1 | CHST-05 | e2e manual | Verify handoff content between modes | N/A — Wave 0 | ⬜ pending |
| 06-01-03 | 01 | 1 | CHST-04 | e2e manual | `/signe design+oversee [test goal]` | N/A — Wave 0 | ⬜ pending |
| 06-02-01 | 02 | 1 | INFRA-09 | e2e manual | Invoke from project dir, verify scoped reads | N/A — Wave 0 | ⬜ pending |
| 06-02-02 | 02 | 1 | CHST-01 | e2e manual | Verify risk surfacing in workflow output | N/A — Wave 0 | ⬜ pending |
| 06-02-03 | 02 | 1 | CHST-02 | e2e manual | Verify summaries after each mode | N/A — Wave 0 | ⬜ pending |
| 06-02-04 | 02 | 1 | CHST-03 | e2e manual | Verify recommendations in summary | N/A — Wave 0 | ⬜ pending |
| 06-03-01 | 03 | 2 | ALL | e2e manual | Full deployment + human validation | N/A — Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Update `/signe-health` to validate new `/signe` skill and updated files
- [ ] No test framework setup needed — prompt engineering project with manual validation

*Existing `/signe-health` infrastructure covers installation validation.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Full pipeline chains modes | INFRA-08 | Requires running 4 subagents sequentially | Invoke `/signe all Build a simple REST API`, verify each mode runs and output feeds forward |
| GSD reads scoped to cwd | INFRA-09 | Requires project directory context | Invoke from a project dir with `.planning/`, verify reads are scoped correctly |
| Proactive risk surfacing | CHST-01 | Requires evaluating natural language output | Check workflow output for risk identification after each stage |
| Milestone summaries | CHST-02 | Requires evaluating structured output | Check for summary blocks after each mode completion |
| Next action recommendations | CHST-03 | Requires evaluating recommendation quality | Check workflow end for ranked next steps |
| Maker-checker iteration | CHST-04 | Requires triggering quality gate failure | Invoke `/signe design+oversee [complex goal]`, verify iteration occurs on FAIL |
| Mode-aware handoffs | CHST-05 | Requires evaluating handoff content | Verify each mode transition includes tailored context for the receiving mode |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
