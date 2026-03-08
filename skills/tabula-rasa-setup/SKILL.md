---
name: tabula-rasa-setup
description: Conversational onboarding -- learn about the user and generate a personalized agent identity
context: fork
agent: tabula-rasa-setup-agent
disable-model-invocation: false
---

## Setup Onboarding

Run a conversational onboarding interview to learn about the user and generate a personalized agent persona.

The setup agent will:
1. Conduct a casual 5-8 question interview about work, communication style, and habits
2. Generate a persona (name, personality, style) based on the conversation
3. Persist the persona to MEMORY.md for use across all sessions

If called from within a project directory, the agent may create a project-scoped persona overlay (see Plan 02 for project-specific customization).

$ARGUMENTS
