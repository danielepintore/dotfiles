local network = require 'network'
local msg = require 'mp.msg'
local utils = require 'utils'
local mp_utils = require 'mp.utils'
local config = require 'config'

local api = {}
local items_cache = {}
local CACHE_TTL = 60

--- Authenticates with Jellyfin server
---@param username string|nil
---@param password string|nil
---@return boolean
function api.login(username, password)
    username = username or config.USERNAME
    password = password or config.PASSWORD

    local url = utils.make_url("/Users/AuthenticateByName")
    local payload = {
        Username = username,
        Pw = password,
    }
    local body = mp_utils.format_json(payload)
    local headers = {
        ["Authorization"] = 'MediaBrowser Client="mpv", Device="mpv", DeviceId="mpv", Version="1.0"',
    }

    local response, err = network.sync_post(url, body, headers)
    if err ~= nil or not response then
        msg.error("Auth: Failed to login, error in request: " .. tostring(err))
        return false
    end

    local result = mp_utils.parse_json(response)
    if not result or not result.User or not result.AccessToken then
        msg.error("Auth: Failed to login, server response invalid")
        return false
    end

    config.setSessionData(result.User.Id, result.AccessToken)
    msg.info("Jellyfin auth successful for user: " .. tostring(result.User.Name or username))
    return true
end

--- Fetches single item details by item ID
---@param item_id string
---@return table|nil
function api.get_item_by_id(item_id)
    if not item_id or item_id == "" then return nil end
    local session = config.getSessionData()
    if not session.UserId then return nil end
    local url = utils.make_url("/Items/" .. item_id, { userID = session.UserId })
    local response, err = network.sync_get(url)
    if not response then return nil end
    return mp_utils.parse_json(response)
end

