--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Gnome calculator is floating
hl.window_rule({
    match = { class = "^(org.gnome.Calculator)$" },
    float = true
})

-- Telegram rules
hl.window_rule({
    match = { class = "^(org.telegram.desktop)$" },
    float = true,
    size = { "(monitor_w*0.3)", "(monitor_h*0.955)" },
    move = { "((monitor_w*1)-window_w-(monitor_w*0.004))", "((monitor_h*0.04))" },
})

-- Dnspy force tiling
hl.window_rule({ match = { class = "^(dnspy.exe)$" }, tile = true })

-- IDA
hl.window_rule({ match = { class = "^(IDA)$" }, focus_on_activate = false })

-- Thunderbird (compose new mail popup should be floating)
hl.window_rule({
    match = { class = "(thunderbird)", title = "(Write.*)" },
    float = true,
    size = { 1000, 800 }
})

-- MATLAB
hl.window_rule({
    match = { title = "(MATLAB [%w%d]* - academic use)$" },
    tile = true,
})
hl.window_rule({
    match = { class = "^(MATLAB [%w%d]* - academic use)$", title = "^(Command HistoryWindow)$" },
    no_focus = true,
    border_size = 0,
    opacity = "1.0 override"
})
hl.window_rule({
    match = { class = "^(MATLAB [%w%d]* - academic use)$", title = "^(DefaultOverlayManager\\.JWindow)$" },
    no_focus = true,
})

-- Rofi blur
hl.layer_rule({
    name         = "rofi-blur",
    match        = { namespace = "rofi" },
    blur         = true,
    ignore_alpha = 0,
    dim_around   = true,
    enabled      = false,
})

-- Waybar blur
hl.layer_rule({
    name         = "waybar-blur",
    match        = { namespace = "waybar" },
    blur         = true,
    ignore_alpha = 0,
    enabled = false,
})

-- Notifications blur with slide animation
hl.layer_rule({
    name         = "notifications-blur",
    match        = { namespace = "notifications" },
    blur         = true,
    animation    = "slide",
    ignore_alpha = 0,
    enabled = false,
})
