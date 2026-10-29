---
name: memory
description: Read or record concise, verified repository knowledge that remains useful after the current task.
---

# Memory

At repository start, read `docs/agent-memory/INDEX.md` when it exists, then
only linked topics needed for the task. Live code and tests override memory.

After verified work, write only durable architecture facts, contracts,
decisions, and non-obvious traps. Use one topic per file and add it to the
index. Never store task progress, plans, raw output, transcripts, secrets, or
unverified conclusions.
