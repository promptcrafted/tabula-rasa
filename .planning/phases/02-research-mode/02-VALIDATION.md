---
phase: 2
slug: research-mode
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-07
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual validation (no automated test framework — agent-based system with no runnable test suite) |
| **Config file** | none |
| **Quick run command** | `/signe-research Claude Code agent architecture` |
| **Full suite command** | Run all 4 presets + general query, verify output format |
| **Estimated runtime** | ~120 seconds per query |

---

## Sampling Rate

- **After every task commit:** Verify file structure and YAML frontmatter validity
- **After every plan wave:** Run one research query and verify output format
- **Before `/gsd:verify-work`:** Full suite must pass (all 4 presets + general)
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | RSRCH-01 | smoke | `/signe-research Claude Code agent architecture` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | RSRCH-02 | integration | Verify output cites multiple sources from different tools | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | RSRCH-03 | smoke | `grep -E "HIGH\|MEDIUM\|LOW" output` | ❌ W0 | ⬜ pending |
| 02-01-04 | 01 | 1 | RSRCH-04 | integration | Observe multiple search rounds in agent output | ❌ W0 | ⬜ pending |
| 02-01-05 | 01 | 1 | RSRCH-05 | smoke | Check output has expected sections and inline URLs | ❌ W0 | ⬜ pending |
| 02-01-06 | 01 | 1 | RSRCH-06 | integration | `/signe-research preset:comparison X vs Y`, verify comparison table | ❌ W0 | ⬜ pending |
| 02-01-07 | 01 | 1 | RSRCH-07 | integration | Output includes specific claims from fetched pages | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `signe/agents/signe-researcher.md` — research agent definition (covers RSRCH-01 through RSRCH-07)
- [ ] `signe/skills/signe-research/SKILL.md` — skill entry point (covers RSRCH-01, RSRCH-06)
- [ ] Updated `signe/CLAUDE.md` — research mode status Available
- [ ] Updated `signe/agents/signe.md` — orchestrator research awareness
- [ ] Updated `signe/rules/signe-delegation.md` — delegation routing Available

*All files are Wave 0 dependencies — no pre-existing test infrastructure.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Multi-source search across MCP tools | RSRCH-02 | MCP tools require live API access, no mock available | Run `/signe-research` and verify output cites sources from multiple tools (Brave, Tavily, Exa, Context7, arxiv) |
| Iterative refinement (gap analysis) | RSRCH-04 | Requires observing multi-round agent behavior | Watch agent execution for multiple search rounds |
| Document reading (not just snippets) | RSRCH-07 | Requires verifying content depth vs search snippet | Check findings include specific details only available from full documents |
| Preset-specific output differences | RSRCH-06 | Each preset produces qualitatively different output | Run each preset and compare output structure |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