--- Fetches items list for given parent_id, layer, sort_mode, and optional search_term
---@param parent_id string|nil
---@param sort_mode number|nil
---@param layer number|nil
---@param search_term string|nil
---@return table|nil items, string|nil err
function api.get_items(parent_id, sort_mode, layer, search_term)
    local session = config.getSessionData()
    if not session.UserId then
        return nil, "Auth failed: Not logged in."
    end

    local cache_key = string.format("%s_%s_%s_%s", parent_id or "root", sort_mode or 0, layer or 0, search_term or "")
    local now = os.time()
    if items_cache[cache_key] and (now - items_cache[cache_key].time) < CACHE_TTL then
        return items_cache[cache_key].data, nil
    end

    local params = {
        userID = session.UserId,
        parentId = parent_id or "",
        enableImageTypes = "Primary",
        imageTypeLimit = "1",
        fields = "PrimaryImageAspectRatio,Taglines,Overview,MediaSources,SeasonId,SeriesId,ParentId,SeriesPrimaryImageTag,ParentPrimaryImageTag",
    }

    if sort_mode == 1 then
        params.sortBy = "PremiereDate"
    elseif layer == 2 then
        params.sortBy = "SortName"
    end

    local search_query = (search_term and search_term ~= "") and search_term or nil
    if search_query then
        params.searchTerm = search_query
    end

    local url = utils.make_url("/Items", params)
    local response, err = network.sync_get(url)

    if not response then
        return nil, "Connection Error: Server unreachable or Auth failed."
    end

    local result = mp_utils.parse_json(response)
    if not result then
        return nil, "Invalid JSON response from server."
    end

    -- If search returned no items, try fallback request without search term
    if (not result.Items or #result.Items == 0) and search_query then
        params.searchTerm = nil
        local fallback_url = utils.make_url("/Items", params)
        local fallback_resp = network.sync_get(fallback_url)
        if fallback_resp then
            local fallback_result = mp_utils.parse_json(fallback_resp)
            if fallback_result and fallback_result.Items then
                items_cache[cache_key] = { time = now, data = fallback_result.Items }
                return fallback_result.Items, nil
            end
        end
    end

    local final_items = result.Items or {}
    items_cache[cache_key] = { time = now, data = final_items }
    return final_items, nil
end

--- Fetches episodes for the season following current season_id in series_id
---@param season_id string|nil
---@param series_id string|nil
---@return table|nil
function api.get_next_season_episodes(season_id, series_id)
    if not season_id and not series_id then return nil end

    -- If series_id is missing, look up season item details to retrieve ParentId (the series_id)
    if season_id and not series_id then
        local season_details = api.get_item_by_id(season_id)
        if season_details then
            series_id = season_details.ParentId or season_details.SeriesId
        end
    end

    if not series_id then return nil end

    local seasons = api.get_items(series_id)
    if not seasons or #seasons == 0 then return nil end

    local current_season_idx = nil
    for i = 1, #seasons do
        if seasons[i].Id == season_id then
            current_season_idx = i
            break
        end
    end

    if not current_season_idx or current_season_idx >= #seasons then
        return nil
    end

    local next_season = seasons[current_season_idx + 1]
    if not next_season then return nil end

    msg.info("Found next season: " .. tostring(next_season.Name or "Next Season"))
    return api.get_items(next_season.Id)
end

--- Fetches additional parts for multi-part items
---@param item_id string
---@return table|nil
function api.get_additional_parts(item_id)
    local url = utils.make_url("/Videos/" .. item_id .. "/AdditionalParts")
    local response, err = network.sync_get(url)
    if not response then return nil end
    local result = mp_utils.parse_json(response)
    return result and result.Items or nil
end

--- Async request to mark an item as played on Jellyfin server
---@param item_id string
---@param on_success function|nil
function api.mark_played_async(item_id, on_success)
    local session = config.getSessionData()
    if not session.UserId or not item_id then return end
    local url = utils.make_url("/Users/" .. session.UserId .. "/PlayedItems/" .. item_id)
    network.async_post(url, nil, nil, 3, function(err)
        msg.warn("Failed to mark item as played: " .. tostring(err))
    end, function(res)
        msg.info("Marked item " .. item_id .. " as played.")
        if on_success then on_success() end
    end)
end

--- Reports playback started to Jellyfin
---@param item_id string
---@param position_ticks number
function api.report_playing_started(item_id, position_ticks)
    if not item_id then return end
    local url = utils.make_url("/Sessions/Playing")
    local payload = {
        ItemId = item_id,
        PositionTicks = math.floor(position_ticks or 0),
        PlayMethod = "DirectPlay",
    }
    network.async_post(url, mp_utils.format_json(payload), nil, 1, function(err) end, function(res) end)
end

--- Reports periodic playback progress to Jellyfin
---@param item_id string
---@param position_ticks number
---@param is_paused boolean
function api.report_playing_progress(item_id, position_ticks, is_paused)
    if not item_id then return end
    local url = utils.make_url("/Sessions/Playing/Progress")
    local payload = {
        ItemId = item_id,
        PositionTicks = math.floor(position_ticks or 0),
        IsPaused = is_paused or false,
        PlayMethod = "DirectPlay",
        EventName = is_paused and "pause" or "timeupdate",
    }
    network.async_post(url, mp_utils.format_json(payload), nil, 1, function(err) end, function(res) end)
end

--- Reports playback stopped to Jellyfin
---@param item_id string
---@param position_ticks number
function api.report_playing_stopped(item_id, position_ticks)
    if not item_id then return end
    local url = utils.make_url("/Sessions/Playing/Stopped")
    local payload = {
        ItemId = item_id,
        PositionTicks = math.floor(position_ticks or 0),
        PlayMethod = "DirectPlay",
    }
    network.async_post(url, mp_utils.format_json(payload), nil, 1, function(err) end, function(res) end)
end

--- Returns video stream URL for playback
---@param item_id string
---@return string
function api.get_stream_url(item_id)
    return utils.make_url("/Videos/" .. item_id .. "/stream", { static = "true" })
end

--- Returns subtitle stream URL
---@param item_id string
---@param source_id string
---@param stream_index number|string
---@param ext string
---@return string
function api.get_subtitle_url(item_id, source_id, stream_index, ext)
    return utils.make_url("/Videos/" .. item_id .. "/" .. source_id .. "/Subtitles/" .. stream_index .. "/Stream." .. ext)
end

--- Returns primary image URL
---@param item_id string
---@param width number
---@param height number
---@return string
function api.get_primary_image_url(item_id, width, height)
    return utils.make_url("/Items/" .. item_id .. "/Images/Primary", { width = width, height = height })
end

return api
