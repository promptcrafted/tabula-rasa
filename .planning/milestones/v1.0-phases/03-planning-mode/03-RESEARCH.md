# Phase 3: Planning Mode - Research

**Researched:** 2026-03-07
**Domain:** Claude Code subagent architecture for goal decomposition and planning orchestration
**Confidence:** HIGH

## Summary

Phase 3 delivers the `signe-planner` agent and `/signe-plan` skill. The planner is a Claude Code subagent that decomposes high-level goals into ordered phases with explicit dependencies, verifiable acceptance criteria, and scope boundaries. It follows the identical architectural pattern established in Phases 1 and 2: a SKILL.md with `context: fork` and `agent: signe-planner` routes to a dedicated agent definition at `~/.claude/agents/signe-planner.md`. The agent runs in a forked context with its own context window -- essential for planning tasks that need to read research output files and produce substantial structured output.

The planner's core differentiator from the researcher is its methodology: instead of multi-source web investigation, it performs goal decomposition using dependency analysis, risk assessment, and value-delivery ordering. When research output exists (files written by `signe-researcher` in the format `signe-research-[topic].md`), the planner extracts requirements, technology decisions, and pitfalls to inform the plan. The planner produces a structured plan document with phases, dependencies, acceptance criteria, scope statements, and ordering rationale.

**Primary recommendation:** Build two files: `signe/skills/signe-plan/SKILL.md` (skill entry point with argument parsing) and `signe/agents/signe-planner.md` (the agent with planning methodology in its system prompt). The agent needs Read, Write, Bash, Grep, Glob tools to navigate project files and write output -- no web search tools needed since planning is about decomposition, not investigation. Update CLAUDE.md, signe.md, and delegation rules to mark planning mode as Available. Deploy to `~/.claude/` and validate with a real planning task.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| PLAN-01 | User can invoke planning via `/signe-plan` skill and Signe spawns `signe-planner` agent | Skill with `context: fork` and `agent: signe-planner` creates the `/signe-plan` slash command and routes to the agent. Pattern validated in Phase 1 (health) and Phase 2 (research). |
| PLAN-02 | Planner decomposes high-level goals into ordered phases with dependencies, deliverables, and rationale | Planning methodology embedded in system prompt defines decomposition steps: goal clarification, phase identification, dependency mapping, deliverable specification, and ordering rationale. |
| PLAN-03 | Planner maps explicit dependencies between tasks ("Phase B requires Phase A output") | System prompt includes dependency analysis section that requires explicit `depends_on` declarations with justification for each dependency link. |
| PLAN-04 | Planner extracts requirements from research output (FEATURES.md, STACK.md, PITFALLS.md) when available | Agent uses Read/Grep/Glob to discover `signe-research-*.md` files in the working directory. System prompt instructs: scan for research output first, extract technology decisions, constraints, and pitfalls before decomposing. |
| PLAN-05 | Each milestone has specific, verifiable acceptance criteria | System prompt mandates acceptance criteria format: "What must be TRUE when this phase is complete" with concrete, testable statements (not vague goals). Anti-pattern examples included in prompt. |
| PLAN-06 | Planner provides explicit rationale for phase ordering based on dependencies, risk, and value | System prompt requires ordering rationale section for each phase addressing three dimensions: dependency chain, risk reduction, and value delivery timing. |
| PLAN-07 | Every plan explicitly states what is in scope and out of scope with reasoning | System prompt requires scope boundary section with two columns: "In Scope (why)" and "Out of Scope (why not)". Reasoning is mandatory for both sides. |
</phase_requirements>

## Standard Stack

### Core

| Component | Value | Purpose | Why Standard |
|-----------|-------|---------|--------------|
| Agent definition | `signe-planner.md` | Planning agent with YAML frontmatter | Same pattern as signe-researcher.md -- validated architecture |
| Skill definition | `signe-plan/SKILL.md` | User-facing `/signe-plan` entry point | Same pattern as signe-research/SKILL.md -- validated architecture |
| Context type | `context: fork` | Isolated context window for planning | Planning reads files and produces large output -- needs dedicated context |
| Model | `model: inherit` | Defer model pinning to Phase 5 | Established decision from Phase 1 (01-02) |
| Memory | `memory: user` | Cross-project planning knowledge | Consistent with all Signe agents |
| Permission mode | `permissionMode: bypassPermissions` | Uninterrupted planning workflow | Consistent with researcher; no destructive operations |

