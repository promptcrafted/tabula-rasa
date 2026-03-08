# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — Signe

**Shipped:** 2026-03-08
**Phases:** 6 | **Plans:** 15 | **Commits:** 78

### What Was Built
- Globally-installed chief of staff agent at `~/.claude/` with Command → Agent → Skill architecture
- 5 specialist modes: research (multi-source with confidence scoring), planning (goal decomposition), design (4 presets), oversight (5-lens review), and full workflow chaining
- Persistent agent playbook (agent-recipes.md) for banking validated subagent patterns
- GSD read-only awareness with cwd-based path scoping for cross-contamination prevention
- Maker-checker loops capped at 2 iterations with user escalation

### What Worked
- **Bottom-up phase ordering** — each phase built on proven patterns from the previous one, eliminating integration surprises
- **Direct cp deployment pattern** — discovered in Phase 2, reused consistently through Phase 6. No installer, no symlinks
- **2-plan phase structure** — agent+skill creation in Plan 01, integration+deployment+validation in Plan 02. Clean separation of concerns
- **Human verification at each phase** — caught real issues (hook schema, health check staleness) that automated checks missed
- **YOLO mode** — eliminated approval friction for a solo developer building in a known-safe environment

### What Was Inefficient
- **Phase 5 grew to 4 plans** — 05-04 remediation plan was needed because oversight review caught gaps. Could have been prevented by running oversight earlier in Phase 5
- **One-liner field missing from SUMMARY frontmatter** — summary-extract returned null for all 15 summaries. Frontmatter schema should include one_liner
- **Context handoff measurement deferred** — Phase 3 research flagged context handoff patterns need measurement, but this was never formally addressed (works in practice, unquantified)

### Patterns Established
- `signe-` prefix for all files (agents, skills, rules, hooks) — zero naming collisions
- maxTurns calibrated per agent role: researcher 50, designer/overseer 40, planner 30
- MCP graceful degradation: try specialized tools first, fall back to WebSearch + WebFetch
- Self-contained agent system prompts — subagents only receive their own prompt, no external context files
- Integration plan as final plan in each phase — consistent deployment checkpoint

### Key Lessons
1. **Flat orchestrator constraint is surprisingly liberating** — forcing all delegation through one thread eliminates coordination complexity entirely
2. **Agent prompt length matters less than structure** — 245-line researcher prompt works well because methodology sections are clearly delimited
3. **Phase-level human verification is non-negotiable for agent packages** — automated tests can't validate "does this feel right when invoked"
4. **Direct file copy beats installers for single-user agent packages** — no package manager, no symlink resolution, no PATH issues
5. **Quality gates need the overseer to exist first** — Phase 5's remediation plan (05-04) proves you need oversight tooling before you can oversee earlier phases

### Cost Observations
- Model mix: ~90% Opus, ~10% Sonnet (via GSD subagents)
- Sessions: ~6 (one per phase, roughly)
- Notable: 42 min total execution across 15 plans — ~2.8 min/plan average. Integration plans faster than creation plans

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Commits | Phases | Key Change |
|-----------|---------|--------|------------|
| v1.0 | 78 | 6 | Initial build — established phase structure and deployment patterns |

### Top Lessons (Verified Across Milestones)

1. Bottom-up phase ordering with human verification at each stage produces reliable agent packages
2. Self-contained agent prompts with clear methodology delimiters scale to 200+ lines without quality degradation
