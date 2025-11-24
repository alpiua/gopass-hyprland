#!/usr/bin/env bash
set -e

LEN=24

pw=$(LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+' </dev/urandom | head -c "$LEN")
printf '%s' "$pw" | wl-copy
notify-send 'Gopass PWGEN' "Password ($LEN chars) generated and copied to clipboard"

