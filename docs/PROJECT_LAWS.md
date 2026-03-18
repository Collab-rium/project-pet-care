# Project Laws — Contract and LLM Guidance

This document records the project's core rules, contributor expectations, and guidance for automated agents (including LLMs) operating on this repository.

1. Purpose
- The repository implements the "Project - Puppy" mobile app (pet profiles, reminders, dashboard, dynamic themes). This file expresses rules that protect project continuity, data safety, and contributor intent.

2. Scope
- Applies to all contributors, CI systems, and automated agents (scripts, bots, LLMs) that read or modify files in this repository.

3. Ownership & Contributors
- Code and content are under the project's chosen license (see repository root for LICENSE if present). Contributors grant the project maintainers permission to merge their contributions under that license.

4. Protected Files
- The following files are protected and MUST NOT be deleted or removed without explicit approval from project maintainers: `PROJECT_CONTEXT.md`, `docs/PROJECT_CONTEXT.md`, `docs/PROJECT_LOG.md`, `docs/PROJECT_LAWS.md`.
- Deletions of protected files will be blocked by the local pre-commit hook. To remove a protected file you must open an issue, get approval, and update or remove the hook after approval.

5. LLM & Automation Rules
- Read-only: LLMs operating on behalf of contributors must treat repository documentation (README, PROJECT_CONTEXT, PROJECT_LAWS, PROJECT_LOG) as authoritative context that informs behavior.
- No secrets: LLMs must not produce, store, or commit secrets (API keys, credentials) into the repo. Any secret material discovered should be recorded in an out-of-band secure store and reported to maintainers.
- No destructive changes: LLMs must not delete protected files or push breaking mass-deletions. Any large refactor or deletion requires human review and an explicit approval step.
- Explain changes: Automated edits must include a short rationale linked to an issue or PR; commit messages should be clear and reference the issue/PR number.

6. Commit & Branching Policy
- Work on feature branches; open PRs against `main` for review. Include tests for new functionality. Small, incremental commits with descriptive messages are preferred.

7. Testing & CI
- New features must include unit tests where applicable. CI should run tests before merging PRs. Failure to include tests for core functionality may delay merging.

8. Data & Privacy
- Avoid committing personal data. If sample data is required for tests, use anonymized or synthetic data and document its source in `docs/`.

9. Security & Vulnerabilities
- Report security issues privately to maintainers. Do not open public issues that expose secrets or vulnerabilities.

10. Amendments
- This file can be amended only via an approved PR and must be referenced in the project's `PROJECT_LOG.md` entry. Maintain a concise change summary when updating.

11. Enforcement
- Hooks and CI checks (where configured) will enforce parts of these laws. Human maintainers reserve the final decision on policy exceptions.

If anything in this file is unclear or you need special permission, open an issue and tag the repository maintainers.
