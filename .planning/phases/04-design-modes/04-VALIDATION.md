---
phase: 4
slug: design-modes
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-07
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual end-to-end validation |
| **Config file** | None -- validation is human-driven invocation |
| **Quick run command** | `/signe-design preset:architecture Design the auth system for a SaaS app` |
| **Full suite command** | Run each preset + verify deliverable structure per preset |
| **Estimated runtime** | ~5 minutes per preset (human review) |

---

## Sampling Rate

- **After every task commit:** Verify file structure and frontmatter validity
- **After every plan wave:** Run `/signe-design` with one preset and inspect output
- **Before `/gsd:verify-work`:** Full suite must pass — ALL FOUR presets validated end-to-end
- **Max feedback latency:** ~60 seconds (agent spawn + first output)

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | ARCH-01 | smoke / manual | Invoke `/signe-design preset:architecture [topic]` and verify agent spawns | Wave 0 | ⬜ pending |
| 04-01-02 | 01 | 1 | ARCH-02 | manual | Check output has Component Boundaries section with table | Wave 0 | ⬜ pending |
| 04-01-03 | 01 | 1 | ARCH-03 | manual | Check output has Data Flows section with Mermaid syntax | Wave 0 | ⬜ pending |
| 04-01-04 | 01 | 1 | ARCH-04 | manual | Check output has API Contracts with input/output/error types | Wave 0 | ⬜ pending |
| 04-01-05 | 01 | 1 | ARCH-05 | manual | Check output has ADR section with decision/context/alternatives/rationale | Wave 0 | ⬜ pending |
| 04-01-06 | 01 | 1 | ARCH-06 | manual | Check output has annotated directory tree | Wave 0 | ⬜ pending |
| 04-02-01 | 02 | 1 | UIUX-01 | smoke / manual | Invoke `/signe-design preset:uiux [topic]` | Wave 0 | ⬜ pending |
| 04-02-02 | 02 | 1 | UIUX-02 | manual | Check output has User Flows section | Wave 0 | ⬜ pending |
| 04-02-03 | 02 | 1 | UIUX-03 | manual | Check output has atomic/composite/page hierarchy | Wave 0 | ⬜ pending |
| 04-02-04 | 02 | 1 | UIUX-04 | manual | Check output has wireframe text specifications | Wave 0 | ⬜ pending |
| 04-02-05 | 02 | 1 | UIUX-05 | manual | Check output references WCAG and specifies a11y per component | Wave 0 | ⬜ pending |
| 04-03-01 | 03 | 1 | AGNT-01 | smoke / manual | Invoke `/signe-design preset:agent [topic]` | Wave 0 | ⬜ pending |
| 04-03-02 | 03 | 1 | AGNT-02 | manual | Check generated agent definition has valid YAML with supported fields | Wave 0 | ⬜ pending |
| 04-03-03 | 03 | 1 | AGNT-03 | manual | Check system prompt has role/context/task/output/guardrails sections | Wave 0 | ⬜ pending |
| 04-03-04 | 03 | 1 | AGNT-04 | manual | Check output has tool allowlist table with justification | Wave 0 | ⬜ pending |
| 04-03-05 | 03 | 1 | AGNT-05 | manual | Check output has SKILL.md with proper frontmatter | Wave 0 | ⬜ pending |
| 04-04-01 | 04 | 2 | PROD-01 | smoke / manual | Invoke `/signe-design preset:product [topic]` | Wave 0 | ⬜ pending |
| 04-04-02 | 04 | 2 | PROD-02 | manual | Check output has user stories in standard format with acceptance criteria | Wave 0 | ⬜ pending |
| 04-04-03 | 04 | 2 | PROD-03 | manual | Check output has MoSCoW table with rationale | Wave 0 | ⬜ pending |
| 04-04-04 | 04 | 2 | PROD-04 | manual | Check output has end-to-end experience map with milestones | Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

No automated test infrastructure needed -- follows established manual e2e pattern from Phases 1, 2, and 3. The deployment and validation plan handles live testing for each preset.

*Existing infrastructure covers all phase requirements.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Architecture preset produces correct deliverables | ARCH-01 through ARCH-06 | Design output requires human judgment on quality and completeness | Invoke with sample topic, verify all 5 deliverable types present |
| UI/UX preset produces correct deliverables | UIUX-01 through UIUX-05 | Wireframes and flow maps require human visual assessment | Invoke with sample topic, verify flow maps, hierarchy, wireframes, a11y |
| Agent preset produces valid YAML | AGNT-01 through AGNT-05 | YAML validity checkable but prompt quality requires human review | Invoke with sample topic, verify YAML parses and prompt structure |
| Product preset produces correct deliverables | PROD-01 through PROD-04 | User stories and prioritization require human judgment | Invoke with sample topic, verify stories, MoSCoW, experience map |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
