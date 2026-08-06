-- network.lua
-- Contains networking code needed to make requests to jellyfin server
local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'utils'
local config = require 'config'

local network = {}

-- Default fallback function for error reporting
local function default_fallback(err_msg)
    msg.error("Network Error: " .. err_msg)
end

--- Inject Authorization header if ApiKey is stored in session
---@param headers table|nil
---@return table
local function prepare_headers(headers)
    headers = headers or {}
    local session = config.getSessionData()
    if session.ApiKey and session.ApiKey ~= "" and not headers["Authorization"] then
        headers["Authorization"] = 'MediaBrowser Token="' .. session.ApiKey .. '"'
    end
    return headers
end

--- Sends an async request to a network resource
local function async_request(method, url, body, headers, max_retries, on_success, fallback_fn)
    method = method or "GET"
    max_retries = max_retries or 3
    fallback_fn = fallback_fn or default_fallback
    headers = prepare_headers(headers)

    assert(method == "GET" or method == "POST" or method == "PUT"
        or method == "PATCH" or method == "DELETE",
        "Invalid request method, check curl docs")
    assert(body == nil or (method == "POST" or method == "PUT" or method == "PATCH"),
        "Invalid request: body provided for a method that does not support it")

    local attempt = 0
    local args = { "curl", "-s", "--fail-with-body", "-L", "--connect-timeout", "10", "-X", method }

    if body ~= nil then
        table.insert(args, "-H")
        table.insert(args, "Content-Type: application/json")
        table.insert(args, "-d")
        table.insert(args, body)
    end

    for key, value in pairs(headers) do
        table.insert(args, "-H")
        table.insert(args, key .. ": " .. value)
    end

    -- the url must be the last argument
    table.insert(args, url)

    local function execute_request()
        attempt = attempt + 1

        mp.command_native_async({
            name = "subprocess",
            capture_stdout = true,
            playback_only = false,
            args = args
        }, function(success, res, err)
            if success and res and res.status == 0 then
                if on_success then
                    on_success(res.stdout)
                end
            else
                if attempt < max_retries then
                    msg.warn("Connection failed for " .. url .. ". Retrying (" .. attempt .. "/" .. max_retries .. ")...")
                    mp.add_timeout(2 * attempt, execute_request)
                else
                    local error_detail = (res and res.stdout) or err or "Unknown error"
                    fallback_fn("Max retries (" .. max_retries .. ") reached for " .. url .. ". Detail: " .. error_detail)
                end
            end
        end)
    end

    execute_request()
end

-- Synchronous HTTP request (Blocking)
local function sync_request(method, url, body, headers, max_retries, fallback_fn)
    method = method or "GET"
    max_retries = max_retries or 3
    fallback_fn = fallback_fn or default_fallback
    headers = prepare_headers(headers)

    assert(method == "GET" or method == "POST" or method == "PUT"
        or method == "PATCH" or method == "DELETE",
        "Invalid request method, check curl docs")
    assert(body == nil or (method == "POST" or method == "PUT" or method == "PATCH"),
        "Invalid request: body provided for a method that does not support it")

    local args = { "curl", "-s", "--fail-with-body", "-L", "--connect-timeout", "10", "-X", method }

    if body ~= nil then
        table.insert(args, "-H")
        table.insert(args, "Content-Type: application/json")
        table.insert(args, "-d")
        table.insert(args, body)
    end

    for key, value in pairs(headers) do
        table.insert(args, "-H")
        table.insert(args, key .. ": " .. value)
    end

    -- the url must be the last argument
    table.insert(args, url)

    for attempt = 1, max_retries do
        local res = mp.command_native({
            name = "subprocess",
            capture_stdout = true,
            playback_only = false,
            args = args,
        })

        if res and res.status == 0 then
            return res.stdout
        else
            msg.warn("Sync connection failed for " .. url .. ". Attempt (" .. attempt .. "/" .. max_retries .. ")")

            if attempt == max_retries then
                local error_detail = (res and res.stdout) or "Unknown error"
                fallback_fn("Max retries (" .. max_retries .. ") reached for " .. url .. ". Detail: " .. error_detail)
                return nil, error_detail
            end

            utils.sleep(2 * attempt)
        end
    end
end

function network.sync_get(url, headers, max_retries, fallback_fn)
    return sync_request("GET", url, nil, headers, max_retries, fallback_fn)
end

function network.sync_post(url, body, headers, max_retries, fallback_fn)
    return sync_request("POST", url, body, headers, max_retries, fallback_fn)
end

function network.sync_put(url, body, headers, max_retries, fallback_fn)
    return sync_request("PUT", url, body, headers, max_retries, fallback_fn)
end

function network.sync_patch(url, body, headers, max_retries, fallback_fn)
    return sync_request("PATCH", url, body, headers, max_retries, fallback_fn)
end

function network.sync_delete(url, headers, max_retries, fallback_fn)
    return sync_request("DELETE", url, nil, headers, max_retries, fallback_fn)
end

function network.async_get(url, headers, max_retries, fallback_fn, on_success)
    return async_request("GET", url, nil, headers, max_retries, on_success, fallback_fn)
end

function network.async_post(url, body, headers, max_retries, fallback_fn, on_success)
    return async_request("POST", url, body, headers, max_retries, on_success, fallback_fn)
end

function network.async_put(url, body, headers, max_retries, fallback_fn, on_success)
    return async_request("PUT", url, body, headers, max_retries, on_success, fallback_fn)
end

function network.async_patch(url, body, headers, max_retries, fallback_fn, on_success)
    return async_request("PATCH", url, body, headers, max_retries, on_success, fallback_fn)
end

function network.async_delete(url, headers, max_retries, fallback_fn, on_success)
    return async_request("DELETE", url, nil, headers, max_retries, fallback_fn, on_success)
end

return network
