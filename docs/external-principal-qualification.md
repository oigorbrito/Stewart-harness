# External principal qualification

The native harness supports two execution modes.

## Default mode

Without `STEWART_FIXTURE_TOKEN`, fixture mutations use the repository `GITHUB_TOKEN`. The harness verifies native negative states, head binding, and fail-closed handling of `UNSTABLE + SUCCESS`.

## External-principal mode

When the Actions secret `STEWART_FIXTURE_TOKEN` is present, **only fixture branch pushes** use that credential. Read/query/check orchestration continues to use the workflow's own `GITHUB_TOKEN`.

The external credential is intentionally narrow:

- resource owner: the user's GitHub account;
- repository access: **only `Stewart-harness`**;
- repository permission: **Contents: Read and write**;
- no administration, issues, workflows, secrets, organization, or other repository access is required for the current gate.

An external push to `fixture/native-state-persistent` must produce the native `pull_request:synchronize` lifecycle. The harness waits for the PR-triggered readiness workflow on the exact new head, then requires:

`OPEN + non-draft + CLEAN + MERGEABLE + checks SUCCESS + review NONE -> READY_FOR_MERGE_CANDIDATE`

The same sequence is repeated after a second head mutation, proving old-head evidence cannot qualify the new head.

## Secret

Store the fine-grained PAT as repository Actions secret:

`STEWART_FIXTURE_TOKEN`

Do not commit the token, print it, put it in repository variables, or broaden its repository scope.

## Why PAT before GitHub App

GitHub documents that workflows created by `GITHUB_TOKEN` are recursion-limited, while a GitHub App installation token or personal access token can trigger the normal workflow lifecycle. A fine-grained PAT is the smallest operational dependency for this one-repository laboratory. If the harness later needs multi-repository installation, short-lived credentials, or centrally revocable app identity, migrate this interface to a GitHub App without changing the evidence contract.
