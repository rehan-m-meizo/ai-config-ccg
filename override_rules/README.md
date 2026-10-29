# Override rules

Machine- or user-specific rules that override `AGENTS.md`. Every `*.md` file
here except this README is git-ignored, so overrides stay on the machine where
they are written and never reach the shared repository.

- One topic per file, e.g. `paths.md`, `tests.md`, `style.md`.
- State the rule plainly and, if it replaces a shared rule, name that rule.
- Keep them short: agents read every file here at the start of each session.

Precedence: the user's current instruction, then these overrides, then
`AGENTS.md`.
