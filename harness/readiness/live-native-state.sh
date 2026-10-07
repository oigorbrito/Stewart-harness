#!/usr/bin/env bash
set -euo pipefail

repo="${GITHUB_REPOSITORY:?}"
owner="${repo%%/*}"
name="${repo##*/}"
run_id="${GITHUB_RUN_ID:?}"
branch="fixture/native-${run_id}"
fixture=".stewart-native-fixture-${run_id}.txt"
classifier="harness/readiness/repository-steward-readiness-classifier-v2.sh"

cleanup() {
  set +e
  if [[ -n "${pr_number:-}" ]]; then
    gh pr close "$pr_number" --repo "$repo" >/dev/null 2>&1 || true
  fi
  git push origin --delete "$branch" >/dev/null 2>&1 || true
}
trap cleanup EXIT

git config user.name "stewart-harness[bot]"
git config user.email "stewart-harness[bot]@users.noreply.github.com"
git checkout -b "$branch"
printf 'native fixture run %s\n' "$run_id" > "$fixture"
git add "$fixture"
git commit -m "test: native readiness fixture ${run_id}"
git push origin "$branch"

pr_url="$(gh pr create --repo "$repo" --base main --head "$branch" --draft \
  --title "test: Stewart native fixture ${run_id} [DO NOT MERGE]" \
  --body "Ephemeral fixture created by the Stewart harness. It will be closed and its branch deleted automatically.")"
pr_number="${pr_url##*/}"
echo "FIXTURE_PR=$pr_number"

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
  return 1
}

# Native draft state dominates all later fields.
classify_expect NOT_READY_DRAFT 6

gh pr ready "$pr_number" --repo "$repo" >/dev/null

head_sha="$(git rev-parse HEAD)"
pending_json="$(gh api -X POST "repos/$repo/check-runs" \
  -f name='stewart-native-fixture-check' \
  -f head_sha="$head_sha" \
  -f status='in_progress')"
check_id="$(jq -r .id <<<"$pending_json")"
classify_expect NOT_READY_CHECKS 10

gh api -X PATCH "repos/$repo/check-runs/$check_id" \
  -f status='completed' -f conclusion='success' >/dev/null
classify_expect READY_FOR_MERGE_CANDIDATE 12

old_head="$head_sha"
printf 'head mutation %s\n' "$run_id" >> "$fixture"
git add "$fixture"
git commit -m "test: mutate native fixture head ${run_id}"
git push origin "$branch"
head_sha="$(git rev-parse HEAD)"
test "$head_sha" != "$old_head"
echo "NATIVE_HEAD_MOVED old=$old_head new=$head_sha decision=PASS"

# Old-head success must not make the new head ready.
classify_expect NOT_READY_CHECKS 10

success_json="$(gh api -X POST "repos/$repo/check-runs" \
  -f name='stewart-native-fixture-check' \
  -f head_sha="$head_sha" \
  -f status='completed' -f conclusion='success')"
test -n "$(jq -r .id <<<"$success_json")"
classify_expect READY_FOR_MERGE_CANDIDATE 12

gh pr close "$pr_number" --repo "$repo" >/dev/null
classify_expect NOT_READY_STATE 6

echo "NATIVE_GITHUB_STATE_MATRIX=PASS"
