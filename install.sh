#!/usr/bin/env bash
# Links this repo's rules and skills into Codex, Claude Code and Gemini.
# Usage: ./install.sh [--dry-run|--check|--uninstall]
set -euo pipefail
exec "$(dirname "${BASH_SOURCE[0]}")/scripts/sync-agents.sh" "${1:---sync}"
