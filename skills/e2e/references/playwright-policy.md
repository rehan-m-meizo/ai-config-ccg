# Playwright policy

- Projects group tests by configuration, not as a substitute for test folders.
- Keep smoke journeys small and retry-free; use bounded retries for broader CI
  suites only to identify flaky tests.
- Keep tests isolated. A failure must not leak state into another test.
- Capture traces on first retry or retain them on failure; do not record every
  test by default.
- Use CI workers and sharding according to repository capacity; prefer stable,
  reproducible runs over maximum parallelism.

Sources: Playwright projects, isolation, retries, configuration, and CI docs.
