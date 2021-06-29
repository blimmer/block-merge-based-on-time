#!/bin/bash

set -xeuo pipefail

# Check whether the version is described in the source code.
grep -F "## [${FUTURE_RELEASE}]" CHANGELOG.md
grep -F '## [Unreleased]' CHANGELOG.md && exit 1

# Extract the latest changelog entries to put them into GitHub release notes.
hit=0
while IFS="" read -r line; do
  if [[ "$line" == "## ["*"]("*")"* ]]; then
    hit=$((hit + 1))
    continue
  fi
  if [[ "$hit" == "1" ]]; then
    echo "$line" >> /tmp/notes.txt
  fi
done < CHANGELOG.md

gh release list
cat /tmp/notes.txt

if [[ "$APPLY" == "true" ]]; then
  gh release create "$FUTURE_RELEASE" --title "$RELEASE_TITLE" --notes-file /tmp/notes.txt
fi