#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_ROOT="$STATE_HOME/calypso-dotfiles/backup"
NOCTALIA_STATE="$STATE_HOME/noctalia"

GREEN=$'\033[38;2;143;245;199m'
SOFT=$'\033[38;2;190;216;203m'
RED=$'\033[38;2;255;180;171m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

log(){ printf "%s◆%s %s\n" "$GREEN" "$RESET" "$1"; }
ok(){ printf "%s  ✓%s %s\n" "$GREEN" "$RESET" "$1"; }
warn(){ printf "%s  !%s %s\n" "$SOFT" "$RESET" "$1"; }
die(){ printf "%s  ✕ %s%s\n" "$RED" "$1" "$RESET" >&2; exit 1; }

[[ "$(uname -s)" == "Linux" ]] || die "Linux is required."

printf "\n%s%sCalypso Linux · Noctalia uninstall%s\n\n" "$GREEN" "$BOLD" "$RESET"
printf "This removes only the Calypso Hyprland/Noctalia configuration.\n"
printf "It does NOT uninstall Hyprland, Noctalia, Kitty, or other packages.\n\n"

find_latest_backup() {
  [[ -d "$BACKUP_ROOT" ]] || return 1
  find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf "%T@ %p\n" 2>/dev/null |
    sort -nr | head -n1 | cut -d" " -f2-
}

LATEST_BACKUP="$(find_latest_backup || true)"

if [[ "${1:-}" != "--yes" && "${1:-}" != "-y" ]]; then
  read -r -p "Continue? [y/N] " answer
  [[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]] || {
    printf "Cancelled.\n"
    exit 0
  }
fi

log "Stopping the Calypso shell process if it is running..."
if command -v pkill >/dev/null 2>&1; then
  pkill -x noctalia >/dev/null 2>&1 || true
fi
ok "Noctalia stop requested"

restore_or_remove() {
  local target="$1"
  local backup_rel="${target#$HOME/}"
  if [[ -n "$LATEST_BACKUP" && -e "$LATEST_BACKUP/$backup_rel" ]]; then
    mkdir -p "$(dirname "$target")"
    rm -rf "$target"
    cp -a "$LATEST_BACKUP/$backup_rel" "$target"
    ok "Restored ~/$backup_rel from latest backup"
  elif [[ -e "$target" || -L "$target" ]]; then
    rm -rf "$target"
    ok "Removed ~/$backup_rel"
  fi
}

log "Restoring or removing Calypso configuration..."
restore_or_remove "$CFG/hypr/hyprland.lua"
restore_or_remove "$CFG/noctalia/config.toml"
restore_or_remove "$CFG/noctalia/palettes/CalypsoEmerald.json"
restore_or_remove "$NOCTALIA_STATE/settings.toml"
restore_or_remove "$NOCTALIA_STATE/state.toml"

log "Removing Calypso helper commands..."
rm -f "$HOME/.local/bin/calypso-wallpaper" "$HOME/.local/bin/calypso-close-active"
ok "Calypso helper commands removed"

log "Removing the bundled Calypso wallpaper copy..."
rm -f "$HOME/.local/share/calypso/CALYPSO-wallpaper.webp"
rmdir "$HOME/.local/share/calypso" 2>/dev/null || true
ok "Bundled Calypso wallpaper removed when present"

if [[ -d "$BACKUP_ROOT" ]]; then
  printf "\nBackups were kept at:\n  %s\n" "$BACKUP_ROOT"
fi

printf "\n%s%sCalypso configuration uninstall complete.%s\n" "$GREEN" "$BOLD" "$RESET"
printf "Your system packages and KDE Plasma configuration were left untouched.\n"
printf "Start your normal session again, or launch your preferred shell manually.\n\n"