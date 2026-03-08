# Phase 6: Workflow + GSD Integration - Research

**Researched:** 2026-03-08
**Domain:** Claude Code agent orchestration, workflow chaining, project-scoped GSD integration
**Confidence:** HIGH

## Summary

Phase 6 wires together all five existing Signe modes (research, plan, design, oversee) into coherent end-to-end workflows, adds GSD awareness for managing project subfolders, and implements the proactive chief of staff behaviors (risk surfacing, milestone summaries, next action recommendations). The core mechanism is straightforward: signe.md already has `Agent(signe-*)` in its tools, so workflow chaining is sequential subagent spawning where each agent's output is collected by the orchestrator and formatted as input for the next agent.

The critical architectural constraint is that Claude Code subagents cannot spawn other subagents. This means all chaining MUST happen in signe.md (the flat orchestrator). Each mode agent runs in `context: fork` via its skill, returns results to the orchestrator, and the orchestrator reformats and passes context to the next mode. This is not a new pattern -- it is exactly how the existing agents work individually; Phase 6 simply chains them sequentially with structured context handoff between stages.

GSD integration requires revising signe-safety.md to allow controlled `.planning/` directory access, adding path validation to prevent cross-project contamination, and teaching signe.md how to route GSD-style commands to the appropriate project subfolder. The maker-checker loop is a design-then-oversee cycle that the orchestrator manages, re-running the overseer after the designer iterates until the quality gate passes or a maximum iteration count is reached.

**Primary recommendation:** Implement workflow chaining as orchestrator-managed sequential delegation in signe.md with structured handoff documents. Do not build a custom pipeline framework -- use the existing Agent tool with explicit context formatting between stages.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
None -- all implementation decisions are deferred to Claude's discretion based on research.

### Claude's Discretion
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- **Workflow chaining mechanism** -- How the research -> plan -> design -> oversee pipeline works concretely. Whether signe.md spawns agents sequentially and passes output between them. Whether the user triggers `/signe` and it runs all four modes or a subset. How output from one mode is formatted as input for the next. What happens when a mode fails mid-chain. Partial runs (e.g., research -> plan only). Entry/exit points in the pipeline
- **GSD orchestration model** -- How Signe "sits above" GSD. Whether Signe invokes GSD slash commands, directly manages `.planning/` directories, or uses another approach. How cross-contamination is prevented between projects (hooks, path validation, scoping). What "runs GSD in project subfolders" means concretely. How Signe knows which project folder to target
- **Context handoff format** -- What mode-aware handoff documents look like when transitioning between workflow stages. How they are tailored per receiving mode (e.g., research output formatted differently for planner vs designer). Where handoffs are stored (ephemeral in conversation vs persisted as files). Whether handoffs are structured Markdown, JSON, or conversation context
- **Maker-checker iteration** -- How design-then-review cycles work end-to-end (CHST-04). Whether loops are auto-triggered after design or user-initiated. Maximum iteration rounds before escalating. How quality gate verdicts from the overseer feed back into the producing agent. Integration with existing quality gate pass/warn/fail levels from Phase 5
- **Proactive chief of staff behaviors** -- How risk identification (CHST-01), milestone summaries (CHST-02), and next action recommendations (CHST-03) are implemented. Whether these are triggered by hooks, inline in the orchestrator, or via dedicated logic in signe.md. What triggers proactive behavior (state changes, workflow stage transitions, user idle periods)
- **signe.md orchestrator updates** -- How the orchestrator evolves from "spawn individual agents" to "chain workflows". Whether the orchestrator gains new sections, skills, or behavioral patterns. How the "Coming Soon" `/signe` entry becomes functional
- **Deployment and integration** -- What changes to settings.json, CLAUDE.md, rules files, and hooks are needed. Whether new skills are created (e.g., `/signe` as a workflow skill) or existing skills are extended

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFRA-08 | Full workflow chaining -- output of each mode (research -> plan -> design -> oversee) feeds input of the next | Workflow chaining architecture: sequential Agent tool calls with structured handoff documents |
| INFRA-09 | GSD workflows run in project subfolders (e.g., `project/.planning/`) to prevent cross-contamination between projects | GSD orchestration model: path validation, cwd-based scoping, safety rule revision |
| CHST-01 | Signe proactively identifies risks and surfaces blockers without being asked | Proactive behaviors section: inline orchestrator logic triggered at workflow stage transitions |
| CHST-02 | Signe summarizes project status at natural milestones | Proactive behaviors section: milestone summaries after each mode completion in a chained workflow |
| CHST-03 | Signe recommends next actions based on current project state | Proactive behaviors section: next action recommendations based on workflow state and output analysis |
| CHST-04 | Signe uses maker-checker loops -- design agent produces, review agent critiques, iterate until quality gate passes | Maker-checker architecture: design -> oversee -> iterate cycle with max 2 rounds before escalation |
| CHST-05 | Signe generates mode-aware context handoff documents when transitioning between workflow stages | Context handoff format: mode-specific Markdown templates passed as conversation context |
</phase_requirements>

