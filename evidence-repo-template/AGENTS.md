# Agent Instructions

These instructions are a repository adapter built on top of externally defined controls. They are **not themselves an OpenSSF, NIST or DORA requirement**.

Before changing code or documentation:

1. Read `policy/project-state.json`, `docs/MATURITY.md`, `docs/ARCHITECTURE.md`, and `docs/TESTING.md`.
2. Run `python scripts/harness.py` before claiming repository readiness.
3. Never convert missing, stale, inaccessible, or unexecuted evidence into `PASS`.
4. Use these result meanings exactly:
   - `PASS`: evidence was found or executed and satisfies the local check.
   - `GAP`: an applicable local requirement is not satisfied.
   - `UNKNOWN_EXTERNAL`: the requirement depends on repository/platform state that this harness cannot prove locally.
   - `NOT_APPLICABLE`: the documented trigger is not currently true.
5. Product labels such as `prototype`, `MVP`, or `production` are descriptive only. They do not promote OSPS maturity.
6. If a release is observed (state file or Git tag), run the release-conditioned checks and report every newly applicable gap.
7. If the number of maintainers or user population materially changes, flag `MATURITY_REASSESSMENT_REQUIRED`; do not silently promote the target level.
8. Do not add a security, release, architecture, or compliance claim unless the supporting evidence is versioned or externally verifiable.
9. Prefer the smallest change that closes a documented gap. Do not add controls merely for appearance.
10. After material project changes, rerun the harness and tests.
