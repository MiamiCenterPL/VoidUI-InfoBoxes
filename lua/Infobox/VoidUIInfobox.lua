--Class initialization and stuff
VoidUIInfobox = VoidUIInfobox or class()

_G.VoidUIInfobox = VoidUIInfobox
--Debug functions:

function VoidUIInfobox:DebugPrint(msg)
    log("[VoidUI Infoboxes]: "..tostring(msg))
    managers.chat:_receive_message(1, "[VoidUI Infoboxes]", tostring(msg), Color("#fc0394"))
end

function VoidUIInfobox:PrintBoxes()
    for idx,child in pairs(VoidUIInfobox:children()) do
        self:DebugPrint("ID: "..tostring(child.id).." | Name: "..tostring(child.name).." | Value: "..tostring(child.value).." | Time: "..tostring(child.time).." | Type: "..tostring(child._type))
    end
end

function VoidUIInfobox:Error(msg)
    log("[VoidUIInfobox]: "..tostring(msg))
end

function VoidUIInfobox:child(id)
    return VoidUIInfobox.childrens and VoidUIInfobox.childrens[id]
end

function VoidUIInfobox:children()
    return VoidUIInfobox.childrens and VoidUIInfobox.childrens or {}
end

function VoidUIInfobox:refresh_all()
    for idx,child in pairs(VoidUIInfobox:children()) do
        child:refresh()
    end
end

function VoidUIInfobox:refresh()
    local data = {
        name_id = self.string_id and self.string_id or nil,
        id = self.id and self.id or nil,
        name = self.name and self.name or nil,
        achievement_id = self._achievement_id and self._achievement_id or nil,
        type = self._type and self._type or nil,
        value = self.value and self.value or nil,
        time = self.time and self.time or nil,
        ap_rounds = self.ap_rounds and self.ap_rounds or nil,
        color_id = self.color_id and self.color_id or nil
    }
    self:remove()
    VoidUIInfobox:new(data)
end

--Fetch textures from VoidUI Infoboxes config
function VoidUIInfobox:get_texture_by_name()
    if VoidUI_IB.get_texture_by_name[self.string_id] then
        return VoidUI_IB.get_texture_by_name[self.string_id].texture, VoidUI_IB.get_texture_by_name[self.string_id].texture_rect
    else
        self:Error("This Infobox doesn't have texture! "..tostring(self.string_id))
        return VoidUI_IB.get_texture_by_name["Timer"].texture, VoidUI_IB.get_texture_by_name["Timer"].texture_rect
    end
end

--This function fetches the scale settings from VoidUI options.
function VoidUIInfobox:get_scale_options()
    local scale = managers.hud._hud_assault_corner and managers.hud._hud_assault_corner._scale or VoidUI.options.hud_assault_scale
    local panel_w, panel_h = 44 * scale, 38 * scale
    return scale, panel_w, panel_h
end

--Functions that you can override in your own class:

--Override this function to remove other stuff left behind.
function VoidUIInfobox:_remove()
    return
end

function VoidUIInfobox:check_valid()
    return true 
end

function VoidUIInfobox:FetchInfo()
    self._priority = 6
    self._type = "Counter"
end

function VoidUIInfobox:create(data)
    self._text_panel = self:new_text(data.value or "empty")
end

--Initialize the infobox
function VoidUIInfobox:init(data)
    if not data.id then
        self:Error("No ID provided!!!")
        log(tostring(debug.traceback()))
        self:remove()
        return
    end
    if self:child(data.id) then
        self:Error("Infobox already exists! "..tostring(data.id))
        log(tostring(debug.traceback()))
        self:remove()
        return
    end
    self.id = data.id
    self.string_id = data.name_id or data.id
    
    self:FetchInfo(data)

    if not self:check_valid(data) then
        self:remove()
        return
    end
    
    if self:PrepareBox() then
        self:create(data)
    else
        self:prepare_hud(data)
    end

    return self --Return the class soo other stuff can use a pointer to it.
end

function VoidUIInfobox:prepare_hud(data)
    local function _spawn_box(box)
        if box:PrepareBox(data) then
            box:create(data)
            box:_set_value(data.value and data.value or 0)
        else
            box:DebugPrint("Something is really wrong with the HUD scripts! "..tostring(self.id).." failed to load!")
            box:remove()
        end
    end
    if managers.hud._hud_assault_corner and managers.hud._hud_objectives then
        _spawn_box(self)
        return
    end
    HUDManager = HUDManager or class()
    Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", self.id.."_IBWaitingCallback", function()
        _spawn_box(self)
    end)
end

