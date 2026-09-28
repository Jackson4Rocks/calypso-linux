#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
WARN=0
FAIL=0

GREEN=$'\033[38;2;143;245;199m'
YELLOW=$'\033[38;2;247;197;109m'
RED=$'\033[38;2;255;180;171m'
RESET=$'\033[0m'

pass(){ printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"; PASS=$((PASS+1)); }
warn(){ printf '%s!%s %s\n' "$YELLOW" "$RESET" "$1"; WARN=$((WARN+1)); }
fail(){ printf '%s✕%s %s\n' "$RED" "$RESET" "$1"; FAIL=$((FAIL+1)); }

printf '\n%sCalypso Material Expressive · verification%s\n\n' "$GREEN" "$RESET"

for f in   "$ROOT/hypr/hyprland.lua"   "$ROOT/dms/calypso-expressive.json"   "$ROOT/scripts/install.sh"   "$ROOT/scripts/calypso-wallpaper"
do
  [[ -f "$f" ]] && pass "Found $(basename "$f")" || fail "Missing $f"
done

if command -v bash >/dev/null 2>&1; then
  bash -n "$ROOT/scripts/install.sh" && pass "install.sh parses" || fail "install.sh has a Bash syntax error"
  bash -n "$ROOT/scripts/calypso-wallpaper" && pass "calypso-wallpaper parses" || fail "calypso-wallpaper has a Bash syntax error"
else
  warn "Bash is not installed; skipped Bash checks"
fi

if command -v jq >/dev/null 2>&1; then
  jq empty "$ROOT/dms/calypso-expressive.json" && pass "DMS theme JSON parses" || fail "DMS theme JSON is invalid"
else
  warn "jq not installed; run 'jq empty dms/calypso-expressive.json' manually"
fi

if command -v luac >/dev/null 2>&1; then
  luac -p "$ROOT/hypr/hyprland.lua" && pass "Hyprland Lua parses" || fail "Hyprland Lua has a syntax error"
else
  warn "luac not installed; Lua syntax check skipped"
fi

if command -v dms >/dev/null 2>&1; then
  pass "dms executable found"
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    if pgrep -x dms >/dev/null 2>&1 && dms ipc list >/dev/null 2>&1; then
      pass "DMS is running and IPC responds"
    else
      warn "DMS is installed but not currently responding; start it with 'dms run'"
    fi
  else
    warn "No Wayland session; live DMS test skipped"
  fi
else
  warn "dms is not installed in this environment"
fi

if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  if hyprctl reload >/dev/null 2>&1; then
    pass "Hyprland accepts the current profile"
  else
    fail "Hyprland rejected the current profile"
  fi
else
  warn "No active Hyprland session; compositor reload test skipped"
fi

printf '\n%sPassed: %d%s   %sWarnings: %d%s   %sFailed: %d%s\n'   "$GREEN" "$PASS" "$RESET" "$YELLOW" "$WARN" "$RESET" "$RED" "$FAIL" "$RESET"

(( FAIL == 0 ))
