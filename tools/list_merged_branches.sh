#!/usr/bin/env bash
#
# Report which remote branches are safe to delete.
#
# Why this exists: `git branch -r --merged main` is WRONG in this repository.
# Every PR here is squash-merged, which creates a new commit on `main` and
# leaves the branch tip unreachable from it. On 2026-07-31 that command
# reported three branches merged minutes earlier as unmerged, while listing
# others as merged. It is wrong in both directions, so it must not be used to
# decide what to delete.
#
# GitHub's own merge record is the authority. This script cross-references it
# with the remote refs and classifies each branch.
#
# This script NEVER deletes anything. It prints the delete command for you to
# run yourself, deliberately: deleting a branch someone else is working from is
# not recoverable from this machine.
#
# Usage:
#   tools/list_merged_branches.sh          # report
#   tools/list_merged_branches.sh --fetch  # prune stale refs first

set -euo pipefail

BASE_BRANCH="${BASE_BRANCH:-main}"
REMOTE="${REMOTE:-origin}"

if ! command -v gh >/dev/null 2>&1; then
    echo "error: gh is required (the git-only check is unreliable with squash merges)." >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "error: gh is not authenticated; cannot read the merge record." >&2
    exit 1
fi

if [[ "${1:-}" == "--fetch" ]]; then
    echo "Fetching and pruning ${REMOTE}..."
    git fetch --prune "$REMOTE"
    echo
fi

# One API call each; PR state is the authority, remote refs are the inventory.
open_prs=$(gh pr list --state open --limit 200 --json number,headRefName \
    -q '.[] | "\(.headRefName)\t\(.number)"')
merged_prs=$(gh pr list --state merged --limit 200 --json number,headRefName,headRefOid \
    -q '.[] | "\(.headRefName)\t\(.number)\t\(.headRefOid)"')

safe=()
review=()

while read -r ref; do
    [[ -z "$ref" ]] && continue
    branch="${ref#refs/remotes/$REMOTE/}"
    [[ "$branch" == "$BASE_BRANCH" || "$branch" == "HEAD" ]] && continue

    # awk with an exact field compare: portable, and no regex metacharacter
    # surprises from branch names containing '.' or '+'.
    open_pr=$(awk -F'\t' -v b="$branch" '$1 == b { print; exit }' <<<"$open_prs")
    if [[ -n "$open_pr" ]]; then
        review+=("$branch|KEEP|open PR #$(cut -f2 <<<"$open_pr")")
        continue
    fi

    merged_pr=$(awk -F'\t' -v b="$branch" '$1 == b { print; exit }' <<<"$merged_prs")
    if [[ -n "$merged_pr" ]]; then
        pr_num=$(cut -f2 <<<"$merged_pr")
        merged_oid=$(cut -f3 <<<"$merged_pr")
        current_oid=$(git rev-parse "$REMOTE/$branch")

        if [[ "$merged_oid" == "$current_oid" ]]; then
            safe+=("$branch|SAFE|merged as PR #$pr_num, tip unchanged")
        else
            review+=("$branch|REVIEW|PR #$pr_num merged, but the branch has moved since; those commits are NOT in $BASE_BRANCH")
        fi
        continue
    fi

    review+=("$branch|REVIEW|no PR found; provenance unknown, do not delete on this script's word")
done < <(git for-each-ref --format='%(refname)' "refs/remotes/$REMOTE/")

printf '%-46s %-8s %s\n' "BRANCH" "STATUS" "BASIS"
printf '%-46s %-8s %s\n' "------" "------" "-----"
# macOS ships bash 3.2, where an empty array is "unbound" under `set -u`.
for row in ${safe[@]+"${safe[@]}"} ${review[@]+"${review[@]}"}; do
    IFS='|' read -r b s basis <<<"$row"
    printf '%-46s %-8s %s\n' "$b" "$s" "$basis"
done

echo
if [[ ${#safe[@]} -eq 0 ]]; then
    echo "Nothing is safe to delete."
    exit 0
fi

echo "${#safe[@]} branch(es) safe to delete. Run this yourself if you agree:"
echo
printf '  git push %s --delete' "$REMOTE"
for row in ${safe[@]+"${safe[@]}"}; do
    printf ' %s' "${row%%|*}"
done
printf '\n\n'
echo "This script does not delete. Read the list before running that."