### Tool Allowlist

| Tool | Purpose | Required? |
|------|---------|-----------|
| Read | Read research output files, project files | Yes -- PLAN-04 requires reading research output |
| Write | Write plan document to disk | Yes -- planner saves structured plan |
| Bash | File discovery, directory listing | Yes -- find research files |
| Grep | Search research output for patterns | Yes -- extract specific findings |
| Glob | Find research files by pattern | Yes -- discover `signe-research-*.md` files |
| WebSearch | NOT included | No -- planner decomposes, doesn't investigate |
| WebFetch | NOT included | No -- planner works from existing research |
| Agent | NOT included | No -- flat orchestrator constraint |

**MCP servers:** None needed. The planner works from local files (research output, project files) and does not need external data sources. This is a deliberate distinction from the researcher.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| No web tools | Include WebSearch for context | Planner should plan from known information, not research during planning. If research is needed, user should run `/signe-research` first. Clean separation of concerns. |
| `maxTurns: 50` | Lower (25-30) | Planning is less tool-intensive than research. 30 turns allows: file discovery (5) + reading (5-10) + planning analysis (5) + writing output (5) + buffer. 30 is sufficient. |

## Architecture Patterns

### Established File Structure (from Phase 1 and 2)

```
signe/
  agents/
    signe-planner.md       # NEW -- planning agent definition
  skills/
    signe-plan/
      SKILL.md             # NEW -- skill entry point
  CLAUDE.md                # UPDATE -- mark Planning as Available
  agents/signe.md          # UPDATE -- move /signe-plan to Now section
  rules/signe-delegation.md # UPDATE -- mark signe-planner as Available
```

### Pattern 1: Agent Definition with Methodology Prompt

**What:** Full planning methodology embedded in the agent's system prompt as structured sections.
**When to use:** Always -- the agent must be self-contained since it runs in a forked context and only receives its own system prompt.
**Validated by:** signe-researcher.md (245 lines, self-contained, sections for methodology, tool selection, output format, safety).

The planner system prompt should follow the same structural pattern:
1. Identity and communication style (brief)
2. Argument parsing (how to extract the planning goal from `$ARGUMENTS`)
3. Planning methodology (multi-step decomposition process)
4. Research integration (how to find and extract from research output)
5. Output format (structured plan template)
6. Safety constraints (read-only for existing files, only create new files)

### Pattern 2: Skill with Argument Routing

**What:** SKILL.md passes `$ARGUMENTS` to the agent, with the body providing minimal instructions and the agent doing the heavy lifting.
**When to use:** Always -- the skill is a thin router, not a logic container.
**Validated by:** signe-research/SKILL.md (18 lines, passes `$ARGUMENTS`, mentions preset detection).

### Pattern 3: Research Output Integration (PLAN-04)

**What:** The planner needs to discover and incorporate research output files.
**Discovery strategy:**
1. Glob for `signe-research-*.md` in the current working directory
2. If found, Read each file and extract: Executive Summary, key Findings (with confidence), Gaps
3. Map findings to plan phases (technology decisions inform implementation phases, pitfalls inform risk ordering)
4. If no research files found, proceed with planning based on the goal description alone

**Important note on FEATURES.md/STACK.md/PITFALLS.md:** The roadmap success criteria mentions these file names, but the deployed researcher agent actually outputs files named `signe-research-[topic].md` with sections for findings, source hierarchy, and gaps. The planner should search for BOTH naming conventions to be robust:
- `signe-research-*.md` (actual researcher output format)
- `FEATURES.md`, `STACK.md`, `PITFALLS.md` (alternative naming if user manually creates these)
- Any `.md` files that contain research-like sections (findings, recommendations, stack decisions)

### Anti-Patterns to Avoid

