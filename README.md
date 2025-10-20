# Gopass Runner for Wayland (Hyprland)

Minimal gopass integration using `walker` as dmenu. Caches your last selection. Actions are executed via a single script.

## Overview

- Select entry via `walker`
- Cache last selected entry (no re-picking every time)
- Copy password (`gopass -c`)
- Copy username field
- Copy URL field
- Copy full entry text
- Generate TOTP (`gopass totp`)
- Show entry as QR (`qrencode`)

## File Layout

```
~/.config/gopass/scripts/
├── gopass_runner.sh   # main command handler
└── gopass_menu.sh     # action menu
```

## Requirements

| Tool         | Purpose                |
|--------------|------------------------|
| gopass       | password backend       |
| walker       | Wayland dmenu          |
| wl-clipboard | clipboard backend      |
| notify-send  | notifications (opt)    |
| qrencode     | QR display (opt)       |

Terminal variable (required for QR):
```bash
export TERMINAL=footclient  # or kitty, alacritty, etc.
```

## Usage

Copy password via cached menu:
```bash
~/.config/gopass/scripts/gopass_runner.sh menu
```

Run full action menu:
```bash
~/.config/gopass/scripts/gopass_menu.sh
```

Available actions:
| Action   | Description           |
|----------|-----------------------|
| pass     | copy password         |
| username | copy login field      |
| url      | copy URL              |
| entry    | copy whole entry text |
| totp     | copy 2FA code         |
| qr       | show QR code          |

## Hyprland Keybinds

```ini
bind = SUPER, backslash, exec, ~/.config/gopass/scripts/gopass_runner.sh menu
bind = SUPER SHIFT, backslash, exec, ~/.config/gopass/scripts/gopass_menu.sh
```

## Cache

Last picked entry:
```
~/.local/state/gopass/last_entry
```

## Install

```bash
mkdir -p ~/.config/gopass/scripts
cp gopass_runner.sh ~/.config/gopass/scripts/
cp gopass_menu.sh ~/.config/gopass/scripts/
chmod +x ~/.config/gopass/scripts/*.sh
```

Optional clipboard timeout:
```bash
gopass config cliptimeout 45
```

## Security

QR and full-entry actions expose sensitive data. Use with care.

## License

MIT
