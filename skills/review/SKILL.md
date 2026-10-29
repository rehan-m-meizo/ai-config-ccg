---
name: review
description: Review a requested change for correctness, scope, regressions, and missing proof without modifying code unless asked.
---

# Review

Read the request, diff, affected callers, and focused tests. Report findings
first, ordered by impact, with file references and evidence. Check that every
change maps to the requested scope and that tests prove behavior rather than
implementation detail. Do not fix findings, broaden the review, or claim a
test passed without running it.
