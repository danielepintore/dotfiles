local mp = require 'mp'
local msg = require 'mp.msg'
local config = require 'config'
local utils = require 'utils'
local api = require 'api'

local player = {}
local active_playlist_items = {}
local current_playing_item = nil
local last_reported_pos = 0
local progress_timer_counter = 0
local next_season_queued_for_item = nil

local popup_overlay = mp.create_osd_overlay("ass-events")
local popup_timer = nil

--- Formats seconds into HH:MM:SS or MM:SS format for OSD display
---@param seconds number
---@return string
local function format_time(seconds)
    seconds = math.floor(seconds or 0)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    else
        return string.format("%d:%02d", m, s)
    end
end

--- Shows a temporary clean OSD popup in top-right corner using ASS overlay
---@param text string
---@param duration number|nil
function player.show_popup(text, duration)
    if popup_timer then
        popup_timer:kill()
        popup_timer = nil
    end
    popup_overlay.data = "{\\an9}{\\fs14}{\\b1}✓ " .. text
    popup_overlay:update()
    popup_timer = mp.add_timeout(duration or 4, function()
        popup_overlay:remove()
        popup_timer = nil
    end)
end

--- Checks if current item is the last episode of its season and dynamically queues the next season
---@param item table|nil
local function check_and_queue_next_season(item)
    if not item or next_season_queued_for_item == item.Id then return end
    if config.use_playlist == "off" then return end

    local season_id = item.SeasonId or item.ParentId
    local series_id = item.SeriesId

    -- Find all items belonging to current season in active_playlist_items
    local current_season_items = {}
    for _, ep in ipairs(active_playlist_items) do
        local ep_season = ep.SeasonId or ep.ParentId
        if (season_id and ep_season == season_id) or not season_id then
            table.insert(current_season_items, ep)
        end
    end

    -- Check if current playing item is the last episode of its season
    local last_ep_in_season = current_season_items[#current_season_items]
    if last_ep_in_season and last_ep_in_season.Id == item.Id then
        next_season_queued_for_item = item.Id

        local next_episodes = api.get_next_season_episodes(season_id, series_id)
        if next_episodes and #next_episodes > 0 then
            msg.info("Queuing " .. #next_episodes .. " episodes from the next season to playlist.")
            
            -- Create an m3u8 playlist to append the next season with correct titles
            local m3u_path = mp.command_native({"expand-path", "~~/mpvfin_next_season.m3u8"})
            local f = io.open(m3u_path, "w")
            if f then
                f:write("#EXTM3U\n")
                for _, ep in ipairs(next_episodes) do
                    if ep and ep.IsFolder == false then
                        f:write("#EXTINF:-1," .. (ep.Name or "Episode") .. "\n")
                        f:write(api.get_stream_url(ep.Id) .. "\n")
                        table.insert(active_playlist_items, ep)
                    end
                end
                f:close()
                mp.commandv("loadlist", m3u_path, "append")
                player.show_popup("Next Season Queued", 3)
            end
        end
    end
end

--- Starts playback of selected video item and appends remaining episodes in folder to playlist
---@param items table
---@param selection_idx number
---@param on_overlay_hide function
function player.play_video(items, selection_idx, on_overlay_hide)
    if not items or #items == 0 or not selection_idx or not items[selection_idx] then
        return
    end

    if on_overlay_hide then
        on_overlay_hide()
    end

    -- Report stop for previous item if still playing
    if current_playing_item then
        api.report_playing_stopped(current_playing_item.Id, last_reported_pos * 10000000)
        current_playing_item = nil
    end

    next_season_queued_for_item = nil

    -- Store active playlist items in player module
    active_playlist_items = {}
    for _, item in ipairs(items) do
        table.insert(active_playlist_items, item)
    end

    mp.commandv("playlist-play-index", "none")
    mp.command("playlist-clear")

    if config.use_playlist ~= "off" then
        -- Generate an m3u8 playlist file to natively support episode titles in mpv's playlist
        local m3u_path = mp.command_native({"expand-path", "~~/mpvfin_playlist.m3u8"})
        local f = io.open(m3u_path, "w")
        if f then
            f:write("#EXTM3U\n")
            local playlist_target_idx = 0
            local current_idx = 0
            for i = 1, #items do
                if items[i].IsFolder == false then
                    if i == selection_idx then
                        playlist_target_idx = current_idx
                    end
                    f:write("#EXTINF:-1," .. (items[i].Name or "Video") .. "\n")
                    f:write(api.get_stream_url(items[i].Id) .. "\n")
                    current_idx = current_idx + 1
                end
            end
            f:close()

            mp.commandv("loadlist", m3u_path, "replace")
            mp.commandv("playlist-play-index", playlist_target_idx)
        end
    else
        -- If playlist is disabled, just load the single item
        local target_item = items[selection_idx]
        mp.commandv("loadfile", api.get_stream_url(target_item.Id), "replace")
        if target_item.Name then
            mp.set_property("force-media-title", target_item.Name)
        end
    end
end

--- Attempts to match current playing video path with item ID in active items list
---@param items table|nil
---@return table|nil
function player.get_playing_item(items)
    local check_items = items
    if not check_items or #check_items == 0 then
        check_items = active_playlist_items
    end
    if not check_items or #check_items == 0 then return nil end

    local path = mp.get_property("path")
    if not path then return nil end

    local video_id = path:match("Videos/([^/?]+)")
    if not video_id then
        local parts = utils.split(path, '/')
        for i = 1, #parts do
            if parts[i] == "Videos" and parts[i + 1] then
                video_id = parts[i + 1]
                break
            end
        end
    end

    if not video_id then return nil end

    -- Check primary list first
    for i = 1, #check_items do
        if check_items[i].Id == video_id then
            return check_items[i]
        end
    end

    -- Fallback check active_playlist_items if different
    if check_items ~= active_playlist_items then
        for i = 1, #active_playlist_items do
            if active_playlist_items[i].Id == video_id then
                return active_playlist_items[i]
            end
        end
    end

    return nil
end

--- Automatically sets media title, resumes saved progress, queues next season if on season end, and loads external text subtitles
---@param items table|nil
function player.on_file_loaded(items)
    local item = player.get_playing_item(items)
    if not item then return end

    current_playing_item = item
    last_reported_pos = 0
    progress_timer_counter = 0

    if item.Name then
        mp.set_property("force-media-title", item.Name)
    end

    -- Check saved resume position
    local ticks = (item.UserData and item.UserData.PlaybackPositionTicks) or 0
    local resume_sec = math.floor(ticks / 10000000)
    local duration = mp.get_property_number("duration") or 0

    if resume_sec > 5 and (duration == 0 or resume_sec < duration - 15) then
        mp.commandv("seek", resume_sec, "absolute")
        player.show_popup("Resumed at " .. format_time(resume_sec), 4)
        last_reported_pos = resume_sec
    end

    -- Check if current episode is the last in season and dynamically queue next season
    check_and_queue_next_season(item)

    -- Report playback started to Jellyfin server
    api.report_playing_started(item.Id, last_reported_pos * 10000000)

    -- Auto-add external text subtitles
    if item.MediaSources then
        for _, source in ipairs(item.MediaSources) do
            if source.Id == item.Id and source.MediaStreams then
                for _, stream in ipairs(source.MediaStreams) do
                    if stream.IsTextSubtitleStream == true and stream.IsExternal == true then
                        local ext = stream.Path and stream.Path:match(".+%.([^.]+)$") or "srt"
                        local sub_url = api.get_subtitle_url(item.Id, source.Id, stream.Index, ext)
                        mp.commandv("sub-add", sub_url, "auto", stream.DisplayTitle or "Subtitle", stream.Language or "")
                    end
                end
                break
            end
        end
    end
end

--- Checks playback progress, periodically updates Jellyfin server, and marks item as watched when >89%
---@param items table|nil
function player.check_watch_progress(items)
    local item = current_playing_item or player.get_playing_item(items)
    if not item then return end

    local pos_sec = mp.get_property_number("time-pos")
    if not pos_sec then return end

    last_reported_pos = pos_sec
    progress_timer_counter = progress_timer_counter + 1

    -- Send progress update to Jellyfin every 5 seconds
    if progress_timer_counter % 5 == 0 then
        local is_paused = mp.get_property_native("pause") or false
        local ticks = math.floor(pos_sec * 10000000)
        api.report_playing_progress(item.Id, ticks, is_paused)
    end

    -- Check played status (>89%)
    local percent = mp.get_property_number("percent-pos")
    if percent and percent > 89 and item.UserData and item.UserData.Played == false then
        item.UserData.Played = true
        api.mark_played_async(item.Id, function()
            player.show_popup("Marked as watched", 4)
        end)
    end
end

--- Reset properties and report playback stopped to Jellyfin when video ends or is stopped
function player.on_end_file()
    if current_playing_item then
        api.report_playing_stopped(current_playing_item.Id, math.floor(last_reported_pos * 10000000))
        current_playing_item = nil
    end
    last_reported_pos = 0
    progress_timer_counter = 0
    mp.set_property_bool("pause", false)
    mp.set_property("force-media-title", "")
end

return player
