#!/bin/bash
# SwiftBar plugin: team Claude Code setup state in the menu bar. Refreshes every 5 minutes.
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
CLI="/usr/local/bin/lobsters-cli"
STATE_DIR="$HOME/.local/state/cloud-lobsters"
STATE="$STATE_DIR/status.json"
# status.json is written at each Claude session start. Between sessions nobody would notice a
# new release, so when the newest-release lookup is older than its TTL (30 min, kept by the
# CLI) refresh it from here: one anonymous, read-only `git ls-remote`, then a rewrite of status.json.
stamp="$STATE_DIR/last-tag-check"
if [ -x "$CLI" ] && { [ ! -f "$stamp" ] || [ -n "$(find "$stamp" -mmin +30 2>/dev/null)" ]; }; then
  "$CLI" status >/dev/null 2>&1
fi
state="$(jq -r '.state // "not-installed"' "$STATE" 2>/dev/null)"
inst="$(jq -r '.tooling.installed // "?"' "$STATE" 2>/dev/null)"
lat="$(jq -r '.tooling.latest // "?"' "$STATE" 2>/dev/null)"
sync="$(jq -r '.rules.lastSync // "never"' "$STATE" 2>/dev/null)"
case "$state" in
  synced)           echo "🦞 $inst" ;;
  update-available) echo "🦞 $inst → $lat | color=orange" ;;
  stale)            echo "🦞 stale | color=orange" ;;
  *)                echo "🦞 ✗ | color=red" ;;
esac
echo "---"
echo "lobsters-cli $inst · newest $lat"
echo "rules synced $sync"
case "$state" in
  update-available) echo "Upgrade now | bash=$CLI param1=upgrade terminal=true" ;;
  not-installed)    echo "Run lobsters-cli setup | bash=$CLI param1=setup terminal=true" ;;
esac
echo "Check | bash=$CLI param1=check terminal=true"
