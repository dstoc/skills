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
  )
done
