# Maturity and applicability model

## Normative basis

The repository uses **OpenSSF OSPS Baseline v2026.08.28** as the normative maturity reference for this starter harness.

OSPS defines:

- Level 1: any code or non-code project with any number of maintainers/users.
- Level 2: code project with at least two maintainers and a small number of consistent users.
- Level 3: code project with a large number of consistent users.

The harness does not invent a numeric threshold for “large number of users”. Promotion therefore requires explicit human evidence in `policy/project-state.json`.

## Product stage is non-normative

`exploration`, `prototype`, `MVP`, `mature-MVP`, and `production` may be useful product labels, but they are not OSPS maturity levels. They never satisfy an OSPS control by themselves.

## Observable triggers

The harness recognizes these observable triggers:

1. **First release observed** — `release.made=true` in the state file or at least one Git tag is present.
2. **Maintainer count changed** — used to request reassessment, not automatic promotion.
3. **OSPS target level changed** — activates the corresponding locally checkable controls.
4. **Project implementation present** — project-specific testing should no longer remain empty.

## State transition rule

A transition never means “all requirements pass.” It means **new requirements may become applicable**.

Example:

```text
first release observed
        ↓
release-conditioned controls become applicable
        ↓
harness checks available local evidence
        ↓
PASS / GAP / UNKNOWN_EXTERNAL
```

## External checks

Some requirements cannot be proved from files alone, including MFA, repository-rule enforcement, branch deletion protection, collaborator permissions, and some hosted CI/security settings. The harness must report these as `UNKNOWN_EXTERNAL` unless queried through an authoritative platform API.

## Reassessment rule

When project facts no longer fit the recorded target maturity, report `MATURITY_REASSESSMENT_REQUIRED`. Never silently promote or demote maturity.
