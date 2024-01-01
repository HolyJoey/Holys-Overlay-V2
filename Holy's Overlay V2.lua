--[[
    Made by holyjoey.
    Credits to:
    nova_plays: allowed me to use NovaLay for new base of the overlay.
    Everyone from previous project
]]

util.keep_running()
util.require_natives()

local colors = {
    background_rect = {r = 0, g = 0, b = 0, a = 175/255},
    top_border = {r = 0, g = 0, b = 0, a = 1.0},
    subhead = {r = 1, g = 1, b = 1, a = 1},
    left_aligned_text = {r = 1, g = 1, b = 1, a = 1},
    right_aligned_text = {r = 160/255, g = 160/255, b = 160/255, a = 1.0},
}

function map_number(number)
    number = number + 2
    local num = 0
    if number == 5 then
        num =  1
    elseif number > 5 then
        num = 1 + (number - 5) * 0.1
    else
        num = 1 - (5 - number) * 0.1
    end
    return ((1.6 - num) % 1.5) * 2
end

function draw_info_text(text, infotext, posX, posY, posX2, size1, size2, info_text_clr)
    local draw_text = directx.draw_text(posX, posY, text, ALIGN_TOP_LEFT, size1, colors.left_aligned_text, true)
    local second_text_width, second_text_height = directx.get_text_size(text, size1)
    local posY2 = posY + (second_text_height/8)
    local draw_infotext = directx.draw_text(posX2, posY2, infotext, ALIGN_TOP_RIGHT, size2, info_text_clr, true)
end

local root = menu.my_root()
local colors_list = root:list("Colors")
local top_color = colors_list:list("Top Border")
local background_color = colors_list:list("Background Border")
local toptext_color = colors_list:list("Top Text Border")
local left_color = colors_list:list("Left Aligned Text")
local right_color = colors_list:list("Right Aligned Text")

-- TOP BORDER COLOR --
menu.rainbow(
    top_color:colour("Top Border Color", {}, "", colors.top_border, true, function(color)
    colors.top_border = color
end))

-- BACKGROUND COLOR --
menu.rainbow(
    background_color:colour("Background Color", {}, "", colors.background_rect, true, function(color)
    colors.background_rect = color
end))

-- SUBHEAD COLOR --
menu.rainbow(
    toptext_color:colour("Top Text Color", {}, "", colors.subhead, true, function(color)
    colors.subhead = color
end))

-- LEFT ALIGNED TEXT COLOR --
menu.rainbow(
    left_color:colour("Left Aligned Text Color", {}, "", colors.left_aligned_text, true, function(color)
    colors.left_aligned_text = color
end))

-- RIGHT ALIGNED TEXT COLOR --
menu.rainbow(
    right_color:colour("Right Aligned Text Color", {}, "", colors.right_aligned_text, true, function(color)
    colors.right_aligned_text = color
end))

-- CHANGE POSITION X --
local current_position_X, current_position_Y = 0.17, 0.725
local position_change_X, position_change_Y = current_position_X, current_position_Y

root:slider("Change Position X", {"xpos"}, "", 0, 1000, current_position_X * 1000, 1, function(count)
    current_position_X = current_position_X + (count/1000)
    position_change_X = (count/1000)
end)

-- CHANGE POSITION Y --
root:slider("Change Position Y", {"ypos"}, "", 0, 1000, current_position_Y * 1000, 1, function(count)
    current_position_Y = current_position_Y + (count/1000)
    position_change_Y = (count/1000)
end)

-- Damn this looks a lot like Toph's work uhhhhh
local function SessionType()
    if util.is_session_started() then
        if NETWORK.NETWORK_SESSION_IS_PRIVATE() then
            return "Invite Only"
        elseif NETWORK.NETWORK_SESSION_IS_CLOSED_CREW() then
            return "Crew Only"
        elseif NETWORK.NETWORK_SESSION_IS_CLOSED_FRIENDS() then
            return "Friends Only"
        elseif NETWORK.NETWORK_SESSION_IS_SOLO() then
            return "Solo"
        else
            return "Public"
        end
    end
    return "Singleplayer"
end

