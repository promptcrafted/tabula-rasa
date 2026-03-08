# Phase 5: Oversight + Memory - Research

**Researched:** 2026-03-08
**Domain:** Claude Code subagent for code review/quality gates + persistent agent methodology playbook
**Confidence:** HIGH

## Summary

Phase 5 delivers two related capabilities: (1) a `signe-overseer` agent invoked via `/signe-oversee` that performs multi-lens code review, plan gap analysis, progress tracking, and quality gate enforcement, and (2) a subagent methodology system where Signe researches best practices, dry-run tests new agents, validates output quality, and banks validated patterns in MEMORY.md topic files.

The overseer follows the same architectural pattern as the researcher (Phase 2), planner (Phase 3), and designer (Phase 4): a YAML frontmatter agent definition spawned via a skill with `context: fork`. The primary design challenge is that the overseer must read both implementation code AND plan files to compare them -- requiring Read, Grep, Glob, and Bash tools for codebase inspection, plus awareness of the `.planning/` directory structure. Unlike the designer's four independent presets, the overseer's five review lenses (security, performance, correctness, test coverage, style) are complementary passes over the same codebase that feed into a single combined report.

The methodology component is an orchestrator-level capability -- it lives in `signe.md`'s behavioral guidelines and uses the existing memory infrastructure (`~/.claude/agent-memory/signe/`). The methodology cycle (research -> design -> test -> validate -> bank) is a documented process that Signe follows when creating new agents, not a separate agent. Validated patterns are stored in topic files under the memory directory.

**Primary recommendation:** Build two files for oversight (`signe-overseer.md` agent + `signe-oversee/SKILL.md` skill), update four integration files (CLAUDE.md, signe.md, delegation rules, settings.json), implement the methodology guidelines in signe.md, and initialize the memory topic file structure. The overseer should run all 5 lenses by default but accept lens selection via arguments. Target 300-400 lines for the agent definition. Deploy to `~/.claude/` and validate with a real code review task against a completed phase's implementation.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
None -- all implementation decisions are deferred to Claude's discretion.

### Claude's Discretion
All implementation decisions are deferred to the researcher to determine based on reference repo patterns (claude-code-best-practice) and Claude Code best practices:

