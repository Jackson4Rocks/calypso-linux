#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DMS="$CFG/DankMaterialShell"
THEME="$DMS/themes/calypso-expressive.json"
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
  printf '%s\n' "$BG$GREEN$BOLD  │          CALYPSO · MATERIAL EXPRESSIVE             │  $RESET"
  printf '%s\n' "$BG$GREEN$BOLD  │              HYPRLAND DOTFILES                     │  $RESET"
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

step "Installing official packages..."
sudo pacman -S --needed   hyprland dms-shell dms-shell-hyprland kitty yazi zsh fastfetch   playerctl brightnessctl grim slurp wl-clipboard jq
ok "Dependency set installed"

step "Preparing a safe backup..."
backup "$CFG/hypr/hyprland.lua"
backup "$DMS/settings.json"
ok "Backup: $BACKUP"

mkdir -p "$CFG/hypr" "$DMS/themes" "$HOME/.local/bin" "$HOME/.local/share/calypso"

step "Installing Hyprland configuration..."
install -m 0644 "$ROOT/hypr/hyprland.lua" "$CFG/hypr/hyprland.lua"
ok "Hyprland profile installed"

step "Installing the Calypso Material 3 Expressive theme..."
install -m 0644 "$ROOT/dms/calypso-expressive.json" "$THEME"

if [[ -f "$DMS/settings.json" ]]; then
  tmp="$(mktemp)"
  jq --arg theme "$THEME"     '.currentThemeName="custom" | .customThemeFile=$theme'     "$DMS/settings.json" > "$tmp" || die "Existing DMS settings.json is invalid JSON; restore from $BACKUP"
  mv "$tmp" "$DMS/settings.json"
else
  cat > "$DMS/settings.json" <<EOF
{
  "currentThemeName": "custom",
  "customThemeFile": "$THEME"
}
EOF
fi
ok "DMS theme selected"

step "Installing the Calypso wallpaper..."
if [[ -f "$REPO/assets/calypso-hero.webp" ]]; then
  install -m 0644 "$REPO/assets/calypso-hero.webp" "$HOME/.local/share/calypso/CALYPSO-wallpaper.webp"
  ok "Bundled wallpaper installed"
else
  warn "Bundled wallpaper asset not found; existing wallpaper is left untouched"
fi

step "Installing the wallpaper helper..."
install -m 0755 "$ROOT/scripts/calypso-wallpaper" "$HOME/.local/bin/calypso-wallpaper"
ok "Wallpaper helper installed"

step "Running static validation..."
bash -n "$ROOT/scripts/install.sh"
bash -n "$ROOT/scripts/calypso-wallpaper"
jq empty "$ROOT/dms/calypso-expressive.json"
if command -v luac >/dev/null 2>&1; then
  luac -p "$ROOT/hypr/hyprland.lua"
  ok "Bash, JSON and Lua checks passed"
else
  warn "Lua parser not installed; Bash and JSON checks passed"
fi

if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  step "Reloading Hyprland..."
  if hyprctl reload >/dev/null 2>&1; then
    ok "Hyprland accepted the configuration"
  else
    warn "Hyprland rejected the new configuration; restoring the previous file"
    [[ -f "$BACKUP/.config/hypr/hyprland.lua" ]] && install -m 0644 "$BACKUP/.config/hypr/hyprland.lua" "$CFG/hypr/hyprland.lua"
    hyprctl reload >/dev/null 2>&1 || true
    die "Hyprland reload failed; see $LOG"
  fi
fi

if command -v dms >/dev/null 2>&1 && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  step "Smoke-testing DankMaterialShell..."
  dms kill >/dev/null 2>&1 || true
  sleep 1
  dms run -d >/dev/null 2>&1 || true
  sleep 3
  if dms ipc list >/dev/null 2>&1; then
    ok "DMS started and answered IPC"
  else
    warn "DMS did not answer IPC; run 'dms run' to inspect its error output"
  fi
else
  warn "No active Wayland/DMS session; live shell test skipped"
fi

if command -v dms >/dev/null 2>&1; then
  step "Running DMS diagnostics..."
  doctor_json="$(dms doctor -j 2>/dev/null || true)"
  if [[ -n "$doctor_json" ]] && jq -e '.summary.errors == 0' >/dev/null 2>&1 <<<"$doctor_json"; then
    ok "DMS doctor reports zero critical errors"
  else
    warn "DMS doctor reported errors or returned no JSON; inspect with 'dms doctor -v'"
  fi
fi

printf '\n%s%sCalypso Material Expressive is installed.%s\n' "$GREEN" "$BOLD" "$RESET"
printf '%sShell:%s DankMaterialShell\n' "$DIM" "$RESET"
printf '%sTheme:%s Calypso Emerald Expressive\n' "$DIM" "$RESET"
printf '%sBackup:%s %s\n' "$DIM" "$RESET" "$BACKUP"
printf '%sLog:%s %s\n\n' "$DIM" "$RESET" "$LOG"
