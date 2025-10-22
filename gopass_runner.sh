#!/usr/bin/env bash
# gopass + walker menu for Hyprland/Omarchy
# - Caches last picked entry to avoid reselecting each time
# - Menu copies password immediately (gopass -c)
# - Actions: menu|pass|username|url|entry|qr|totp
# - Notifications via notify-send if available
# - Terminal for QR is taken from $TERMINAL

set -euo pipefail

need(){ command -v "$1" >/dev/null 2>&1 || { echo "Error: '$1' not found" >&2; exit 1; }; }
need gopass
need walker

HAS_NOTIFY=0; command -v notify-send >/dev/null 2>&1 && HAS_NOTIFY=1
HAS_QR=0;      command -v qrencode    >/dev/null 2>&1 && HAS_QR=1

notify(){ ((HAS_NOTIFY)) && notify-send "gopass" "$1" || printf '%s\n' "$1"; }

# State file for last selection
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gopass"
mkdir -p "$STATE_DIR"
LAST="$STATE_DIR/last_entry"

save_last(){ [[ -n "${1:-}" ]] && printf '%s' "$1" >"$LAST"; }

pick(){
  # List flat entries, pick with walker dmenu
  local sel
  sel="$(gopass list -f 2>/dev/null | sed 's|/$||' | sort | walker --dmenu || true)"
  [[ -n "$sel" ]] && save_last "$sel"
  printf '%s' "$sel"
}

get_sel(){
  # Resolve entry: arg > cached > pick
  local arg="${1:-}"
  if [[ -n "$arg" ]]; then printf '%s' "$arg"; return; fi
  if [[ -s "$LAST" ]]; then cat "$LAST"; return; fi
  pick
}

clip(){ # Copy secret or field via gopass clipboard (cliptimeout is configured in gopass)
  local e="$1" f="${2:-}"
  if [[ -n "$f" ]]; then
    gopass show -c -- "$e" "$f" >/dev/null 2>&1 && { notify "Copied '$f' for '$e'"; return 0; }
    notify "Field '$f' not found in '$e'"; return 1
  else
    gopass show -c -- "$e" >/dev/null 2>&1 && return 0
    notify "Failed to copy password for '$e'"; return 1
  fi
}

copy_entry(){
  # Copy full entry text via wl-copy
  need wl-copy
  gopass show -- "$1" | wl-copy && notify "Entry text copied for '$1'" || { notify "Read failed: '$1'"; return 1; }
}

qr_show(){
  # Render password as ANSI QR in $TERMINAL
  ((HAS_QR)) || { notify "qrencode not installed"; return 1; }
  : "${TERMINAL:?Error: \$TERMINAL is not set}"
  local e="$1" s
  s="$(gopass show -o -- "$e" | head -n1)" || { notify "Cannot read password"; return 1; }
  "$TERMINAL" -e bash -lc 'printf %s "$0" | qrencode -t ansiutf8; echo; read -n1 -s -p "[QR] Press any key to close"' "$s" || true
}

totp_clip(){
  # Copy TOTP using `gopass totp -c`
  gopass totp -c -- "$1" >/dev/null 2>&1 && notify "TOTP copied for '$1'" || { notify "No TOTP for '$1'"; return 1; }
}

act="${1:-menu}"

case "$act" in
  menu)
    sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0; clip "$sel"
    ;;
  pass|clipboard)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; clip "$sel"
    ;;
  username)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; clip "$sel" "username"
    ;;
  url)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; clip "$sel" "url"
    ;;
  entry)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; copy_entry "$sel"
    ;;
  qr)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; qr_show "$sel"
    ;;
  totp)
    sel="$(get_sel "${2:-}")"; [[ -z "${sel:-}" ]] && sel="$(pick)"; [[ -z "${sel:-}" ]] && exit 0
    save_last "$sel"; totp_clip "$sel"
    ;;
  *)
    echo "Usage: $0 [menu|pass|username|url|entry|qr|totp] [ENTRY]" >&2; exit 2
    ;;
esac