- **Vague acceptance criteria:** "System should work well" is not verifiable. Each criterion must be a testable boolean statement. The system prompt should include anti-pattern examples.
- **Missing dependency justification:** "Phase 2 depends on Phase 1" without explaining WHY. Each dependency link needs a concrete reason (output X required as input for Y).
- **Scope creep through omission:** Not stating out-of-scope items is an invitation for scope expansion. The planner must always produce both in-scope and out-of-scope lists.
- **Risk-blind ordering:** Ordering phases by "logical sequence" without considering risk or value. The planner should surface risk early and deliver value incrementally.
- **Planning without research:** If the goal involves technology decisions, the planner should recommend running `/signe-research` first rather than making uninformed technology choices.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Dependency graph visualization | ASCII art dependency diagrams | Simple dependency table with `depends_on` field | Graph visualization in a text agent adds complexity without value; a dependency list is clear enough |
| Project management features | Tracking, status updates, progress bars | Leave for oversight mode (Phase 5) | The planner plans, the overseer tracks. Clean separation of concerns. |
| Risk scoring algorithms | Numerical risk scores or matrices | Qualitative risk assessment (high/medium/low) with narrative justification | Numerical risk scores give false precision; the planner should provide reasoning, not numbers |
| Template libraries | Multiple plan templates for different project types | One universal plan template with flexible sections | Template proliferation creates maintenance burden; one good template adapts to any project |

**Key insight:** The planner's value is in the decomposition methodology and the quality of acceptance criteria, not in sophisticated tooling. Keep the agent focused on thinking clearly about dependencies, risks, and scope.

## Common Pitfalls

### Pitfall 1: Over-Decomposition

**What goes wrong:** Breaking a goal into 15+ phases with trivial tasks, creating overhead that exceeds the work itself.
**Why it happens:** Decomposition without judgment. Every sub-task gets its own phase.
**How to avoid:** System prompt should instruct: "Aim for 3-7 phases. If you have more than 7, consolidate related work. Each phase should represent 1-3 days of meaningful work, not individual tasks."
**Warning signs:** Phases that are a single file change or a single function.

### Pitfall 2: Circular Dependencies

**What goes wrong:** Phase A depends on Phase B which depends on Phase A.
**Why it happens:** Not tracking dependency chains end-to-end.
**How to avoid:** System prompt should instruct: "After mapping all dependencies, verify there are no cycles. If A depends on B and B depends on A, merge them into one phase or break the cycle by identifying the minimal viable deliverable."
**Warning signs:** Phases that "partially" depend on each other.

### Pitfall 3: Acceptance Criteria That Can't Fail

**What goes wrong:** Criteria like "code is well-structured" or "system is performant" -- no one can objectively evaluate these.
**Why it happens:** Writing criteria from the perspective of intent rather than verification.
**How to avoid:** System prompt should require: "Each acceptance criterion must be answerable with YES or NO. If you can't imagine a concrete test, the criterion is too vague."
**Warning signs:** Adjectives without metrics (fast, clean, robust, scalable).

### Pitfall 4: Ignoring Research Output

**What goes wrong:** Planner produces a plan that contradicts or ignores the technology decisions from prior research.
**Why it happens:** Not reading research files, or reading them superficially.
**How to avoid:** System prompt should instruct: "BEFORE planning, search for research output. Read it. Extract technology decisions, constraints, and pitfalls. Reference them explicitly in the plan."
**Warning signs:** Plan mentions technologies or approaches not validated by research.

### Pitfall 5: Missing the "Why Not" for Out-of-Scope Items

**What goes wrong:** Out-of-scope list is just a list of excluded items without reasoning.
**Why it happens:** Scope exclusion treated as an afterthought.
**How to avoid:** System prompt should require: "Every out-of-scope item needs a one-sentence reason WHY it's excluded. Common reasons: not needed for v1, separate concern, requires prerequisite work not yet done."
**Warning signs:** Out-of-scope section is just bullet points with no explanation.

## Code Examples

Verified patterns from the existing codebase (HIGH confidence -- directly from deployed files):

### Agent YAML Frontmatter (from signe-researcher.md)

```yaml
---
name: signe-planner
description: Goal decomposition agent. Breaks high-level goals into ordered phases with dependencies, acceptance criteria, and scope boundaries.
tools: Read, Write, Bash, Grep, Glob
model: inherit
memory: user
maxTurns: 30
permissionMode: bypassPermissions
---
```

### Skill YAML Frontmatter (from signe-research/SKILL.md)

```yaml
---
name: signe-plan
description: Structured planning with dependency mapping, acceptance criteria, and scope management
context: fork
agent: signe-planner
disable-model-invocation: false
---
```