## Standard Stack

### Core
| Component | Location | Purpose | Why Standard |
|-----------|----------|---------|--------------|
| signe.md (updated) | `signe/agents/signe.md` | Orchestrator with workflow chaining logic | Flat orchestrator is the established pattern; all delegation flows through here |
| `/signe` skill | `signe/skills/signe/SKILL.md` | New skill entry point for full workflow | Follows existing skill pattern (context: fork, agent: signe) but routes to signe itself |
| signe-delegation.md (updated) | `signe/rules/signe-delegation.md` | Updated routing table with `/signe` entry | Existing rules file, needs Phase 6 routing additions |
| signe-safety.md (updated) | `signe/rules/signe-safety.md` | Revised GSD constraints for controlled access | Existing rules file, constraint #3 needs revision |

### Supporting
| Component | Location | Purpose | When to Use |
|-----------|----------|---------|-------------|
| signe-lifecycle.js (updated) | `signe/hooks/signe-lifecycle.js` | Enhanced with workflow stage tracking | Provides workflow progress logging |
| CLAUDE.md (updated) | `signe/CLAUDE.md` | `/signe` moved from (Phase 6) to Available | Every session loads this |
| SIGNE-GUIDE.md (updated) | `signe/SIGNE-GUIDE.md` | Updated usage guide with workflow examples | Reference documentation |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Sequential orchestrator chaining | Agent Teams (experimental) | Agent Teams provides parallel coordination but is experimental, Windows support uncertain, and overkill for sequential pipeline |
| Inline context handoff | Persisted handoff files on disk | Disk persistence adds complexity; ephemeral conversation context is simpler and matches existing `context: fork` pattern where subagent output returns to orchestrator |
| Custom pipeline framework | JSON-driven workflow engine | Over-engineering; the Agent tool already provides sequential chaining natively |

## Architecture Patterns

### Recommended Project Structure (Changes Only)
```
signe/
├── agents/
│   └── signe.md                    # UPDATED: workflow chaining + GSD awareness + proactive behaviors
├── skills/
│   ├── signe/                      # NEW: full workflow skill
│   │   └── SKILL.md
│   └── [existing skills unchanged]
├── rules/
│   ├── signe-delegation.md         # UPDATED: /signe routing + Phase 6 note
│   └── signe-safety.md             # UPDATED: controlled GSD access
├── hooks/
│   └── signe-lifecycle.js          # UPDATED: workflow stage tracking
├── CLAUDE.md                       # UPDATED: /signe Available
└── SIGNE-GUIDE.md                  # UPDATED: workflow usage examples
```

### Pattern 1: Sequential Workflow Chaining
**What:** Signe.md spawns mode agents sequentially, collecting each agent's output and formatting it as input for the next agent in the chain.
**When to use:** User invokes `/signe` with a goal that spans multiple modes.
**How it works:**

The orchestrator (signe.md) receives the user's goal via `/signe`. It then:

1. Determines which modes are needed (default: all four in order, but user can specify a subset)
2. Spawns `signe-researcher` with the goal as research topic
3. Collects research output (the written file path + recap)
4. Formats research findings as planning context and spawns `signe-planner`
5. Collects plan output
6. Formats plan as design context and spawns `signe-designer`
7. Collects design output
8. Spawns `signe-overseer` to review the design (maker-checker)
9. If overseer returns FAIL, re-runs designer with feedback (max 2 iterations)
10. Presents final summary to user

**Key constraint:** Subagents cannot spawn other subagents. The orchestrator (signe.md) is the ONLY entity that calls `Agent(signe-*)`. This is already enforced -- subagent tool lists do not include `Agent`.

