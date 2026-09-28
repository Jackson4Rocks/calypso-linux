# Calypso Linux — Material Expressive Hyprland

This directory contains the optional Hyprland profile for Calypso Linux.

**KDE Plasma remains the main Calypso desktop.** This profile is for users who want a tiling, keyboard-driven Wayland workflow.

## Shell choice

The profile uses **DankMaterialShell (DMS)** instead of a hand-rolled Quickshell shell.

That choice is deliberate: DMS is a mature Quickshell-based desktop shell with native Hyprland integration and a Material 3 design system. Calypso supplies its own **Emerald Expressive** theme on top.

The profile stays focused on a small, understandable stack:

- Hyprland
- DankMaterialShell
- Kitty
- Yazi
- Zsh
- Fastfetch
- Playerctl
- Brightnessctl
- Grim + Slurp + wl-clipboard

## Material 3 Expressive

The DMS theme lives at:

    dms/calypso-expressive.json

The design uses dark emerald surfaces, layered containers, high-contrast mint accents, and the Material 3 expressive color-scheme mode.

The installer backs up an existing DMS settings file before selecting the Calypso theme.

## Installation

From the repository root:

    cd dotfiles
    bash scripts/install.sh

The installer:

1. installs the required Arch packages
2. backs up existing Hyprland/DMS configuration
3. installs the Hyprland profile
4. installs the Calypso DMS theme
5. installs the bundled Calypso wallpaper
6. runs Bash, JSON and Lua checks where the required parsers exist
7. reloads Hyprland when running inside Hyprland
8. smoke-tests DMS IPC when a Wayland session is available

To verify the profile later:

    bash scripts/verify.sh

## Useful keybindings

| Key | Action |
| --- | --- |
| **SUPER + Enter** | Open terminal |
| **SUPER + E** | Open Yazi in Kitty |
| **SUPER + Space** | Open DMS launcher |
| **SUPER + V** | Clipboard history |
| **SUPER + N** | Notifications |
| **SUPER + C** | Quick settings |
| **SUPER + X** | Power menu |
| **SUPER + ,** | DMS settings |
| **SUPER + Shift + K** | Show keybindings |
| **SUPER + F** | Toggle fullscreen |
| **SUPER + Tab** | Cycle windows |
| **SUPER + 1…0** | Switch workspace |
| **SUPER + Shift + 1…0** | Move window to workspace |
| **SUPER + Shift + R** | Reload Hyprland |
| **Print** | Region screenshot |
| **SUPER + Print** | Full-screen screenshot |

## Wallpaper

The bundled wallpaper is installed to:

    ~/.local/share/calypso/CALYPSO-wallpaper.webp

Use the helper to set another image:

    calypso-wallpaper /path/to/image.webp

With no argument, it restores the bundled Calypso wallpaper.

## Stability notes

The profile starts DMS from Hyprland itself with:

    dms run -d

That keeps the optional shell tied to the Hyprland session rather than enabling a global user service that could also start while you are using KDE Plasma.

The installer does **not** replace or remove the KDE Plasma desktop configuration.
