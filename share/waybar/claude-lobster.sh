#!/bin/bash
# Waybar custom module: team Claude Code setup state. See README.md next to this file.
STATE="$HOME/.local/state/cloud-lobsters/status.json"
state="$(jq -r '.state // "not-installed"' "$STATE" 2>/dev/null)"
inst="$(jq -r '.tooling.installed // "?"' "$STATE" 2>/dev/null)"
lat="$(jq -r '.tooling.latest // "?"' "$STATE" 2>/dev/null)"
sync="$(jq -r '.rules.lastSync // "never"' "$STATE" 2>/dev/null)"
case "$state" in
  synced)           text="🦞 $inst"; tip="claude-lobster $inst, rules synced $sync" ;;
  update-available) text="🦞 $inst → $lat"; tip="claude-lobster $lat available: claude-lobster upgrade" ;;
  stale)            text="🦞 stale"; tip="rules not synced since $sync" ;;
  *)                text="🦞 ✗"; tip="claude-lobster not set up: run claude-lobster setup" ;;
esac
jq -nc --arg t "$text" --arg tip "$tip" --arg c "$state" '{text: $t, tooltip: $tip, class: $c}'
