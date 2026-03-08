# Domain Pitfalls: Claude Code Global Agent Package

**Domain:** Global Claude Code agent package (~/.claude/) with Command/Agent/Skill architecture
**Project:** Signe
**Researched:** 2026-03-07

---

## Critical Pitfalls

Mistakes that cause rewrites, architectural dead ends, or fundamental breakage.

---

### Pitfall 1: The "May or May Not Be Relevant" Instruction Undermining

**What goes wrong:** Claude Code wraps all CLAUDE.md content in `<system-reminder>` tags with the disclaimer: *"IMPORTANT: this context may or may not be relevant to your tasks. You should not respond to this context unless it is highly relevant to your task."* This tells the model to treat instructions as optional background noise. As conversations grow, instructions marked as "may not be relevant" are deprioritized first.

**Why it happens:** By design in Claude Code's architecture. The disclaimer exists because CLAUDE.md files load for every session regardless of relevance.

**Consequences:** Progressive instruction drift during long sessions. Startup procedures, processing rules, and behavioral rules are treated as suggestions. A Signe orchestration session involving research then planning then oversight could easily exceed the threshold where instructions begin degrading.

**Warning signs:**
- Agent stops following workflow sequences (skipping research before planning)
- Agent acknowledges rules when asked but doesn't apply them during execution
- Behavior consistency drops sharply after auto-compaction events

**Prevention:**
- Keep each CLAUDE.md file under 100 lines (not the 200-line max -- aim lower because multiple files concatenate)
- Use hooks (deterministic, cannot be ignored) for any behavior that MUST happen every time
- Use PreToolUse hooks as guardrails rather than relying on instruction compliance
- Front-load the most critical instructions in the first 10 lines of each file
- Split instructions into `.claude/rules/` files that are narrowly scoped

**Confidence:** HIGH -- documented in multiple GitHub issues, verified by community.

**Phase relevance:** Phase 1 (Foundation). Must be addressed in initial CLAUDE.md architecture.

---

### Pitfall 2: Instruction Overload Causes Uniform Degradation

**What goes wrong:** As instruction count increases, quality decreases uniformly across ALL instructions. Claude Code's system prompt already contains ~50 built-in instructions. Each CLAUDE.md, rules file, skill description, and agent definition adds more. A comprehensive package like Signe could push past 200+ instructions where even frontier models begin exponential decay.

**Why it happens:** LLMs have finite attention. Frontier thinking models follow approximately 150-200 instructions with reasonable consistency. Adding 4 modes, 8+ agent definitions, 10+ skills, memory instructions, and workflow protocols can exceed the budget.

**Consequences:** Everything gets slightly worse. Research mode bleeds into planning. Oversight skips steps. Personality becomes inconsistent. Debugging is difficult because nothing is specifically "broken."

**Prevention:**
- Budget total instructions. Target under 150 across what loads for any single session
- Use lazy-loading skill architecture: descriptions (~100 tokens) at startup, full content (~5K tokens) on invocation
- Each agent preloads ONLY its relevant skills, not all skills
- Validate with `/context` command to see actual token consumption
- Agent descriptions stay under 140 characters

**Confidence:** HIGH -- documented by HumanLayer, corroborated by Anthropic's best practices.

**Phase relevance:** Phase 1-2. Must be considered from initial architecture.

---

### Pitfall 3: Subagents Cannot Spawn Subagents -- Architecture Must Be Flat

**What goes wrong:** Signe's design envisions hierarchical delegation where a research agent might spawn a web-search subagent. This is impossible. Subagents do not have access to the Agent tool. They cannot spawn other subagents. Period.

**Why it happens:** Claude Code prevents nesting to avoid complexity and infinite recursion. The Agent tool is only available to the main thread or to agents running via `claude --agent`.

**Consequences:** Any design assuming hierarchical delegation will fail. The "chief of staff delegates to specialist who delegates to sub-specialist" pattern cannot work.

