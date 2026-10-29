# Waybar module (Omarchy, Hyprland)

In `~/.config/waybar/config.jsonc`, add `"custom/claude-team"` to `modules-right` and:

```jsonc
"custom/claude-team": {
  "exec": "/usr/local/share/claude-team/waybar/claude-team.sh",
  "return-type": "json",
  "interval": 300,
  "on-click": "alacritty -e /usr/local/bin/claude-team upgrade"
}
```

In `~/.config/waybar/style.css`:

```css
#custom-claude-team.update-available { color: @warning; }
#custom-claude-team.stale            { color: @warning; }
#custom-claude-team.not-installed    { color: @error; }
```

Then `omarchy-restart-waybar` (or `killall -SIGUSR2 waybar`).
