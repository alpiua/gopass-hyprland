#!/bin/bash  
choice=$(echo -e "TOTP\nQR\nURL\nEntry\nUsername\nPass" | walker --dmenu -p "Gopass…")  
  
case "$choice" in  
  "TOTP") $HOME/.config/gopass/scripts/gopass_runner.sh totp ;;  
  "URL") $HOME/.config/gopass/scripts/gopass_runner.sh url ;;  
  "QR") $HOME/.config/gopass/scripts/gopass_runner.sh qr ;;  
  "Username") $HOME/.config/gopass/scripts/gopass_runner.sh username ;;  
  "Entry") $HOME/.config/gopass/scripts/gopass_runner.sh entry ;;  
  "Pass") $HOME/.config/gopass/scripts/gopass_runner.sh pass ;;  
esac
