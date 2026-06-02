#!/usr/bin/env bash
# View uncommitted working-tree changes in a READ-ONLY jj workspace.
#
# Why this exists: this workspace shares a jj repo whose git object store is
# mounted read-only. Any jj command that needs to snapshot the working copy
# (jj st, jj diff, jj log, ...) fails with "Failed to snapshot the working
# copy / Permission denied .../.git/objects". So we read the on-disk changes
# with plain git, using a throwaway index, never writing to the store.
#
# Usage (run from anywhere inside the workspace):
#   jj-wt.sh status        # short status, incl. untracked (default)
#   jj-wt.sh stat          # diffstat of tracked changes
#   jj-wt.sh files         # changed file names only
#   jj-wt.sh diff [paths]  # full patch (optionally limited to paths)
#   jj-wt.sh <git-subcmd> [args]   # escape hatch: any git command vs the base
#
# Base of the diff is the working-copy parent (@-), matching `jj diff`.
set -euo pipefail

# 1. Find the workspace root (nearest ancestor containing .jj)
root=$PWD
while [ "$root" != "/" ] && [ ! -e "$root/.jj" ]; do root=$(dirname "$root"); done
[ -e "$root/.jj" ] || { echo "jj-wt: not inside a jj workspace" >&2; exit 1; }

# 2. Resolve the backing git object store from .jj/repo -> store/git_target
repo=$(cat "$root/.jj/repo")
case "$repo" in /*) ;; *) repo="$root/.jj/$repo" ;; esac
repo=$(realpath "$repo")
gitdir=$(cat "$repo/store/git_target")
case "$gitdir" in /*) ;; *) gitdir="$repo/store/$gitdir" ;; esac
gitdir=$(realpath "$gitdir")

# 3. Base commit = git commit_id of the working-copy parent (@-).
#    --ignore-working-copy skips the (impossible) snapshot.
base=$(jj --ignore-working-copy log --no-graph -r @- -T commit_id)

# 4. Drive git with a throwaway index seeded from the base tree.
#    cd to the root so pathspecs are workspace-relative, not cwd-relative.
idx=$(mktemp)
trap 'rm -f "$idx"' EXIT
export GIT_DIR="$gitdir" GIT_WORK_TREE="$root" GIT_INDEX_FILE="$idx"
cd "$root"
git read-tree "$base"

cmd=${1:-status}; [ $# -gt 0 ] && shift || true
case "$cmd" in
  status) git -c status.showUntrackedFiles=all status -s "$@" -- . ':(exclude).jj' ;;
  diff)   git diff "$base" "$@" ;;
  stat)   git diff --stat "$base" "$@" ;;
  files)  git diff --name-only "$base" "$@" ;;
  *)      git "$cmd" "$@" ;;
esac
