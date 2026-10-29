# ai-config-ccg

A starter configuration for using Codex, Claude Code, and Gemini/Antigravity
with one set of rules, skills, and project-owned task state. In this checkout,
this directory is authoritative for those three agents.

This is intended as a **starting setup for a fresh agent configuration**, not
an add-on to an existing setup. Review and adapt the rules before using it;
do not layer it over existing global instructions or skill collections. The
sync script refuses conflicting files and unmanaged skills rather than
silently replacing them.

## Relationship to ATMAR

[ATMAR](https://github.com/revdfdev/ATMAR) (Agentic Tracker Memory And
Retrieval) documents the project-owned continuity pattern behind this setup:
trackers hold feature state, rules hold working behavior, relevant memory can
be retrieved when needed, and live repository code and tests remain ground
truth. ATMAR is the separate case-study and method reference; this repository
is an operational configuration inspired by it, not the ATMAR repository, a
dependency on it, or a claim that the method has been universally validated.

Here, shared rules and skill procedures live in `ai-config-ccg`. Each project
owns its own facts in `AGENTS.md` and `docs/agent-memory/`, and its own active
work state in `.atmar/trackers/<slug>/`. A new agent or thread reads those
artifacts, checks them against live code, and continues within the tracker
boundary. Research findings are recorded before a tracked proposal; chat
history is not the source of truth.

ATMAR's quickstart evaluates continuity: whether a fresh agent can recover
and continue a feature. This setup additionally governs delivery. A tidy
tracker or successful handoff is not a completed feature; the requested
behavior must work and pass its acceptance checks.

## Start from a clean setup

1. Put this repository at `~/ai-config-ccg`. If you use another location,
   update the paths in `AGENTS.md` before syncing.
2. Read `AGENTS.md`; adjust project-specific assumptions for your
   work. Keep each project's durable facts in that project's own `AGENTS.md`.
3. Inspect the existing rule and skill paths shown below. Use a fresh agent
   profile or manually resolve conflicts first; the script will not merge
   existing configurations or delete unmanaged skills.
4. Run `./install.sh --dry-run` to see every link it would create, then
   `./install.sh`, then `./install.sh --check`. Use
   `./scripts/validate-skills.sh` to check the skill structure.
5. In a project, ask an agent to follow its repository `AGENTS.md`. Start a new thread for a new task; for tracked work, carry
   the tracker path and current state into the new thread.

`AGENTS.md` is the single global rule set and `skills/` is the single source
of reusable skills. It is the only rule file loaded every session and is kept
under 1k tokens; `WORKFLOW/` and `GUARDRAILS/` hold the same rules in long form
and are read only when needed. Tracker-controlled work uses repository-local
`.atmar/trackers/<slug>/` state, while the tracker process and templates live
here. Agent-specific paths expose symlinks to these files:

