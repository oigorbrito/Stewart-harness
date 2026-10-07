# Stewart Harness

Public GitHub Actions harness for the Repository Steward capabilities.

## Current gate

The first automated gate covers the accepted **readiness** core:

- readiness classifier v2 synthetic matrix;
- workflow-run/PR association synthetic matrix;
- shell syntax validation;
- provenance and READ/REPORT authority guard.

The imported core is pinned to the accepted Searchleads evidence state at commit `450243c4de7223db5d2e0b10de737de403520d3d`.

## Evidence semantics

`IMPLEMENTED != EXECUTED != VERIFIED != ACCEPTED`

A green synthetic matrix proves only the synthetic core exercised by this repository. It does not prove native GitHub event delivery, branch protection behavior, review state propagation, or automatic write authority.

## Next gates

Native PR fixtures will exercise GitHub-hosted state transitions automatically. Write-capable capabilities remain separate and are not granted by readiness acceptance.
