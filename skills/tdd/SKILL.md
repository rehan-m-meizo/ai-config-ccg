---
name: tdd
description: Change backend behavior through an observed failing test followed by the smallest passing implementation.
---

# TDD

List behavioral scenarios first: success, boundaries, missing input, invalid
state, and observable persistence or contract effects. Write one focused test,
run it, and confirm it fails for the expected behavioral reason. Make the
smallest implementation change that passes, then run related tests.

Do not change an assertion merely to match broken behavior. Check real
consumers before changing a shared contract. Report pre-existing failures as
unverified unless they are proven unrelated.
