#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
NOCTALIA="$CFG/noctalia"
NOCTALIA_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/noctalia"
BACKUP="$HOME/.local/state/calypso-dotfiles/backup/$(date +%Y%m%d-%H%M%S)"
LOG="$HOME/.local/state/calypso-dotfiles/logs/install-$(date +%Y%m%d-%H%M%S).log"

BG=$'\033[48;2;3;12;8m'
GREEN=$'\033[38;2;143;245;199m'
SOFT=$'\033[38;2;190;216;203m'
DIM=$'\033[38;2;104;137;121m'
RED=$'\033[38;2;255;180;171m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

mkdir -p "$BACKUP" "$(dirname "$LOG")"
exec > >(tee -a "$LOG") 2>&1

banner() {
  printf '\n%s\n' "$BG$GREEN$BOLD  ╭──────────────────────────────────────────────────────╮  $RESET"
  printf '%s\n' "$BG$GREEN$BOLD  │            CALYPSO · NOCTALIA                     │  $RESET"
  printf '%s\n' "$BG$GREEN$BOLD  │          MATERIAL 3 EXPRESSIVE                    │  $RESET"
  printf '%s\n\n' "$BG$GREEN$BOLD  ╰──────────────────────────────────────────────────────╯  $RESET"
}
step(){ printf '%s◆%s %s\n' "$GREEN" "$RESET" "$1"; }
ok(){ printf '%s  ✓%s %s\n' "$GREEN" "$RESET" "$1"; }
warn(){ printf '%s  !%s %s\n' "$SOFT" "$RESET" "$1"; }
die(){ printf '%s  ✕ %s%s\n' "$RED" "$1" "$RESET" >&2; exit 1; }

backup() {
  local file="$1"
  [[ -e "$file" ]] || return 0
  local rel="${file#$HOME/}"
  mkdir -p "$BACKUP/$(dirname "$rel")"
  cp -a "$file" "$BACKUP/$rel"
  ok "Backed up ~/$rel"
}

banner

step "Checking the environment..."
[[ "$(uname -s)" == "Linux" ]] || die "Linux is required."
command -v pacman >/dev/null 2>&1 || die "This installer targets Arch-based systems with pacman."
command -v sudo >/dev/null 2>&1 || die "sudo is required."
ok "Arch package manager detected"

step "Installing the Hyprland + Noctalia stack..."
sudo pacman -S --needed   hyprland noctalia kitty yazi dolphin zsh fastfetch   playerctl brightnessctl grim slurp wl-clipboard jq curl
ok "Official packages are ready"

command -v noctalia >/dev/null 2>&1 || die "Noctalia was not installed successfully."

step "Preparing a safe backup..."
backup "$CFG/hypr/hyprland.lua"
backup "$NOCTALIA/config.toml"
backup "$NOCTALIA/palettes/CalypsoEmerald.json"
backup "$NOCTALIA_STATE/settings.toml"
ok "Backup: $BACKUP"

mkdir -p   "$CFG/hypr"   "$NOCTALIA/palettes"   "$NOCTALIA_STATE"   "$HOME/.local/bin"   "$HOME/.local/share/calypso"

step "Installing Calypso Hyprland configuration..."
install -m 0644 "$ROOT/hypr/hyprland.lua" "$CFG/hypr/hyprland.lua"
ok "Hyprland profile installed"

step "Installing the Calypso Material 3 palette..."
install -m 0644 "$ROOT/noctalia/palettes/CalypsoEmerald.json"   "$NOCTALIA/palettes/CalypsoEmerald.json"
ok "Emerald palette installed"

step "Installing the Noctalia configuration..."
install -m 0644 "$ROOT/noctalia/config.toml" "$NOCTALIA/config.toml"
ok "Noctalia configuration installed"

step "Installing the Calypso wallpaper collection..."
mkdir -p "$HOME/.local/share/calypso/wallpapers"
if [[ -f "$REPO/assets/calypso-hero.webp" ]]; then
  install -m 0644 "$REPO/assets/calypso-hero.webp" "$HOME/.local/share/calypso/CALYPSO-wallpaper.webp"
  ok "Bundled Calypso wallpaper installed"
