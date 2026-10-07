# Native GitHub state qualification

This harness exercises the readiness classifier against **real GitHub pull-request state** in this public laboratory repository.

It automatically creates an ephemeral branch and PR, then verifies:

1. draft -> `NOT_READY_DRAFT`;
2. ready + in-progress check -> `NOT_READY_CHECKS`;
3. successful check on current head -> `READY_FOR_MERGE_CANDIDATE`;
4. head mutation invalidates the old-head success -> `NOT_READY_CHECKS`;
5. successful check on the new head restores readiness;
6. closed PR -> `NOT_READY_STATE`.

The fixture PR is closed and its branch deleted by cleanup.

## Authority boundary

The workflow receives `contents: write`, `pull-requests: write`, and `checks: write` **only inside Stewart-harness** so it can manufacture test state. This is test-fixture authority, not Repository Steward production authority.

## Event-delivery boundary

GitHub suppresses most workflow recursion for events caused by the repository's own `GITHUB_TOKEN`. Therefore this gate proves live GitHub API state transitions and classifier behavior, but does **not** prove that a separately installed observer receives every native event caused by an external actor. That remains a distinct gate requiring a GitHub App or other external credential.