local fps = 0
util.create_thread(function()
    while true do
        fps = math.ceil(1/SYSTEM.TIMESTEP())
        util.yield(1000)
    end
end)

local replayInterface = memory.read_long(memory.rip(memory.scan("48 8D 0D ? ? ? ? 48 8B D7 E8 ? ? ? ? 48 8D 0D ? ? ? ? 8A D8 E8 ? ? ? ? 84 DB 75 13 48 8D 0D") + 3))
local pedInterface = memory.read_long(replayInterface + 0x0018)
local vehInterface = memory.read_long(replayInterface + 0x0010)
local objectInterface = memory.read_long(replayInterface + 0x0028)
local pickupInterface = memory.read_long(replayInterface + 0x0020)

--Change info title
local infoTitle = SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME()
menu.text_input(menu.my_root(), "Change Title", { "ChangeTitle" }, "", function(fuck)
    infoTitle = fuck
end)

menu.toggle(menu.my_root(), "Disable Top Border", {""}, "", function(on)
    top_border_toggle = on
    util.yield()
end)

util.create_tick_handler(function()
        local mapped_number = map_number(3)
        local mapped_number_text = ((6 - 3) % 5)
        if not top_border_toggle then
            directx.draw_rect(position_change_X, position_change_Y, 0.11 / mapped_number, 0.03 / mapped_number, colors.top_border)
            directx.draw_text(position_change_X + ((0.11 / mapped_number) / 2), position_change_Y + ((0.03 / mapped_number) / 2), infoTitle, ALIGN_CENTRE, 0.45 / (mapped_number_text / 3.5), colors.subhead, true)
        end
        directx.draw_rect(position_change_X, position_change_Y + (0.03 / mapped_number), 0.11 / mapped_number, 0.28 / mapped_number, colors.background_rect)

        local posX_left = position_change_X + 0.0035
        local player_info_offset = posX_left + (0.1 / mapped_number)
        local text_size = 0.40 / (mapped_number_text / 3)
        local infotext_size = 0.35 / (mapped_number_text / 3)

        -- Count players in the session
        local playercount = 0
        for i, pid in pairs(players.list(true, true, true)) do
            playercount = playercount + 1
        end

        -- Count modders in the session
        local moddercount = 0
        for i, pid in pairs(players.list(true, true, true)) do
            if players.is_marked_as_modder(pid) then
                moddercount = moddercount + 1
            end
        end

        -- Count friends in the session
        local friendcount = 0
        for i, pid in pairs(players.list(false, true, false)) do
            friendcount = friendcount + 1
        end

        -- Count strangers in the session
        local strangercount = 0
        for i, pid in pairs(players.list(false, false, true)) do
            strangercount = strangercount + 1
        end

        -- Player Info --
        draw_info_text("Session Type:", SessionType(), posX_left, position_change_Y + (0.04 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Host:", players.get_name(players.get_host()), posX_left, position_change_Y + (0.06 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("SH:", players.get_name(players.get_script_host()), posX_left, position_change_Y + (0.08 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Players:", playercount, posX_left, position_change_Y + (0.1 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Modders:", moddercount, posX_left, position_change_Y + (0.12 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Friends:", friendcount, posX_left, position_change_Y + (0.14 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Strangers:", strangercount, posX_left, position_change_Y + (0.16 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Time:", os.date("%X"), posX_left, position_change_Y + (0.18 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("FPS:", fps, posX_left, position_change_Y + (0.2 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Peds:", memory.read_int(pedInterface + 0x0110).."/"..memory.read_int(pedInterface + 0x0108), posX_left, position_change_Y + (0.22 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Vehicles:", memory.read_int(vehInterface + 0x0190).."/"..memory.read_int(vehInterface + 0x0188), posX_left, position_change_Y + (0.24 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Objects:", memory.read_int(objectInterface + 0x0168).."/"..memory.read_int(objectInterface + 0x0160), posX_left, position_change_Y + (0.26 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
        draw_info_text("Pickups:", memory.read_int(pickupInterface + 0x0110).."/"..memory.read_int(pickupInterface + 0x0108), posX_left, position_change_Y + (0.28 / mapped_number), player_info_offset, text_size, infotext_size, colors.right_aligned_text)
end)
