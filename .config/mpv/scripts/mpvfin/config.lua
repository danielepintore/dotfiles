local mp = require 'mp'
local opt = require 'mp.options'

local config = {
    --- Jellyfin Server connection URL
    SERVER_URL = "http://localhost",

    --- Jellyfin Server connection Port
    ---@type integer
    SERVER_PORT = 8096,

    --- Jellyfin Username
    USERNAME = "",

    --- Jellyfin Password
    PASSWORD = "",

    --- Path to store downloaded thumbnail images. If empty, defaults to '~~/jellyfin_images'
    image_path = "",

    --- Completely disable fetching and rendering of thumbnail images
    ---@type "on"|"off"|""
    hide_images = "",

    --- Hide episode descriptions/plots if you haven't watched the episode yet
    ---@type "on"|"off"|""
    hide_spoilers = "on",

    --- Automatically open the Jellyfin menu as soon as mpv starts
    ---@type "on"|"off"|""
    show_by_default = "",

    --- Automatically open the Jellyfin menu when playback finishes and mpv is idle
    ---@type "on"|"off"|""
    show_on_idle = "",

    --- Load episodes/movies into an m3u8 playlist instead of a single file
    ---@type "on"|"off"|""
    use_playlist = "on",

    --- Strategy for hiding spoiler thumbnails of unwatched episodes
    ---@type "blur"|"hide"|"show"
    image_spoiler = "blur",

    --- Text color for unselected/unwatched items (in BGR or ABGR hex format)
    colour_default = "FFFFFF",

    --- Text color for the currently highlighted item (in BGR or ABGR hex format)
    colour_selected = "FF",

    --- Text color for items already watched (in BGR or ABGR hex format)
    colour_watched = "A0A0A0",

    --- Sorting behavior for items (0 = default, 1 = by PremiereDate, 2 = by SortName)
    ---@type 0|1|2
    sort_mode = 0,
}

-- Read options from mpv options system
opt.read_options(config, mp.get_script_name())

-- Set fallback image cache path if non-specified
if not config.image_path or config.image_path == "" then
    config.image_path = mp.command_native({ "expand-path", "~~/jellyfin_images" })
end


return config
