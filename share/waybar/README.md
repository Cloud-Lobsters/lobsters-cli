# Waybar module (Omarchy, Hyprland)

In `~/.config/waybar/config.jsonc`, add `"custom/claude-lobsters-cli"` to `modules-right` and:

```jsonc
"custom/claude-lobsters-cli": {
  "exec": "/usr/local/share/claude-lobsters-cli/waybar/claude-lobsters-cli.sh",
  "return-type": "json",
  "interval": 300,
  "on-click": "alacritty -e /usr/local/bin/claude-lobsters-cli upgrade"
}
```

In `~/.config/waybar/style.css`:

```css
#custom-claude-lobsters-cli.update-available { color: @warning; }
#custom-claude-lobsters-cli.stale            { color: @warning; }
#custom-claude-lobsters-cli.not-installed    { color: @error; }
```

Then `omarchy-restart-waybar` (or `killall -SIGUSR2 waybar`).
