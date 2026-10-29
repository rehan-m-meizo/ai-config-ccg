#!/usr/bin/env bash
set -euo pipefail

source_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
test_home=$(mktemp -d /tmp/ai-config-ccg-sync.XXXXXX)
trap 'gio trash -f "$test_home"' EXIT
export AI_CONFIG_CCG_TEST_HOME="$test_home"

if "$source_root/scripts/sync-agents.sh" --check >/dev/null 2>&1; then
  echo 'expected missing links to fail check' >&2
  exit 1
fi
plan=$("$source_root/scripts/sync-agents.sh" --dry-run)
grep -q "^link $test_home/.claude/CLAUDE.md -> $source_root/AGENTS.md$" <<<"$plan"
grep -q "^link $test_home/.gemini/config/skills/tdd -> $source_root/skills/tdd$" <<<"$plan"
grep -q "^link $test_home/.claude/settings.json -> $source_root/claude/settings.json$" <<<"$plan"
grep -q "^link $test_home/.codex/rules/guard.rules -> $source_root/codex/guard.rules$" <<<"$plan"
grep -q "^link $test_home/.codex/hooks.json -> $source_root/codex/hooks.json$" <<<"$plan"
grep -q "^link $test_home/.gemini/config/hooks.json -> $source_root/gemini/hooks.json$" <<<"$plan"
[[ -z "$(ls -A "$test_home")" ]]

mkdir -p "$test_home/.codex"
ln -s "$source_root/skills" "$test_home/.codex/skills"
"$source_root/scripts/sync-agents.sh" --sync >/dev/null
"$source_root/scripts/sync-agents.sh" --check >/dev/null
"$source_root/scripts/sync-agents.sh" --sync >/dev/null

mkdir "$test_home/.claude/skills/synced"
"$source_root/scripts/sync-agents.sh" --check >/dev/null

stale="$test_home/.claude/skills/retired-skill"
ln -s "$source_root/skills/retired-skill" "$stale"
if "$source_root/scripts/sync-agents.sh" --check >/dev/null 2>&1; then
  echo 'expected stale central skill link to fail check' >&2
  exit 1
fi
"$source_root/scripts/sync-agents.sh" --sync >/dev/null
[[ ! -L "$stale" ]]

conflict="$test_home/.gemini/GEMINI.md"
unlink "$conflict"
ln -s /etc/hosts "$conflict"
if "$source_root/scripts/sync-agents.sh" --sync >/dev/null 2>&1; then
  echo 'expected conflicting rule link to fail safely' >&2
  exit 1
fi
[[ "$(realpath "$conflict")" == /etc/hosts ]]
unlink "$conflict"
ln -s "$source_root/AGENTS.md" "$conflict"

unmanaged="$test_home/.gemini/config/skills/unmanaged"
mkdir "$unmanaged"
if "$source_root/scripts/sync-agents.sh" --check >/dev/null 2>&1; then
  echo 'expected unmanaged skill to fail check' >&2
  exit 1
fi
if "$source_root/scripts/sync-agents.sh" --sync >/dev/null 2>&1; then
  echo 'expected unmanaged skill to block sync safely' >&2
  exit 1
fi
[[ -d "$unmanaged" ]]

"$source_root/scripts/sync-agents.sh" --uninstall >/dev/null
[[ ! -e "$test_home/.claude/CLAUDE.md" && ! -L "$test_home/.claude/CLAUDE.md" ]]
[[ ! -L "$test_home/.claude/skills/tdd" ]]
[[ ! -e "$test_home/.claude/settings.json" && ! -L "$test_home/.claude/settings.json" ]]
[[ ! -L "$test_home/.codex/rules/guard.rules" ]]
[[ -d "$unmanaged" && -d "$test_home/.claude/skills/synced" ]]

rmdir "$unmanaged"
"$source_root/install.sh" >/dev/null
"$source_root/scripts/sync-agents.sh" --check >/dev/null
echo 'sync behavior: PASS'
