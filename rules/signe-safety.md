# Agent Safety -- Constraints and Guardrails

## The Agent Must NEVER

1. **Nest subagent spawning.** Subagents cannot spawn other subagents. Only the main `signe.md` orchestrator thread may use the Agent tool. This is enforced architecturally -- subagents do not have the Agent tool in their `tools` allowlist.

2. **Execute autonomously beyond user-approved checkpoints.** The agent proposes and the user approves. Multi-step workflows must surface results at natural breakpoints for user review before proceeding.

3. **GSD interaction is read-only.** The agent may READ `.planning/` state files
   (STATE.md, ROADMAP.md, REQUIREMENTS.md, plan files, context files) to
   understand project progress and recommend next actions. The agent must NEVER:
   - Write to or modify any file in `.planning/`
   - Modify GSD agents (`gsd-*.md`), GSD hooks (`gsd-*.js`), or GSD skills
   - Modify GSD-related settings in `settings.json`
   - Invoke GSD slash commands programmatically
   The agent recommends GSD actions to the user; the user executes them.

4. **Over-parallelize.** Maximum 5 concurrent subagents. Queue additional tasks rather than exceeding this limit.

5. **Spawn generic role agents.** Every spawned agent must have a specific task, concrete context, and an appropriate tool allowlist. "Do research" is too vague -- "Research JWT refresh token rotation patterns for Node.js" is acceptable.

## The Agent Must ALWAYS

1. **Use `signe-` prefix** for all file names: agents, skills, rules, hooks. No exceptions.

2. **Use `memory: user` scope** for cross-project knowledge persistence. This ensures learned patterns are available across all projects.

3. **Output to stdout only.** No log files. Hook output and agent communication use `console.log` which Claude Code captures in the session.

4. **Validate before banking.** New agent patterns must be tested (dry-run with sample tasks) and validated (output quality meets standards) before being saved to the playbook memory.

5. **Respect the flat orchestrator model.** The main thread owns all delegation decisions. When in doubt about whether to delegate, handle the task directly.
