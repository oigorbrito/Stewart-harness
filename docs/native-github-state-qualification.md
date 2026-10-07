# Native GitHub state qualification

This harness exercises the readiness classifier against **real GitHub pull-request state** in this public laboratory repository.

A persistent draft PR, **#3** on branch `fixture/native-state-persistent`, is the controlled fixture. It is created once outside GitHub Actions; every subsequent qualification run is automatic.

The Actions harness verifies:

1. draft -> `NOT_READY_DRAFT`;
2. ready + in-progress check -> `NOT_READY_CHECKS`;
3. successful checks on the current head -> `READY_FOR_MERGE_CANDIDATE`;
4. a real head mutation invalidates old-head success -> `NOT_READY_CHECKS`;
5. success attached to the new head restores readiness;
6. closed PR -> `NOT_READY_STATE`;
7. cleanup reopens the fixture and returns it to draft.

## Authority boundary

The workflow receives `contents: write`, `pull-requests: write`, and `checks: write` only inside **Stewart-harness**. It does not receive permission to create pull requests, and the repository setting that would allow Actions to create/approve PRs remains disabled.

This is test-fixture authority, not Repository Steward production authority.

## Event-delivery boundary

Events caused by the repository's own `GITHUB_TOKEN` are subject to GitHub's workflow-recursion suppression. This gate therefore proves live GitHub state transitions, head binding, and classifier behavior. It does **not** prove delivery of every native event to a separately installed observer acting on events from an external principal. That remains a separate GitHub App/external-credential gate.
