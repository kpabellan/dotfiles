-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = "",
    mode = "highres",
    position = "auto",
    scale = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "kitty"
local fileManager = "yazi"
local menu = "rofi -show drun"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- exec-once is now the hyprland.start event. hl.exec_cmd spawns async,
-- so no & disown needed. The second arg is a table of window rule effects,
-- which is how [workspace 1 silent] is expressed now.
hl.on("hyprland.start", function()
    hl.exec_cmd('swaybg -i "$(cat ~/.cache/wal/wal)" --mode fill')
    hl.exec_cmd("waybar")
    hl.exec_cmd("solaar --window=hide")

    hl.exec_cmd(
        'kitty --title "fastfetch" -e bash -c "fastfetch -c ~/.config/fastfetch/start.jsonc; exec bash"',
        { workspace = "1 silent" }
    )
    hl.exec_cmd(
        'kitty --title "tty-clock" -e tty-clock -c -C 3',
        { workspace = "1 silent" }
    )
    hl.exec_cmd(
        'sleep 1 && kitty --title "cava" -e cava',
        { workspace = "1 silent" }
    )
    hl.exec_cmd(
        'kitty --title "btop" -e btop',
        { workspace = "1 silent" }
    )
    hl.exec_cmd(
        "firefox --new-window https://www.duckduckgo.com",
        { workspace = "1 silent" }
    )
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in = 20,
        gaps_out = 30,

        border_size = 2,

        col = {
            active_border = "rgba(595959aa)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = true,

        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 10,

        active_opacity = 0.975,
        inactive_opacity = 0.75,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            -- Was rgba(1a1a1aee) i.e. RRGGBBAA; hex literals here are AARRGGBB
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 5,
            passes = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true, -- You probably want this
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true,   -- If true disables the random hyprland logo / anime girl background. :(
    },
})

-- Curves replace bezier, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-- Points are now {x, y} pairs, was: bezier = myBezier, 0.05, 0.9, 0.1, 1.05
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- Animations are now one call each. The old "1" enable flag became enabled,
-- the number became speed, and the trailing style string became style.
hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/ for more
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- Keysym names come from xkbcommon-keysyms.h minus the XKB_KEY_ prefix,
-- so RETURN is now "Return".
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd('pgrep -x "rofi" > /dev/null && pkill rofi || ' .. menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("wlogout"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- This loop replaces the 20 hand-written binds from the old config.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging (was bindm)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness (was bindel -> locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),{ locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                        { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                        { locked = true, repeating = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Matching props go inside match, effects go outside it.
-- Rules are evaluated top to bottom; last matching effect wins.

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Firefox
hl.window_rule({
    name = "firefox-ws1",
    match = { workspace = 1, class = "^(firefox)$" },
    float = true,
    size = "906 953",
    move = "982 95",
})

-- Fastfetch
hl.window_rule({
    name = "fastfetch-ws1",
    match = { workspace = 1, title = "^(fastfetch)$" },
    float = true,
    size = "431 158",
    move = "32 95",
})

-- tty-clock
hl.window_rule({
    name = "ttyclock-ws1",
    match = { workspace = 1, title = "^(tty-clock)$" },
    float = true,
    size = "431 158",
    move = "507 95",
})

-- Cava
hl.window_rule({
    name = "cava-ws1",
    match = { workspace = 1, title = "^(cava)$" },
    float = true,
    size = "906 158",
    move = "32 297",
})

-- Btop
hl.window_rule({
    name = "btop-ws1",
    match = { workspace = 1, title = "^(btop)$" },
    float = true,
    size = "906 549",
    move = "32 499",
})

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({ workspace = 2, on_created_empty = "firefox" })
hl.workspace_rule({ workspace = 3, on_created_empty = "code" })
hl.workspace_rule({ workspace = 4, on_created_empty = "webcord" })
hl.workspace_rule({ workspace = 5, on_created_empty = "spotify" })
