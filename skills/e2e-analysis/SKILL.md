---
name: e2e-analysis
description: Analyze a failing or missing Playwright journey to determine whether the defect belongs in UI, API, data, environment, or test setup.
---

# E2E analysis

Start from the failing user-visible step and preserve artifacts: trace,
screenshot, request/response evidence, console output, and test data. Decide
whether the failure is application behavior, test isolation, environment,
fixture state, or a flaky interaction. Reproduce with the narrowest affected
Playwright project.

Do not patch the test to hide an application failure or retry until green. Hand
off an application defect to `bug-triage`; change the E2E test only when its
assumption is disproven.
