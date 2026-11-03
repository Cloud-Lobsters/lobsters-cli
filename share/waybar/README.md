# Waybar module (Omarchy, Hyprland)

In `~/.config/waybar/config.jsonc`, add `"custom/lobsters-cli"` to `modules-right` and:

```jsonc
"custom/lobsters-cli": {
  "exec": "/usr/local/share/lobsters-cli/waybar/lobsters-cli.sh",
  "return-type": "json",
  "interval": 300,
  "signal": 8,
  "on-click": "/usr/local/share/lobsters-cli/waybar/lobsters-cli.sh sync",
  "on-click-right": "alacritty -e /usr/local/bin/lobsters-cli upgrade"
}
```

A click pulls the team rules now (`lobsters-cli sync --notify`): the result comes as a
notification and the module redraws at once, through `signal` 8 (change both the config and
`SIGNAL` in the script if 8 is taken). A right-click opens `lobsters-cli upgrade` in a terminal.

In `~/.config/waybar/style.css`:

```css
#custom-lobsters-cli.update-available { color: @warning; }
#custom-lobsters-cli.stale            { color: @warning; }
#custom-lobsters-cli.not-installed    { color: @error; }
```

Then `omarchy-restart-waybar` (or `killall -SIGUSR2 waybar`).
