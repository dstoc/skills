#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

for dir in */; do
  dir=${dir%/}

  # If the top-level dir is itself a skill, don't make it a plugin.
  [ ! -f "$dir/SKILL.md" ] || continue

  (
    cd "$dir"

    skills="$(
      find . -mindepth 2 -type f -name SKILL.md \
        | sed 's#/SKILL\.md$##' \
        | sort
    )"

    # No nested skills, no plugin.
    [ -n "$skills" ] || exit 0

    mkdir -p .claude-plugin

    printf '%s\n' "$skills" \
      | jq -R -s --arg name "dstoc-skills-$dir" \
          'split("\n")[:-1] | {name: $name, skills: .}' \
      > .claude-plugin/plugin.json

    # Codex expects .codex-plugin/plugin.json; make that point at the same dir.
    if [ -L .codex-plugin ]; then
      rm .codex-plugin
    elif [ -e .codex-plugin ]; then
      printf >&2 '%s\n' "error: $dir/.codex-plugin exists and is not a symlink"
      exit 1
    fi

    ln -s .claude-plugin .codex-plugin
  )
done
