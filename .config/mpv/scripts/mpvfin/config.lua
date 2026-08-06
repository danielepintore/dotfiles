local mp = require 'mp'
local opt = require 'mp.options'

local config = {
    SERVER_URL = "http://localhost",
    SERVER_PORT = 8096,
    USERNAME = "",
    PASSWORD = "",
    image_path = "",
    hide_images = "",
    hide_spoilers = "on",
    show_by_default = "",
    show_on_idle = "",
    use_playlist = "on",
    image_spoiler = "blur", -- "blur": blurs unwatched episodes, "hide": doesn't show image for unwatched, "off": always shows images
    colour_default = "FFFFFF",
    colour_selected = "FF",
    colour_watched = "A0A0A0",
    sort_mode = 0,
}

-- Read options from mpv options system (e.g. mpvfin.conf or jellyfin.conf)
opt.read_options(config, mp.get_script_name())

-- If user configured under 'jellyfin', fallback read
local jf_opts = {}
opt.read_options(jf_opts, "jellyfin")

if jf_opts.url and jf_opts.url ~= "" then
    local host, port = jf_opts.url:match("^(https?://[^:]+):?(%d*)$")
    if host then
        config.SERVER_URL = host
        if port and port ~= "" then config.SERVER_PORT = tonumber(port) end
    else
        config.SERVER_URL = jf_opts.url
    end
end
for k, v in pairs(jf_opts) do
    if v and v ~= "" and k ~= "url" then
        config[k] = v
    end
end

-- Set fallback image cache path if non-specified
if not config.image_path or config.image_path == "" then
    config.image_path = mp.command_native({"expand-path", "~~/jellyfin_images"})
end

---@class SessionData
---@field UserId string | nil
---@field ApiKey string | nil
local session_data = {
    UserId = nil,
    ApiKey = nil,
}

---@param user_id string
---@param api_key string
function config.setSessionData(user_id, api_key)
    assert(user_id ~= nil and user_id ~= "", "UserId must not be empty")
    assert(api_key ~= nil and api_key ~= "", "ApiKey must not be empty")

    session_data.UserId = user_id
    session_data.ApiKey = api_key
end

---@return SessionData
function config.getSessionData()
    return session_data
end

return config
