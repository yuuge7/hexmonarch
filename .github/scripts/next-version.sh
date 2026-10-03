#!/usr/bin/env bash
# Picks the version for the next release and writes it into pubspec.yaml.
#
# A release is "HexMonarch vX.Y" with git tag vX.Y, where X.Y comes from
# `version: X.Y.Z+BUILD` in pubspec.yaml (Z is only shown when it is not 0).
#
#   - The pubspec version has no tag yet (first release, or the version was
#     raised by hand, e.g. to 1.0.0): release it as it is.
#   - The tag already exists: raise the minor (X.Y -> X.Y+1, patch back to 0)
#     until the tag is free.
#   - Either way the build number ends up higher than the one in the previous
#     release: Android refuses an update whose versionCode did not go up.
#
# So a push never lands on an existing release.
#
# Needs the full history and every tag (actions/checkout with fetch-depth: 0).
# Prints the result; inside GitHub Actions it also sets step outputs:
#   version   pubspec version, e.g. 0.5.0+6
#   label     0.5
#   tag       v0.5
#   bumped    true when pubspec.yaml was changed
set -euo pipefail

pubspec="${1:-pubspec.yaml}"
pattern='^version:[[:space:]]*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)[[:space:]]*$'

current="$(sed -nE "s/$pattern/\1.\2.\3+\4/p" "$pubspec" | head -n 1)"
if [ -z "$current" ]; then
  echo "error: $pubspec needs a line like 'version: 1.2.3+4'" >&2
  exit 1
fi

name="${current%%+*}"
build="${current##*+}"
IFS=. read -r major minor patch <<<"$name"

label() {
  if [ "$patch" = "0" ]; then echo "$major.$minor"; else echo "$major.$minor.$patch"; fi
}

while git rev-parse -q --verify "refs/tags/v$(label)" >/dev/null; do
  minor=$((minor + 1))
  patch=0
done

previous_build=0
if last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*' 2>/dev/null)"; then
  previous_build="$(git show "$last_tag:$pubspec" 2>/dev/null | sed -nE "s/$pattern/\4/p" | head -n 1)"
  previous_build="${previous_build:-0}"
fi
if [ "$build" -le "$previous_build" ]; then
  build=$((previous_build + 1))
fi

version="$major.$minor.$patch+$build"
bumped=false
if [ "$version" != "$current" ]; then
  bumped=true
  sed -i -E "s/^version:[[:space:]]*.*$/version: $version/" "$pubspec"
fi

echo "pubspec : $current"
echo "release : HexMonarch v$(label)  (tag v$(label), pubspec $version, bumped=$bumped)"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "version=$version"
    echo "label=$(label)"
    echo "tag=v$(label)"
    echo "bumped=$bumped"
  } >>"$GITHUB_OUTPUT"
fi
