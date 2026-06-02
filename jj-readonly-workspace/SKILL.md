---
name: jj-readonly-workspace
description: View working-tree changes (file list, diff) and history in a jj workspace whose repo is mounted read-only. Use when jj commands fail with "Failed to snapshot the working copy / Permission denied ... .git/objects", or whenever you need to see uncommitted edits or history in such a workspace.
---

# Inspecting a read-only jj workspace

## The situation

You are in a **jj workspace** that shares its repo with a sibling checkout.
The sibling holds the git object store, and it is mounted **read-only**. Files
in the workspace can be edited freely, but the backing `.git/objects` cannot be
written.

jj snapshots the working copy on almost every command (`jj st`, `jj diff`,
`jj log`, `jj show`, ...). Snapshotting writes new blobs to the object store,
which fails the moment any file on disk differs from the last snapshot:

```
Internal error: Failed to snapshot the working copy
Caused by:
... Could not create named temp file in '.../.git/objects'
... Permission denied (os error 13)
```

You also cannot commit, `jj new`, `jj describe`, `jj squash`, or
`jj workspace update-stale` — anything that writes is blocked. The workspace
commit history **read-only for inspection only**.

The two ways around it:
- **History & committed revisions** → run jj with `--ignore-working-copy`.
- **Uncommitted working-tree changes** → read them with plain `git` against
  the (readable) object store, using a throwaway index. Use the bundled
  `jj-wt.sh` helper.

## Viewing working-tree changes (uncommitted edits)

jj cannot show these — it would need to snapshot. Use the bundled helper at
`./scripts/jj-wt.sh` (relative to this skill's base directory). Run it from
anywhere inside the workspace:

```bash
./scripts/jj-wt.sh status            # short status + untracked
./scripts/jj-wt.sh stat              # diffstat
./scripts/jj-wt.sh files             # changed file names
./scripts/jj-wt.sh diff [-- path...] # full patch
```

The base of the comparison is the working-copy parent `@-`, so the output
matches what `jj diff` *would* show. `status` lists untracked files too
(it hides `.jj/`).

## Viewing history and committed diffs

For anything already committed, jj works — just add `--ignore-working-copy`
so it skips the (impossible) snapshot. Make it a habit; without it these
commands fail whenever the working tree is dirty.

```bash
jj --ignore-working-copy log                          # graph of recent history
jj --ignore-working-copy log -r '::@' -n 20           # ancestors of working copy
jj --ignore-working-copy show <rev>                   # a commit's message + diff
jj --ignore-working-copy diff -r <rev>                # changes introduced by <rev>
jj --ignore-working-copy diff --from <a> --to <b>     # diff between two commits
jj --ignore-working-copy log -r @- -T commit_id       # git commit id of a rev
```

Note: a plain `jj --ignore-working-copy diff` (or `diff -r @`) shows the *last
snapshot* of the working copy, **not** your current on-disk edits — for those
use `jj-wt.sh` above.
