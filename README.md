# tabula-rasa

Your AI chief of staff for Claude Code.

## What is this

tabula-rasa is a chief of staff agent system for Claude Code that personalizes itself to you. It chains research, planning, design, and oversight into coherent workflows -- delegating to specialist subagents that each follow their own methodology. It ships as a set of agent files that install into your `~/.claude/` directory. On first run, it interviews you about your work and communication style, then generates its own name and personality. From that point on, it remembers you across sessions.

## Quick install

```bash
git clone https://github.com/your-username/tabula-rasa.git
cd tabula-rasa
bash install.sh
```

Then start Claude Code and run `/setup` for first-time personalization.

Windows users: run install.sh in Git Bash (included with Git for Windows).

## What you get

Five modes, each backed by a specialist subagent:

| Mode | Command | What it does |
|------|---------|--------------|
| Research | `/signe-research` | Multi-source investigation with confidence scoring |
| Planning | `/signe-plan` | Goal decomposition with dependency mapping |
| Design | `/signe-design` | Architecture, UI/UX, agent, or product design |
| Oversight | `/signe-oversee` | Code review, quality gates, progress tracking |
| Pipeline | `/signe` | Chain all modes into a single workflow |

## How it works

tabula-rasa uses a flat orchestrator model. The main agent delegates to specialist subagents -- it never nests (subagents cannot spawn other subagents). Each mode has its own methodology and turn budget. Memory persists across sessions via `MEMORY.md` in user scope, so the agent accumulates knowledge about your projects and preferences over time.

## Example interaction

```
You: /signe-research JWT refresh token rotation patterns for Node.js

Agent: Starting multi-source investigation...

## Research: JWT Refresh Token Rotation

### Sources Consulted
- RFC 6749 (OAuth 2.0 framework)
- OWASP Token Security guidelines
- 3 production implementations (auth0, okta, custom)

### Key Findings

| Pattern | Security | Complexity | Recommendation |
|---------|----------|------------|----------------|
| Sliding window | Medium | Low | Good for SPAs |
| Rotation on use | High | Medium | Recommended for APIs |
| Token families | High | High | Best for multi-device |

### Recommendation (HIGH confidence)
Use rotation-on-use with token families. Each refresh token is
single-use; reuse of an old token invalidates the entire family
(detects token theft). jose library handles JWT operations cleanly.

### Risks
- Token family table grows unbounded without cleanup job
- Clock skew between services can cause false invalidation
```

## Setup walkthrough

When you run `/setup` for the first time, the agent starts a conversation to learn about you:

- What kind of work you do (domain, languages, team size)
- How you prefer to communicate (concise vs. detailed, proactive vs. reactive)
- Your habits and workflow preferences

Based on your answers, it generates its own name and personality -- picking traits that complement your working style. This persona is stored in `~/.claude/agent-memory/signe/MEMORY.md` and loads automatically every session.

You can also run `/setup` inside a project directory to create a project-specific persona that overrides the global one for that project. Use `/reset-persona` to start over.

## Documentation

Full mode documentation, persona customization, and troubleshooting: [docs/guide.md](docs/guide.md)

## License

MIT
