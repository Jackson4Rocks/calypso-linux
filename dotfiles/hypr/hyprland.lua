-- Calypso Linux — Material Expressive Hyprland
-- Hyprland 0.55+ Lua configuration.
--
-- KDE Plasma remains the main Calypso desktop.
-- This optional profile uses Noctalia v5 as the shell.

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 14,
    border_size = 2,
    layout = "dwindle",
    resize_on_border = true,
    allow_tearing = false,
  },

  decoration = {
    rounding = 18,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 0.94,
    fullscreen_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
    },
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
      new_optimizations = true,
      xray = false,
      vibrancy = 0.10,
    },
  },

  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = true,
  },

  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    accel_profile = "adaptive",
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
      tap_and_drag = true,
      disable_while_typing = true,
    },
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    focus_on_activate = true,
    enable_swallow = false,
    initial_workspace_tracking = 1,
  },

  xwayland = {
    force_zero_scaling = false,
  },
})

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XDG_MENU_PREFIX", "plasma-")

hl.curve("calypsoExpressive", {
  type = "bezier",
  points = { { 0.16, 1.0 }, { 0.30, 1.0 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "calypsoExpressive", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 7, bezier = "calypsoExpressive", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "calypsoExpressive", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 7, bezier = "calypsoExpressive" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "calypsoExpressive" })
hl.animation({ leaf = "layers", enabled = true, speed = 7, bezier = "calypsoExpressive", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "calypsoExpressive", style = "slidefade" })

local terminal = "kitty"
local file_manager = "kitty -- yazi"
local main_mod = "SUPER"
local noctalia = "noctalia msg "

local function exec(command)
  return hl.dsp.exec_cmd(command)
end

-- Noctalia v5 Settings is a regular Hyprland window. Do NOT use
-- hl.dsp.window.kill() directly on it: upstream issue #2699 documents
-- that killing the settings window can terminate the whole shell.
-- The safe close helper routes that window through Noctalia IPC.

-- Applications and window controls.
hl.bind(main_mod .. " + RETURN", exec(terminal), { description = "Open terminal" })
hl.bind(main_mod .. " + E", exec(file_manager), { description = "Open file manager" })
hl.bind(main_mod .. " + Q", exec("calypso-close-active"), { description = "Close active window safely" })
hl.bind(main_mod .. " + SHIFT + Q", exec("calypso-close-active"), { description = "Close active window safely" })
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind(main_mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(main_mod .. " + P", exec("hyprctl dispatch pseudo"), { description = "Toggle pseudotile" })

-- Focus and movement.
hl.bind(main_mod .. " + LEFT", exec("hyprctl dispatch movefocus l"), { description = "Focus left" })
hl.bind(main_mod .. " + RIGHT", exec("hyprctl dispatch movefocus r"), { description = "Focus right" })
hl.bind(main_mod .. " + UP", exec("hyprctl dispatch movefocus u"), { description = "Focus up" })
hl.bind(main_mod .. " + DOWN", exec("hyprctl dispatch movefocus d"), { description = "Focus down" })
hl.bind(main_mod .. " + SHIFT + LEFT", exec("hyprctl dispatch movewindow l"), { description = "Move window left" })
hl.bind(main_mod .. " + SHIFT + RIGHT", exec("hyprctl dispatch movewindow r"), { description = "Move window right" })
hl.bind(main_mod .. " + SHIFT + UP", exec("hyprctl dispatch movewindow u"), { description = "Move window up" })
hl.bind(main_mod .. " + SHIFT + DOWN", exec("hyprctl dispatch movewindow d"), { description = "Move window down" })
hl.bind(main_mod .. " + TAB", exec("hyprctl dispatch cyclenext"), { description = "Cycle windows" })
hl.bind("ALT + TAB", exec(noctalia .. "window-switcher"), { description = "Open Noctalia window switcher" })

-- Noctalia panels.
hl.bind(main_mod .. " + SPACE", exec(noctalia .. "panel-toggle launcher"), { description = "Open launcher" })
hl.bind(main_mod .. " + S", exec(noctalia .. "panel-toggle control-center"), { description = "Open Control Center" })
hl.bind(main_mod .. " + V", exec(noctalia .. "panel-toggle clipboard"), { description = "Open clipboard history" })
hl.bind(main_mod .. " + N", exec(noctalia .. "panel-toggle control-center notifications"), { description = "Open notifications" })
hl.bind(main_mod .. " + W", exec(noctalia .. "panel-toggle wallpaper"), { description = "Open wallpaper picker" })
hl.bind(main_mod .. " + X", exec(noctalia .. "panel-toggle session"), { description = "Open session menu" })
hl.bind(main_mod .. " + COMMA", exec(noctalia .. "settings-toggle"), { description = "Open Noctalia settings" })

hl.bind(main_mod .. " + L", exec(noctalia .. "session lock"), { description = "Lock session" })
hl.bind(main_mod .. " + SHIFT + W", exec(noctalia .. "wallpaper-next"), { description = "Next wallpaper" })
hl.bind(main_mod .. " + SHIFT + B", exec(noctalia .. "bar-toggle main"), { description = "Toggle the Calypso bar" })
hl.bind(main_mod .. " + CTRL + S", exec(noctalia .. "panel-toggle control-center system"), { description = "Open system panel" })
hl.bind(main_mod .. " + CTRL + Q", exec(noctalia .. "panel-toggle session"), { description = "Open session menu" })
hl.bind(main_mod .. " + SHIFT + M", exec(noctalia .. "notification-dnd-toggle"), { description = "Toggle Do Not Disturb" })
hl.bind(main_mod .. " + M", exec(noctalia .. "media toggle"), { description = "Toggle media playback" })
hl.bind(main_mod .. " + SHIFT + R", exec(noctalia .. "config-reload"), { description = "Reload Noctalia configuration" })
-- Workspaces: use Hyprland's native dispatcher directly.
-- This remains independent of Noctalia, so workspace switching still works
-- when the shell is restarting or temporarily unavailable.
for i = 1, 9 do
  hl.bind(main_mod .. " + " .. i, exec("hyprctl dispatch workspace " .. i), {
    description = "Switch to workspace " .. i,
  })
  hl.bind(main_mod .. " + SHIFT + " .. i, exec("hyprctl dispatch movetoworkspace " .. i), {
    description = "Move window to workspace " .. i,
  })
end

hl.bind(main_mod .. " + 0", exec("hyprctl dispatch workspace 10"), {
  description = "Switch to workspace 10",
})
hl.bind(main_mod .. " + SHIFT + 0", exec("hyprctl dispatch movetoworkspace 10"), {
  description = "Move window to workspace 10",
})

-- Scratchpad.
hl.bind(main_mod .. " + T", hl.dsp.workspace.toggle_special("magic"), {
  description = "Toggle scratchpad",
})
hl.bind(main_mod .. " + SHIFT + T", hl.dsp.window.move({
  workspace = "special:magic",
  follow = false,
}), {
  description = "Send window to scratchpad",
})

-- Media and hardware.
hl.bind("XF86AudioRaiseVolume", exec(noctalia .. "volume-up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", exec(noctalia .. "volume-down"), { repeating = true })
hl.bind("XF86AudioMute", exec(noctalia .. "volume-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", exec(noctalia .. "brightness-up"), { repeating = true })
hl.bind("XF86MonBrightnessDown", exec(noctalia .. "brightness-down"), { repeating = true })
hl.bind("XF86AudioPlay", exec(noctalia .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext", exec(noctalia .. "media next"), { locked = true })
hl.bind("XF86AudioPrev", exec(noctalia .. "media previous"), { locked = true })

-- Screenshots.
hl.bind("PRINT", exec(noctalia .. "screenshot-region"), {
  description = "Screenshot region",
})
hl.bind(main_mod .. " + PRINT", exec(noctalia .. "screenshot-fullscreen"), {
  description = "Screenshot focused monitor",
})

-- Noctalia integration recommended by its Hyprland documentation.
hl.window_rule({
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  size = { 1080, 920 },
})

hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("noctalia")
end)