else
  warn "Bundled Calypso wallpaper asset not found; keeping the collection only"
fi

WALLPAPER_DIR="$HOME/.local/share/calypso/wallpapers"
WALLPAPER_LIST="$ROOT/wallpapers/enderman-curated.txt"
BASE_URL="https://files.enderman.ch/wallpapers"

while IFS= read -r wallpaper || [[ -n "$wallpaper" ]]; do
  [[ -z "$wallpaper" || "$wallpaper" == \#* ]] && continue
  encoded="${wallpaper// /%20}"
  target="$WALLPAPER_DIR/$wallpaper"
  if [[ -s "$target" ]]; then
    continue
  fi
  if curl -fL --retry 3 --connect-timeout 10 --silent --show-error "$BASE_URL/$encoded" -o "$target"; then
    ok "Downloaded $wallpaper"
  else
    rm -f "$target"
    warn "Could not download $wallpaper; continuing without it"
  fi
done < "$WALLPAPER_LIST"

step "Installing the wallpaper helper..."
install -m 0755 "$ROOT/scripts/calypso-wallpaper" "$HOME/.local/bin/calypso-wallpaper"
install -m 0755 "$ROOT/scripts/calypso-close-active" "$HOME/.local/bin/calypso-close-active"
ok "Wallpaper helper installed"

step "Running local validation..."
bash -n "$ROOT/scripts/install.sh"
bash -n "$ROOT/scripts/calypso-wallpaper"
bash -n "$ROOT/scripts/calypso-close-active"
[[ -f "$ROOT/wallpapers/enderman-curated.txt" ]]
jq empty "$ROOT/noctalia/palettes/CalypsoEmerald.json"

if command -v luac >/dev/null 2>&1; then
  luac -p "$ROOT/hypr/hyprland.lua"
  ok "Bash, JSON and Lua checks passed"
else
  warn "Lua parser not installed; Bash and JSON checks passed"
fi

if command -v noctalia >/dev/null 2>&1; then
  if noctalia config validate "$NOCTALIA/config.toml"; then
    ok "Noctalia accepted the Calypso configuration"
  else
    die "Noctalia rejected the configuration; see $LOG"
  fi
fi

if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  step "Reloading Hyprland..."
  if hyprctl reload >/dev/null 2>&1; then
    ok "Hyprland accepted the configuration"
  else
    warn "Hyprland rejected the new configuration; restoring the previous file"
    [[ -f "$BACKUP/.config/hypr/hyprland.lua" ]] &&       install -m 0644 "$BACKUP/.config/hypr/hyprland.lua" "$CFG/hypr/hyprland.lua"
    hyprctl reload >/dev/null 2>&1 || true
    die "Hyprland reload failed; see $LOG"
  fi
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v noctalia >/dev/null 2>&1; then
  step "Restarting Noctalia and checking its IPC..."
  pkill -x noctalia >/dev/null 2>&1 || true
  sleep 1
  noctalia >/tmp/calypso-noctalia.log 2>&1 &
  NOCTALIA_PID=$!
  sleep 4
  if kill -0 "$NOCTALIA_PID" >/dev/null 2>&1 && noctalia msg --help >/dev/null 2>&1; then
    ok "Noctalia started and its IPC endpoint is available"
  else
    warn "Noctalia did not stay alive; inspect /tmp/calypso-noctalia.log"
  fi
else
  warn "No active Hyprland session; live Noctalia smoke test skipped"
fi

printf '\n%s%sCalypso Noctalia setup is installed.%s\n' "$GREEN" "$BOLD" "$RESET"
printf '%sShell:%s Noctalia\n' "$DIM" "$RESET"
printf '%sTheme:%s Calypso Emerald · Material 3 Expressive\n' "$DIM" "$RESET"
printf '%sLock screen:%s Material-style blurred wallpaper + centered clock/login layout\n' "$DIM" "$RESET"
printf '%sBackup:%s %s\n' "$DIM" "$RESET" "$BACKUP"
printf '%sLog:%s %s\n\n' "$DIM" "$RESET" "$LOG"
