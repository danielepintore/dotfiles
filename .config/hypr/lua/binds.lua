---------------------
---- KEYBINDINGS ----
---------------------
local defaults = require("lua/defaults")
local utils = require("lua/utils")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(utils.uwsm(defaults.apps.terminal)))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(utils.uwsm(defaults.apps.messenger)))
--hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(utils.uwsm(defaults.apps.fileManager)))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(utils.uwsm(defaults.apps.browser)))
hl.bind(mainMod .. "+ SHIFT + W", hl.dsp.exec_cmd(utils.noctalia_ipc("wallpaper toggle")))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(utils.uwsm("sh -c 'IMG=$(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png') && grim $IMG && wl-copy < $IMG'")))
hl.bind(mainMod .. "+ SHIFT + S", hl.dsp.exec_cmd(utils.uwsm("sh -c 'IMG=$(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png') && grim -g \"$(slurp)\" $IMG && wl-copy < $IMG'")))
hl.bind("PRINT", hl.dsp.exec_cmd(utils.uwsm("pkill slurp; sh -c 'IMG=$(xdg-user-dir PICTURES)/Screenshots/$(date +'%s_grim.png') && grim -g \"$(slurp)\" $IMG && wl-copy < $IMG'")))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(utils.noctalia_ipc("launcher toggle")))
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(utils.noctalia_ipc("bar toggle")))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
-- hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. "+ SHIFT + l", hl.dsp.window.resize({x=10, y=0, relative = true}), { repeating = true })
hl.bind(mainMod .. "+ SHIFT + h", hl.dsp.window.resize({x=-10, y=0, relative = true}), { repeating = true })
hl.bind(mainMod .. "+ SHIFT + k", hl.dsp.window.resize({x=0, y=-10, relative = true}), { repeating = true })
hl.bind(mainMod .. "+ SHIFT + j", hl.dsp.window.resize({x=0, y=10, relative = true}), { repeating = true })

-- 
-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(utils.noctalia_ipc("volume increase")), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(utils.noctalia_ipc("volume decrease")), { locked = true, repeating = true })

-- Mic volume
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("amixer -q set Dmic0 3%+"), { locked = true, repeating = true })
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("amixer -q set Dmic0 3%-"), { locked = true, repeating = true })

hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(utils.noctalia_ipc("volume decrease")), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(utils.noctalia_ipc("volume muteOutput")), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(utils.noctalia_ipc("brightness increase")), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(utils.noctalia_ipc("brightness decrease")), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(utils.noctalia_ipc("brightness decrease")),{ locked = true, repeating = true })

-- Noctalia shutdown menu
hl.bind(mainMod .. " + Delete",hl.dsp.exec_cmd(utils.noctalia_ipc("sessionMenu toggle")),{ release = true, locked = false, repeating = false })
-- Long press for lock screen (prevents accidental presses)
hl.bind(mainMod .. " + Delete",hl.dsp.exec_cmd(utils.noctalia_ipc("lockScreen lock")),{ long_press = true, locked = false, repeating = false })
-- Noctalia settings menu
hl.bind(mainMod .. " + HOME",hl.dsp.exec_cmd(utils.noctalia_ipc("settings toggle")),{ locked = false, repeating = false })
-- Do not disturb
hl.bind("XF86NotificationCenter",hl.dsp.exec_cmd(utils.noctalia_ipc("notifications toggleDND")),{ locked = false, repeating = false })

-- Media controls (requires playerctl)
hl.bind("XF86Favorites",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86HangupPhone",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86PickupPhone",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