**Prevention:**
- Design Signe as a flat orchestrator: main thread spawns subagents, subagents complete self-contained tasks
- Use `tools: Agent(signe-researcher, signe-planner, signe-designer, signe-overseer)` in Signe's main agent to whitelist spawnable subagents
- For complex workflows, chain from main thread: main -> researcher -> (results) -> main -> planner
- Use Skills (not subagents) for shared behavior that runs in the caller's context
- Preload skills into subagents via `skills:` frontmatter for domain knowledge

**Confidence:** HIGH -- official, documented, confirmed architectural constraint.

**Phase relevance:** Phase 1 (Foundation). The entire architecture must be designed around this.

---

### Pitfall 4: MEMORY.md Accumulates Stale Data

**What goes wrong:** MEMORY.md has a hard 200-line limit. Only the first 200 lines load. After 10+ sessions, ~30% redundant entries. Stale observations push out valuable recent learnings. Agent's "institutional memory" degrades over time.

**Why it happens:** Auto-memory never proactively curates or removes old entries. New entries are appended, not merged. No automatic deduplication.

**Consequences:** For Signe's agent playbook, this is catastrophic. Early exploratory findings crowd out validated best practices. Stale model advice persists after model updates invalidate it.

**Prevention:**
- Implement explicit curation instructions: "Before adding, read existing entries and remove contradicted/superseded/stale ones"
- Separate concerns: MEMORY.md as index, topic files (model-playbook.md, patterns.md) for detailed knowledge
- Use `memory: user` scope for cross-project persistence
- Implement PostToolUse hook warning when MEMORY.md exceeds 150 lines
- Include date stamps and confidence levels in memory entries

**Confidence:** HIGH -- 200-line limit documented, staleness widely reported.

**Phase relevance:** Phase 2-3. Memory architecture designed early, curation refined as agents generate data.

---

### Pitfall 5: Subagent Permission Escalation via bypassPermissions

**What goes wrong:** When the parent agent runs with `bypassPermissions` or `--dangerously-skip-permissions`, ALL subagents inherit this mode and it CANNOT be overridden. Even if a subagent's frontmatter says `permissionMode: plan`, the parent's bypass takes precedence.

**Why it happens:** bypassPermissions propagates to all child contexts by design.

**Consequences:** Research subagent that should be read-only gets full write/execute access. Prompt injection in fetched web content could trigger destructive actions. The "research is read-only" security model breaks silently.

**Prevention:**
- NEVER run Signe with `bypassPermissions`
- Use `permissionMode: default` or `plan` for Signe herself
- For research agents, use explicit tool allowlists: `tools: Read, Grep, Glob, WebSearch, WebFetch`
- Use `disallowedTools: Write, Edit, Bash` as belt-and-suspenders
- Test permission boundaries during dry-run validation

**Confidence:** HIGH -- documented in official docs: "If the parent uses bypassPermissions, this takes precedence and cannot be overridden."

**Phase relevance:** Phase 2 (Agent Design). Permission model before any agent deployment.

---

### Pitfall 6: Context Window Starvation from System Overhead

**What goes wrong:** Claude Code reserves ~33K tokens as compaction buffer. System prompt, tool definitions, MCP schemas, and memory consume 30-40K tokens before any conversation. With a comprehensive agent package, effective usable context shrinks to 100-120K tokens out of 200K. Auto-compaction at ~167K is lossy.

**Why it happens:** Every component adds to system prompt overhead. MCP servers add tool schemas. Skills add descriptions. Rules files load. Memory files load. Additive and invisible without `/context` audit.

**Consequences:** Multi-step workflows (research -> plan -> design -> oversee) may trigger compaction mid-workflow, losing critical context from earlier phases.

