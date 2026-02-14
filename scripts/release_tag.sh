#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: ./release_tag.sh <version> <cn|intl>"
  exit 1
fi

VERSION="$1"
FLAVOR="$2"

if [[ "$FLAVOR" != "cn" && "$FLAVOR" != "intl" ]]; then
  echo "Flavor must be cn or intl"
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree not clean. Please commit or stash changes first."
  exit 1
fi

tag="v${VERSION}+${FLAVOR}"

echo "Creating tag $tag"

git tag "$tag"

git push origin "$tag"

echo "Pushed tag $tag"