- Review lenses and depth -- How the 5 review lenses (security, performance, correctness, test coverage, style) are organized. Whether all lenses run every time or are selectable. How deep each lens goes. Output format for findings (file, line, issue, severity, recommended fix per OVRS-06)
- Plan comparison mechanism -- How the overseer finds and reads plan acceptance criteria (OVRS-03). Gap report format. How to match implementation artifacts to plan expectations
- Quality gates and enforcement -- What constitutes pass/fail per phase (OVRS-05). Severity levels. Whether failure blocks progression or warns. How quality criteria are defined
- Progress tracking -- How the overseer tracks completed vs remaining milestones (OVRS-04). Blocker detection. Remaining work estimation approach
- Methodology trigger and flow -- When the research->design->test->validate->bank cycle happens (METH-01 through METH-04). Whether user-initiated or automatic. How dry-run testing works for new agents. What "validate output quality" means concretely
- Playbook/memory structure -- How validated patterns are stored in MEMORY.md topic files (METH-05). Organization scheme (by model, task type, or agent). What metadata each pattern entry captures (model, task type, prompt pattern, success/failure notes)
- Model pinning strategy -- Phase 1 deferred model assignment to Phase 5. Whether agents should specify models (e.g., cheaper models for review tasks) or keep model: inherit. Whether different agents benefit from different models
- Agent definition details -- maxTurns, permissionMode, tool allowlist, system prompt structure for signe-overseer. Which MCP servers the overseer needs (filesystem tools for reading code, possibly GitHub for PR context)
- Skill definition -- SKILL.md structure for signe-oversee, context type (fork expected), argument parsing, review scope specification
- Overseer output format -- How review results are structured. Whether findings are written to files or returned inline. Summary vs detailed output modes

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| OVRS-01 | User can invoke oversight via `/signe-oversee` skill and Signe spawns `signe-overseer` agent | Skill with `context: fork` and `agent: signe-overseer` creates the entry point. Same pattern as all other Signe skills. |
| OVRS-02 | Overseer performs multi-lens code review (security, performance, correctness, test coverage, style as separate passes) | Five sequential review passes, each producing a findings list. All lenses run by default; optional lens selection via `lens:` prefix in arguments. |
| OVRS-03 | Overseer compares implementation against plan acceptance criteria and flags gaps | Overseer Globs for plan files in `.planning/`, reads acceptance criteria, then verifies each criterion against the codebase using Grep/Read. Produces a gap report table. |
| OVRS-04 | Overseer tracks progress (completed vs remaining milestones, blockers, remaining work estimate) | Overseer reads ROADMAP.md and STATE.md, compares against plan acceptance criteria completion, produces progress summary with blocker detection. |
| OVRS-05 | Overseer enforces quality gates per phase -- pass/fail with criteria, blocks progress on failure | Quality gate is a verdict (PASS/WARN/FAIL) based on severity aggregation. FAIL = any critical finding or >50% acceptance criteria unmet. Output includes clear remediation steps. |
| OVRS-06 | Overseer produces actionable feedback (specific file, line, issue, severity, recommended fix) | Every finding follows a structured format: file path, line number(s), issue description, severity (critical/high/medium/low), and concrete recommended fix. |
| METH-01 | Signe researches best practices for each model/agent type before designing prompts | Methodology guidelines in signe.md instruct Signe to spawn signe-researcher before signe-designer when creating new agents. |
| METH-02 | Signe drafts agent prompts following structured methodology (not ad-hoc) | Methodology references the designer's agent preset which already enforces structured prompt engineering (role, context, methodology, output, guardrails). |
| METH-03 | Signe dry-run tests new agents with sample tasks and evaluates output quality | Methodology instructs Signe to invoke the new agent with 2-3 sample tasks and evaluate output against defined quality criteria before banking. |
| METH-04 | Signe validates tested agents against quality criteria before banking as working patterns | Quality criteria: output follows expected format, findings are actionable, no hallucinated file references, severity levels are appropriate. |
| METH-05 | Signe banks validated agent patterns in MEMORY.md topic files (model, task type, prompt pattern, success/failure notes) | Topic file `agent-recipes.md` in `~/.claude/agent-memory/signe/` stores validated patterns with metadata: model, task type, prompt pattern, what worked, what failed, date validated. |
</phase_requirements>

## Standard Stack

### Core

| Component | Value | Purpose | Why Standard |
|-----------|-------|---------|--------------|
| Agent definition | `signe-overseer.md` | Oversight agent with YAML frontmatter and 5-lens review methodology | Same pattern as signe-researcher.md, signe-planner.md, signe-designer.md |
| Skill definition | `signe-oversee/SKILL.md` | User-facing `/signe-oversee` entry point | Same pattern as all other Signe skills |
| Context type | `context: fork` | Isolated context window for review work | Review reads many files -- needs dedicated context to avoid polluting main thread |
| Model | `model: inherit` | Keep consistent with all other agents | See Model Pinning section below for rationale |
| Memory | `memory: user` | Cross-project review knowledge | Consistent with all Signe agents |
| Permission mode | `permissionMode: bypassPermissions` | Uninterrupted review workflow | Consistent with all other Signe agents; overseer is read-heavy, writes only report files |

### Tool Allowlist

| Tool | Purpose | Required? |
|------|---------|-----------|
| Read | Read source files, plan files, config files | Yes -- core review capability |
| Write | Write review report to disk | Yes -- output delivery |
| Bash | Run test commands, git diff, file discovery | Yes -- test execution and git context |
| Grep | Search codebase for patterns, issues, references | Yes -- core review capability |
| Glob | Find files by pattern (test files, plan files, source files) | Yes -- file discovery |
| WebSearch | No | No -- review is local codebase analysis, not web research |
| WebFetch | No | No -- same as above |

### MCP Servers