**Prevention:**
- Audit with `/context` after setup -- target under 30K system overhead
- Use subagents aggressively: each gets its own 200K context
- Design workflows so each phase completes in a subagent, returning concise summaries
- Use `model: haiku` for simple subagent tasks (own context window)
- Consider `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to tune compaction timing

**Confidence:** HIGH -- token numbers verified from official docs.

**Phase relevance:** Phase 1-2. System overhead budget established early.

---

## Moderate Pitfalls

---

### Pitfall 7: Hook Cross-Platform Failures on Windows

**What goes wrong:** Hooks with bash-specific syntax fail silently on Windows. `$HOME`, `/tmp`, POSIX paths all break. Claude Code on Windows uses cmd.exe by default, not bash.

**Prevention:**
- Write ALL hooks in Node.js. Claude Code requires Node.js on every platform
- Use `os.homedir()` instead of `$HOME`
- Use `path.join()` for path construction
- Use `command: "node ~/.claude/hooks/script-name.js"` pattern
- Test on Windows (Minta's primary environment)

**Confidence:** HIGH -- documented in changelog, multiple GitHub issues.

**Phase relevance:** Phase 1 (Foundation). Hook infrastructure must be cross-platform from start.

---

### Pitfall 8: Global Agents Collide with Project-Level Definitions

**What goes wrong:** When Signe defines agents in `~/.claude/agents/` and a project defines agents with the same name in `.claude/agents/`, the project-level definition wins silently. Signe's agent is replaced with no warning.

**Prevention:**
- Namespace ALL of Signe's components with `signe-` prefix: `signe-researcher`, `signe-planner`, etc.
- Run `claude agents` to audit overrides when entering a new project
- Use unique skill names with the same prefix pattern
- Always use `memory: user` scope so memory persists regardless of project context

**Confidence:** HIGH -- precedence order documented in official subagent docs.

**Phase relevance:** Phase 1 (Foundation). Naming conventions before any agents created.

---

### Pitfall 9: Agent Drift in Multi-Step Workflows

**What goes wrong:** Over extended interaction sequences, agents progressively deviate from original intent. Research found drift manifests after ~73 interactions with 42% task success reduction. By 600 interactions, semantic drift affects ~50% of agents.

**Prevention:**
- Use subagents (each with fresh context) for each phase
- Keep main orchestrator lean: spawn -> get summary -> spawn next
- Include behavioral anchoring in system prompts: examples, not just rules
- Implement checkpoint hooks validating output structure at phase boundaries
- For very long workflows, start new session and pass state via files

**Confidence:** MEDIUM -- research paper on general multi-agent systems, not specifically Claude Code.

**Phase relevance:** Phase 3 (Workflow Design).

---

### Pitfall 10: YAML Frontmatter Description Field Misuse

**What goes wrong:** Agent descriptions serve as routing hints. Long descriptions (1300+ chars) waste tokens and confuse routing. Vague descriptions cause false delegation.

**Prevention:**
- Keep descriptions to ~140 characters: routing hints, not documentation
- Write as WHEN clauses: "Use when the user needs deep investigation of technologies"
- Avoid overlapping trigger words across agents
- Put all behavioral instructions in the markdown body, not the description
- Test routing with ambiguous prompts

**Confidence:** HIGH -- documented in GitHub issues.

**Phase relevance:** Phase 2 (Agent Design).

---

### Pitfall 11: GSD Cross-Contamination When Orchestrating External Workflows

**What goes wrong:** Running GSD across multiple projects, state from one project can leak into another if working directories are not properly isolated.

**Prevention:**
- Always pass explicit absolute paths to subagents
- Use `isolation: worktree` for GSD-running subagents
- Validate working directory as first step in any GSD-invoking agent
- Implement PreToolUse hook checking working directory before .planning/ writes

**Confidence:** MEDIUM -- risk well-understood, specific interaction with Signe's global scope not yet validated.

**Phase relevance:** Phase 3-4 (Workflow Integration).

---

### Pitfall 12: LLM Non-Determinism Breaks Testing and Validation

**What goes wrong:** Signe's methodology requires dry-run testing of prompts. But the same prompt yields different results across invocations. Even at temperature=0, batch variance produces variance.

**Prevention:**
- Run dry-run tests minimum 3-5 times, evaluate worst result
- Use hooks for any behavior requiring 100% consistency
- Design playbook to store success rates, not binary pass/fail
- Include failure mode documentation alongside success patterns
- Build evaluation criteria tolerant of variance: "contains required sections" not "matches expected output"

**Confidence:** HIGH -- non-determinism well-documented.

**Phase relevance:** Phase 2-3 (Agent Design + Testing Methodology).

---

## Minor Pitfalls

---

### Pitfall 13: Skill Auto-Invocation Misfires

**What goes wrong:** Skills with auto-invocation enabled fire based on Claude's interpretation of descriptions, not explicit triggers. Overlapping descriptions cause unpredictable selection.

**Prevention:**
- Write descriptions with explicit trigger conditions
- Prefer `disable-model-invocation: true` for Signe's specialized capabilities
- Test with edge-case prompts to verify no inappropriate firing

**Phase relevance:** Phase 2 (Skill Organization).

---

### Pitfall 14: Hook Exit Code Confusion

**What goes wrong:** Exit 0 = allow, exit 2 = block, exit 1 = hook error (tool still proceeds). Many assume exit 1 = block. The `{"approve": false}` format does NOT work -- use `hookSpecificOutput` pattern.

**Prevention:**
- Document exit code contract in every hook script
- Use exit 2 (not exit 1) for all blocking hooks
- Use `hookSpecificOutput` JSON response format
- Test hooks by triggering the block condition

**Phase relevance:** Phase 1 (Foundation hooks).

---

### Pitfall 15: Subagent Results Bloat the Main Context

**What goes wrong:** Subagent results return to main conversation context. 4 parallel subagents returning 5K tokens each = 20K consumed in main thread.

**Prevention:**
- Include summarization instructions: "Return results in under 500 tokens"
- Design subagent prompts to write details to files, return only summaries
- Chain sequentially when context is tight

**Phase relevance:** Phase 2-3 (Agent Design + Workflow Design).

---

### Pitfall 16: CLAUDE.md Files Are Additive, Not Overriding

**What goes wrong:** Global and project CLAUDE.md files load simultaneously. If they contain conflicting instructions, outcome is unpredictable.

**Prevention:**
- Design Signe's global CLAUDE.md for universal, project-agnostic instructions only
- Never put tool-specific or workflow-specific instructions in global CLAUDE.md
- Use rules/ files for scoped instructions
- Document which instructions live at which scope level

**Phase relevance:** Phase 1 (Foundation).

---

## Phase-Specific Warning Matrix

| Phase | Likely Pitfall | Severity | Mitigation |
|-------|---------------|----------|------------|
| Phase 1: Foundation | #1 Instruction undermining, #2 Overload, #3 No nesting, #7 Windows hooks, #8 Name collisions, #14 Exit codes, #16 Additive CLAUDE.md | Critical | Budget instructions, use hooks for enforcement, namespace agents, write Node.js hooks |
| Phase 2: Agent Design | #5 Permission escalation, #10 Description misuse, #12 Non-determinism, #13 Skill misfires | Critical | Explicit tool allowlists, 140-char descriptions, multi-run validation |
| Phase 3: Workflow Design | #4 Memory staleness, #6 Context starvation, #9 Agent drift, #11 GSD cross-contamination, #15 Result bloat | High | Memory curation, subagent isolation, checkpoint hooks, explicit paths |
| Phase 4: Oversight + Polish | #9 Agent drift (ongoing), #12 Non-determinism (ongoing) | Moderate | Behavioral anchoring, continuous evaluation, playbook refinement |

---

## Key Takeaway

The single most dangerous pattern is **assuming instruction compliance**. CLAUDE.md instructions are advisory, not binding. The "may or may not be relevant" disclaimer, instruction overload, compaction-induced memory loss, and agent drift all compound to make prose instructions unreliable over long sessions. The prevention strategy: **use hooks for enforcement, subagents for isolation, and skills for lazy-loading. Reserve CLAUDE.md instructions for guidance that can gracefully degrade.**

---

## Sources

- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Claude Code Memory](https://code.claude.com/docs/en/memory)
- [Claude Code Subagents](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Settings](https://code.claude.com/docs/en/settings)
- [Claude Code Permissions](https://code.claude.com/docs/en/permissions)
