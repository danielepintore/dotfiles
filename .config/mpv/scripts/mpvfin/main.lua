local mp = require 'mp'
local msg = require 'mp.msg'

-- Add script-modules to package path
package.path = mp.command_native({"expand-path", "~~/script-modules/?.lua;"}) .. package.path

local config = require 'config'
local utils = require 'utils'
local network = require 'network'
local api = require 'api'
local image = require 'image'
local player = require 'player'
local ui = require 'ui'

-- Version check
local mpv_ver_str = mp.get_property("mpv-version") or ""
local version_num = tonumber(string.sub(mpv_ver_str, 8, 11)) or 999.0

if version_num < 38.0 then
    msg.error("Minimum mpv version (0.38.0) not met for mpvfin script.")
else
    image.init()
    ui.init()

    -- Key bindings
    mp.add_key_binding("Ctrl+j", "jf", ui.toggle)
    mp.add_key_binding("ESC", nil, ui.disable)

    local input_success, _ = pcall(require, "user-input-module")
    if input_success then
        mp.add_key_binding("Ctrl+f", "jf_search", ui.search_input)
    end

    -- Property observers
    if config.hide_images ~= "on" then
        mp.observe_property("osd-width", "number", ui.on_width_change)
    end
    mp.observe_property("osd-align-x", "string", ui.on_align_x_change)
    mp.observe_property("osd-align-y", "string", ui.on_align_y_change)

    if config.show_on_idle == "on" then
        mp.observe_property("idle-active", "bool", ui.on_idle_change)
    end

    -- Events & Timers
    mp.register_event("file-loaded", function()
        player.on_file_loaded(ui.get_items())
    end)
    mp.register_event("end-file", player.on_end_file)

    mp.add_periodic_timer(1, function()
        player.check_watch_progress(ui.get_items())
    end)

    -- Auto show by default option
    if config.show_by_default == "on" then
        ui.toggle()
    end
end
