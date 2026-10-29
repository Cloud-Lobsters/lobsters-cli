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
  synced)           echo "☁︎ | sfimage=checkmark.icloud" ;;
  update-available) echo "☁︎ v$lat | sfimage=icloud.and.arrow.down color=orange" ;;
  stale)            echo "☁︎ | sfimage=exclamationmark.icloud color=orange" ;;
  *)                echo "☁︎ | sfimage=xmark.icloud color=red" ;;
esac
echo "---"
echo "claude-team $inst · newest $lat"
echo "rules synced $sync"
case "$state" in
  update-available) echo "Upgrade now | bash=/usr/local/bin/claude-team param1=upgrade terminal=true" ;;
  not-installed)    echo "Run claude-team setup | bash=/usr/local/bin/claude-team param1=setup terminal=true" ;;
esac
echo "Check | bash=/usr/local/bin/claude-team param1=check terminal=true"
