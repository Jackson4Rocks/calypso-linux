#!/bin/bash
set -euo pipefail

echo "==> Configuring Calypso Linux live environment..."

install -d -m 0755 /etc/sudoers.d /etc/sddm.conf.d /usr/share/backgrounds/calypso /usr/share/calypso
install -d -m 0755 /usr/local/bin /usr/share/applications
install -d -m 0755 /usr/share/icons/hicolor/scalable/apps

cat > /usr/lib/os-release <<'EOF_OS'
NAME="Calypso Linux"
ID=calypso
ID_LIKE=arch
PRETTY_NAME="Calypso Linux"
VERSION="0.2"
VERSION_ID="0.2"
HOME_URL="https://github.com/Jackson4Rocks/calypso-linux"
SUPPORT_URL="https://github.com/Jackson4Rocks/calypso-linux/issues"
BUG_REPORT_URL="https://github.com/Jackson4Rocks/calypso-linux/issues"
EOF_OS
rm -f /etc/os-release
ln -s ../usr/lib/os-release /etc/os-release

echo "==> Creating the Calypso live user..."
if ! id -u calypso >/dev/null 2>&1; then
    useradd --create-home --shell /usr/bin/zsh --groups wheel calypso
fi
usermod --shell /usr/bin/zsh calypso
usermod --append --groups wheel calypso
install -d -m 0755 -o calypso -g calypso /home/calypso

cat > /etc/sudoers.d/calypso <<'EOF_SUDO'
calypso ALL=(ALL) NOPASSWD: ALL
EOF_SUDO
chmod 0440 /etc/sudoers.d/calypso

cp -a /etc/skel/. /home/calypso/

# Start the live desktop in KDE's dark visual mode.
install -d -m 0700 /home/calypso/.config
cat > /home/calypso/.config/kdeglobals <<'EOF_KDEGLOBALS'
[General]
ColorScheme=BreezeDark

[KDE]
LookAndFeelPackage=org.kde.breeze.desktop
EOF_KDEGLOBALS
install -d -m 0755 /home/calypso/.config/systemd/user/default.target.wants

if [ -f /etc/skel/.config/systemd/user/calypso-live-welcome.service ]; then
    install -m 0644 /etc/skel/.config/systemd/user/calypso-live-welcome.service         /home/calypso/.config/systemd/user/calypso-live-welcome.service
    ln -sf ../calypso-live-welcome.service         /home/calypso/.config/systemd/user/default.target.wants/calypso-live-welcome.service
fi

if [ -f /etc/skel/.local/share/calypso/wallpapers/Calypso-Default.svg ]; then
    install -d -m 0755 /usr/share/backgrounds/calypso
    install -m 0644 /etc/skel/.local/share/calypso/wallpapers/Calypso-Default.svg         /usr/share/backgrounds/calypso/Calypso-Default.svg
fi

rm -f /etc/sddm.conf.d/calypso.conf
cat > /etc/sddm.conf.d/calypso-live.conf <<'EOF_SDDM'
[General]
DisplayServer=wayland

[Autologin]
User=calypso
Session=plasma.desktop
Relogin=false
EOF_SDDM
chmod 0644 /etc/sddm.conf.d/calypso-live.conf

systemctl enable calypso-wallpapers.service 2>/dev/null || true
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl enable sddm.service 2>/dev/null || true
systemctl enable power-profiles-daemon.service 2>/dev/null || true

if [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
    cat > /etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop <<'EOF_POLKIT'
[Desktop Entry]
Name=Polkit Authentication Agent
Comment=Authentication Agent
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
Terminal=false
Type=Application
NoDisplay=true
X-GNOME-Autostart-Phase=Initialization
EOF_POLKIT
fi

chmod 0755 /usr/local/bin/calypso-calamares 2>/dev/null || true
chmod 0755 /usr/local/bin/calypso-live-welcome 2>/dev/null || true
chmod 0644 /usr/share/applications/calypso-installer.desktop 2>/dev/null || true

cat > /home/calypso/.profile <<'EOF_PROFILE'
export CALYPSO_NAME="Calypso Linux"
export CALYPSO_DESKTOP="KDE Plasma"
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland,x11
export SDL_VIDEODRIVER=wayland
export MOZ_ENABLE_WAYLAND=1
EOF_PROFILE

cat > /home/calypso/.zshenv <<'EOF_ZSHENV'
export CALYPSO_NAME="Calypso Linux"
export CALYPSO_DESKTOP="KDE Plasma"
EOF_ZSHENV

if [ -f /etc/skel/.local/share/calypso/calypso-mark.svg ]; then
    install -m 0644 /etc/skel/.local/share/calypso/calypso-mark.svg         /usr/share/icons/hicolor/scalable/apps/calypso-linux.svg
fi

printf 'Calamares : %s
' "$(command -v calamares >/dev/null 2>&1 && echo installed || echo missing)"
test -f /etc/calamares/settings.conf
test -f /etc/calamares/branding/calypso/branding.desc
test -x /usr/local/bin/calypso-calamares

chown -R calypso:calypso /home/calypso
chmod 0755 /home/calypso
chmod 0700 /home/calypso/.config 2>/dev/null || true

echo "Calypso live environment ready."
