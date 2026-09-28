# Calypso Linux — Material Expressive Hyprland

This directory contains the optional Hyprland profile for Calypso Linux.

**KDE Plasma remains the main Calypso desktop.** This profile is for users who want a tiling, keyboard-driven Wayland workflow.

The keybindings in this profile are Hyprland-only. When KDE Plasma is running, there is no active Hyprland instance, so `hyprctl` cannot inspect or control the compositor and these `SUPER`/`ALT` bindings are not present. KDE's own shortcut system remains in control.

## Shell choice

The profile uses **Noctalia** as the desktop shell.

Noctalia is an independent Wayland shell. Calypso only ships configuration, theming, and integration files for it; Noctalia's source is not copied into this repository.

The profile stays focused on a small stack:

- Hyprland
- Noctalia
- Kitty
- Yazi
- Zsh
- Fastfetch
- Playerctl
- Brightnessctl
- Grim + Slurp + wl-clipboard

## Material 3 Expressive

Calypso ships a custom **Emerald** Noctalia palette at:

    noctalia/palettes/CalypsoEmerald.json

It uses Material 3-style surface roles, emerald primary/secondary accents, expressive rounded surfaces, and a dark-first visual direction.

The configuration lives at:

    noctalia/config.toml

The palette is selected as:

    source = "custom"
    custom_palette = "CalypsoEmerald"

## Lock screen

The Noctalia lock screen is configured to match the Calypso website's visual language:

- dark emerald background
- blurred/tinted wallpaper
- large centered digital clock
- Calypso wordmark-style title
- subtle secondary text
- rounded authentication UI supplied by Noctalia
- smooth fade/wipe transitions

The lock-screen widgets are declared in [lockscreen_widgets].

## Installation

From the repository root:

    cd dotfiles
    bash scripts/install.sh

The installer:

1. installs the Arch packages required for the profile
2. backs up existing Hyprland and Noctalia configuration
3. installs the Calypso Hyprland profile
4. installs the Calypso Material 3 palette
5. installs the Noctalia configuration and lock screen
6. installs the bundled Calypso wallpaper
7. runs Bash, JSON, Lua, and Noctalia configuration validation
8. reloads Hyprland when running inside Hyprland
9. smoke-tests Noctalia under Wayland when a graphical session is available

To verify the profile later:

    bash scripts/verify.sh

## Uninstallation

To remove the Calypso configuration without uninstalling system packages:

    bash scripts/uninstall.sh

The uninstaller stops Noctalia, restores the newest backup created by the installer when one exists, removes Calypso helper commands and the bundled wallpaper copy, and leaves Hyprland/Noctalia packages and KDE Plasma configuration installed. Backups are kept under `~/.local/state/calypso-dotfiles/backup/`.

## Useful keybindings

| Key | Action |
| --- | --- |
| **SUPER + Enter** | Open terminal |
| **SUPER + B** | Open Firefox |
| **SUPER + E** | Open Dolphin |
| **SUPER + Space** | Open Noctalia launcher |
| **SUPER + S** | Open Control Center |
| **SUPER + V** | Clipboard history |
| **SUPER + W** | Wallpaper picker |
| **SUPER + X** | Session menu |
| **SUPER + ,** | Noctalia settings |
| **ALT + Tab** | Noctalia window switcher |
| **SUPER + F** | Toggle fullscreen |
| **RMB + drag** | Move the active window |
| **SUPER + Tab** | Cycle windows |
| **SUPER + 1…0** | Switch workspace |
| **SUPER + Shift + 1…0** | Move window to workspace |
| **SUPER + Shift + R** | Reload Noctalia configuration |
| **Print** | Noctalia screenshot region |
| **SUPER + Print** | Noctalia screenshot full screen |

## Wallpaper

The Calypso wallpaper collection is installed to:

    ~/.local/share/calypso/wallpapers/

It is curated from Enderman's public wallpaper directory and includes a mix of astronomy, forests, mountains, night skies, and darker scenic wallpapers. The collection is downloaded during installation from:

    https://files.enderman.ch/wallpapers/

The bundled Calypso wallpaper remains available at:

    ~/.local/share/calypso/CALYPSO-wallpaper.webp

Use the helper to set any image:

    calypso-wallpaper /path/to/image.webp

With no argument, it restores the bundled Calypso wallpaper.

## Stability notes

Workspace switching is handled directly by Hyprland's native workspace dispatcher instead of depending on shell state. Noctalia is only responsible for the surrounding desktop UI.

The installer does **not** replace or remove the KDE Plasma desktop configuration.
