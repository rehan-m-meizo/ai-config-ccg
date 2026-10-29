# Tracker schema

```text
.atmar/trackers/<slug>/
├── STATE.md
├── research.md
└── proposal.md
```

`STATE.md` is the authority for lifecycle state. Exactly one tracker may be
`active` in a repository. `research.md` stores evidence, not a chat transcript.
`proposal.md` defines the approved boundary and must be finalized before work
becomes active.

State values are exactly: `research`, `proposed`, `finalized`, `active`,
`dropped`, and `completed`.
