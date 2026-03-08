# tabula-rasa (internal: Signe)

## What This Is

tabula-rasa is an open-source Claude Code agent package — a chief of staff AI that lives at `~/.claude/` and personalizes itself to each user. On first run, `/setup` guides a conversation where the agent learns about the user and then picks its own name, gender, and personality. From that point on, it's their personal chief of staff with 5 modes: research, plan, design, oversee, and full pipeline chaining. Built on Command → Agent → Skill architecture with flat orchestration.

## Current Milestone: v1.1 Public Release

**Goal:** Package Signe as `tabula-rasa` — a public GitHub repo with install script, setup workflow for agent self-personalization, scrubbed of all private references, with polished README.

**Target features:**
- Setup workflow (`/setup`) — conversational onboarding where agent learns user context and self-names
- Dynamic persona system replacing hardcoded "Signe" identity
- Git repo with install script (mirrors GSD pattern)
- All 5 modes + pipeline chaining shipped (scrubbed of private refs)
- Polished README with features, install instructions, and examples
- Per-project or global persona (user's choice)

## Core Value

Signe must be able to chain research → plan → design → oversee in a single coherent workflow, delegating to specialized subagents she designs, tests, and validates herself.

## Requirements

### Validated

- ✓ Global installation at `~/.claude/` — v1.0
- ✓ Chief of staff personality with proactive risk identification — v1.0
- ✓ Research mode with multi-source investigation and confidence scoring — v1.0
- ✓ Planning mode with goal decomposition and dependency mapping — v1.0
- ✓ Design mode (4 presets: architecture, UI/UX, agent, product) — v1.0
- ✓ Oversight mode with 5-lens code review and quality gates — v1.0
- ✓ Full workflow chaining (research → plan → design → oversee) — v1.0
- ✓ GSD orchestration with cwd-based cross-contamination prevention — v1.0
- ✓ Subagent methodology (research → design → test → validate → bank) — v1.0
- ✓ Agent playbook memory via user-scope MEMORY.md and topic files — v1.0
- ✓ Command → Agent → Skill architecture with YAML frontmatter — v1.0
- ✓ Flat orchestrator constraint enforced at 3 levels — v1.0
- ✓ Maker-checker loops with 2-iteration cap and user escalation — v1.0

### Active

- [ ] Setup workflow — conversational onboarding with agent self-naming
- [ ] Dynamic persona system — replace hardcoded Signe identity with user-specific persona
- [ ] Install script — clone-and-run installation mirroring GSD pattern
- [ ] Privacy scrub — remove all personal paths, MCP configs, private references
- [ ] Public README — features, install, usage examples
- [ ] Per-project persona override — folder-level identity customization

### Out of Scope

- Per-project installation — global by design, per-project copies create version drift
- Custom CLI tool — pure `.claude/` structure following reference repo patterns
- Mobile/web interface — CLI agent only
- Nested agent spawning — Claude Code does not support subagents spawning subagents
- Over-parallelization (>5 subagents) — diminishing returns from coordination overhead
- Cross-project pattern recognition (ADV-01) — deferred to v1.2+
- Model-aware prompt optimization (ADV-02) — deferred to v1.2+
- Agent teams integration (ADV-03) — pending Windows support
- Automatic memory curation (MEM-01) — deferred to v1.2+
- Progressive knowledge distillation (MEM-02) — deferred to v1.2+

## Context

Shipped v1.0 with 14,722 LOC across 83 files.
Tech stack: Claude Code agents (YAML frontmatter), Node.js hooks, Markdown skills.
Installation: `~/.claude/` with direct file copy deployment.

5 specialist agents: signe-researcher (50 turns), signe-planner (30 turns), signe-designer (40 turns), signe-overseer (40 turns), signe-test-agent (read-only health check).

6 skills: `/signe-health`, `/signe-research`, `/signe-plan`, `/signe-design`, `/signe-oversee`, `/signe` (full pipeline).

MCP tools: Brave, Tavily, Exa, Context7, arxiv for research; all tools inherited by subagents from environment.

## Constraints

- **Architecture**: Must follow Command → Agent → Skill pattern — no custom frameworks
- **Location**: Must live at `~/.claude/` (global scope) — not per-project
- **Memory**: Must use native Claude Code agent memory (`memory: user`) — no external databases
- **CLAUDE.md size**: Each instruction file must stay under 200 lines — split into rules/ files as needed
- **Subagent design**: Must follow research → plan → dry-run → validate methodology
- **GSD integration**: GSD runs in project subfolders to avoid cross-contamination
- **Platform**: Windows 11 — hooks/scripts must be cross-platform compatible

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Global install at ~/.claude/ | Available everywhere without per-project setup | ✓ Good — zero friction across projects |
| Command → Agent → Skill architecture | Proven pattern from reference repo | ✓ Good — clean separation of concerns |
| User-scope MEMORY.md for agent knowledge | Native Claude Code feature; 200-line discipline | ✓ Good — persists across sessions |
| Dry-run testing for new subagents | Validates prompts work with specific models | ✓ Good — methodology section in signe.md |
| GSD in subfolders | Prevents cross-contamination between projects | ✓ Good — cwd-based path scoping works |
| Chief of staff personality | Manages complexity rather than just executing | ✓ Good — proactive behaviors shipped |
| Direct cp deployment (no installer) | Simple, no PATH issues, single-user package | ✓ Good — consistent across all 6 phases |
| Flat orchestrator (no nested spawning) | Eliminates coordination complexity | ✓ Good — architecturally enforced at 3 levels |
| Self-contained agent prompts | Subagents only receive their own system prompt | ✓ Good — 245-line researcher works reliably |
| maxTurns calibrated per role | Researcher 50, designer/overseer 40, planner 30 | ✓ Good — no turn limit issues observed |

---
*Last updated: 2026-03-08 after v1.1 milestone start*
