MinionInfobox = MinionInfobox or class(VoidUIInfobox)

function MinionInfobox:get_texture_by_name()
    return VoidUI_IB.get_texture_by_name["joker"].texture, VoidUI_IB.get_texture_by_name["joker"].texture_rect
end

function MinionInfobox:new_bar(align)
    local scale, panel_w, panel_h = self:get_scale_options()
    local new_bar = self._panel:bitmap({
        valign = align,
        vertical = "bottom",
        align = align,
        w = panel_w / 1.2,
        h = panel_h / 20,
        layer = 3,
        color = self.crim_color
    })
    local new_bar_bg = self._panel:bitmap({
        valign = "center",
        vertical = "bottom",
        align = "center",
        visible = false,
        w = panel_w / 1.2,
        h = panel_h / 20,
        layer = 3
    })
    return new_bar, new_bar_bg
end

function MinionInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Minion_priority or 6
    self._type = "Minion"

    self.value = 0
    self.color_id = data.color_id
    self.crim_color = tweak_data.chat_colors[self.color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
    self.health_align = "center"
    if VoidUI_IB.options.joker_align_to == 2 then
        self.health_align = "left"
    elseif VoidUI_IB.options.joker_align_to == 3 then
        self.health_align = "right"
    end

    if Jokermon then
        self.xp_align = "center"
        if VoidUI_IB.options.xp_align == 2 then
            self.xp_align = "left"
        elseif VoidUI_IB.options.xp_align == 3 then
            self.xp_align = "right"
        end
    end
    self._nearly_dead = false
    
    if VoidUI_IB.options.FloatingJokerBoxes then
        self.is_floating_panel = true
        self.mov_unit = data.unit
        self.radius = 320
    end
end

function MinionInfobox:check_valid()
    if not VoidUI_IB.options.jokers_infobox then
        return false
    elseif VoidUI_IB.options.ShowOnlyOwnedJokers then
        if tonumber(self.color_id) ~= tonumber(_G.LuaNetworking:LocalPeerID()) then
            return false
        end
    end
    return true
end

function MinionInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    self._icon:set_color(self.crim_color)
    self._name_panel = self:new_text(managers.localization:text("VoidUI_IB_joker"), "top", "right", "right", true)
    self._name_panel:set_h(panel_h / 2)
    self._name_panel:set_color(self.crim_color)
    
    self:FixFont(self._name_panel, font_size)
    if VoidUI_IB.options.jokers_kills then
        self._text_panel = self:new_text("x0", "bottom", "center", "center")
        self._text_panel:set_color(self.crim_color)
        self._text_panel:set_font_size(panel_h / 4)
    end
    if VoidUI_IB.options.joker_health_type == 2 then
        self._health_bar, self._health_bar_bg = self:new_bar(self.health_align)
        self._health_bar:set_center(self._background:center() - panel_w / 20)
        self._health_bar_bg:set_center(self._background:center() - panel_w / 20)
        self._health_bar:set_bottom(self._background:bottom())
        self._health_bar_bg:set_bottom(self._background:bottom())
    elseif VoidUI_IB.options.joker_health_type == 1 then
        self._health_value = self:new_text("100%", "bottom", self.health_align, self.health_align)
        self._health_value:set_color(self.crim_color)
        self._health_value:set_font_size(panel_h / 4)
        local _,_,_,h = self._health_value:text_rect()
        self._health_value:set_h(h)
        self._health_value:set_w(panel_w / 1.2)
        self._health_value:set_center(self._background:center())
        self._health_value:set_bottom(self._background:bottom())
    end
    if Jokermon then
        if VoidUI_IB.options.joker_xp_type == 1 then
            self._xp_value = self:new_text("0%", "bottom", self.xp_align, self.xp_align)
            self._xp_value:set_color(Color("80dfff"))
            self._xp_value:set_font_size(panel_h / 4)
            local _,_,_,h = self._xp_value:text_rect()
            self._xp_value:set_h(h)
            self._xp_value:set_w(panel_w / 1.2)
            self._xp_value:set_center(self._background:center())
            self._xp_value:set_bottom(self._background:bottom())
        elseif VoidUI_IB.options.joker_xp_type == 2 then
            self._xp_bar, self._xp_bar_bg = self:new_bar(self.xp_align)
            self._xp_bar:set_center(self._background:center() - panel_w / 20)
            self._xp_bar:set_color(Color("80dfff"))
            self._xp_bar_bg:set_center(self._background:center() - panel_w / 20)
            self._xp_bar:set_bottom(self._background:bottom())
            self._xp_bar_bg:set_bottom(self._background:bottom())
        end
    end
    if self._health_bar then
        self._health_bar:set_center(self._background:center() - panel_w / 20)
        self._health_bar_bg:set_center(self._background:center() - panel_w / 20)
        self._health_bar:set_bottom(self._background:bottom())
        self._health_bar_bg:set_bottom(self._background:bottom())
        if self._xp_bar then
            self._xp_bar:set_bottom(self._health_bar:top() - panel_h / 40)
            self._xp_bar_bg:set_bottom(self._health_bar_bg:top() - panel_h / 40)
            if self._text_panel then
                self._text_panel:set_bottom(self._xp_bar:top() - panel_h / 40)
            end
        elseif self._xp_value then
            self._xp_value:set_bottom(self._health_bar:top() - panel_h / 40)
            if self._text_panel then
                if self.xp_align == "center" then
                    self._text_panel:set_bottom(self._xp_value:top())
                else
                    self._text_panel:set_bottom(self._health_bar:top() - panel_h / 40)
                end
            end
        end
    elseif self._health_value then
        if self._xp_bar then
            self._xp_bar:set_bottom(self._background:bottom() - panel_h / 40)
            self._xp_bar_bg:set_bottom(self._background:bottom() - panel_h / 40)
            self._health_value:set_bottom(self._xp_bar_bg:top())
            if self._text_panel then
                if self.health_align == "center" then
                    self._text_panel:set_bottom(self._health_value:top())
                else
                    self._text_panel:set_bottom(self._xp_bar_bg:top() - panel_h / 40)
                end
            end
        elseif self._xp_value then
            self._health_value:set_bottom(self._background:bottom() - panel_h / 60)
            if self.health_align == self.xp_align then
                self._xp_value:set_bottom(self._health_value:top())
                if self._text_panel and self.health_align == "center" then
                    self._text_panel:set_bottom(self._xp_value:top())
                elseif self._text_panel then
                    self._text_panel:set_bottom(self._background:bottom() - panel_h / 40)
                end
            else
                self._xp_value:set_bottom(self._background:bottom() - panel_h / 60)
                if self._text_panel then
                    if self.health_align == "center" then
                        self._text_panel:set_bottom(self._health_value:top())
                    elseif self.xp_align == "center" then
                        self._text_panel:set_bottom(self._xp_value:top())
                    else
                        self._text_panel:set_bottom(self._background:bottom() - panel_h / 40)
                    end
                end
            end
        end
    end

    local player_boxes_table = VoidUI_IB._player_boxes
    table.insert(player_boxes_table[self._priority][self.color_id], 1, self.name)
    local order = 1
    for _color_id, _peer_data in ipairs(player_boxes_table[self._priority]) do
        for _,panel_name in pairs(_peer_data) do
            if panel_name == self.name then
                self.position = order
            end
            order = order + 1
        end
    end
end

function MinionInfobox:rename_joker(name)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    self._name_panel:set_text(name)
    self:FixFont(self._name_panel, font_size)
end

function MinionInfobox:_set_value(kills)
    if not kills then
        self.value = tonumber(self.value) + 1
    else
        self.value = kills  
    end
    self._text_panel:set_text("x"..tostring(self.value))
end

function MinionInfobox:update_info(health_ratio, exp_ratio)
    if self._health_bar and health_ratio then
        self._health_bar:set_w(self._health_bar_bg:w() * health_ratio)
        self.health_ratio = health_ratio
        local align = VoidUI_IB.options.joker_align_to or 1
		if align == 1 then
			self._health_bar:set_center(self._health_bar_bg:center())
		elseif align == 2 then
			self._health_bar:set_left(self._health_bar_bg:left())
		elseif align == 3 then
			self._health_bar:set_right(self._health_bar_bg:right())
		end
        if not self._nearly_dead and health_ratio <= 0.15 then
            self._nearly_dead = true
            self._health_bar:set_color(tweak_data.screen_colors.risk)
            self._icon:set_color(tweak_data.screen_colors.risk)
            self._background:animate(callback(self, self, "_blink_background"))
            self:set_blinking_icon(true, Color(1,0,0), self.crim_color)
        end
    elseif self._health_value and health_ratio then
        self._health_value:set_text(tostring(math.ceil(health_ratio * 100)).."%")
        self.health_ratio = health_ratio
        if not self._nearly_dead and health_ratio <= 0.15 then
            self._nearly_dead = true
            self._health_value:set_color(tweak_data.screen_colors.risk)
            self._icon:set_color(tweak_data.screen_colors.risk)
            self._background:animate(callback(self, self, "_blink_background"))
        end
    end
    if exp_ratio and self._xp_bar then
        self._xp_bar:set_w(self._xp_bar_bg:w() * exp_ratio)
        if self.xp_align == "center" then
			self._xp_bar:set_center(self._xp_bar_bg:center())
		elseif self.xp_align == "left" then
			self._xp_bar:set_left(self._xp_bar_bg:left())
		elseif self.xp_align == "right" then
			self._xp_bar:set_right(self._xp_bar_bg:right())
		end
    elseif exp_ratio and self._xp_value then
        self._xp_value:set_text(tostring(math.ceil(exp_ratio * 100)).."%")
    end
end

function MinionInfobox:_remove()
    local player_boxes_table = VoidUI_IB._player_boxes
    local box_table = player_boxes_table[self._priority][self.color_id]
    table.remove(box_table, table.index_of(box_table, self.name))
end