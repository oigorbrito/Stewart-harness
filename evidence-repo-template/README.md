# Evidence-Driven Repository Template

This repository is a **starter harness**, not a claim of maturity or compliance.

Its purpose is to make a new repository start with:

- versioned project instructions and engineering evidence;
- a minimal executable verification command;
- machine-readable project state;
- explicit maturity/release triggers;
- fail-closed reporting (`PASS`, `GAP`, `UNKNOWN_EXTERNAL`, `NOT_APPLICABLE`);
- a path to stronger controls as externally defined requirements become applicable.

## Canonical verification

```bash
python scripts/harness.py
python -m unittest discover -s tests -v
```

## First-use checklist

1. Replace the project name and purpose below.
2. Select a real license and save it as `LICENSE` (see `LICENSE-SELECT.md`).
3. Update `policy/project-state.json` with observable facts only.
4. Implement the project under `src/` and tests under `tests/`.
5. Configure GitHub Repository Rules / branch protection outside the repository.
6. Enable OpenSSF Scorecard using `.github/workflows/scorecard.yml.example` after pinning every action to an exact commit SHA.

## Project purpose

**STATUS: UNDEFINED**

Describe the project here before implementation is considered established.

## Basic usage

**STATUS: NOT_RELEASED**

Before the first official release, replace this section with installation, configuration and basic-usage instructions.

## Defect reporting

Use GitHub Issues for non-sensitive defects. Security vulnerabilities must follow `SECURITY.md`.

## Maturity semantics

`product_stage` in `policy/project-state.json` is informational only. Terms such as `MVP` are **not** treated as proof of an OpenSSF maturity level.

The normative security maturity target is `osps_target_level`, and every promotion must be supported by observable evidence. See `docs/MATURITY.md`.
