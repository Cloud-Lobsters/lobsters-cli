#!/bin/bash
# SwiftBar plugin: team Claude Code setup state in the menu bar. Refreshes every 5 minutes.
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
STATE="$HOME/.local/state/cloud-lobsters/status.json"
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
  update-available) echo "Upgrade now | bash=/usr/local/bin/lobsters-cli param1=upgrade terminal=true" ;;
  not-installed)    echo "Run lobsters-cli setup | bash=/usr/local/bin/lobsters-cli param1=setup terminal=true" ;;
esac
echo "Check | bash=/usr/local/bin/lobsters-cli param1=check terminal=true"
