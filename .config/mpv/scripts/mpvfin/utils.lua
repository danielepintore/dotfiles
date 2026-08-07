local mp = require 'mp'
local config = require 'config'

local utils = {}

--- Returns the full URL for a given resource path and optional query table
---@param resource string
---@param params table|nil
---@return string
function utils.make_url(resource, params)
    local server_url = config.SERVER_URL:gsub("/+$", "")
    resource = resource:gsub("^/+", "")
    local url = server_url .. ":" .. tostring(config.SERVER_PORT) .. "/" .. resource

    if params and type(params) == "table" then
        local query_parts = {}
        for k, v in pairs(params) do
            if v ~= nil and v ~= "" then
                table.insert(query_parts, k .. "=" .. utils.url_encode(tostring(v)))
            end
        end
        if #query_parts > 0 then
            local sep = url:find("%?") and "&" or "?"
            url = url .. sep .. table.concat(query_parts, "&")
        end
    end
    return url
end

--- URL-encodes a string
---@param str string|nil
---@return string
function utils.url_encode(str)
    if not str then return "" end
    str = string.gsub(str, "\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "%%20")
    return str
end

--- Breaks long text strings into multiple lines with ASS formatting flags
---@param str string|nil
---@param flags string
---@param space number
---@return string
function utils.line_break(str, flags, space)
    if str == nil or str == "" then return "" end
    flags = flags or ""
    space = space or 30
    local text = flags
    local n = 1
    local len = #str
    for i = 1, len do
        local c = str:sub(i, i)
        if (c == ' ' and i - n > space) or c == '\n' then
            text = text .. str:sub(n, i - 1) .. "\n" .. flags
            n = i + 1
        end
    end
    text = text .. str:sub(n, len)
    return text
end

--- Splits a string into array by delimiter
---@param inputstr string
---@param sep string|nil
---@return table
function utils.split(inputstr, sep)
    if not inputstr then return {} end
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

--- Creates directory recursively if non-existent
---@param path string
function utils.mkdir(path)
    if not path or path == "" then return end
    local is_windows = package.config:sub(1, 1) == '\\'
    if is_windows then
        os.execute('mkdir "' .. path .. '"')
    else
        os.execute('mkdir -p "' .. path .. '"')
    end
end

--- Blocks execution for given seconds
---@param seconds number
function utils.sleep(seconds)
    local os_family = mp.get_property_native("options/os-family")
    if not os_family then
        local is_windows = package.config:sub(1,1) == "\\"
        os_family = is_windows and "windows" or "linux"
    end
    local sleep_args
    if os_family == "windows" then
        sleep_args = { "timeout", "/t", tostring(seconds), "/nobreak" }
    else
        sleep_args = { "sleep", tostring(seconds) }
    end

    mp.command_native({
        name = "subprocess",
        args = sleep_args,
        capture_stdout = true,
        capture_stderr = true
    })
end

return utils
