#!/usr/bin/env bash
set -euo pipefail

mode=${1:---sync}
if [[ "$mode" != --sync && "$mode" != --check && "$mode" != --dry-run && "$mode" != --uninstall ]]; then
  echo 'usage: scripts/sync-agents.sh [--sync|--check|--dry-run|--uninstall]' >&2
  exit 2
fi

source_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
required_root=$(realpath -m "${HOME:?}/ai-config-ccg")
if [[ "$source_root" != "$required_root" ]]; then
  echo "this repository must live at $required_root (hooks call scripts there); it is at $source_root" >&2
  exit 1
fi
agent_home=${AI_CONFIG_CCG_TEST_HOME:-$HOME}
agent_home=$(cd "$agent_home" && pwd -P)
skill_manifests=("$source_root"/skills/*/SKILL.md)
if [[ ! -f "${skill_manifests[0]}" ]]; then
  echo 'no central skills found' >&2
  exit 1
fi

agent_skill_dirs=(
  "$agent_home/.codex/skills"
  "$agent_home/.claude/skills"
  "$agent_home/.gemini/config/skills"
)
rule_targets=(
  "$agent_home/.codex/AGENTS.md"
  "$agent_home/.claude/CLAUDE.md"
  "$agent_home/.gemini/GEMINI.md"
)
extra_links=(
  "$source_root/claude/settings.json|$agent_home/.claude/settings.json"
  "$source_root/codex/guard.rules|$agent_home/.codex/rules/guard.rules"
  "$source_root/codex/hooks.json|$agent_home/.codex/hooks.json"
  "$source_root/gemini/hooks.json|$agent_home/.gemini/config/hooks.json"
)

if [[ "$mode" == --uninstall ]]; then
  removed=0
  for target in "${rule_targets[@]}"; do
    if [[ -L "$target" && "$(realpath -m "$target")" == "$source_root/AGENTS.md" ]]; then
      unlink "$target"
      ((removed += 1))
    fi
  done
  for pair in "${extra_links[@]}"; do
    target=${pair#*|}
    if [[ -L "$target" && "$(realpath -m "$target")" == "${pair%%|*}" ]]; then
      unlink "$target"
      ((removed += 1))
    fi
  done
  for target_dir in "${agent_skill_dirs[@]}"; do
    if [[ -L "$target_dir" ]]; then
      if [[ "$(realpath -m "$target_dir")" == "$source_root/skills" ]]; then
        unlink "$target_dir"
        ((removed += 1))
      fi
      continue
    fi
    [[ -d "$target_dir" ]] || continue
    for target in "$target_dir"/*; do
      [[ -L "$target" && "$(realpath -m "$target")" == "$source_root"/skills/* ]] || continue
      unlink "$target"
      ((removed += 1))
    done
  done
  echo "agent rules and skills: uninstalled ($removed link(s) removed)"
  exit 0
fi

errors=0
changes=0
planned=()

check_directory() {
  local target=$1
  if [[ -L "$target" ]]; then
    if [[ "$(realpath -m "$target")" == "$source_root/skills" ]]; then
      ((changes += 1))
      planned+=("replace $target symlink with a directory")
      return
    fi
    echo "conflict: $target is a different symlink" >&2
    ((errors += 1))
  elif [[ -e "$target" && ! -d "$target" ]]; then
    echo "conflict: $target is not a directory" >&2
    ((errors += 1))
  elif [[ ! -d "$target" ]]; then
    ((changes += 1))
    planned+=("mkdir $target")
  fi
}

check_link() {
  local source=$1 target=$2
  if [[ -L "$target" && "$(realpath -m "$target")" == "$source" ]]; then
    return
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    echo "conflict: $target is not linked to $source" >&2
    ((errors += 1))
  else
    ((changes += 1))
    planned+=("link $target -> $source")
  fi
}

for target in "${agent_skill_dirs[@]}"; do
  check_directory "$target"
done
for target in "${rule_targets[@]}"; do
  check_link "$source_root/AGENTS.md" "$target"
done
for pair in "${extra_links[@]}"; do
  check_link "${pair%%|*}" "${pair#*|}"
done
for target_dir in "${agent_skill_dirs[@]}"; do
  if [[ -L "$target_dir" && "$(realpath -m "$target_dir")" == "$source_root/skills" ]]; then
    continue
  fi
  for manifest in "${skill_manifests[@]}"; do
    name=${manifest%/SKILL.md}
    name=${name##*/}
    check_link "$source_root/skills/$name" "$target_dir/$name"
  done
  if [[ -d "$target_dir" ]]; then
    for target in "$target_dir"/*; do
      [[ -e "$target" || -L "$target" ]] || continue
      [[ "$target" == "$agent_home/.codex/skills/.system" ]] && continue
      [[ "$target" == "$agent_home/.claude/skills/synced" ]] && continue
      if [[ -L "$target" ]]; then
        resolved=$(realpath -m "$target")
        if [[ "$resolved" == "$source_root"/skills/* && ! -f "$resolved/SKILL.md" ]]; then
          ((changes += 1))
          planned+=("unlink stale $target")
          continue
        fi
      fi
      if [[ ! -f "$source_root/skills/${target##*/}/SKILL.md" ]]; then
        echo "conflict: unmanaged skill $target" >&2
        ((errors += 1))
      fi
    done
  fi
done

if ((errors > 0)); then
  echo "$errors conflict(s); no changes made" >&2
  exit 1
fi

if [[ "$mode" == --dry-run ]]; then
  ((changes > 0)) && printf '%s\n' "${planned[@]}"
  echo "$changes change(s) planned; nothing changed"
  exit 0
fi

if [[ "$mode" == --check ]]; then
  if ((changes > 0)); then
    echo "$changes missing or outdated link(s)" >&2
    exit 1
  fi
  echo 'agent rules and skills: synced'
  exit 0
fi

for target in "${agent_skill_dirs[@]}"; do
  if [[ -L "$target" ]]; then
    unlink "$target"
  fi
  mkdir -p "$target"
done
for target in "${rule_targets[@]}"; do
  mkdir -p "${target%/*}"
  if [[ ! -L "$target" ]]; then
    ln -s "$source_root/AGENTS.md" "$target"
  fi
done
for pair in "${extra_links[@]}"; do
  target=${pair#*|}
  mkdir -p "${target%/*}"
  [[ -L "$target" ]] || ln -s "${pair%%|*}" "$target"
done
for target_dir in "${agent_skill_dirs[@]}"; do
  for manifest in "${skill_manifests[@]}"; do
    name=${manifest%/SKILL.md}
    name=${name##*/}
    target="$target_dir/$name"
    if [[ ! -L "$target" ]]; then
      ln -s "$source_root/skills/$name" "$target"
    fi
  done
  for target in "$target_dir"/*; do
    [[ -L "$target" ]] || continue
    resolved=$(realpath -m "$target")
    [[ "$resolved" == "$source_root"/skills/* ]] || continue
    [[ -f "$resolved/SKILL.md" ]] || unlink "$target"
  done
done

echo "agent rules and skills: synced ($changes new link(s))"