**Entry/exit points:**
- Full pipeline: `research -> plan -> design -> oversee`
- Partial runs: `research -> plan`, `plan -> design`, `design -> oversee`
- User specifies via argument: `/signe research+plan Build a JWT auth system`
- Default (no mode specifier): full pipeline

```
User invokes /signe "Build a JWT auth system"
    │
    ▼
signe.md (orchestrator)
    │
    ├── 1. Spawn signe-researcher
    │       └── Returns: signe-research-jwt-auth.md + recap
    │
    ├── 2. Format research as planning input
    │   └── Spawn signe-planner with research context
    │       └── Returns: signe-plan-jwt-auth.md + recap
    │
    ├── 3. Format plan as design input
    │   └── Spawn signe-designer with plan context
    │       └── Returns: signe-design-jwt-auth.md + recap
    │
    ├── 4. Spawn signe-overseer to review design
    │       └── Returns: signe-review-jwt-auth.md + verdict
    │
    ├── 5. If FAIL: re-spawn designer with feedback (max 2x)
    │
    └── 6. Present milestone summary to user
```

### Pattern 2: Mode-Aware Context Handoff
**What:** When transitioning between workflow stages, the orchestrator generates a handoff document tailored to the receiving mode's needs.
**When to use:** Every mode transition in a chained workflow.
**How it works:**

Each mode agent already writes its output to a file and returns a recap. The orchestrator uses the recap + file path to construct the next agent's prompt. The handoff is NOT a separate file -- it is structured text injected into the next agent's delegation prompt.

**Handoff templates by transition:**

| From | To | What the handoff contains |
|------|-----|--------------------------|
| Research -> Plan | Planner | Key findings summary, technology decisions, constraints, pitfalls to avoid, file path to full report |
| Plan -> Design | Designer | Phase structure, acceptance criteria, dependency order, scope boundaries, file path to full plan |
| Design -> Oversee | Overseer | Design deliverables list, file paths, acceptance criteria from plan, specific review focus areas |
| Oversee -> Design (iteration) | Designer | Specific findings with severity, recommended fixes, which criteria failed, iteration count |

The handoff is ephemeral conversation context passed via the Agent tool's prompt parameter. This matches how Claude Code subagents work -- they receive only their system prompt plus the delegation message. No separate handoff files are persisted.

### Pattern 3: Maker-Checker Loop
**What:** Design agent produces, overseer reviews, iterate until quality gate passes.
**When to use:** Design -> oversee stage of workflow chaining.
**How it works:**

```
signe.md orchestrator:
    │
    ├── Spawn signe-designer with plan context
    │       └── Returns: design output + file path
    │
    ├── Spawn signe-overseer scope:gate on design output
    │       └── Returns: verdict (PASS/WARN/FAIL) + findings
    │
    ├── If PASS: proceed to summary
    │
    ├── If WARN: present findings to user, recommend proceeding
    │
    ├── If FAIL (iteration 1):
    │   └── Re-spawn signe-designer with:
    │       - Original plan context
    │       - Overseer findings (specific issues + recommended fixes)
    │       - Instruction: "Address these findings"
    │       └── Returns: revised design
    │       └── Re-spawn signe-overseer on revised design
    │
    ├── If FAIL (iteration 2):
    │   └── Escalate to user: "Design failed quality gate twice. Issues: [...]"
    │       └── User decides: proceed anyway, provide guidance, or abandon
    │
    └── Maximum 2 maker-checker iterations (matches existing METH pattern)
```

This uses the existing quality gate levels from Phase 5 (PASS/WARN/FAIL) without modification.

### Pattern 4: GSD-Aware Project Scoping
**What:** Signe detects the current working directory to scope GSD operations to the correct project.
**When to use:** When Signe needs to interact with `.planning/` directories.
**How it works:**

GSD integration does NOT mean Signe invokes GSD slash commands. Signe operates at a higher level -- she can read `.planning/` state to understand project context, recommend next GSD actions, and scope her awareness to the current project directory.

**Cross-contamination prevention:**
- Signe uses `process.cwd()` (Node.js) or Bash `pwd` to determine the current project
- All `.planning/` path references are relative to cwd, never absolute paths to other projects
- The orchestrator validates that file operations target only `${cwd}/.planning/` and subdirectories
- No hooks needed for path validation -- the orchestrator itself enforces scoping in its prompt