| Agent | Rules | Skills |
| --- | --- | --- |
| Codex | `~/.codex/AGENTS.md` | `~/.codex/skills` |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/skills` |
| Gemini/Antigravity | `~/.gemini/GEMINI.md` | `~/.gemini/config/skills` |

`./install.sh` (a wrapper for `scripts/sync-agents.sh`) creates or refreshes
the three agents' rule and skill links. `--dry-run` lists planned changes
without making them, `--check` verifies the links, and `--uninstall` removes
only links that point into this repository; your own files and skills stay.
The script preserves conflicting user files, removes stale links into this
repository, flags unmanaged skills without deleting them, and leaves Codex's
runtime-managed `.system` and Claude's `synced` skills alone. It does not
copy rules into projects or create trackers automatically.

## Choose the workflow for the task

All tasks follow **analyse → plan → implement → prove**, scaled to the task.
The feature or fix is the outcome; tracker documents only preserve its scope
and evidence. Do not count tracker creation, state transitions, or test-writing
as completion by themselves.
The agent is a collaborator: you choose the objective and material tradeoffs.
Before editing, it must inspect the relevant live code or configuration,
callers, and tests, then connect each change to that evidence. If it cannot
inspect what the change depends on, it must say so rather than guess.
Check for an active tracker first. If one exists, `tracker-control` owns the
boundary until its acceptance criteria are proven or the user changes or
drops it. Load only the relevant skills, not every skill for every task.

| Task | Skill path | What to do |
| --- | --- | --- |
| Small feature or contained change | `pattern` when an analogous implementation exists; `tdd` for backend behavior | Inspect the nearest relevant pattern and callers, define success and failure cases, make the requested change, run focused proof. No tracker by default. |
| Large, research-first, or cross-session feature | `tracker-control`, then relevant `pattern`, `tdd`, or `e2e` | Create `.atmar/trackers/<slug>/` from `templates/tracker/`. Record findings and sources in `research.md`; put scope, acceptance criteria, and checks in `proposal.md`. Get the proposal approved, move `STATE.md` through `research` → `proposed` → `finalized` → `active`, implement only that boundary, then mark `completed` when proof passes. Use `dropped` only when the user abandons or changes it. |
| Bug or regression | `bug-triage`; then `tdd` for a backend fix; `e2e-analysis` for a cross-layer UI failure | Capture observed versus expected behavior and environment, reproduce, trace the first divergence, write a regression test at the lowest useful layer, fix it, and rerun relevant checks. Use a tracker only if the investigation is substantial or must survive sessions. |
| End-user journey | `e2e` | Use a separate Playwright project and isolated test state when a real UI flow is necessary to prove the requested behavior. Do not require E2E for docs or config edits. |
| Before a commit or handoff | `simplify`, `review`, and `memory` only when applicable | Keep the diff scoped, name exact checks and results, and save only confirmed durable facts. If context becomes unreliable, ask for a new thread and give a short tracker/file handoff. |

A direct request to implement authorizes work within its stated scope. A
research or planning request does not. For tracked work, proposal approval
sets the boundary; implementation begins when the user requests it. Do not
expand scope to fix adjacent problems. The skill files under `skills/` contain
the detailed procedures; this table is a route map, not a replacement for
them.

The skills are currently plain, portable `SKILL.md` directories linked into
the three agents. They may later be converted into distributable skill
packages, but this setup does not build, publish, or install a package.

## Enforcement (Claude Code)

`install.sh` also links `~/.claude/settings.json` to `claude/settings.json`,
which adds three hooks from `hooks/`:

- `guard-bash.py` denies `--no-verify` and `Co-Authored-By`, and forces an
  approval prompt for push, tag, destructive git, `rm -rf`, cluster changes,
  image pushes, and PR/release creation.
- `prompt-reminder.sh` adds a one-line scope/proof reminder to each prompt.
- `proof-gate.py` stops Claude from ending a turn that edited files without a
  check run after the last edit and a reported result, or "not verified".

Run `scripts/test-hooks.sh` after changing them.

For Codex, `install.sh` links `~/.codex/rules/guard.rules` to
`codex/guard.rules`: the same commands are forbidden or need approval
(`scripts/test-codex-rules.sh` checks them with `codex execpolicy check`).
Prefix rules cannot make exceptions, so `git stash list` and `git tag -l` also
prompt. `~/.codex/hooks.json` links to `codex/hooks.json` (reminder and proof
gate).

For Antigravity, `~/.gemini/config/hooks.json` links to `gemini/hooks.json`:
the same guard on `run_command` (risky commands use `force_ask`), the reminder
as a `PreInvocation` ephemeral message, and the proof gate on `Stop`.
`proof-gate.py` reads Claude, Codex, and Antigravity transcripts.

## Layout

- `MEMORIES/` — durable facts shared by agents; each project keeps its own
  memory in `docs/agent-memory/`.
- `WORKFLOW/` — long-form workflow and thread handoff; optional reading.
- `GUARDRAILS/` — long-form scope and safety rules; optional reading.
- `templates/` — starter files for tracker research, memory, skills, and E2E.
- `skills/` — canonical, portable agent skills; each owns a `SKILL.md`.
- `templates/tracker/` — research-first tracker state, research, and proposal
  templates.
- `templates/playwright/` — separate-project Playwright configuration starter.
- `docs/` — reference material and decisions.
- `scripts/` — safe maintenance utilities.

Never put credentials, tokens, machine-specific caches, transcripts, or
generated runtime state in this repository.
