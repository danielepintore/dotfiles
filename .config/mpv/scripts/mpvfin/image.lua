local mp = require 'mp'
local msg = require 'mp.msg'
local config = require 'config'
local utils = require 'utils'
local api = require 'api'

local image = {}

local active_async_cmd = nil
local scale = 2

--- Initializes image storage directory
function image.init()
    if config.hide_images ~= "on" then
        utils.mkdir(config.image_path)
    end
end

--- Removes poster image overlay and cancels ongoing conversion task
function image.remove()
    if active_async_cmd ~= nil then
        mp.abort_async_command(active_async_cmd)
        active_async_cmd = nil
    end
    mp.commandv("overlay-remove", "0")
end

--- Internal handler when image generation completes
local function on_image_ready(success, result, error, userdata, is_shown_fn)
    active_async_cmd = nil
    if not success or not result or result.status ~= 0 then
        if result and not result.killed_by_us then
            msg.error("Failed to create image: " .. tostring(result.status))
        end
        return
    end

    local width, height, filepath, align_x, align_y, ow, oh, dw, dh = unpack(userdata)

    local margin_x = 40
    local margin_y = 40
    local x = (align_x == 3) and margin_x or math.floor(ow - dw - margin_x)
    local y = (align_y == 0) and margin_y or math.floor(oh - dh - margin_y)

    if is_shown_fn and is_shown_fn() then
        mp.command_native({
            name = "overlay-add",
            id = 0,
            x = x,
            y = y,
            file = filepath,
            offset = 0,
            fmt = "bgra",
            w = width,
            h = height,
            stride = width * 4,
            dw = dw,
            dh = dh
        })
    end
end

local current_image_state = {}

--- Updates the poster image overlay for the given item
---@param item table|nil
---@param ow number
---@param oh number
---@param align_x number
---@param align_y number
---@param is_shown_fn function
function image.update(item, ow, oh, align_x, align_y, is_shown_fn)
    if config.hide_images == "on" or not item or ow <= 0 or oh <= 0 then
        image.remove()
        current_image_state = {}
        return
    end

    local image_item_id = nil
    if item.ImageTags and item.ImageTags.Primary then
        image_item_id = item.Id
    elseif item.SeriesPrimaryImageTag and item.SeriesId then
        image_item_id = item.SeriesId
    elseif item.ParentPrimaryImageTag and item.ParentId then
        image_item_id = item.ParentId
    elseif item.ParentPrimaryImageTag and item.SeasonId then
        image_item_id = item.SeasonId
    end

    if image_item_id then
        -- Handle image spoilers for unwatched episodes
        local should_blur = false
        if item.IsFolder == false and item.UserData and item.UserData.Played == false then
            if config.image_spoiler == "hide" then
                return
            elseif config.image_spoiler == "blur" then
                should_blur = true
            end
        end

        local target_dw = math.floor(ow * 0.20)
        if target_dw <= 0 then target_dw = 180 end

        local aspect = item.PrimaryImageAspectRatio or 0.666
        local target_dh = math.floor(target_dw / aspect)
        if target_dh <= 0 then target_dh = 270 end

        local width = math.floor(target_dw / scale)
        local height = math.floor(target_dh / scale)

        local blur_suffix = should_blur and "_blur" or ""
        local blur_filter = should_blur and "boxblur=20," or ""
        local filepath = config.image_path .. "/" .. image_item_id .. "_" .. width .. "_" .. height .. blur_suffix .. ".bgra"
        local img_url = api.get_primary_image_url(image_item_id, width, height)

        if current_image_state.filepath == filepath and
           current_image_state.ow == ow and
           current_image_state.oh == oh and
           current_image_state.align_x == align_x and
           current_image_state.align_y == align_y then
            return
        end

        image.remove()
        current_image_state = { filepath = filepath, ow = ow, oh = oh, align_x = align_x, align_y = align_y }

        -- If the processed image already exists, load it immediately
        local f = io.open(filepath, "r")
        if f then
            f:close()
            on_image_ready(true, {status = 0}, nil, { width, height, filepath, align_x, align_y, ow, oh, target_dw, target_dh }, is_shown_fn)
            return
        end

        active_async_cmd = mp.command_native_async({
            name = "subprocess",
            playback_only = false,
            args = {
                "mpv",
                img_url,
                "--no-config",
                "--msg-level=all=no",
                "--vf=lavfi=[" .. blur_filter .. "format=bgra]",
                "--of=rawvideo",
                "--o=" .. filepath
            }
        }, function(success, result, error)
            on_image_ready(success, result, error, { width, height, filepath, align_x, align_y, ow, oh, target_dw, target_dh }, is_shown_fn)
        end)
    end
end

return image
