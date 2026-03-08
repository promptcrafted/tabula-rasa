---
name: signe-reset-persona
description: Wipe agent persona and return to pre-setup state. Run /setup again to create a new identity.
context: none
disable-model-invocation: false
---

## Reset Persona

Wipe the agent persona from MEMORY.md, returning the agent to its pre-setup state (unnamed chief of staff, role-only identity).

### Execution (inline -- no agent spawn needed)

This skill runs inline because `context: none`. The main orchestrator executes these steps directly.

### Step 1: Determine Scope

Check `$ARGUMENTS` to determine what to reset:

- **No arguments (default):** Reset global persona only
- **`$ARGUMENTS` contains "project":** Reset project persona only (keep global)
- **`$ARGUMENTS` contains "all":** Reset both global AND all project-scoped personas

If no arguments provided AND the user is in a project directory (has `.git/`, `package.json`, etc.), ask: "Do you want to reset your global persona, just the project override for [project name], or both? (global / project / all)"

### Step 2: Reset Global Persona

If scope includes global:

1. Read `~/.claude/agent-memory/signe/MEMORY.md`
2. Find the `## Persona` section
3. Remove everything from `## Persona` up to (but not including) the next `##` heading
4. If no next heading exists, remove from `## Persona` to end of file
5. Write back the remaining content using the Write tool
6. Preserve ALL other content: `# Signe Memory` title, `## Topics` index, agent-recipes references, learned patterns, everything else

### Step 3: Reset Project Persona

If scope includes project:

1. Find the project-scoped MEMORY.md:
   - Check `~/.claude/projects/` for the directory matching the current project
   - Also check `.claude/MEMORY.md` in the project root
2. Read the project MEMORY.md
3. Find the `## Project Persona Override` section
4. Remove everything from `## Project Persona Override` up to the next `##` heading or end of section
5. Write back the remaining content

If `$ARGUMENTS` contains "all": scan all directories under `~/.claude/projects/` for MEMORY.md files containing `## Project Persona Override` sections and remove them all.

### Step 4: Confirm

After reset, confirm to the user with the appropriate message:

- **Global reset:** "Persona wiped. I'm back to being your unnamed chief of staff. Run /setup whenever you're ready to create a new identity."
- **Project reset:** "Project persona override removed for [project name]. I'll use my global personality here now."
- **All reset:** "All personas wiped -- global and all project overrides. I'm back to being your unnamed chief of staff. Run /setup to start fresh."

### Safety

- Do NOT wipe anything other than `## Persona` and `## Project Persona Override` sections
- Do NOT delete the MEMORY.md files themselves
- Do NOT modify Topics index, agent-recipes references, learned patterns, or any other memory content
- Always read before writing to avoid data loss

$ARGUMENTS
