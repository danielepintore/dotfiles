local mp = require 'mp'
local msg = require 'mp.msg'
local config = require 'config'
local utils = require 'utils'
local api = require 'api'
local image = require 'image'
local player = require 'player'

local input_success, input = pcall(require, "user-input-module")

local ui = {}

local overlay = nil
local meta_overlay = nil
local shown = false

local parent_id = { "", "", "", "" }
local selection = { 1, 1, 1, 1 }
local list_start = { 1, 1, 1, 1 }
local layer = 1
local items = {}
local user_query = ""

local ow, oh, op = 0, 0, 0

local align_x = 1 -- 1 = left, 2 = center, 3 = right
local align_y = 4 -- 4 = top, 8 = center, 0 = bottom
local align_other = "{\\a7}"

--- Returns whether UI overlay is currently shown
---@return boolean
function ui.is_shown()
    return shown
end

--- Returns current items table
---@return table
function ui.get_items()
    return items
end

--- Alignment calculation helper
local function set_align()
    align_other = "{\\a" .. ((4 - align_x) + align_y) .. "}"
end

--- Formats metadata overlay for selected item (Top-Right section)
---@param item table|nil
local function update_metadata(item)
    if not meta_overlay then return end
    meta_overlay.data = ""
    if not item then
        meta_overlay:update()
        return
    end

    local name = utils.line_break(item.Name, align_other .. "{\\fs24}", 35)
    meta_overlay.data = meta_overlay.data .. name .. "\n"

    local year = item.ProductionYear and tostring(item.ProductionYear) or ""
    local time = item.RunTimeTicks and ("   " .. math.floor(item.RunTimeTicks / 600000000) .. "m") or ""
    local rating = item.CommunityRating and ("   " .. tostring(item.CommunityRating)) or ""

    local hidden = ""
    local watched = ""
    if item.UserData then
        if item.UserData.Played == false then
            if config.hide_spoilers ~= "off" then
                hidden = "{\\bord0}{\\1a&HFF&}"
            end
        else
            watched = "   Watched"
        end
    end

    local favourite = (item.UserData and item.UserData.IsFavorite == true) and "   Favorite" or ""

    meta_overlay.data = meta_overlay.data .. align_other .. "{\\fs16}" .. year .. time .. rating .. watched .. favourite .. "\n\n"

    if item.Taglines and item.Taglines[1] then
        local tagline = utils.line_break(item.Taglines[1], align_other .. "{\\fs20}", 35)
        meta_overlay.data = meta_overlay.data .. tagline .. "\n"
    end

    if item.Overview then
        local description = utils.line_break(item.Overview, align_other .. "{\\fs16}" .. hidden, 38)
        meta_overlay.data = meta_overlay.data .. description
    end

    meta_overlay:update()
end

--- Formats items list overlay with pagination and ASS colors (Left side)
local function update_list()
    if not overlay then return end
    overlay.data = ""
    local magic_num = 29

    if selection[layer] - list_start[layer] > magic_num then
        list_start[layer] = selection[layer] - magic_num
    elseif selection[layer] - list_start[layer] < 0 then
        list_start[layer] = selection[layer]
    end

    local i = list_start[layer]
    while i <= list_start[layer] + magic_num do
        if i > #items then break end

        local index = ""
        if items[i].IndexNumber and items[i].IsFolder == false then
            index = items[i].IndexNumber .. ". "
        end

        overlay.data = overlay.data .. "{\\fs16}{\\c&H"
        if i == selection[layer] then
            overlay.data = overlay.data .. config.colour_selected
        elseif items[i].UserData and items[i].UserData.Played == true then
            overlay.data = overlay.data .. config.colour_watched
        else
            overlay.data = overlay.data .. config.colour_default
        end

        overlay.data = overlay.data .. "&}" .. index .. (items[i].Name or "Unknown") .. "\n"
        i = i + 1
    end

    overlay:update()
end

--- Updates entire UI view data (list, poster image, metadata)
function ui.update_data()
    update_list()
    local item = items[selection[layer]]
    image.update(item, ow, oh, align_x, align_y, ui.is_shown)
    update_metadata(item)
end

--- Fetches items from Jellyfin server and updates overlay view
function ui.update_overlay()
    if not overlay then return end
    overlay.data = "{\\fs16}Loading..."
    overlay:update()

    local result_items, err = api.get_items(parent_id[layer], config.sort_mode, layer, user_query)
    if err ~= nil or result_items == nil then
        overlay.data = "{\\fs16}" .. (err or "Connection Error: Server unreachable or Auth failed.")
        overlay:update()
        if meta_overlay then meta_overlay.data = ""; meta_overlay:update() end
        image.remove()
        items = {}
        return
    end

    if #result_items == 0 then
        overlay.data = "{\\fs16}No items found in this folder."
        overlay:update()
        if meta_overlay then meta_overlay.data = ""; meta_overlay:update() end
        image.remove()
        items = {}
        return
    end

    local expanded_items = {}
    for i = 1, #result_items do
        local item = result_items[i]
        local part_count = item.PartCount or 1
        if part_count > 1 then
            local new_items = api.get_additional_parts(item.Id)
            if new_items and #new_items > 0 then
                local base_name = item.Name or "Part"
                local first_part = {}
                for k, v in pairs(item) do first_part[k] = v end
                first_part.Name = base_name .. " (Part 1)"
                first_part.PartCount = 1
                table.insert(expanded_items, first_part)
                
                for j = 1, part_count - 1 do
                    if new_items[j] then
                        local part_item = {}
                        for k, v in pairs(item) do part_item[k] = v end
                        part_item.Id = new_items[j].Id
                        part_item.Name = base_name .. " (Part " .. (j + 1) .. ")"
                        part_item.PartCount = 1
                        table.insert(expanded_items, part_item)
                    end
                end
            else
                table.insert(expanded_items, item)
            end
        else
            table.insert(expanded_items, item)
        end
    end

    items = expanded_items
    ui.update_data()