| Server | Purpose | Required? |
|--------|---------|-----------|
| None | Overseer works entirely with local filesystem tools | The overseer does not need web research, search APIs, or external services. All review is against local code and local plan files. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Single overseer with 5 lenses | 5 parallel review subagents (a la HAMY's 9-agent pattern) | Parallel agents save time but overseer cannot spawn subagents (flat orchestrator constraint). The single-agent approach is architecturally correct for Signe. |
| `model: inherit` | `model: haiku` for cheaper reviews | Reviews require deep code understanding and nuanced judgment. Haiku would miss subtle issues. Keep inherit and let the user choose their model. |
| Write report to file | Return findings inline | Reports can be long (50+ findings). Writing to file keeps conversation clean and allows the user to reference later. Write to file AND return recap. |

## Architecture Patterns

### Recommended Project Structure

New files for this phase:

```
signe/
  agents/
    signe-overseer.md           # NEW -- oversight agent definition (~300-400 lines)
  skills/
    signe-oversee/
      SKILL.md                  # NEW -- skill entry point
~/.claude/
  agent-memory/
    signe/
      MEMORY.md                 # EXISTS -- update with methodology topic index
      agent-recipes.md          # NEW -- validated agent pattern playbook
```

Files to update:

```
signe/
  CLAUDE.md                     # UPDATE -- mode table status: Available
  agents/signe.md               # UPDATE -- Coming Soon section, add methodology guidelines
  rules/signe-delegation.md     # UPDATE -- phase note, agent status
```

### Pattern 1: Overseer Agent Structure

**What:** The overseer agent follows the same three-section structure as all Signe agents: (1) YAML frontmatter, (2) role definition + argument parsing, (3) methodology.

**When to use:** Always -- this is the only pattern for Signe subagents.

**Agent frontmatter:**

```yaml
---
name: signe-overseer
description: Code review and quality verification agent. Reviews implementation against plans, enforces quality gates, and tracks progress.
tools: Read, Write, Bash, Grep, Glob
model: inherit
memory: user
maxTurns: 40
permissionMode: bypassPermissions
---
```

**Rationale for maxTurns: 40:** Same as designer. Overseer needs to read many files (plans, source code, tests), run analysis, and produce a structured report. More tool-intensive than planner (30) but not as exploratory as researcher (50).

### Pattern 2: Five-Lens Review Methodology

**What:** The overseer runs five sequential review passes over the codebase. Each lens produces a findings list. Results are combined into a single structured report.

**Lens definitions:**

| Lens | Focus | What to Check |
|------|-------|---------------|
| Security | Vulnerabilities, injection risks, auth issues, secrets exposure | Hardcoded credentials, input validation, permission checks, error message information leakage |
| Performance | Bottlenecks, resource usage, algorithmic concerns | N+1 queries, memory leaks, unnecessary computation, large file reads, missing caching |
| Correctness | Logic errors, edge cases, requirement compliance | Off-by-one errors, null handling, race conditions, business logic alignment with requirements |
| Test Coverage | Test existence, quality, coverage gaps | Missing tests for critical paths, test quality (meaningful assertions vs trivial), integration test gaps |
| Style | Code consistency, naming, organization, documentation | Naming conventions, file organization, comment quality, dead code, duplication |

**Lens execution order:** Security -> Correctness -> Performance -> Test Coverage -> Style. Security and correctness first because they are most critical and benefit from fresh context. Style last because it is least critical.

### Pattern 3: Plan Gap Analysis

**What:** The overseer reads plan acceptance criteria and verifies each one against the actual codebase.

**Process:**
1. Glob for `.planning/phases/*/XX-*-PLAN.md` to find relevant plan files
2. Extract acceptance criteria (lines matching `- [ ]` or `- [x]` pattern)
3. For each criterion, verify against the codebase using Grep/Read
4. Produce a gap report table with: criterion, status (MET/UNMET/PARTIAL), evidence (file:line), notes

**Gap report format:**

```markdown
## Gap Report: Phase [X]

| # | Acceptance Criterion | Status | Evidence | Notes |
|---|---------------------|--------|----------|-------|
| 1 | [criterion text] | MET | `path/file.md:42` | [optional notes] |
| 2 | [criterion text] | UNMET | - | [what's missing] |
| 3 | [criterion text] | PARTIAL | `path/file.md:15` | [what's incomplete] |

**Summary:** X/Y criteria met, Z gaps identified
```

### Pattern 4: Quality Gate Verdict

**What:** The overseer produces a final verdict that determines whether a phase passes quality review.

**Verdict levels:**

| Verdict | Criteria | Action |
|---------|----------|--------|
| PASS | No critical/high findings AND >80% acceptance criteria MET | Proceed to next phase |
| WARN | No critical findings but has high findings OR 50-80% criteria MET | Proceed with noted concerns |
| FAIL | Any critical finding OR <50% acceptance criteria MET | Block progression, remediate first |

### Pattern 5: Progress Tracking

**What:** The overseer reads ROADMAP.md, STATE.md, and plan files to produce a progress summary.

**Output format:**

```markdown
## Progress Report

**Phase:** [X] - [Name]
**Plans:** [completed]/[total]
**Acceptance Criteria:** [met]/[total] ([percentage]%)

### Completed
- [x] [milestone/deliverable]

### Remaining
- [ ] [milestone/deliverable] -- [estimated effort]

### Blockers
- [blocker description] -- [impact] -- [suggested resolution]

### Estimated Remaining Work
[estimate based on velocity from STATE.md metrics]
```

### Pattern 6: Methodology Guidelines (in signe.md)

**What:** Process Signe follows when creating new agents. Lives in signe.md behavioral guidelines, not in a separate agent.

**The cycle:**

```
1. RESEARCH: Spawn signe-researcher to investigate model/task best practices
   - What prompt patterns work for this task type
   - What tools the agent needs
   - Known pitfalls and failure modes

2. DESIGN: Spawn signe-designer (agent preset) to produce agent definition
   - Uses research findings as input
   - Produces YAML frontmatter + system prompt + skill definition

3. TEST: Invoke the new agent with 2-3 sample tasks
   - Vary task complexity (simple, medium, complex)
   - Evaluate output against quality criteria

4. VALIDATE: Check output quality against criteria
   - Output follows expected format
   - Findings are actionable and specific (not vague)
   - No hallucinated file references
   - Severity levels are appropriate
   - Success rate >= 2/3 sample tasks

5. BANK: Save validated pattern to agent-recipes.md
   - Model used, task type, prompt pattern summary
   - What worked well, what needed adjustment
   - Date validated, confidence level
```

### Pattern 7: Memory Topic File Structure

**What:** Validated patterns stored in `~/.claude/agent-memory/signe/agent-recipes.md`.

**Entry format:**

```markdown
### [Agent Name] - [Task Type]

**Validated:** [date]
**Model:** [model used during validation]
**Confidence:** [HIGH/MEDIUM/LOW]

**Prompt pattern:** [1-2 sentence summary of what makes this agent effective]

**What works:**
- [specific pattern that produced good results]
- [specific pattern that produced good results]

**What failed:**
- [pattern that was tried and produced poor results]

**Key metrics:**
- Sample tasks tested: [N]
- Success rate: [X/N]
- Average output quality: [brief assessment]
```

### Anti-Patterns to Avoid

- **Overseer modifying code:** The overseer is read-only except for writing its report file. It never fixes issues -- it reports them. Signe's maker-checker separation demands that the producing agent and reviewing agent are different.
- **Overly granular lenses:** Running each lens as a separate subagent is impossible (flat orchestrator) and unnecessary. Five sequential passes within one agent is sufficient.
- **Vague findings:** Every finding must reference a specific file and line number. "The code has security issues" is not actionable. "In `auth.js:42`, the JWT secret is hardcoded as a string literal" is actionable.
- **Memory as database:** MEMORY.md and topic files are curated prose, not structured data. Keep entries concise and natural-language. The 200-line limit on MEMORY.md means only the index loads automatically -- detailed patterns live in topic files read on-demand.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| File discovery | Custom recursive file search | Glob + Grep tools | Built-in tools are optimized and handle edge cases |
| Test execution | Custom test runner | `Bash("npm test")` or equivalent | Let the project's own test infrastructure run |
| Git diff analysis | Manual file comparison | `Bash("git diff")` or `Bash("git log")` | Git provides structured diff output |
| Report formatting | Custom template engine | Direct markdown in Write tool | Agent produces markdown natively |
| Memory persistence | Custom storage system | Native `memory: user` + MEMORY.md + topic files | Claude Code's built-in memory system is the only supported approach |

**Key insight:** The overseer's value is in judgment and analysis, not in tooling. Use the existing tools (Read, Grep, Glob, Bash) for data gathering and focus the agent's system prompt on analysis methodology and output quality.

## Common Pitfalls

### Pitfall 1: Overseer Hallucinating File References

**What goes wrong:** The agent produces findings referencing files or line numbers that don't exist, especially after reading many files and losing track of context.
**Why it happens:** Context pressure after reading 20+ files causes the agent to confuse file contents.
**How to avoid:** Instruct the agent to verify every file reference with a Read or Grep call before including it in the report. Include a self-check step: "Before finalizing, verify each file:line reference exists."
**Warning signs:** Findings reference files not in the project, or line numbers that don't match the described code.

### Pitfall 2: Lens Cross-Contamination

**What goes wrong:** Security findings appear in the performance section, style findings in correctness, etc.
**Why it happens:** Without clear section boundaries, the agent blurs lens distinctions during a long review session.
**How to avoid:** Process one lens at a time. Complete all findings for lens N, write them to the report section, then move to lens N+1. Use explicit "Now reviewing for [LENS]" markers in the methodology.
**Warning signs:** Findings categorized under the wrong lens, or the same finding appearing in multiple lenses.

### Pitfall 3: Memory Staleness (Pitfall 4 from Phase 1 Research)

**What goes wrong:** Agent-recipes.md accumulates outdated patterns as models evolve.
**Why it happens:** No automatic curation. Old entries persist indefinitely.
**How to avoid:** Include date stamps and model versions on every entry. Instruct Signe to review and prune entries older than 90 days or for superseded model versions. Keep agent-recipes.md under 200 lines; start a new topic file if it grows.
**Warning signs:** Memory contains patterns for model versions no longer in use.

### Pitfall 4: Quality Gate Too Strict or Too Lenient

**What goes wrong:** FAIL verdict on every review (too strict) or PASS verdict despite real issues (too lenient).
**Why it happens:** Severity calibration is subjective. Different codebases have different quality norms.
**How to avoid:** The severity definitions must be concrete and examples-based, not abstract. Include examples of what constitutes critical vs high vs medium vs low for each lens. Default to WARN for first-time reviews to calibrate.
**Warning signs:** User consistently disagrees with verdicts.

### Pitfall 5: Methodology Becomes Ceremony

**What goes wrong:** The research->design->test->validate->bank cycle is followed mechanically without improving agent quality.
**Why it happens:** The cycle is documented but not evaluated. Signe follows steps without reflecting on whether each step adds value.
**How to avoid:** The validation step must have concrete criteria, not just "looks good." Track success rates across dry-runs. If an agent consistently passes dry-run but fails in production, the dry-run methodology needs updating.
**Warning signs:** All agents pass validation but users report poor quality.

## Code Examples

### Overseer Skill Definition

```yaml
---
name: signe-oversee
description: Code review, quality gates, and progress tracking
context: fork
agent: signe-overseer
disable-model-invocation: false
---

## Oversight Task

Review the following scope using your multi-lens methodology.

$ARGUMENTS

If the first token starts with `scope:`, use it to narrow the review:
- `scope:security` -- run only the security lens
- `scope:plan` -- run only the plan gap analysis
- `scope:progress` -- run only the progress tracker
- `scope:gate` -- run the quality gate verdict only

Otherwise, run the full review (all lenses + plan comparison + progress + verdict).

Check `.planning/` for plan files and acceptance criteria to compare against.
```

### Overseer Finding Format

```markdown
### [LENS-NNN] [Issue Title]

**File:** `path/to/file.ext:42-48`
**Severity:** critical | high | medium | low
**Lens:** security | performance | correctness | test-coverage | style

**Issue:** [1-2 sentence description of the problem]

**Evidence:**
```[language]
// The problematic code snippet
```

**Recommended Fix:**
```[language]
// The suggested correction
```

**Rationale:** [Why this matters and what could go wrong if not fixed]
```

### Methodology Entry in signe.md

```markdown
## Subagent Methodology

When creating a NEW agent (not using an existing one):

1. **Research first:** Spawn `/signe-research` to investigate:
   - Prompt patterns that work for this task type and model
   - Tool requirements and permission considerations
   - Known pitfalls and failure modes
   - Community examples of similar agents

2. **Design with agent preset:** Spawn `/signe-design preset:agent` with research findings:
   - Produces YAML frontmatter, system prompt, tool rationale, skill definition
   - Uses structured methodology (not ad-hoc prompt writing)

3. **Dry-run test:** Create the agent files, then invoke with 2-3 sample tasks:
   - One simple task, one medium, one edge case
   - Evaluate: Does output follow format? Are findings specific? No hallucinations?

4. **Validate:** Check results against criteria:
   - Output follows expected structure
   - Findings reference real files/lines (not hallucinated)
   - Severity assignments are appropriate
   - Success rate >= 2 out of 3 sample tasks

5. **Bank or iterate:** If validated, save pattern to agent-recipes.md:
   - Model, task type, prompt pattern, what worked, what failed, date
   - If not validated, adjust design and re-test (max 2 iterations)
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single-model self-review | Cross-model or independent-agent review | 2025-2026 | Maker-checker separation improves review quality |
| Manual code review prompts | Specialized review subagents with structured methodology | Feb 2026 | Parallel review agents can cover 5+ quality dimensions |
| Ad-hoc agent creation | Research -> design -> test -> validate -> bank cycle | Signe Phase 5 | Systematic methodology prevents prompt drift and ensures quality |
| Monolithic MEMORY.md | Index MEMORY.md + topic files | Claude Code v2.1.33 (Feb 2026) | Scales beyond 200-line limit while maintaining auto-load |

## Model Pinning Decision

**Recommendation: Keep `model: inherit` for all agents including the overseer.**

Rationale:
- All four existing agents use `model: inherit`. Consistency reduces cognitive overhead.
- Review tasks require deep code understanding and nuanced judgment. Cheaper models (haiku) would miss subtle issues.
- The user controls model selection at the session level. If they want cheaper reviews, they start the session with a cheaper model.
- Model pinning adds a maintenance burden: model names change, new models release, pinned values become stale.
- If model-specific optimization is discovered through methodology validation, it can be documented in agent-recipes.md as a recommendation, not enforced in frontmatter.

**Exception:** If future methodology validation discovers a model that is dramatically better or cheaper for review tasks, update the agent-recipes.md entry and consider pinning at that time.

## Open Questions

1. **Scope specification granularity**
   - What we know: The skill accepts scope prefixes (scope:security, scope:plan, etc.) and defaults to full review
   - What's unclear: Whether users will want file-level scope (review only `src/auth/`) or always want full-project review
   - Recommendation: Start with full-project review. Add file/directory scoping in a future iteration if users request it. Keep the skill arguments simple for v1.

2. **Review report file naming**
   - What we know: Other Signe agents use `signe-[mode]-[topic].md` naming
   - What's unclear: Whether review reports should include timestamps to avoid overwriting previous reviews
   - Recommendation: Use `signe-review-[date]-[scope].md` (e.g., `signe-review-2026-03-08-phase5.md`). Include date to preserve review history.

3. **Methodology trigger automation**
   - What we know: METH-01 through METH-04 describe a research->design->test->validate cycle
   - What's unclear: Whether this should be automatic (Signe always does it) or user-initiated
   - Recommendation: User-initiated. Signe's methodology guidelines say "when creating a NEW agent" -- the user decides when to create new agents. Signe follows the methodology when asked, not proactively.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual validation (no automated test framework -- this is a Claude Code agent package, not a software project) |
| Config file | None -- validation is behavioral/functional |
| Quick run command | `claude -p "invoke /signe-oversee on the signe project"` |
| Full suite command | Manual invocation of each capability (5 lenses, plan gap, progress, quality gate) |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| OVRS-01 | `/signe-oversee` spawns signe-overseer agent | manual (e2e) | Invoke skill, verify agent spawns | Wave 0 |
| OVRS-02 | Multi-lens review produces 5 categorized finding sections | manual (e2e) | Invoke full review, check output has 5 lens sections | Wave 0 |
| OVRS-03 | Plan comparison produces gap report with file/line references | manual (e2e) | Invoke with `scope:plan`, check gap report table | Wave 0 |
| OVRS-04 | Progress tracking shows completed/remaining/blockers | manual (e2e) | Invoke with `scope:progress`, check progress summary | Wave 0 |
| OVRS-05 | Quality gate produces PASS/WARN/FAIL verdict | manual (e2e) | Invoke with `scope:gate`, check verdict present | Wave 0 |
| OVRS-06 | Findings include file, line, severity, recommended fix | manual (e2e) | Check any finding for all 4 fields | Wave 0 |
| METH-01 | Signe researches before designing new agents | manual (behavioral) | Ask Signe to create a new agent, verify research step | Wave 0 |
| METH-02 | Agent prompts follow structured methodology | manual (behavioral) | Check designed agent uses role/context/methodology/output/guardrails | Wave 0 |
| METH-03 | Dry-run testing with sample tasks | manual (behavioral) | Ask Signe to test a new agent, verify sample task execution | Wave 0 |
| METH-04 | Validation against quality criteria before banking | manual (behavioral) | Verify validation step occurs with concrete criteria | Wave 0 |
| METH-05 | Patterns banked in MEMORY.md topic files | manual (behavioral) | Check agent-recipes.md for banked entry with required fields | Wave 0 |

### Sampling Rate

- **Per task commit:** Manual invocation of modified capability
- **Per wave merge:** Full review of completed agent definition against requirements
- **Phase gate:** Human validation of all OVRS and METH requirements end-to-end

### Wave 0 Gaps

- [ ] `signe/agents/signe-overseer.md` -- the main agent definition (does not exist yet)
- [ ] `signe/skills/signe-oversee/SKILL.md` -- the skill entry point (does not exist yet)
- [ ] `~/.claude/agent-memory/signe/agent-recipes.md` -- methodology playbook topic file (does not exist yet)

## Sources

### Primary (HIGH confidence)
- Existing Signe agents (`signe-researcher.md`, `signe-planner.md`, `signe-designer.md`) -- established patterns for agent architecture, tool selection, preset routing, skill definition, and deployment
- Existing project architecture (`ARCHITECTURE.md`, `PITFALLS.md`) -- documented patterns and pitfalls for Claude Code agent packages
- [Claude Code official docs](https://code.claude.com/docs/en/sub-agents) -- subagent capabilities, frontmatter fields, tool restrictions
- [Claude Code memory docs](https://code.claude.com/docs/en/memory) -- MEMORY.md structure, 200-line limit, topic files, memory scope

### Secondary (MEDIUM confidence)
- [HAMY parallel code review agents](https://hamy.xyz/blog/2026-02_code-reviews-claude-subagents) -- 9-agent parallel review pattern (adapted to single-agent sequential for Signe's flat orchestrator constraint)
- [VoltAgent awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) -- code-reviewer, architect-reviewer, security-auditor agent patterns
- [subagents.app reviewer](https://subagents.app/agents/reviewer) -- five-phase review methodology (functionality, security, performance, quality, maintainability)
- [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) -- phase-gated development, cross-model QA, memory patterns

### Tertiary (LOW confidence)
None -- all findings verified against at least one primary or secondary source.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- identical pattern to 3 prior Signe agents, no novel architecture
- Architecture: HIGH -- five-lens review and plan gap analysis are straightforward applications of existing tools (Read, Grep, Glob)
- Methodology: MEDIUM -- the research->design->test->validate->bank cycle is a new process not yet validated in practice. Design is sound but effectiveness is unknown until Phase 5 execution.
- Pitfalls: HIGH -- pitfalls 1-2 specific to oversight agents, pitfalls 3-5 carry forward from Phase 1 research

**Research date:** 2026-03-08
**Valid until:** 2026-04-08 (30 days -- stable domain, patterns well-established)
