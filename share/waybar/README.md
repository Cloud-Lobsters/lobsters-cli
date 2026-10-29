# Waybar module (Omarchy, Hyprland)

In `~/.config/waybar/config.jsonc`, add `"custom/claude-lobster"` to `modules-right` and:

```jsonc
"custom/claude-lobster": {
  "exec": "/usr/local/share/claude-lobster/waybar/claude-lobster.sh",
  "return-type": "json",
  "interval": 300,
  "on-click": "alacritty -e /usr/local/bin/claude-lobster upgrade"
}
```

In `~/.config/waybar/style.css`:

```css
#custom-claude-lobster.update-available { color: @warning; }
#custom-claude-lobster.stale            { color: @warning; }
#custom-claude-lobster.not-installed    { color: @error; }
```

Then `omarchy-restart-waybar` (or `killall -SIGUSR2 waybar`).