end

-- Navigation actions
local function move_up()
    if #items > 1 then
        selection[layer] = selection[layer] - 1
        if selection[layer] <= 0 then selection[layer] = #items end
        ui.update_data()
    end
end

local function move_down()
    if #items > 1 then
        selection[layer] = selection[layer] + 1
        if selection[layer] > #items then selection[layer] = 1 end
        ui.update_data()
    end
end

local function move_right()
    if #items == 0 then return end
    local item = items[selection[layer]]
    if not item then return end

    if item.IsFolder == false then
        player.play_video(items, selection[layer], ui.disable)
    else
        layer = layer + 1
        parent_id[layer] = item.Id
        selection[layer] = 1
        user_query = ""
        ui.update_overlay()
    end
end

local function move_left()
    if layer <= 1 then return end
    layer = layer - 1
    user_query = ""
    ui.update_overlay()
end

local function key_up()
    if align_y == 0 then move_down() else move_up() end
end

local function key_down()
    if align_y == 0 then move_up() else move_down() end
end

local function key_right()
    if align_x == 3 then move_left() else move_right() end
end

local function key_left()
    if align_x == 3 then move_right() else move_left() end
end

local function toggle_watched()
    if #items == 0 then return end
    local item = items[selection[layer]]
    if not item or not item.Id then return end

    if not item.UserData then
        item.UserData = {}
    end

    local is_played = item.UserData.Played == true
    if is_played then
        item.UserData.Played = false
        ui.update_data()
        api.mark_unplayed_async(item.Id, function()
            player.show_popup("Marked as unwatched", 2)
        end)
    else
        item.UserData.Played = true
        ui.update_data()
        api.mark_played_async(item.Id, function()
            player.show_popup("Marked as watched", 2)
        end)
    end
end

--- Toggles UI overlays and keybindings
function ui.toggle()
    if shown then
        mp.remove_key_binding("jup")
        mp.remove_key_binding("jright")
        mp.remove_key_binding("jdown")
        mp.remove_key_binding("jleft")
        
        mp.remove_key_binding("jvup")
        mp.remove_key_binding("jvright")
        mp.remove_key_binding("jvdown")
        mp.remove_key_binding("jvleft")

        mp.remove_key_binding("jselect_enter")
        mp.remove_key_binding("jselect_space")
        mp.remove_key_binding("jback")
        mp.remove_key_binding("jtoggle_watched")

        image.remove()
        if overlay then overlay:remove() end
        if meta_overlay then meta_overlay:remove() end
    else
        mp.add_forced_key_binding("UP", "jup", key_up, { repeatable = true })
        mp.add_forced_key_binding("RIGHT", "jright", key_right)
        mp.add_forced_key_binding("DOWN", "jdown", key_down, { repeatable = true })
        mp.add_forced_key_binding("LEFT", "jleft", key_left)

        mp.add_forced_key_binding("k", "jvup", key_up, { repeatable = true })
        mp.add_forced_key_binding("l", "jvright", key_right)
        mp.add_forced_key_binding("j", "jvdown", key_down, { repeatable = true })
        mp.add_forced_key_binding("h", "jvleft", key_left)

        mp.add_forced_key_binding("ENTER", "jselect_enter", move_right)
        mp.add_forced_key_binding("SPACE", "jselect_space", move_right)
        mp.add_forced_key_binding("BS", "jback", move_left)
        mp.add_forced_key_binding("w", "jtoggle_watched", toggle_watched)

        local session = config.getSessionData()
        if not session.ApiKey or session.ApiKey == "" then
            if overlay then
                overlay.data = "{\\fs16}Authenticating..."
                overlay:update()
            end
            api.login()
        end

        if #items == 0 then
            ui.update_overlay()
        else
            ui.update_data()
        end
    end
    shown = not shown
end

--- Disables and hides UI overlay
function ui.disable()
    if shown then
        ui.toggle()
    end
end

--- Executes search query and opens overlay
---@param query string|nil
function ui.search(query)
    if query then
        user_query = utils.url_fix(query) .. "&recursive=true"
        shown = false
        items = {}
        ui.toggle()
    end
end

--- Prompts user for search input using user-input-module if present
function ui.search_input()
    if input_success and input then
        input.get_user_input(ui.search)
    else
        msg.warn("user-input-module not found, search disabled.")
    end
end

-- Property Observers
function ui.on_width_change(name, data)
    ow, oh, op = mp.get_osd_size()
    if shown and #items > 0 then
        image.update(items[selection[layer]], ow, oh, align_x, align_y, ui.is_shown)
    end
end

function ui.on_align_x_change(name, data)
    if data == "right" then
        align_x = 3
    elseif data == "center" then
        align_x = 2
    else
        align_x = 1
    end
    set_align()
end

function ui.on_align_y_change(name, data)
    if data == "bottom" then
        align_y = 0
    elseif data == "center" then
        align_y = 8
    else
        align_y = 4
    end
    set_align()
end

function ui.on_idle_change(_, is_idle)
    if is_idle and not shown and config.show_on_idle == "on" then
        ui.toggle()
    end
end

--- Initializes ASS overlay objects
function ui.init()
    overlay = mp.create_osd_overlay("ass-events")
    meta_overlay = mp.create_osd_overlay("ass-events")
    set_align()
end

return ui
