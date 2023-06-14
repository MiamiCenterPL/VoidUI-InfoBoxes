SentryInfobox = SentryInfobox or class(MinionInfobox)

SentryInfobox.get_texture_by_name = VoidUIInfobox.get_texture_by_name

function SentryInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Sentry_priority or 6
    self._type = "Sentry"

    self.color_id = data.color_id
    if VoidUI_IB.options.sentry_remember_kills and VoidUI_IB._sentry_kills[self.color_id.."_"..self.string_id] and #VoidUI_IB._sentry_kills[self.color_id.."_"..self.string_id] > 0 then
        self.value = VoidUI_IB._sentry_kills[self.color_id.."_"..self.string_id][1]
        table.remove(VoidUI_IB._sentry_kills[self.color_id.."_"..self.string_id], 1)
    else
        self.value = 0
    end
    self.crim_color = tweak_data.chat_colors[self.color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
    self.ap_rounds = data.ap_rounds
    self.health_align = "center"
    self.ammo_align = "center"
    self._nearly_dead = false
    if VoidUI_IB.options.sentry_align_to == 2 then
        self.health_align = "left"
    elseif VoidUI_IB.options.sentry_align_to == 3 then
        self.health_align = "right"
    end
    if VoidUI_IB.options.sentry_ammo_align_to == 2 then
        self.ammo_align = "left"
    elseif VoidUI_IB.options.sentry_ammo_align_to == 3 then
        self.ammo_align = "right"
    end
    self.ammo_ratio = data.ammo_ratio
    self.health_ratio = data.health_ratio
    
    if VoidUI_IB.options.FloatingSentryBoxes then
        self.is_floating_panel = true
        self.pos = data.pos
        self._radius = 340
    end
end

function SentryInfobox:check_valid()
    if VoidUI_IB.options.ShowOnlyOwnedSentry then
        if tonumber(self.color_id) ~= tonumber(_G.LuaNetworking:LocalPeerID()) then
            return false
        end
    end
    if not VoidUI_IB.options.sentry_infobox then
        return false
    end
    return true
end

function SentryInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    self._icon:set_color(self.crim_color)
    self._name_panel = self:new_text(managers.localization:text("VoidUI_IB_sentry"), "top", "right", "right")
    self._name_panel:set_color(self.crim_color)
    self._name_panel:set_w(panel_w / 1.5)
    self._name_panel:set_right(self._background:right() - self._border:w() / 12)
    self._name_panel:set_top(self._background:top())
    self:FixFont(self._name_panel, font_size)
    self.single_fire_mode = self._panel:bitmap({
        alpha = self.ap_rounds and 1 or 0,
        w = panel_w / 4.3,
        h = panel_h / 4.3,
        layer = 3,
        texture = "guis/textures/pd2/blackmarket/inv_mod_singlefire"
    })
    self.auto_fire_mode = self._panel:bitmap({
        alpha = self.ap_rounds and 0 or 1,
        w = panel_w / 4.3,
        h = panel_h / 4.3,
        layer = 3,
        texture = "guis/textures/pd2/blackmarket/inv_mod_autofire"
    })
    if VoidUI_IB.options.sentry_kills then
        self._text_panel = self:new_text("x"..self.value, "bottom", "center", "center")
        self._text_panel:set_font_size(font_size)
        self._text_panel:set_color(self.crim_color)
    end
    if VoidUI_IB.options.sentry_health_type == 2 then
        self._health_bar, self._health_bar_bg = self:new_bar(self.health_align)
        self._health_bar:set_center(self._background:center() - panel_w / 20)
        self._health_bar_bg:set_center(self._background:center() - panel_w / 20)
        self._health_bar:set_bottom(self._background:bottom())
        self._health_bar_bg:set_bottom(self._background:bottom())
        self._health_bar:set_color(Color("62fc03"))
        self._health_bar:set_w(self._health_bar_bg:w() * self.health_ratio)
    elseif VoidUI_IB.options.sentry_health_type == 1 then
        self._health_value = self:new_text(tostring(math.ceil(self.health_ratio * 100)).."%", "bottom", self.health_align, self.health_align)
        self._health_value:set_font_size(font_size / 1.2)
        local _,_,_,h = self._health_value:text_rect()
        self._health_value:set_h(h * 0.8)
        self._health_value:set_color(Color("62fc03"))
    end
    if VoidUI_IB.options.sentry_ammo_type == 2 then
        self._ammo_bar, self._ammo_bar_bg = self:new_bar(self.ammo_align)
        self._ammo_bar:set_center(self._background:center() - panel_w / 20)
        self._ammo_bar_bg:set_center(self._background:center() - panel_w / 20)
        self._ammo_bar:set_color(Color("ff9100"))
        self._ammo_bar:set_w(self._ammo_bar_bg:w() * self.ammo_ratio)
    elseif VoidUI_IB.options.sentry_ammo_type == 1 then
        self._ammo_value = self:new_text(tostring(math.ceil(self.ammo_ratio * 100)).."%", "bottom", self.ammo_align, self.ammo_align)
        self._ammo_value:set_font_size(font_size / 1.2)
        local _,_,_,h = self._ammo_value:text_rect()
        self._ammo_value:set_h(h * 0.8)
        self._ammo_value:set_color(Color("ff9100"))
    end
    self.single_fire_mode:set_left(self._background:left() + panel_w / 8)
    self.single_fire_mode:set_top(self._background:top() + panel_h / 14)
    self.auto_fire_mode:set_left(self._background:left() + panel_w / 8)
    self.auto_fire_mode:set_top(self._background:top() + panel_h / 14)
    if self._health_bar then
        self._health_bar:set_center(self._background:center() - panel_w / 20)
        self._health_bar_bg:set_center(self._background:center() - panel_w / 20)
        self._health_bar:set_bottom(self._background:bottom())
        self._health_bar_bg:set_bottom(self._background:bottom())
        if self._ammo_bar then
            self._ammo_bar:set_bottom(self._health_bar:top() - panel_h / 40)
            self._ammo_bar_bg:set_bottom(self._health_bar_bg:top() - panel_h / 40)
            if self._text_panel then
                self._text_panel:set_bottom(self._ammo_bar:top() - panel_h / 40)
            end
        elseif self._ammo_value then
            self._ammo_value:set_bottom(self._health_bar:top() - panel_h / 40)
            if self._text_panel then
                if self.ammo_align == "center" then
                    self._text_panel:set_bottom(self._ammo_value:top())
                else
                    self._text_panel:set_bottom(self._health_bar:top() - panel_h / 40)
                end
            end
        end
    elseif self._health_value then
        if self._ammo_bar then
            self._ammo_bar:set_bottom(self._background:bottom() - panel_h / 40)
            self._ammo_bar_bg:set_bottom(self._background:bottom() - panel_h / 40)
            self._health_value:set_bottom(self._ammo_bar_bg:top())
            if self._text_panel then
                if self.health_align == "center" then
                    self._text_panel:set_bottom(self._health_value:top())
                else
                    self._text_panel:set_bottom(self._ammo_bar_bg:top() - panel_h / 40)
                end
            end
        elseif self._ammo_value then
            self._health_value:set_bottom(self._background:bottom() - panel_h / 40)
            if self.health_align == self.ammo_align then
                self._ammo_value:set_bottom(self._health_value:top())
                if self._text_panel and self.health_align == "center" then
                    self._text_panel:set_bottom(self._ammo_value:top())
                elseif self._text_panel then
                    self._text_panel:set_bottom(self._background:bottom() - panel_h / 40)
                end
            else
                self._ammo_value:set_bottom(self._background:bottom() - panel_h / 40)
                if self._text_panel then
                    if self.health_align == "center" then
                        self._text_panel:set_bottom(self._health_value:top())
                    elseif self.ammo_align == "center" then
                        self._text_panel:set_bottom(self._ammo_value:top())
                    else
                        self._text_panel:set_bottom(self._background:bottom() - panel_h / 40)
                    end
                end
            end
        end
    end

    self:update_info(self.health_ratio, self.ammo_ratio, self.ap_rounds)
    local player_boxes_table = VoidUI_IB._player_boxes
    local last_box = #player_boxes_table[self._priority][self.color_id]
    table.insert(player_boxes_table[self._priority][self.color_id], last_box > 0 and last_box + 1 or 1, self.name)
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

function SentryInfobox:_set_value(kills)
    if not kills then
        self.value = tonumber(self.value) + 1
    else
        self.value = kills  
    end
    self._text_panel:set_text("x"..tostring(self.value))
end

function SentryInfobox:update_info(health_ratio, ammo_ratio, ap_rounds)
    if self._health_bar and health_ratio then
        self._health_bar:set_w(self._health_bar_bg:w() * health_ratio)
        self.health_ratio = health_ratio
        local align = VoidUI_IB.options.sentry_align_to or 1
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
        self._health_value:set_text(tostring(math.floor(health_ratio * 100)).."%")
        self.health_ratio = health_ratio
        if not self._nearly_dead and health_ratio <= 0.15 then
            self._nearly_dead = true
            self._health_value:set_color(tweak_data.screen_colors.risk)
            self._icon:set_color(tweak_data.screen_colors.risk)
            self._background:animate(callback(self, self, "_blink_background"))
        end
    end
    if self._ammo_bar and ammo_ratio then
        self._ammo_bar:set_w(self._ammo_bar_bg:w() * ammo_ratio)
        self.ammo_ratio = ammo_ratio
        if VoidUI_IB.options.sentry_ammo_align_to == 1 then
			self._ammo_bar:set_center(self._ammo_bar_bg:center())
		elseif VoidUI_IB.options.sentry_ammo_align_to == 2 then
			self._ammo_bar:set_left(self._ammo_bar_bg:left())
		elseif VoidUI_IB.options.sentry_ammo_align_to == 3 then
			self._ammo_bar:set_right(self._ammo_bar_bg:right())
		end
    elseif self._ammo_value and ammo_ratio then
        self.ammo_ratio = ammo_ratio
        self._ammo_value:set_text(tostring(math.ceil(ammo_ratio * 100)).."%")
    end
    if ap_rounds ~= nil then
        self.single_fire_mode:set_alpha(ap_rounds and 1 or 0)
		self.auto_fire_mode:set_alpha(ap_rounds and 0 or 1)
        self.ap_rounds = ap_rounds
    end
end

function SentryInfobox:_remove()
    local player_boxes_table = VoidUI_IB._player_boxes
    local box_table = player_boxes_table[self._priority][self.color_id]
    local _sentry_kills = VoidUI_IB._sentry_kills
    table.remove(box_table, table.index_of(box_table, self.name))
    if self.string_id and VoidUI_IB.options.sentry_remember_kills and self.health_ratio and self.health_ratio > 0 then
        if not _sentry_kills[self.color_id.."_"..self.string_id] then
            _sentry_kills[self.color_id.."_"..self.string_id] = {}
        end
        table.insert(_sentry_kills[self.color_id.."_"..self.string_id], self.value)
    end
end