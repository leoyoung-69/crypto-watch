#!/bin/bash
# Installs a macOS LaunchAgent that runs `git pull` in this repo every morning
# and shows a notification when a new digest arrives.
# Usage: ./scripts/install-autopull.sh [HOUR] [MINUTE]   (local Mac time, default 08:15)
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
HOUR="${1:-8}"
MINUTE="${2:-15}"
LABEL="com.leo.crypto-watch.autopull"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
RUNNER="$REPO/scripts/pull-and-notify.sh"
LOG="$HOME/Library/Logs/crypto-watch-autopull.log"

chmod +x "$RUNNER"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$RUNNER</string></array>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>$HOUR</integer><key>Minute</key><integer>$MINUTE</integer></dict>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Installed: pulls $REPO daily at $(printf '%02d:%02d' "$HOUR" "$MINUTE") local time. Log: $LOG"
echo "Uninstall: launchctl bootout gui/$(id -u)/$LABEL && rm $PLIST"
