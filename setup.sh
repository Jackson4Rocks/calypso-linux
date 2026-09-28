#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="${ROOT_DIR}/iso"
SKEL="${ISO_DIR}/airootfs/etc/skel"
PROFILE_PACKAGES=(
  hyprland
  noctalia
  kitty
  dolphin
  firefox
  zsh
  fastfetch
  playerctl
  brightnessctl
  grim
  slurp
  wl-clipboard
  jq
  curl
  xdg-desktop-portal
  xdg-desktop-portal-hyprland
  pipewire
  wireplumber
  polkit
  polkit-gnome
  power-profiles-daemon
  upower
  xorg-xwayland
  networkmanager
)

usage() {
  cat <<'EOF'
Usage: bash setup.sh [--system|--stage-iso]

  --system      Install the complete Calypso Hyprland/Noctalia dependency
                set on the current Arch-based system, then install dotfiles.
  --stage-iso   Copy the current Calypso Hyprland/Noctalia profile into the
                ISO skeleton and verify the ISO dependency manifest.

With no argument, --system is used.
EOF
}

die() {
  printf 'setup.sh: %s\n' "$*" >&2
  exit 1
}

install_system() {
  command -v pacman >/dev/null 2>&1 || die "pacman is required."
  command -v sudo >/dev/null 2>&1 || die "sudo is required."

  sudo pacman -S --needed "${PROFILE_PACKAGES[@]}"

  CALYPSO_SKIP_PACKAGES=1 bash "${ROOT_DIR}/dotfiles/scripts/install.sh"
}

stage_iso() {
  [[ -f "${ISO_DIR}/packages.x86_64" ]] || die "ISO package manifest is missing."

  mkdir -p     "${SKEL}/.config/hypr"     "${SKEL}/.config/noctalia/palettes"     "${SKEL}/.local/bin"     "${ISO_DIR}/airootfs/usr/share/calypso"

  install -m 0644 "${ROOT_DIR}/dotfiles/hypr/hyprland.lua"     "${SKEL}/.config/hypr/hyprland.lua"
  install -m 0644 "${ROOT_DIR}/dotfiles/noctalia/config.toml"     "${SKEL}/.config/noctalia/config.toml"
  install -m 0644 "${ROOT_DIR}/dotfiles/noctalia/palettes/CalypsoEmerald.json"     "${SKEL}/.config/noctalia/palettes/CalypsoEmerald.json"
  install -m 0755 "${ROOT_DIR}/dotfiles/scripts/calypso-wallpaper"     "${SKEL}/.local/bin/calypso-wallpaper"
  install -m 0755 "${ROOT_DIR}/dotfiles/scripts/calypso-close-active"     "${SKEL}/.local/bin/calypso-close-active"
  install -m 0644 "${ROOT_DIR}/dotfiles/wallpapers/enderman-curated.txt"     "${ISO_DIR}/airootfs/usr/share/calypso/enderman-wallpapers.txt"

  # The full installed OS owns the stock collection system-wide.
  # Keep the user dotfiles path for normal manual installs, but point the
  # ISO-installed Noctalia profile at the system stock wallpaper directory.
  sed -i     's#directory = "~/.local/share/calypso/wallpapers"#directory = "/usr/share/backgrounds/calypso/stock"#'     "${SKEL}/.config/noctalia/config.toml"
  sed -i     's#directory_dark = "~/.local/share/calypso/wallpapers"#directory_dark = "/usr/share/backgrounds/calypso/stock"#'     "${SKEL}/.config/noctalia/config.toml"
  sed -i     's#directory_light = "~/.local/share/calypso/wallpapers"#directory_light = "/usr/share/backgrounds/calypso/stock"#'     "${SKEL}/.config/noctalia/config.toml"

  for package in "${PROFILE_PACKAGES[@]}"; do
    grep -qxF "${package}" "${ISO_DIR}/packages.x86_64" ||       die "ISO package manifest is missing: ${package}"
  done

  bash -n "${ROOT_DIR}/dotfiles/scripts/install.sh"
  bash -n "${ROOT_DIR}/dotfiles/scripts/uninstall.sh"
  bash -n "${ROOT_DIR}/dotfiles/scripts/calypso-wallpaper"
  bash -n "${ROOT_DIR}/dotfiles/scripts/calypso-close-active"

  if command -v luac >/dev/null 2>&1; then
    luac -p "${ROOT_DIR}/dotfiles/hypr/hyprland.lua"
  fi

  printf 'Calypso ISO setup staged successfully.\n'
  printf '  Hyprland: %s\n' "${SKEL}/.config/hypr/hyprland.lua"
  printf '  Noctalia: %s\n' "${SKEL}/.config/noctalia/config.toml"
  printf '  Wallpapers manifest: %s\n' "${ISO_DIR}/airootfs/usr/share/calypso/enderman-wallpapers.txt"
}

case "${1:---system}" in
  --system)
    install_system
    ;;
  --stage-iso)
    stage_iso
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
