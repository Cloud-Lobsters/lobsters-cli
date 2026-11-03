#!/bin/bash
# Waybar custom module: team Claude Code setup state. See README.md next to this file.
export PATH="/usr/local/bin:$PATH"
CLI="/usr/local/bin/lobsters-cli"
STATE_DIR="$HOME/.local/state/cloud-lobsters"
STATE="$STATE_DIR/status.json"
# `lobsters-cli.sh sync` is the module's click action (see README.md): pull the rules now, tell
# the person through a notification, then wake the module so the bar shows the new state.
# The signal number must match "signal" in the module's config.
SIGNAL=8
if [ "${1:-}" = sync ]; then
  [ -x "$CLI" ] && "$CLI" sync --notify
  pkill -RTMIN+$SIGNAL waybar 2>/dev/null
  exit 0
fi
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
  synced)           text="🦞 $inst"; tip="lobsters-cli $inst, rules synced $sync" ;;
  update-available) text="🦞 $inst → $lat"; tip="lobsters-cli $lat available: right-click to upgrade" ;;
  stale)            text="🦞 stale"; tip="rules not synced since $sync" ;;
  *)                text="🦞 ✗"; tip="lobsters-cli not set up: run lobsters-cli setup" ;;
esac
[ "$state" = not-installed ] || tip="$tip"$'\n'"click: sync rules now · right-click: upgrade"
jq -nc --arg t "$text" --arg tip "$tip" --arg c "$state" '{text: $t, tooltip: $tip, class: $c}'
