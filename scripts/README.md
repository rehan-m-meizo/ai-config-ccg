# Scripts

`sync-agents.sh --sync` links this repository's global rules and every
`skills/*/SKILL.md` directory into Codex, Claude Code, and Gemini. It removes
stale links into this repository. `--check` reports drift without changing it.
Conflicting files are left untouched and cause a nonzero exit. Set
`AI_CONFIG_CCG_TEST_HOME` only when testing against an isolated home directory.

`test-sync-agents.sh` verifies first sync, repeat sync, stale-link cleanup,
and conflict protection. `validate-skills.sh` checks skill structure.
