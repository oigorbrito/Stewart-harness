# Contributing

## Contribution process

1. Open or reference an issue when the change is non-trivial.
2. Work on a branch rather than committing directly to the primary branch.
3. Keep changes scoped and reviewable.
4. Add or update tests when behavior changes.
5. Run the canonical verification locally:

```bash
python scripts/harness.py
python -m unittest discover -s tests -v
```

6. Open a pull request describing the change and the evidence executed.
7. Do not report a check as passed unless it was executed on the current change.

## Acceptable contributions

Changes should preserve documented interfaces and invariants, avoid introducing generated binaries into source control, and keep dependency changes explicit and reviewable.

## Test policy

At repository bootstrap, tests may be minimal. As the project matures, the applicable OSPS target level controls whether automated tests in CI, documented test execution, and test-update policy become mandatory. See `docs/MATURITY.md`.
