#!/usr/bin/env bash
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/noctalia/config.toml"
PALETTE="$ROOT/noctalia/palettes/CalypsoEmerald.json"

PASS=0
WARN=0
FAIL=0

GREEN=$'\033[38;2;143;245;199m'
YELLOW=$'\033[38;2;247;197;109m'
RED=$'\033[38;2;255;180;171m'
RESET=$'\033[0m'

pass(){ printf "%s✓%s %s\n" "$GREEN" "$RESET" "$1"; PASS=$((PASS+1)); }
warn(){ printf "%s!%s %s\n" "$YELLOW" "$RESET" "$1"; WARN=$((WARN+1)); }
fail(){ printf "%s✕%s %s\n" "$RED" "$RESET" "$1"; FAIL=$((FAIL+1)); }

printf "\n%sCalypso Noctalia · verification%s\n\n" "$GREEN" "$RESET"

for f in \
  "$ROOT/hypr/hyprland.lua" \
  "$CONFIG" \
  "$PALETTE" \
  "$ROOT/scripts/install.sh" \
  "$ROOT/scripts/calypso-wallpaper" \
  "$ROOT/scripts/ci-noctalia-smoke.sh"
do
  if [[ -f "$f" ]]; then
    pass "Found ${f#$ROOT/}"
  else
    fail "Missing $f"
  fi
done

if command -v bash >/dev/null 2>&1; then
  bash -n "$ROOT/scripts/install.sh" && pass "install.sh parses" || fail "install.sh has a Bash syntax error"
  bash -n "$ROOT/scripts/calypso-wallpaper" && pass "calypso-wallpaper parses" || fail "calypso-wallpaper has a Bash syntax error"
  bash -n "$ROOT/scripts/ci-noctalia-smoke.sh" && pass "Noctalia smoke test parses" || fail "Noctalia smoke test has a Bash syntax error"
else
  warn "Bash is not installed; skipped Bash checks"
fi

if command -v jq >/dev/null 2>&1; then
  jq empty "$PALETTE" && pass "Noctalia palette JSON parses" || fail "Noctalia palette JSON is invalid"
  for mode in dark light; do
    if jq -e ".${mode}.mPrimary and .${mode}.mOnPrimary and .${mode}.mSecondary and .${mode}.mOnSecondary and .${mode}.mTertiary and .${mode}.mOnTertiary and .${mode}.mError and .${mode}.mOnError and .${mode}.mSurface and .${mode}.mOnSurface and .${mode}.mSurfaceVariant and .${mode}.mOnSurfaceVariant and .${mode}.mOutline and .${mode}.mShadow and .${mode}.mHover and .${mode}.mOnHover" "$PALETTE" >/dev/null; then
      pass "Material 3 $mode palette has all required roles"
    else
      fail "Material 3 $mode palette is missing a required role"
    fi
  done
else
  warn "jq not installed; skipped palette JSON checks"
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$CONFIG" <<'PY'
import sys, tomllib
from pathlib import Path
cfg = tomllib.loads(Path(sys.argv[1]).read_text())
assert cfg["theme"]["source"] == "custom"
assert cfg["theme"]["custom_palette"] == "CalypsoEmerald"
assert cfg["lockscreen"]["enabled"] is True
assert cfg["lockscreen_widgets"]["enabled"] is True
assert cfg["lockscreen_widgets"]["widget"]["clock_main"]["type"] == "clock"
assert cfg["lockscreen_widgets"]["widget"]["date_main"]["type"] == "label"
print("Noctalia TOML structure: valid")
PY
  [[ "$?" -eq 0 ]] && pass "Noctalia TOML structure is valid" || fail "Noctalia TOML structure is invalid"
else
  warn "python3 not installed; skipped TOML structure check"
fi

if command -v luac >/dev/null 2>&1; then
  luac -p "$ROOT/hypr/hyprland.lua" && pass "Hyprland Lua parses" || fail "Hyprland Lua has a syntax error"
else
  warn "luac not installed; Lua syntax check skipped"
fi

if command -v noctalia >/dev/null 2>&1; then
  pass "noctalia executable found"
  if noctalia config validate "$CONFIG" >/dev/null 2>&1; then
    pass "Noctalia accepts the Calypso configuration"
  else
    fail "Noctalia rejected the Calypso configuration"
  fi
  if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    if pgrep -x noctalia >/dev/null 2>&1 && noctalia msg --help >/dev/null 2>&1; then
      pass "Noctalia is running and its IPC is available"
    else
      warn "Noctalia is installed but not currently responding; start it with \"noctalia\""
    fi
  else
    warn "No Wayland session; live Noctalia test skipped"
  fi
else
  warn "Noctalia is not installed in this environment"
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

printf "\n%sPassed: %d%s   %sWarnings: %d%s   %sFailed: %d%s\n" \
  "$GREEN" "$PASS" "$RESET" "$YELLOW" "$WARN" "$RESET" "$RED" "$FAIL" "$RESET"

(( FAIL == 0 ))
