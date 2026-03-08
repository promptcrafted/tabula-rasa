#!/usr/bin/env bash
# tabula-rasa installer
# Copies agent files to ~/.claude/ with conflict detection and backup.
#
# Windows users: Run this script in Git Bash (included with Git for Windows).
# Do NOT use cmd.exe or PowerShell directly.
#
# Usage:
#   git clone <repo-url> && cd tabula-rasa && bash install.sh

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${CYAN}[info]${NC}  $1"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
err()   { echo -e "${RED}[error]${NC} $1"; }

# ── Locate script directory ──────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Pre-flight checks ───────────────────────────────────────────────────────
info "Running pre-flight checks..."

if ! command -v claude &>/dev/null; then
    err "Claude Code CLI not found."
    echo "    Install it first: https://docs.anthropic.com/en/docs/claude-code"
    echo "    Then run 'claude' once to initialize ~/.claude/"
    exit 1
fi
ok "Claude Code CLI found"

CLAUDE_HOME="$HOME/.claude"
if [ ! -d "$CLAUDE_HOME" ]; then
    err "~/.claude/ directory not found."
    echo "    Run 'claude' once to create it, then re-run this script."
    exit 1
fi
ok "~/.claude/ directory exists"

# ── Conflict detection and backup ────────────────────────────────────────────
CONFLICTS=()

check_conflict() {
    local target="$1"
    if [ -e "$CLAUDE_HOME/$target" ]; then
        CONFLICTS+=("$target")
    fi
}

# Check agents
for f in "$SCRIPT_DIR"/agents/signe*.md; do
    check_conflict "agents/$(basename "$f")"
done

# Check skills
for d in "$SCRIPT_DIR"/skills/signe*/; do
    dirname="$(basename "$d")"
    check_conflict "skills/$dirname/SKILL.md"
done

# Check rules
for f in "$SCRIPT_DIR"/rules/signe-*.md; do
    check_conflict "rules/$(basename "$f")"
done

# Check hooks
check_conflict "hooks/signe-lifecycle.js"

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    BACKUP_DIR="$CLAUDE_HOME/backups/tabula-rasa-$(date +%Y%m%d-%H%M%S)"
    warn "Found ${#CONFLICTS[@]} existing file(s) that will be overwritten."
    info "Backing up to $BACKUP_DIR"

    for conflict in "${CONFLICTS[@]}"; do
        backup_path="$BACKUP_DIR/$conflict"
        mkdir -p "$(dirname "$backup_path")"
        cp "$CLAUDE_HOME/$conflict" "$backup_path"
    done

    ok "Backed up ${#CONFLICTS[@]} file(s)"
    echo ""
fi

# ── Copy operations ──────────────────────────────────────────────────────────
info "Installing agent files..."

COPIED=0

# Agents
mkdir -p "$CLAUDE_HOME/agents"
for f in "$SCRIPT_DIR"/agents/signe*.md; do
    cp "$f" "$CLAUDE_HOME/agents/"
    COPIED=$((COPIED + 1))
done
ok "Agents: $(ls "$SCRIPT_DIR"/agents/signe*.md | wc -l) files"

# Skills (preserve directory structure)
mkdir -p "$CLAUDE_HOME/skills"
for d in "$SCRIPT_DIR"/skills/signe*/; do
    dirname="$(basename "$d")"
    mkdir -p "$CLAUDE_HOME/skills/$dirname"
    cp "$d"SKILL.md "$CLAUDE_HOME/skills/$dirname/SKILL.md"
    COPIED=$((COPIED + 1))
done
ok "Skills: $(ls -d "$SCRIPT_DIR"/skills/signe*/ | wc -l) directories"

# Rules
mkdir -p "$CLAUDE_HOME/rules"
for f in "$SCRIPT_DIR"/rules/signe-*.md; do
    cp "$f" "$CLAUDE_HOME/rules/"
    COPIED=$((COPIED + 1))
done
ok "Rules: $(ls "$SCRIPT_DIR"/rules/signe-*.md | wc -l) files"

# Hooks
mkdir -p "$CLAUDE_HOME/hooks"
cp "$SCRIPT_DIR/hooks/signe-lifecycle.js" "$CLAUDE_HOME/hooks/"
COPIED=$((COPIED + 1))
ok "Hooks: signe-lifecycle.js"

# ── CLAUDE.md special handling ───────────────────────────────────────────────
if [ ! -f "$CLAUDE_HOME/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/templates/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
    ok "CLAUDE.md: installed from template"
    COPIED=$((COPIED + 1))
else
    warn "CLAUDE.md: already exists (not overwritten)"
    echo "    Template available at: $SCRIPT_DIR/templates/CLAUDE.md"
    echo "    You can manually merge the agent section if needed."
fi

# ── agent-memory directory ───────────────────────────────────────────────────
if [ ! -d "$CLAUDE_HOME/agent-memory/signe" ]; then
    mkdir -p "$CLAUDE_HOME/agent-memory/signe"
    ok "Created agent-memory/signe/ directory"
else
    ok "agent-memory/signe/ already exists (preserved)"
fi

# ── settings-merge.json note ─────────────────────────────────────────────────
echo ""
warn "settings-merge.json was NOT auto-merged into ~/.claude/settings.json"
echo "    Review $SCRIPT_DIR/settings-merge.json and manually merge"
echo "    any needed settings into ~/.claude/settings.json"

# ── Post-install summary ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}Installation complete!${NC} ($COPIED files copied)"
echo ""
echo "Next steps:"
echo "  1. Run 'claude' to start Claude Code"
echo "  2. Type /signe-health to verify the installation"
echo "  3. Type /setup for first-time personalization"
echo ""
echo "The agent will introduce itself and learn about you during /setup."
echo "After that, use /signe-research, /signe-plan, /signe-design,"
echo "/signe-oversee, or /signe for the full pipeline."