**What Signe can do with GSD awareness:**
1. Read `.planning/STATE.md` to understand project progress
2. Read `.planning/ROADMAP.md` to understand project structure
3. Read plan files to understand what was planned vs executed
4. Recommend GSD commands: "Phase 3 research is complete. Run `/gsd:plan-phase 3` to create plans."
5. Surface risks from STATE.md blockers/concerns

**What Signe does NOT do:**
- Does not invoke GSD slash commands directly (those are user-initiated)
- Does not write to `.planning/` (Signe is read-only for GSD artifacts)
- Does not manage GSD configuration or modify GSD agents/hooks

### Pattern 5: Proactive Chief of Staff Behaviors
**What:** Signe proactively surfaces risks, summarizes milestones, and recommends next actions without being asked.
**When to use:** During workflow chaining (at stage transitions) and when invoked directly.

**Implementation approach:** These behaviors are embedded in signe.md's system prompt as behavioral guidelines, not as separate agents or hooks. They trigger at natural workflow breakpoints.

**CHST-01 Risk Identification:**
- After each mode agent returns, analyze output for risk signals
- Research: LOW confidence findings, gaps in coverage, conflicting sources
- Planning: Missing dependencies, underspecified acceptance criteria, scope ambiguity
- Design: Unresolved tradeoffs, missing error handling, accessibility gaps
- Oversee: FAIL verdicts, high-severity findings, untested code paths
- Surface identified risks in milestone summaries

**CHST-02 Milestone Summaries:**
- At the end of each workflow stage, output a structured summary:
  - What was accomplished
  - What changed from expectations
  - What comes next
  - Open concerns/risks
- At the end of a full workflow, output a comprehensive summary

**CHST-03 Next Action Recommendations:**
- After completing a workflow (or partial workflow), recommend the next step
- Context-aware: if GSD state exists, recommend specific GSD commands
- If no GSD state, recommend appropriate Signe modes
- Rank recommendations if multiple valid next steps exist

### Anti-Patterns to Avoid
- **Building a custom pipeline engine:** The Agent tool already provides sequential chaining. Do not add a JSON-driven pipeline config, workflow state machine, or pipeline DSL. The orchestrator prompt IS the workflow definition.
- **Persisting handoff documents as files:** Handoff context is ephemeral -- passed in the Agent tool's prompt. Files add cleanup burden and stale state risk. The mode agents already persist their own output files.
- **Having Signe invoke GSD slash commands:** Signe reads GSD state, she does not execute GSD workflows. GSD commands are user-initiated. Signe recommends which command to run next.
- **Adding new mode agents for workflow management:** No "signe-workflow-manager" agent. The orchestrator (signe.md) handles workflow logic directly. Adding agents for meta-orchestration violates the flat model.
- **Nested delegation workarounds:** Never try to make a subagent spawn another subagent. Claude Code enforces this constraint architecturally -- subagent tool lists cannot include `Agent`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Sequential agent chaining | Custom pipeline framework | Agent tool calls in signe.md prompt | Agent tool already provides sequential chaining with context passing |
| Quality gate logic | Custom scoring system | Existing overseer PASS/WARN/FAIL | Phase 5 already implemented and validated quality gates |
| Project directory scoping | Path validation hooks | `cwd` detection in orchestrator prompt | Simpler, no additional hook infrastructure needed |
| Workflow state tracking | External state file | Orchestrator conversation context | State lives in the orchestrator's context window during the workflow |
| Mode-aware formatting | Template engine | Inline formatting in orchestrator prompt | Templates add complexity; 4 transition types can be handled with inline instructions |

**Key insight:** Phase 6 is primarily a prompt engineering exercise on signe.md, not a code engineering exercise. The infrastructure (agents, skills, hooks) already exists. Phase 6 wires them together through orchestrator behavior changes and a new skill entry point.

## Common Pitfalls

### Pitfall 1: Context Window Exhaustion During Chained Workflows
**What goes wrong:** A full 4-mode workflow generates substantial output from each agent. If the orchestrator accumulates all output in its context window, it may hit limits before completing the pipeline.
**Why it happens:** Each mode agent returns its full recap (15-25 lines) plus file paths. Across 4 modes + maker-checker iterations, this can be 100+ lines of accumulated context.
**How to avoid:** The orchestrator should pass only essential context forward. Each handoff should include: (1) the file path to the full output, (2) a condensed summary of key decisions/findings, (3) specific items the next mode needs. Do not pass full recaps through the entire chain.
**Warning signs:** Orchestrator context window warnings, truncated output, or failed agent spawning late in the pipeline.

