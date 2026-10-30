# Waybar module (Omarchy, Hyprland)

In `~/.config/waybar/config.jsonc`, add `"custom/lobsters-cli"` to `modules-right` and:

```jsonc
"custom/lobsters-cli": {
  "exec": "/usr/local/share/lobsters-cli/waybar/lobsters-cli.sh",
  "return-type": "json",
  "interval": 300,
  "on-click": "alacritty -e /usr/local/bin/lobsters-cli upgrade"
}
```

In `~/.config/waybar/style.css`:

```css
#custom-lobsters-cli.update-available { color: @warning; }
#custom-lobsters-cli.stale            { color: @warning; }
#custom-lobsters-cli.not-installed    { color: @error; }
```

Then `omarchy-restart-waybar` (or `killall -SIGUSR2 waybar`).