function VoidUIInfobox:get_hud(box_type) --Ready
    local hud
    local hud_option = VoidUI_IB.options["hud_"..box_type] or 1

    if self.is_floating_panel then
        hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
        if hud then
            return hud
        else
            self:Error("HUD is not loaded! "..tostring(self.id))
        end
    end

    local function pick_hud_assault_or_objectives(hud_option)
        if hud_option == 1 then
            if VoidUI.options.enable_assault then
                return managers.hud._hud_assault_corner
            elseif VoidUI.options.enable_objectives then
                self:Error("Assault HUD is not enabled, using objectives HUD instead.")
                return managers.hud._hud_objectives
            end
        elseif hud_option == 2 then
            if VoidUI.options.enable_objectives then
                return managers.hud._hud_objectives
            elseif VoidUI.options.enable_assault then
                self:Error("Objectives HUD is not enabled, using Assault HUD instead.")
                return managers.hud._hud_assault_corner
            end
        end
    end

    if hud_option <= 2 then
        hud = pick_hud_assault_or_objectives(hud_option)
    else
        hud_option = hud_option - 2
        hud = managers.hud._hud_infobox[hud_option]
        if VoidUI_IB.options[hud_option.."_"..self._priority.."_row_size"] <= #hud._custom_icons[self._priority] then
            local overflow_hud = VoidUI_IB.options[hud_option.."_hud_overflow"] or 3
            if overflow_hud == 3 then
                self:Error("Infobox HUD is full, removing infobox.")
                self:remove()
                return
            else
                hud = pick_hud_assault_or_objectives(overflow_hud)
            end
        end
    end
    
    if not hud then
        return false
    end

    return hud
end

--This function creates an icon and returns it.
function VoidUIInfobox:new_icon(texture, texture_rect) --Ready function!
    local color

    if VoidUI_HMV then
        if VoidUI_HMV.options.generic_colors then
            color = VoidUI_HMV:GetColor("icon_color")
        else
            color = VoidUI_HMV:GetColor(self.string_id.."_icon")
        end
    else
        color = Color(1,1,1)
    end
    local scale, panel_w, panel_h = self:get_scale_options()
	local new_icon = self._panel:bitmap({
		texture = texture,
		texture_rect = texture_rect or nil,
		valign = "top",
		alpha = 0.6,
		layer = 2,
		color = color,
		w = panel_w / 2.2,
		h = panel_h / 1.8,
		x = 0,
		y = 0
	})

	return new_icon
end

--This function creates a text panel and returns it.
function VoidUIInfobox:new_text(text, vertical, valign, align, word_wrap) --ready
    local color

    if VoidUI_HMV then
        if VoidUI_HMV.options.generic_colors then
            color = VoidUI_HMV:GetColor("text_color")
        else
            color = VoidUI_HMV:GetColor("num_"..self.string_id)
        end
    else
        color = Color(1,1,1)
    end
    local scale, panel_w, panel_h = self:get_scale_options()
    local new_text = self._panel:text({
        text = text or "x0",
        valign = valign or "right",
        vertical = vertical or "bottom",
        align = align or "right",
        word_wrap = word_wrap and word_wrap or false,
        wrap = word_wrap and word_wrap or false,
        w = panel_w / 1.5,
        h = panel_h,
        layer = 3,
        x = 0,
        y = 0,
        color = color,
        font = tweak_data.hud_corner.assault_font,
        font_size = panel_h / 2
    })
    new_text:set_center(self._background:center())
    return new_text
end

--This function creates a background and returns it.
function VoidUIInfobox:new_background()
	local highlight_texture = "guis/textures/VoidUI/hud_highlights"
    local scale, panel_w, panel_h = self:get_scale_options()
	local new_background = self._panel:bitmap({
        name = "background",
		texture = highlight_texture,
		texture_rect = {0,316,171,150},
		layer = 1,
		w = panel_w,
		h = panel_h,
		color = Color.black
	})
	return new_background
end

--This function creates a border and returns it.
function VoidUIInfobox:new_border()
	local highlight_texture = "guis/textures/VoidUI/hud_highlights"
    local scale, panel_w, panel_h = self:get_scale_options()
	local new_border = self._panel:bitmap({
        name = "border",
		texture = highlight_texture,
		texture_rect = {172,316,171,150},
		layer = 2,
		w = panel_w,
		h = panel_h,
	})
	return new_border
