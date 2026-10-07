#!/usr/bin/env bash
set -euo pipefail

repo="${GITHUB_REPOSITORY:?}"
owner="${repo%%/*}"
name="${repo##*/}"
pr_number=3
fixture_branch="fixture/native-state-persistent"
classifier="$PWD/harness/readiness/repository-steward-readiness-classifier-v2.sh"
worktree="$(mktemp -d)"

set_draft() {
  local pr_id
  pr_id="$(gh pr view "$pr_number" --repo "$repo" --json id --jq .id)"
  gh api graphql \
    -f query='mutation($id:ID!){convertPullRequestToDraft(input:{pullRequestId:$id}){pullRequest{isDraft}}}' \
    -f id="$pr_id" >/dev/null
}

restore_fixture() {
  set +e
  gh pr reopen "$pr_number" --repo "$repo" >/dev/null 2>&1 || true
  set_draft >/dev/null 2>&1 || true
  git worktree remove --force "$worktree" >/dev/null 2>&1 || true
}
trap restore_fixture EXIT

gh pr reopen "$pr_number" --repo "$repo" >/dev/null 2>&1 || true
set_draft

# Rebuild the persistent fixture from the exact current main commit so that
# BEHIND/UNSTABLE from a previous qualification run cannot contaminate this run.
git fetch origin main "$fixture_branch"
git worktree add --force "$worktree" "origin/$fixture_branch"
git -C "$worktree" config user.name "stewart-harness[bot]"
git -C "$worktree" config user.email "stewart-harness[bot]@users.noreply.github.com"
git -C "$worktree" reset --hard origin/main
printf 'Persistent Stewart native GitHub state fixture. DO NOT MERGE.\nrun=%s\n' "${GITHUB_RUN_ID:?}" > "$worktree/.stewart-native-fixture.txt"
git -C "$worktree" add .stewart-native-fixture.txt
git -C "$worktree" commit -m "test: reset persistent native fixture ${GITHUB_RUN_ID}"
git -C "$worktree" push --force-with-lease origin HEAD:"$fixture_branch"
echo "NATIVE_FIXTURE_SYNC base=$(git rev-parse origin/main) head=$(git -C "$worktree" rev-parse HEAD) decision=PASS"

query_pr() {
  gh api graphql \
    -f query='query($owner:String!,$name:String!,$number:Int!){repository(owner:$owner,name:$name){pullRequest(number:$number){state isDraft mergeStateStatus mergeable reviewDecision statusCheckRollup{state} baseRefName headRefName headRefOid}}}' \
    -f owner="$owner" -f name="$name" -F number="$pr_number"
}

classify_expect() {
  local expected="$1" attempts="${2:-1}" response actual
  for ((i=1; i<=attempts; i++)); do
    response="$(mktemp)"
    query_pr > "$response"
    actual="$(bash "$classifier" --response "$response")"
    rm -f "$response"
    if [[ "$actual" == "$expected" ]]; then
      echo "NATIVE_STATE expected=$expected actual=$actual attempt=$i decision=PASS"
      return 0
    fi
    sleep 2
  done
  echo "NATIVE_STATE expected=$expected actual=$actual decision=FAIL" >&2
  query_pr >&2 || true
  return 1
}

# 1. Native draft state.
classify_expect NOT_READY_DRAFT 8

# 2. Ready PR with an explicitly pending check.
gh pr ready "$pr_number" --repo "$repo" >/dev/null
head_sha="$(gh pr view "$pr_number" --repo "$repo" --json headRefOid --jq .headRefOid)"
pending_json="$(gh api -X POST "repos/$repo/check-runs" \
  -f name='stewart-native-fixture-check' \
  -f head_sha="$head_sha" \
  -f status='in_progress')"
check_id="$(jq -r .id <<<"$pending_json")"
classify_expect NOT_READY_CHECKS 12

# 3. Same head becomes ready only after all observed checks are successful.
gh api -X PATCH "repos/$repo/check-runs/$check_id" \
  -f status='completed' -f conclusion='success' >/dev/null
classify_expect READY_FOR_MERGE_CANDIDATE 20

# 4. Move the real PR head. Old-head success must not qualify the new head.
printf 'head mutation run=%s\n' "${GITHUB_RUN_ID:?}" >> "$worktree/.stewart-native-fixture.txt"
git -C "$worktree" add .stewart-native-fixture.txt
git -C "$worktree" commit -m "test: mutate persistent native fixture ${GITHUB_RUN_ID}"
old_head="$head_sha"
git -C "$worktree" push origin HEAD:"$fixture_branch"
head_sha="$(git -C "$worktree" rev-parse HEAD)"
test "$head_sha" != "$old_head"
echo "NATIVE_HEAD_MOVED old=$old_head new=$head_sha decision=PASS"
classify_expect NOT_READY_CHECKS 12

# 5. Success bound to the new head restores readiness.
success_json="$(gh api -X POST "repos/$repo/check-runs" \
  -f name='stewart-native-fixture-check' \
  -f head_sha="$head_sha" \
  -f status='completed' -f conclusion='success')"
test -n "$(jq -r .id <<<"$success_json")"
classify_expect READY_FOR_MERGE_CANDIDATE 20

# 6. Closed native state dominates an otherwise-good head.
gh pr close "$pr_number" --repo "$repo" >/dev/null
classify_expect NOT_READY_STATE 8

# Leave the persistent fixture safe for the next run.
gh pr reopen "$pr_number" --repo "$repo" >/dev/null
set_draft
classify_expect NOT_READY_DRAFT 8

echo "NATIVE_GITHUB_STATE_MATRIX=PASS"
