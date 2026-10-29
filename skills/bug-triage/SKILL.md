---
name: bug-triage
description: Diagnose a bug or regression by reproducing it, locating the first divergence, and choosing the correct unit, integration, or E2E proof.
---

# Bug triage

Record the exact observed and expected behavior, input, state, and environment.
Reproduce it before editing. Trace from the symptom toward the earliest point
where correct data or behavior becomes wrong, and label the cause confirmed,
supported, or speculative.

Choose proof at the lowest layer that reproduces the defect: unit for local
logic, integration for contract or persistence behavior, and E2E only for a
real user journey. Use `tdd` for the fix. If a UI failure may be cross-layer,
use `e2e-analysis` before changing code.
