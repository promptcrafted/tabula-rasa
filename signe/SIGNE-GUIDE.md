# Signe User Guide

Signe is your chief of staff agent for structured thinking. She handles research, planning, and design through specialized subagents, each with their own methodology.

## Quick Reference

| Command | What it does | When to use |
|---------|-------------|-------------|
| `/signe-research <topic>` | Multi-source investigation | Before building anything — understand the landscape |
| `/signe-plan <goal>` | Goal decomposition with dependencies | After research — break work into phases |
| `/signe-design <topic>` | Structured design deliverables | After planning — produce specifications |
| `/signe-oversee [scope:lens] <target>` | Code review with quality gates | After building — verify quality and completeness |
| `/signe-health` | Installation check | If something seems broken |

## The Workflow Chain

The modes are designed to feed into each other:

```
/signe-research → writes signe-research-*.md
         ↓
/signe-plan    → reads research files, writes signe-plan-*.md
         ↓
/signe-design  → reads research files, writes signe-design-*.md
         ↓
/signe-oversee → reads plan files, writes signe-review-*.md
```

Each mode automatically looks for output from previous modes in your current directory. You don't need to pass files between them — just run them from the same folder.

## Research (`/signe-research`)

Investigates a topic using web search, library docs, papers, and code analysis. Returns structured findings with confidence levels.

**Basic usage:**
```
/signe-research JWT refresh token rotation patterns for Node.js
```

**With preset:**
```
/signe-research preset:comparison React vs Vue vs Svelte for a dashboard app
```

**Presets:**
- `ecosystem` — Map the landscape: libraries, tools, community health
- `feasibility` — Can this be built? Technical constraints, effort, risks
- `comparison` — Side-by-side analysis of alternatives
- `sota` — State-of-the-art: latest papers, cutting-edge approaches
- `general` — Auto-detect (default)

**Output:** `signe-research-[topic].md` with citations, confidence scores, and source URLs.

## Planning (`/signe-plan`)

Decomposes a goal into phases with dependencies, acceptance criteria, and scope boundaries.

**Basic usage:**
```
/signe-plan Build a real-time collaborative whiteboard app
```

**Tips:**
- Run research first — the planner automatically reads `signe-research-*.md` files in your directory
- Be specific about constraints: "Build X using Y with Z budget/timeline"
- The planner produces testable acceptance criteria, not vague milestones

**Output:** `signe-plan-[goal].md` with phases, dependencies, acceptance criteria, and explicit scope boundaries (what's in vs. out).

## Design (`/signe-design`)

Produces structured specifications — not code. Four presets for different design needs.

**Basic usage (auto-detects preset):**
```
/signe-design Design the authentication system for our API
```

**With explicit preset:**
```
/signe-design preset:architecture Design a REST API gateway for microservices
/signe-design preset:uiux Design the onboarding flow for a project management app
/signe-design preset:agent Design a code review agent for Claude Code
/signe-design preset:product Design the MVP for a habit tracking app
```

### Preset Details

**Architecture** — System structure and technical decisions
- Component Boundary Tables
- Mermaid data flow diagrams
- API contracts (input/output types, error cases)
- Architecture Decision Records (ADRs)
- Annotated file/folder structure

**UI/UX** — User experience and interface design
- User flow maps (entry → decisions → outcomes)
- Component hierarchy (atomic → composite → page)
- Wireframe text specifications (layout, content, interactions)
- WCAG 2.1 AA accessibility requirements

**Agent** — Claude Code agent/skill design
- Complete YAML frontmatter definitions
- System prompt structure (role, context, methodology, guardrails)
- Tool selection rationale table
- Skill entry point definitions

**Product** — Feature scoping and user experience
- User stories with acceptance criteria
- MoSCoW prioritization tables
- Experience maps (end-to-end user journeys)

**Output:** `signe-design-[preset]-[topic].md`

## Oversight (`/signe-oversee`)

Multi-lens code review that compares implementation against plans. Produces a structured review with findings, gap analysis, and a quality gate verdict.

**Basic usage:**
```
/signe-oversee review the auth module
```

**Scoped usage (focus on a specific lens):**
```
/signe-oversee scope:security review the API handlers
```

**Available lenses:**
- `security` — Authentication, authorization, input validation, secrets handling
- `correctness` — Logic errors, edge cases, plan gap analysis
- `performance` — Resource usage, complexity, caching opportunities
- `test-coverage` — Test existence, coverage gaps, missing edge case tests
- `style` — Naming conventions, file organization, documentation completeness

**Scope options:**
- `full` (default) — Runs all lenses sequentially
- `scope:security` — Security lens only
- `scope:correctness` — Correctness lens only
- `scope:performance` — Performance lens only
- `scope:test-coverage` — Test coverage lens only
- `scope:style` — Style lens only

**Quality gate verdicts:**
- **PASS** — No critical or high findings, >80% criteria met
- **WARN** — No critical findings but has high findings, or 50-80% criteria met
- **FAIL** — Any critical finding, or <50% criteria met

**Output:** `signe-review-[date]-[target].md` with per-lens findings, gap report, and overall quality gate verdict.

## Best Practices

**Chain modes for complex work.** Research first, then plan, then design. Each builds on the last.

**Be specific.** "Design an auth system" produces generic output. "Design OAuth2 + JWT auth for a multi-tenant SaaS API with role-based access" produces targeted specs.

**Use presets when you know what you want.** Auto-detection works, but explicit presets skip the guessing.

**Run from the right directory.** Signe writes output files to your current working directory and reads prior research from there too.

**Review after building.** Run `/signe-oversee` after implementing a plan to verify quality and catch gaps before moving on.

**Each invocation is independent.** Signe forks a fresh agent per call. Previous conversation context doesn't carry over — the research files on disk are the handoff mechanism.

## Troubleshooting

**Agent doesn't spawn:** Run `/signe-health` to validate installation.

**Wrong preset selected:** Use `preset:name` as the first token to force it.

**Missing research context:** Make sure you ran `/signe-research` from the same directory before `/signe-plan` or `/signe-design`.

**Output file not found:** Check your current working directory. Files are written relative to where you invoked the command.

**Review seems incomplete:** Use `scope:lens` to focus on a specific area, or ensure `.planning/` exists for plan gap analysis.