### Skill Body Pattern (from signe-research/SKILL.md)

```markdown
## Planning Task

Decompose the following goal into an actionable, phased plan.

$ARGUMENTS

Before planning, check the current directory for research output files
(signe-research-*.md, FEATURES.md, STACK.md, PITFALLS.md) and incorporate
their findings into your plan.

Produce a structured plan document with phases, dependencies, acceptance
criteria, and scope boundaries.
```

### Planning Output Template (recommended)

The planner should write output to `signe-plan-[slugified-goal].md`:

```markdown
# Plan: [Goal]

**Date:** [YYYY-MM-DD]
**Goal:** [one-sentence goal statement]
**Research incorporated:** [list of research files read, or "None found"]

## Scope

### In Scope
| Item | Rationale |
|------|-----------|
| [item] | [why it's included] |

### Out of Scope
| Item | Rationale |
|------|-----------|
| [item] | [why it's excluded] |

## Phases

### Phase 1: [Name]
**Goal:** [what this phase achieves]
**Depends on:** [nothing / Phase N -- because X output is required]
**Deliverables:**
- [concrete deliverable 1]
- [concrete deliverable 2]

**Acceptance Criteria:**
- [ ] [Testable boolean statement 1]
- [ ] [Testable boolean statement 2]

**Ordering Rationale:**
- Dependencies: [what must exist before this can start]
- Risk: [what risk does this phase reduce]
- Value: [what value does completing this phase unlock]

### Phase 2: [Name]
[...same structure...]

## Dependency Map

| Phase | Depends On | Reason |
|-------|-----------|--------|
| 1 | - | No dependencies |
| 2 | 1 | [concrete reason] |
| 3 | 1, 2 | [concrete reason for each] |

## Risk Assessment

| Risk | Impact | Mitigation | Addressed In |
|------|--------|------------|--------------|
| [risk] | [impact] | [mitigation] | Phase N |

## Research Integration

[If research output was found, summarize how it informed the plan:
- Technology decisions adopted
- Pitfalls that influenced ordering
- Constraints that shaped scope]
```

### Recap Pattern (from signe-researcher.md output delivery)

After writing the full plan, output a concise recap to the conversation:

