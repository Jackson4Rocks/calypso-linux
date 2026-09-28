#!/usr/bin/env bash
set -euo pipefail

ROOT="/repo"
export HOME="/tmp/calypso-noctalia-home"
export XDG_RUNTIME_DIR="/tmp/xdg-runtime"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

mkdir -p   "$XDG_RUNTIME_DIR"   "$XDG_CONFIG_HOME/noctalia/palettes"   "$XDG_CACHE_HOME"   "$XDG_STATE_HOME"
chmod 700 "$XDG_RUNTIME_DIR"

cp "$ROOT/dotfiles/noctalia/config.toml" "$XDG_CONFIG_HOME/noctalia/config.toml"
cp "$ROOT/dotfiles/noctalia/palettes/CalypsoEmerald.json"   "$XDG_CONFIG_HOME/noctalia/palettes/CalypsoEmerald.json"

noctalia config validate "$XDG_CONFIG_HOME/noctalia/config.toml"

dbus-run-session -- bash -s <<'INNER'
set -euo pipefail

weston   --backend=headless-backend.so   --socket=wayland-calypso   --idle-time=0   >/tmp/weston.log 2>&1 &
WESTON_PID=$!
cleanup() {
  kill "$WESTON_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for _ in $(seq 1 30); do
  [[ -S "$XDG_RUNTIME_DIR/wayland-calypso" ]] && break
  sleep 0.5
done

[[ -S "$XDG_RUNTIME_DIR/wayland-calypso" ]] || {
  cat /tmp/weston.log
  exit 1
}

export WAYLAND_DISPLAY=wayland-calypso

set +e
timeout 15s noctalia >/tmp/noctalia.log 2>&1
STATUS=$?
set -e

if [[ "$STATUS" -eq 124 ]]; then
  echo "Noctalia remained alive for the smoke-test window."
  exit 0
fi

echo "Noctalia exited during the smoke test with status $STATUS."
cat /tmp/noctalia.log
echo "--- Weston log ---"
cat /tmp/weston.log
exit 1
INNER
