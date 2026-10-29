#!/bin/bash
# Waybar custom module: team Claude Code setup state. See README.md next to this file.
STATE="$HOME/.local/state/cloud-lobsters/status.json"
state="$(jq -r '.state // "not-installed"' "$STATE" 2>/dev/null)"
inst="$(jq -r '.tooling.installed // "?"' "$STATE" 2>/dev/null)"
lat="$(jq -r '.tooling.latest // "?"' "$STATE" 2>/dev/null)"
sync="$(jq -r '.rules.lastSync // "never"' "$STATE" 2>/dev/null)"
case "$state" in
  synced)           text="☁"; tip="claude-team $inst, rules synced $sync" ;;
  update-available) text="☁ v$lat"; tip="claude-team $lat available (you have $inst): claude-team upgrade" ;;
  stale)            text="☁ !"; tip="rules not synced since $sync" ;;
  *)                text="☁ ×"; tip="claude-team not set up: run claude-team setup" ;;
esac
jq -nc --arg t "$text" --arg tip "$tip" --arg c "$state" '{text: $t, tooltip: $tip, class: $c}'