```markdown
## Plan: [Goal]

**Phases:** [count] | **Research integrated:** [yes/no]

### Phase Overview
1. **[Phase 1 name]** -- [1-sentence summary]
2. **[Phase 2 name]** -- [1-sentence summary]
[...]

### Key Decisions
- [Decision 1 with rationale]
- [Decision 2 with rationale]

### Risks
- [Top risk and mitigation]

---
Full plan: `[file path]`
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single monolithic plan | Phased decomposition with dependencies | Standard practice | Enables incremental delivery and risk management |
| Vague milestones | Verifiable acceptance criteria | Agile/BDD evolution | Enables objective progress assessment |
| Sequential-only ordering | Dependency + risk + value ordering | Modern project planning | Better risk reduction and faster value delivery |

**Relevant to this implementation:**
- The planning agent doesn't need to implement project management tooling (Gantt charts, burndown). It decomposes goals and defines phases.
- The Claude Code subagent architecture means the planner runs once, produces a document, and returns. It is not a persistent planner that tracks progress over time (that's oversight mode in Phase 5).

## maxTurns Recommendation

**Recommendation:** `maxTurns: 30`

**Rationale:** Planning is less tool-intensive than research. The planner needs to:
1. Discover research files (2-3 tool calls: Glob + Read)
2. Read research output (3-5 tool calls per file)
3. Analyze and decompose (thinking, no tool calls)
4. Write the plan document (1 Write call)
5. Output recap to conversation (no tool call)

Total: ~10-15 tool calls plus thinking. 30 turns provides comfortable headroom without risking runaway execution. The researcher uses 50 because it performs many web searches and page fetches; the planner works from local files only.

## Open Questions

1. **Research output file naming convention mismatch**
   - What we know: The roadmap success criteria mentions "FEATURES.md, STACK.md, PITFALLS.md" but the deployed researcher writes `signe-research-[topic].md` files.
   - What's unclear: Whether the user intends to add these specific file names as future researcher output formats, or whether "FEATURES.md, STACK.md, PITFALLS.md" was a conceptual placeholder.
   - Recommendation: Make the planner search for both conventions. Glob for `signe-research-*.md` AND `FEATURES.md`/`STACK.md`/`PITFALLS.md`. This handles both current researcher output and any future format changes.

2. **Context handoff measurement**
   - What we know: STATE.md flags "Context handoff patterns need measurement in Phase 3" as a research concern.
   - What's unclear: What specific measurements are needed and what constitutes success.
   - Recommendation: The planner skill uses `context: fork` (same as researcher), so context handoff is the same proven pattern. The "measurement" concern is more relevant to Phase 6 (workflow chaining where one mode's output feeds the next). For Phase 3, the handoff is: user types `/signe-plan [goal]` -> skill passes `$ARGUMENTS` to agent -> agent produces plan file. This is the same pattern that works for `/signe-research`. No additional measurement infrastructure needed in Phase 3.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual end-to-end validation |
| Config file | None -- validation is human-driven invocation |
| Quick run command | `/signe-plan "Build a REST API for user management"` |
| Full suite command | Run quick command + verify output file structure |

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| PLAN-01 | `/signe-plan` spawns signe-planner agent | smoke / manual | Invoke `/signe-plan "test goal"` and verify agent spawns | Wave 0 |
| PLAN-02 | Planner produces phased decomposition with dependencies | manual | Check output file has Phases section with depends_on fields | Wave 0 |
| PLAN-03 | Dependencies are explicit with justification | manual | Check output has Dependency Map table with Reason column | Wave 0 |
| PLAN-04 | Planner reads research output when available | manual | Place a `signe-research-*.md` file in cwd, invoke planner, verify "Research integrated: yes" in recap | Wave 0 |
| PLAN-05 | Acceptance criteria are specific and verifiable | manual | Check each criterion is a boolean YES/NO testable statement | Wave 0 |
| PLAN-06 | Ordering rationale addresses dependencies, risk, value | manual | Check each phase has Ordering Rationale section with all three dimensions | Wave 0 |
| PLAN-07 | Scope boundaries stated with reasoning | manual | Check output has In Scope and Out of Scope tables with Rationale columns | Wave 0 |

### Sampling Rate

- **Per task commit:** Verify file structure and frontmatter validity
- **Per wave merge:** Run `/signe-plan` with a real goal and inspect output
- **Phase gate:** Full end-to-end validation (same as Phase 2 pattern)

### Wave 0 Gaps

- No automated test infrastructure needed -- validation follows the same manual end-to-end pattern established in Phase 1 and Phase 2
- The deployment and validation plan (Plan 02) handles live testing

## Sources

### Primary (HIGH confidence)

- Deployed `signe-researcher.md` at `~/.claude/agents/signe-researcher.md` -- reference pattern for agent definition structure, YAML frontmatter, system prompt organization, and tool allowlist
- Deployed `signe-research/SKILL.md` at `~/.claude/skills/signe-research/SKILL.md` -- reference pattern for skill definition, argument routing, context fork
- Deployed `signe.md` at `~/.claude/agents/signe.md` -- orchestrator structure, Available/Coming Soon sections
- Deployed `signe-delegation.md` at `~/.claude/rules/signe-delegation.md` -- routing table format, status conventions
- `.planning/REQUIREMENTS.md` -- PLAN-01 through PLAN-07 requirement definitions
- `.planning/ROADMAP.md` -- Phase 3 success criteria and phase structure
- `.planning/STATE.md` -- project state, decisions, and open concerns
- Phase 2 plans (`02-01-PLAN.md`, `02-02-PLAN.md`) -- plan structure and deployment pattern

### Secondary (MEDIUM confidence)

- Phase 2 CONTEXT.md -- user preferences for implementation discretion (applied analogously to Phase 3)

### Tertiary (LOW confidence)

None -- all findings derived from primary sources (deployed code and planning documents).

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- identical architecture pattern to Phase 2, all components validated
- Architecture: HIGH -- follows established patterns with no architectural novelty
- Pitfalls: MEDIUM -- pitfalls are general planning quality concerns, validated by planning best practices but not project-specific testing
- Tool allowlist: HIGH -- deliberate decision to exclude web tools, justified by separation of concerns

**Research date:** 2026-03-07
**Valid until:** 2026-04-07 (stable -- Claude Code agent architecture is not changing rapidly)
