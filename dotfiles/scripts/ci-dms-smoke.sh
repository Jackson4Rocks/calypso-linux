#!/usr/bin/env bash
set -euo pipefail

ROOT="/repo"
export HOME="/tmp/calypso-dms-home"
export XDG_RUNTIME_DIR="/tmp/xdg-runtime"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export DMS_DISABLE_MATUGEN=1

mkdir -p   "$XDG_RUNTIME_DIR"   "$XDG_CONFIG_HOME/DankMaterialShell/themes"   "$XDG_CACHE_HOME"   "$XDG_STATE_HOME"
chmod 700 "$XDG_RUNTIME_DIR"

cp "$ROOT/dotfiles/dms/calypso-expressive.json"   "$XDG_CONFIG_HOME/DankMaterialShell/themes/calypso-expressive.json"

cat > "$XDG_CONFIG_HOME/DankMaterialShell/settings.json" <<EOF
{
  "currentThemeName": "calypso-expressive",
  "customThemeFile": "$XDG_CONFIG_HOME/DankMaterialShell/themes/calypso-expressive.json",
  "matugenScheme": "scheme-expressive"
}
EOF

dbus-run-session -- bash -s <<'INNER'
set -euo pipefail

weston   --backend=headless-backend.so   --socket=wayland-calypso   --idle-time=0   >/tmp/weston.log 2>&1 &
WESTON_PID=$!
cleanup() {
  kill "$WESTON_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for _ in $(seq 1 30); do
  if [[ -S "$XDG_RUNTIME_DIR/wayland-calypso" ]]; then
    break
  fi
  sleep 0.5
done

[[ -S "$XDG_RUNTIME_DIR/wayland-calypso" ]] || {
  cat /tmp/weston.log
  exit 1
}

export WAYLAND_DISPLAY=wayland-calypso

set +e
timeout 12s dms run >/tmp/dms.log 2>&1
STATUS=$?
set -e

if [[ "$STATUS" -eq 124 ]]; then
  echo "DMS remained alive for the smoke-test window."
  exit 0
fi

echo "DMS exited during the smoke test with status $STATUS."
cat /tmp/dms.log
echo "--- Weston log ---"
cat /tmp/weston.log
exit 1
INNER
