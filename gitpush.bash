#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date '+%Y-%m-%d %H:%M:%S')"

git pull

git add -A
git commit -m "update ${STAMP}"

git push