### Pitfall 2: Infinite Maker-Checker Loops
**What goes wrong:** Designer and overseer disagree on quality standards, leading to endless revision cycles.
**Why it happens:** Overseer's criteria may be stricter than what the designer can achieve in a single iteration, or findings may be subjective (style preferences vs. objective quality issues).
**How to avoid:** Hard cap at 2 iterations (matches existing METH methodology pattern from Phase 5). After 2 FAIL verdicts, escalate to user with specific issues. Only FAIL triggers re-iteration; WARN is presented to user as advisory.
**Warning signs:** Same findings appearing in consecutive review cycles.

### Pitfall 3: GSD Safety Rule Revision Breaking Existing Protections
**What goes wrong:** Revising signe-safety.md constraint #3 ("Modify GSD files or workflows") too broadly, allowing Signe to accidentally modify GSD infrastructure.
**Why it happens:** The constraint needs to be relaxed for Signe to read `.planning/` state, but the revision could unintentionally allow write access.
**How to avoid:** Change from "GSD files are off-limits" to "Signe may READ `.planning/` state files (STATE.md, ROADMAP.md, plan files) for project awareness. Signe must NEVER write to `.planning/`, modify GSD agents (`gsd-*.md`), GSD hooks (`gsd-*.js`), or GSD-related settings." The revision explicitly preserves write protection.
**Warning signs:** Signe modifying plan files or state files during workflows.

### Pitfall 4: `/signe` Skill Routing Confusion
**What goes wrong:** The new `/signe` skill conflicts with or confuses the existing individual mode skills.
**Why it happens:** Users might expect `/signe research topic` to work like `/signe-research topic`, but `/signe` is a workflow orchestrator, not a research shortcut.
**How to avoid:** Clear argument parsing in the `/signe` skill: first argument specifies mode subset (e.g., `research+plan`, `design+oversee`, `all`), remaining arguments are the goal. If no mode subset specified, default to full pipeline. The skill description should clearly distinguish `/signe` (workflow) from `/signe-research` (single mode).
**Warning signs:** Users invoking `/signe` expecting single-mode behavior.

### Pitfall 5: Partial Workflow Failure Recovery
**What goes wrong:** A mode agent fails mid-pipeline (e.g., researcher hits tool errors, planner cannot decompose), and the orchestrator has no recovery strategy.
**Why it happens:** Subagent failures surface as poor-quality output or error messages, not as clean exit codes.
**How to avoid:** After each agent returns, the orchestrator should validate the output before proceeding: (1) Did the agent write an output file? (2) Does the recap contain actionable content? (3) Are there explicit error messages? If validation fails, the orchestrator should: retry once with adjusted context, or stop the pipeline and report what completed successfully.
**Warning signs:** Downstream agents receiving empty or error-filled context from upstream failures.

## Code Examples

### Example 1: /signe Skill Definition (SKILL.md)

```yaml
---
name: signe
description: Full workflow orchestration -- chain research, planning, design, and oversight into a coherent end-to-end pipeline. Use when a goal needs multiple Signe modes in sequence.
context: fork
agent: signe
disable-model-invocation: true
---

## Workflow Task

Run a multi-mode workflow for the following goal.

$ARGUMENTS

### Mode Selection

Parse the first token for mode specifier:
- `all` or no specifier: research -> plan -> design -> oversee (full pipeline)
- `research+plan`: research then plan only
- `plan+design`: plan then design only
- `design+oversee`: design then oversee with maker-checker loop
- `research+plan+design`: research, plan, then design (skip oversee)
- Single mode names (research, plan, design, oversee): redirect to the specific skill

If a single mode is requested, suggest using the dedicated skill instead
(e.g., `/signe-research` for research-only).

### Workflow Execution

Follow the workflow chaining instructions in your system prompt.
At each stage transition, generate a mode-aware handoff.
After each stage, provide a milestone summary.
At the end, provide a comprehensive workflow summary with next action recommendations.
```

### Example 2: Workflow Chaining Section for signe.md

