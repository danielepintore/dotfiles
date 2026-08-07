local mp = require 'mp'
local mp_utils = require 'mp.utils'

local session = {}

---@class SessionData
---@field UserId string | nil
---@field ApiKey string | nil
local session_data = {
    UserId = nil,
    ApiKey = nil,
}

local session_file = mp.command_native({ "expand-path", "~~/mpvfin_session.json" })

local function loadSessionData()
    local f = io.open(session_file, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local data = mp_utils.parse_json(content)
        if data and data.UserId and data.ApiKey then
            session_data.UserId = data.UserId
            session_data.ApiKey = data.ApiKey
        end
    end
end
loadSessionData()

---@param user_id string
---@param api_key string
function session.setSessionData(user_id, api_key)
    if user_id == nil or user_id == "" then return false, "UserId must not be empty" end
    if api_key == nil or api_key == "" then return false, "ApiKey must not be empty" end

    session_data.UserId = user_id
    session_data.ApiKey = api_key

    local f = io.open(session_file, "w")
    if f then
        f:write(mp_utils.format_json(session_data))
        f:close()
    end

    return true
end

function session.clearSessionData()
    session_data.UserId = nil
    session_data.ApiKey = nil
    os.remove(session_file)
end

---@return SessionData
function session.getSessionData()
    return session_data
end

return session
