#!/bin/bash
# Pulls the latest digest and posts a macOS notification for any new files.
set -uo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO" || exit 1

before="$(git rev-parse HEAD 2>/dev/null)"
git pull --ff-only --quiet || { echo "$(date) pull failed"; exit 1; }
after="$(git rev-parse HEAD)"

if [ "$before" != "$after" ]; then
  for f in $(git diff --name-only --diff-filter=A "$before" "$after" -- daily/); do
    title="$(head -1 "$f" | sed 's/^# //')"
    osascript -e "display notification \"$title\" with title \"Crypto Watch\" sound name \"Glass\""
    echo "$(date) new: $f"
  done
else
  echo "$(date) no new digest"
fi
