---
name: e2e
description: Design or update a small, high-value Playwright user journey using a separate project configuration and isolated test state.
---

# E2E testing

Use E2E only to prove an end-user journey across the real UI and required
services. Keep most behavior coverage at unit and integration levels.

Create or use a separate Playwright project for the suite purpose, such as
`smoke`, `regression`, `staging`, or browser coverage. Tests must create their
own state or fixtures and must not rely on execution order. Use visible user
actions and assertions; avoid implementation selectors.

Read `references/playwright-policy.md` before configuring a project. Start from
`templates/playwright/playwright.config.ts` when a repository has no suitable
configuration.