```markdown
## Workflow Chaining

When invoked via `/signe` or asked to run a multi-mode workflow:

### Pipeline Execution

1. **Parse mode selection** from the user's request
2. **For each mode in the pipeline:**
   a. Format context for the target mode using the handoff template below
   b. Spawn the mode agent with formatted context
   c. Collect output (file path + recap)
   d. Validate output: file was written, recap has content, no error signals
   e. If validation fails: retry once, then stop pipeline and report
   f. Generate milestone summary
   g. Identify risks from output

3. **At design -> oversee transition:** Apply maker-checker loop:
   a. Spawn overseer with design output
   b. If PASS: proceed
   c. If WARN: note findings, proceed
   d. If FAIL (attempt 1): re-spawn designer with findings, then re-oversee
   e. If FAIL (attempt 2): escalate to user

4. **After pipeline completion:**
   - Comprehensive summary of all stages
   - Identified risks across the workflow
   - Recommended next actions

### Context Handoff Templates

**Research -> Plan handoff:**
Include in planner prompt:
- "Research findings are available at [file path]"
- Key technology decisions (bulleted list)
- Critical constraints identified
- Pitfalls that should inform phase ordering

**Plan -> Design handoff:**
Include in designer prompt:
- "Plan is available at [file path]"
- Phase structure and acceptance criteria
- Dependency order
- Scope boundaries

**Design -> Oversee handoff:**
Include in overseer prompt:
- "Design deliverables at [file path]"
- Acceptance criteria from plan
- Specific areas to focus review on

**Oversee -> Design (iteration) handoff:**
Include in designer prompt:
- "Previous design at [file path]"
- Overseer findings with severity levels
- Specific items that caused FAIL verdict
- "This is iteration [N] of 2 maximum"
```

### Example 3: Revised signe-safety.md Constraint #3

```markdown
3. **GSD interaction is read-only.** Signe may READ `.planning/` state files
   (STATE.md, ROADMAP.md, REQUIREMENTS.md, plan files, context files) to
   understand project progress and recommend next actions. Signe must NEVER:
   - Write to or modify any file in `.planning/`
   - Modify GSD agents (`gsd-*.md`), GSD hooks (`gsd-*.js`), or GSD skills
   - Modify GSD-related settings in `settings.json`
   - Invoke GSD slash commands programmatically
   Signe recommends GSD actions to the user; the user executes them.
```

### Example 4: Updated Delegation Table Entry

```markdown
| `/signe` | `signe` (self) | Multi-mode workflow chaining | Available |
```

Note: `/signe` routes back to signe.md itself (not a separate agent). The skill uses `context: fork` with `agent: signe`, which creates a new signe context for the workflow. This is the same pattern as the built-in `/batch` skill which orchestrates multiple agents from a single entry point.

### Example 5: Proactive Behaviors Section for signe.md

