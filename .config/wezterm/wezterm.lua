-- Wezterm config api
local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action
local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

-- Default shell (avoid to run zshprofile each time)
config.default_prog = { '/usr/bin/zsh' }

-- Font
config.font_size = 12
config.font = wezterm.font 'JetBrains Mono'

-- Theme
config.color_scheme = 'Grandshell (terminal.sexy)'
config.force_reverse_video_cursor = true
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- Window
config.window_background_opacity = 0.8
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.1 }
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Keymaps
config.leader = { key = 'a', mods = 'CTRL' }
config.keys = {
    -- Pane
    { key = '\\',    mods = 'CTRL',       action = act.SplitHorizontal },
    { key = '-',     mods = 'CTRL',       action = act.SplitVertical },
    { key = 'm',     mods = 'CTRL',       action = act.TogglePaneZoomState },

    -- Vim movements
    { key = 'h',     mods = 'CTRL',       action = act.ActivatePaneDirection 'Left' },
    { key = 'l',     mods = 'CTRL',       action = act.ActivatePaneDirection 'Right' },
    { key = 'k',     mods = 'CTRL',       action = act.ActivatePaneDirection 'Up' },
    { key = 'j',     mods = 'CTRL',       action = act.ActivatePaneDirection 'Down' },

    -- Vim resize panel
    { key = 'H',     mods = 'CTRL',       action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'J',     mods = 'CTRL',       action = act.AdjustPaneSize { 'Down', 5 } },
    { key = 'K',     mods = 'CTRL',       action = act.AdjustPaneSize { 'Up', 5 } },
    { key = 'L',     mods = 'CTRL',       action = act.AdjustPaneSize { 'Right', 5 } },

    -- Vim copy mode
    { key = 'Enter', mods = 'CTRL',       action = act.ActivateCopyMode, },

    -- Tabs
    { key = 'Space', mods = 'CTRL',       action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 't',     mods = 'CTRL|SHIFT', action = act.ShowTabNavigator },
    { key = 't',     mods = 'LEADER',     action = act.ShowTabNavigator },
    { key = '7',     mods = 'CTRL',       action = act.ActivateTab(0) },
    { key = '8',     mods = 'CTRL',       action = act.ActivateTab(1) },
    { key = '9',     mods = 'CTRL',       action = act.ActivateTab(2) },
    { key = '0',     mods = 'CTRL',       action = act.ActivateTab(3) },

    -- Workspaces
    { key = 's',     mods = 'CTRL|SHIFT', action = act.ShowLauncherArgs { flags = "WORKSPACES" } },
    { key = 's',     mods = 'LEADER',     action = act.ShowLauncherArgs { flags = "WORKSPACES" } },
    -- Rename current workspace
    {
        key = 'r',
        mods = 'LEADER',
        action = act.PromptInputLine {
            description = 'Enter new name for session',
            action = wezterm.action_callback(
                function(window, pane, line)
                    if line then
                        wezterm.mux.rename_workspace(
                            window:mux_window():get_workspace(),
                            line
                        )
                    end
                end
            ),
        },
    },
}

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.status_update_interval = 1000
config.colors = {
    tab_bar = {
        background = 'Transparent',
    }
}
wezterm.on("update-right-status", function(window, pane)
    -- Workspace name
    -- Time
    local time = wezterm.strftime("%H:%M")

    -- Let's add color to one of the components
    window:set_right_status(wezterm.format({
        { Text = "[" .. window:active_workspace() .. "] " },
        { Text = time .. " " },
    }))
end)

smart_splits.apply_to_config(config, {
    -- the default config is here, if you'd like to use the default keys,
    -- you can omit this configuration table parameter and just use
    -- smart_splits.apply_to_config(config)

    -- directional keys to use in order of: left, down, up, right
    -- if you want to use separate direction keys for move vs. resize, you
    -- can also do this:
    direction_keys = {
        move = { 'h', 'j', 'k', 'l' },
        resize = { 'H', 'J', 'K', 'L' },
    },
    -- modifier keys to combine with direction_keys
    modifiers = {
        move = 'CTRL',   -- modifier to use for pane movement, e.g. CTRL+h to move left
        resize = 'CTRL', -- modifier to use for pane resize, e.g. META+h to resize to the left
    },
    -- log level to use: info, warn, error
    log_level = 'info',
})

return config
