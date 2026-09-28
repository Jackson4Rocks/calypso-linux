-- Calypso Linux — Material Expressive Hyprland
-- Hyprland 0.55+ Lua configuration.
--
-- The desktop shell is DankMaterialShell (DMS). DMS is started only by
-- Hyprland so the optional profile does not interfere with KDE Plasma.

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
    active_opacity = 1.0,
    inactive_opacity = 0.94,
    fullscreen_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 24,
      render_power = 3,
    },
    blur = {
      enabled = true,
      size = 7,
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

-- Keep DMS on the dark Calypso theme instead of allowing an automatic
-- wallpaper recolor pass to overwrite the curated palette.
hl.env("DMS_DISABLE_MATUGEN", "1")
hl.env("DMS_DANKBAR_LAYER", "overlay")

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

local function exec(command)
  return hl.dsp.exec_cmd(command)
end

-- Core app bindings.
hl.bind(main_mod .. " + RETURN", exec(terminal), { description = "Open terminal" })
hl.bind(main_mod .. " + E", exec(file_manager), { description = "Open file manager" })
hl.bind(main_mod .. " + Q", hl.dsp.window.kill(), { description = "Close focused window" })
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.window.kill(), { description = "Kill focused window" })
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), { description = "Toggle fullscreen" })
hl.bind(main_mod .. " + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
hl.bind(main_mod .. " + P", exec("hyprctl dispatch pseudo"), { description = "Toggle pseudotile" })
hl.bind(main_mod .. " + TAB", exec("hyprctl dispatch cyclenext"), { description = "Cycle windows" })
hl.bind(main_mod .. " + SHIFT + TAB", exec("hyprctl dispatch cyclenext prev"), { description = "Cycle windows backwards" })
hl.bind(main_mod .. " + LEFT", exec("hyprctl dispatch movefocus l"), { description = "Focus left" })
hl.bind(main_mod .. " + RIGHT", exec("hyprctl dispatch movefocus r"), { description = "Focus right" })
hl.bind(main_mod .. " + UP", exec("hyprctl dispatch movefocus u"), { description = "Focus up" })
hl.bind(main_mod .. " + DOWN", exec("hyprctl dispatch movefocus d"), { description = "Focus down" })
hl.bind(main_mod .. " + SHIFT + LEFT", exec("hyprctl dispatch movewindow l"), { description = "Move window left" })
hl.bind(main_mod .. " + SHIFT + RIGHT", exec("hyprctl dispatch movewindow r"), { description = "Move window right" })
hl.bind(main_mod .. " + SHIFT + UP", exec("hyprctl dispatch movewindow u"), { description = "Move window up" })
hl.bind(main_mod .. " + SHIFT + DOWN", exec("hyprctl dispatch movewindow d"), { description = "Move window down" })

-- DMS: Material 3 shell controls.
hl.bind(main_mod .. " + SPACE", exec("dms ipc call spotlight toggle"), { description = "Open launcher" })
hl.bind(main_mod .. " + V", exec("dms ipc call clipboard toggle"), { description = "Open clipboard history" })
hl.bind(main_mod .. " + N", exec("dms ipc call notifications toggle"), { description = "Open notifications" })
hl.bind(main_mod .. " + C", exec("dms ipc call control-center toggle"), { description = "Open quick settings" })
hl.bind(main_mod .. " + X", exec("dms ipc call powermenu toggle"), { description = "Open power menu" })
hl.bind(main_mod .. " + COMMA", exec("dms ipc call settings toggle"), { description = "Open shell settings" })
hl.bind(main_mod .. " + SHIFT + K", exec("dms ipc call keybinds toggle hyprland"), { description = "Show keybinds" })
hl.bind(main_mod .. " + SHIFT + R", exec("hyprctl reload"), { description = "Reload Hyprland" })
hl.bind(main_mod .. " + SHIFT + W", exec("dms ipc call file browse wallpaper"), { description = "Open wallpaper picker" })

for i = 1, 9 do
  hl.bind(main_mod .. " + " .. i, exec("hyprctl dispatch workspace " .. i), {
    description = "Switch to workspace " .. i,
  })
  hl.bind(main_mod .. " + SHIFT + " .. i, exec("hyprctl dispatch movetoworkspace " .. i), {
    description = "Move window to workspace " .. i,
  })
end

hl.bind(main_mod .. " + 0", exec("hyprctl dispatch workspace 10"), { description = "Switch to workspace 10" })
hl.bind(main_mod .. " + SHIFT + 0", exec("hyprctl dispatch movetoworkspace 10"), { description = "Move window to workspace 10" })

-- Scratchpad.
hl.bind(main_mod .. " + S", exec("hyprctl dispatch togglespecialworkspace magic"), {
  description = "Toggle scratchpad",
})
hl.bind(main_mod .. " + SHIFT + S", exec("hyprctl dispatch movetoworkspace special:magic"), {
  description = "Send window to scratchpad",
})

-- Hardware controls.
hl.bind("XF86AudioRaiseVolume", exec("dms ipc call audio increment 5"), { repeating = true })
hl.bind("XF86AudioLowerVolume", exec("dms ipc call audio decrement 5"), { repeating = true })
hl.bind("XF86AudioMute", exec("dms ipc call audio mute"), { locked = true })
hl.bind("XF86AudioMicMute", exec("dms ipc call mic mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", exec("dms ipc call brightness increment 5"), { repeating = true })
hl.bind("XF86MonBrightnessDown", exec("dms ipc call brightness decrement 5"), { repeating = true })
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })

-- Wayland screenshots.
hl.bind("PRINT", exec("sh -lc 'grim -g \"$(slurp)\" - | wl-copy'"), {
  description = "Screenshot region to clipboard",
})
hl.bind(main_mod .. " + PRINT", exec("sh -lc 'grim - | wl-copy'"), {
  description = "Screenshot full screen to clipboard",
})

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("dms run -d")
end)
