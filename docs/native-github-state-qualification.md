# Native GitHub state qualification

This harness exercises the readiness classifier against **real GitHub pull-request state** in this public laboratory repository.

A persistent draft PR, **#3** on branch `fixture/native-state-persistent`, is the controlled fixture. It is created once outside GitHub Actions; subsequent self-token qualification runs are automatic.

## Automated self-token gate

The Actions harness verifies real GitHub state transitions:

1. draft -> `NOT_READY_DRAFT`;
2. ready + in-progress check -> `NOT_READY_CHECKS`;
3. completed current-head check-runs, a successful `workflow_dispatch` run, and a successful commit status are attached to the fixture head;
4. if GitHub still reports `mergeStateStatus=UNSTABLE`, the classifier must remain `NOT_READY_CHECKS` rather than promote the PR;
5. a real head mutation invalidates all old-head success evidence;
6. success evidence is rebound to the new head and the same fail-closed platform boundary is checked again;
7. closed PR -> `NOT_READY_STATE`;
8. cleanup reopens the fixture and returns it to draft.

The gate accepts `CLEAN + SUCCESS -> READY_FOR_MERGE_CANDIDATE` if GitHub natively produces that state. Under the repository's own `GITHUB_TOKEN`, the currently observed state is `UNSTABLE + SUCCESS -> NOT_READY_CHECKS`, which is the required fail-closed result.

## Evidence boundary

`SELF_TOKEN_NATIVE_NEGATIVE_STATES = AUTOMATED`

`SELF_TOKEN_HEAD_BINDING = AUTOMATED`

`SELF_TOKEN_UNSTABLE_FAIL_CLOSED = AUTOMATED`

`RECURRING_NATIVE_CLEAN_POSITIVE = NOT_PROVEN_WITH_GITHUB_TOKEN`

`EXTERNAL_PRINCIPAL_EVENT_DELIVERY = REQUIRED_FOR_FULL_POSITIVE_GATE`

GitHub suppresses most recursive workflow events caused by the repository's own `GITHUB_TOKEN`. Therefore self-token runs do not establish that an external actor's `pull_request:synchronize` lifecycle and observer delivery are equivalent. A restricted GitHub App installation token or another external principal is required for that separate end-to-end positive gate.

## Authority boundary

The workflow receives `actions: write`, `checks: write`, `contents: write`, `pull-requests: write`, and `statuses: write` only inside **Stewart-harness** to manufacture fixture state. The repository setting that allows Actions to create or approve pull requests remains disabled.

These permissions are **test-fixture authority only**. They do not grant Repository Steward production write, merge, review, branch-rule, or promotion authority.