end
--This function removes entire infobox.
function VoidUIInfobox:remove()
    if not self._panel then
        if self then
            self = nil
            return
        end
    end
    local hud = self:get_hud(self._type)
    local _custom_icons = hud._custom_icons
    local icons_panel = hud._icons_panel and hud._icons_panel or hud.panel
    if _custom_icons and table.contains(_custom_icons[self._priority], self._panel) then
        table.remove(_custom_icons[self._priority], table.index_of(_custom_icons[self._priority], self._panel))
    end
    if alive(self._panel) then
        local panel_alpha = self._panel:alpha()
        local panel_x = self._panel:x()
        local panel_w = self._panel:w()
        self._panel:stop()
        self._panel:animate(function(o)
            over(0.4, function(p)
                if alive(self._panel) then
                    self._panel:set_alpha(math.lerp(panel_alpha, 0, p))
                    self._panel:set_x(math.lerp(panel_x, panel_x + panel_w, p))
                end
            end)
            
            if self.is_floating_panel then
                self._panel:parent():remove(self._panel)
                FloatingInfobox:remove_floating_box(self.id)
            else
                icons_panel:remove(self._panel)
            end

            self = nil
        end)
        VoidUIInfobox.childrens[self.id] = nil
    end
    if hud and hud.sort_boxes then
        hud:sort_boxes()
    end
    self:_remove()
end

function VoidUIInfobox:set_value(value)
    if not self._text_panel then
        if value then
            self:remove()
            self.value = value
            --Let's actually save this value *somewhere*
        end
        return --We don't have a text panel yet, so we can't set the value
    end
    if not self._set_value then
        self:Error("This infobox doesn't have a _set_value function!"..tostring(self.id))
        return
    end
    self:_set_value(value)
end

--This function is changing the font size of the text panel to fit the width of the infobox.
function VoidUIInfobox:FixFont(panel, font_size) --ready
    panel:set_font_size(font_size)
    local _,_,w,h = panel:text_rect()
    if w > panel:w() then
        panel:set_font_size(font_size * (panel:w() / w))
    end
    if h > panel:h() then
        panel:set_font_size(font_size * (panel:h() / h))
    end
end

--This function creates an Infobox frame with the icon, places it on the hud panel and is calling a sorting function.
--To add text to the infobox, please do it in other Class create() function.
function VoidUIInfobox:PrepareBox()
    local scale, panel_w, panel_h = self:get_scale_options()
    local hud = self:get_hud(self._type)

    VoidUIInfobox.childrens = VoidUIInfobox.childrens or {}
    VoidUIInfobox.childrens[self.id] = self

    if not hud then
        return false
    end
    local icons_panel = hud._icons_panel and hud._icons_panel or hud.panel --hud.panel is for Floating Infoboxes
    local _custom_icons = hud._custom_icons

    self._panel = icons_panel:panel({
		w = panel_w,
		h = panel_h,
		alpha = 1
	})

    self._background = self:new_background()
    self._border = self:new_border()
    local texture,texture_rect = self:get_texture_by_name()
    self._icon = self:new_icon(texture, texture_rect)
    self._icon:set_center(self._background:center())

    if _custom_icons then
        if self.position then
            table.insert(_custom_icons[self._priority], self.position, self._panel)
        else
            table.insert(_custom_icons[self._priority], self._panel)
        end
        hud:sort_boxes()
    end
    if self.is_floating_panel then
        FloatingInfobox:add_floating_box({
            id = self.id,
            panel = self._panel,
            pos = self.pos,
            mov_unit = self.mov_unit,
            radius = self._radius
        })
    end
    self._background:animate(callback(self, self, "_blink_background"))

    return true
end

--This function simply blinks the background of the infobox
function VoidUIInfobox:_blink_background(background) --ready
	local TOTAL_T = 0.4
	local t = 0
	local color = 1
	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt
		color = math.lerp(1, 0, t / TOTAL_T)
		background:set_color(Color(color,color,color))
	end
end

--This function will set the icon of the infobox to a blinking icon from start_color to end_color.
--start_color is not required, and will default to white or color set by VoidUI HMV .
--Execute this function with blink = false to stop the blinking, and blink = true to start it.
function VoidUIInfobox:set_blinking_icon(blink, end_color, start_color) --ready
    self._icon:stop()
    if VoidUI_HMV and not start_color then
        if VoidUI_HMV.options.generic_colors then
            start_color = VoidUI_HMV:GetColor("icon_color")
        else
            start_color = VoidUI_HMV:GetColor(self.string_id.."_icon")
        end
    else
        start_color = start_color or Color(1,1,1)
    end
    if blink then
        self._icon:animate(callback(self, self, "_blinking_icon"), start_color, end_color)
    else
        self._icon:set_color(start_color)
    end
end

--This function is called by set_blinking_icon to blink the icon.
function VoidUIInfobox:_blinking_icon(icon, start_color, end_color) --ready
    local d = true
    local TOTAL_T = 1
    local t = 0
    if not end_color then
        end_color = tweak_data.chat_colors[5]
    end
    while true do
        local dt = coroutine.yield()
		t = t + dt
        icon:set_color(math.lerp(d and start_color or end_color, d and end_color or start_color, t / TOTAL_T), math.lerp(d and end_color or start_color, d and start_color or end_color, t / TOTAL_T))
        if t >= TOTAL_T then t = 0
			d = not d
		end
    end
end