#!/usr/bin/env bash
# Release the configs with a calendar version YYYY.MM.N (N counts releases within the month):
# writes VERSION, commits it and tags v<version>. The Indie Image Sensor Evaluation app shows this
# version next to each sensor.
#   bash release.sh           # tag the next version locally
#   bash release.sh --push    # and push the commit and tag
set -euo pipefail
cd "$(dirname "$0")"
[ -z "$(git status --porcelain)" ] || { echo "Commit or stash your changes first." >&2; exit 1; }
git fetch -q --tags origin || echo "Could not fetch tags; numbering from local tags." >&2
month="$(date +%Y.%m)"
last="$(git tag -l "v$month.*" | sed "s/^v$month\.//" | sort -n | tail -1)"
version="$month.$(( ${last:--1} + 1 ))"
echo "$version" > VERSION
git add VERSION
git commit -qm "Release $version"
git tag "v$version"
echo "Tagged v$version"
if [ "${1:-}" = "--push" ]; then git push origin HEAD "v$version"; fi