```markdown
## Proactive Behaviors

These behaviors apply at ALL times, not just during workflows.

### Risk Identification (CHST-01)
After each subagent completes, scan the output for:
- LOW confidence findings (research)
- Missing dependencies or underspecified criteria (planning)
- Unresolved tradeoffs or missing error handling (design)
- FAIL/WARN verdicts or high-severity findings (oversight)
Surface identified risks immediately. Do not wait to be asked.

### Milestone Summaries (CHST-02)
At natural breakpoints (after each mode completes, at workflow end):
- What was accomplished
- What changed from expectations
- What comes next
- Open concerns

### Next Action Recommendations (CHST-03)
After completing work, recommend the next step:
- If `.planning/STATE.md` exists: recommend specific GSD commands based on project state
- If research output exists but no plan: recommend `/signe-plan`
- If plan exists but no design: recommend `/signe-design`
- If design exists but no review: recommend `/signe-oversee`
- Rank recommendations when multiple valid next steps exist
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Individual mode invocation only | Workflow chaining via orchestrator | Phase 6 (now) | Users no longer manually chain `/signe-research` then `/signe-plan` then `/signe-design` |
| GSD files completely off-limits | Read-only GSD awareness | Phase 6 (now) | Signe can read project state and recommend GSD actions |
| Reactive only (responds when asked) | Proactive risk/summary/recommendation | Phase 6 (now) | Chief of staff personality fully realized |
| No maker-checker | Design -> oversee iteration loops | Phase 6 (now) | Quality gates applied to design output automatically |

**No deprecated or outdated patterns in existing Signe infrastructure.** All five existing mode agents and skills remain unchanged. Phase 6 only adds behavior to the orchestrator and creates one new skill.

## Open Questions

1. **`/signe` skill routing to signe.md itself**
   - What we know: Skills with `context: fork` and `agent: signe` would create a new signe instance. This signe instance has `Agent(signe-*)` in its tools, so it CAN spawn subagents.
   - What's unclear: Whether a forked signe instance running as a subagent can successfully use the Agent tool to spawn its own subagents. Claude Code docs say "Subagents cannot spawn other subagents" -- but signe.md when run as a main thread agent via `claude --agent` CAN spawn subagents.
   - Recommendation: Test this during implementation. If forked signe cannot spawn sub-subagents, the `/signe` skill should NOT use `context: fork`. Instead, it should run inline (no `context` field), injecting workflow instructions directly into the main signe conversation. This is the safer approach and should be the default implementation.

2. **Context window budget for full pipeline**
   - What we know: Each mode agent uses its own context window (context: fork). The orchestrator accumulates summaries.
   - What's unclear: Exact token budget for 4-mode pipeline with 2 maker-checker iterations in the orchestrator's context.
   - Recommendation: Keep handoff summaries to 10-15 lines per stage. Total orchestrator accumulation should stay under 200 lines for a full pipeline.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual end-to-end validation (human-verified) |
| Config file | None -- Signe is a prompt engineering project, not a code project |
| Quick run command | `/signe-health` (validates installation) |
| Full suite command | Manual: invoke `/signe all Build a simple REST API` and verify pipeline completes |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| INFRA-08 | Workflow chaining feeds output between modes | e2e manual | `/signe all [test goal]` | N/A -- Wave 0 |
| INFRA-09 | GSD runs in project subfolders without cross-contamination | e2e manual | Invoke from project dir, verify `.planning/` reads are scoped | N/A -- Wave 0 |
| CHST-01 | Proactive risk identification | e2e manual | Verify risk surfacing in workflow output | N/A -- Wave 0 |
| CHST-02 | Milestone summaries at breakpoints | e2e manual | Verify summaries appear after each mode in workflow | N/A -- Wave 0 |
| CHST-03 | Next action recommendations | e2e manual | Verify recommendations in workflow summary | N/A -- Wave 0 |
| CHST-04 | Maker-checker loops | e2e manual | `/signe design+oversee [test goal]` and verify iteration | N/A -- Wave 0 |
| CHST-05 | Mode-aware context handoffs | e2e manual | Verify handoff content between modes in workflow | N/A -- Wave 0 |

### Sampling Rate
- **Per task commit:** `/signe-health` (quick validation)
- **Per wave merge:** Manual full pipeline test
- **Phase gate:** Human verification of all 7 requirements via end-to-end workflow

### Wave 0 Gaps
None -- this is a prompt engineering project with manual validation. The `/signe-health` check should be updated to validate the new `/signe` skill and updated files (Wave 0 task), but no test framework setup is needed.

## Sources

### Primary (HIGH confidence)
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents) -- Subagent architecture, context: fork, Agent tool chaining, frontmatter fields, no nested spawning
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) -- Skill frontmatter, context: fork + agent field, $ARGUMENTS, disable-model-invocation
- Existing Signe codebase (all files in `signe/` directory) -- Established patterns from Phases 1-5

### Secondary (MEDIUM confidence)
- [Claude Code Best Practice repo](https://github.com/shanraisshan/claude-code-best-practice) -- Referenced as pattern source in CONTEXT.md; consistent with findings from official docs
- [Claude Code Agent Teams Guide](https://claudefa.st/blog/guide/agents/agent-teams) -- Confirmed Agent Teams is experimental and not suitable for sequential pipeline use case

### Tertiary (LOW confidence)
- None -- all findings verified against official documentation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All components are updates to existing files, using established patterns from Phases 1-5
- Architecture: HIGH -- Sequential chaining via Agent tool is documented in official Claude Code docs; flat orchestrator pattern is already validated
- Pitfalls: HIGH -- Based on architectural constraints (context window, no nested spawning) that are well-documented
- GSD integration: MEDIUM -- Read-only approach is safe, but exact path validation mechanism needs implementation-time validation
- `/signe` skill self-routing: MEDIUM -- Whether forked signe can spawn sub-subagents needs empirical testing; fallback (inline execution) is documented

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (stable -- Claude Code subagent architecture unlikely to change)
