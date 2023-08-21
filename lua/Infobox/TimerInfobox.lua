TimerInfobox = TimerInfobox or class(VoidUIInfobox)

if VoidUI_IB.options.AnimateTimerBorders then
    function TimerInfobox:new_border()
        local highlight_texture = "guis/textures/VoidUI_IB/hud_timer_border"
        local scale, panel_w, panel_h = self:get_scale_options()
        local new_border = self._panel:bitmap({
            name = "border",
            texture = highlight_texture,
            texture_rect = {0,0,171,150},
            layer = 2,
            w = panel_w,
            h = panel_h
        })
        return new_border
    end
end

function TimerInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Timer_priority or 6
    self._type = "Timer"

    self.time = data.time
    self.string_id = data.name

    if self.string_id == "Unknown" and VoidUI_IB.options.PrintUnknownTimers and not VoidUI_IB.options.debug_show_timer_id then
        self:DebugPrint("Unknown timer, please report this to VoidUIInfoboxes dev".."\nID: "..tostring(data.id)..(data.editor_name and "\nName: "..tostring(data.editor_name) or "").."\nLevelID: "..tostring(Global.game_settings.level_id)..(data.instance_name and "\nInstanceName: "..tostring(data.instance_name) or ""..(data.time and "\nTime: "..tostring(data.time) or "")))
    end

    if data.pos then
        self.is_floating_panel = true
        self.pos = data.pos
        self._radius = 300
    end
    if data.unit then
        self.is_floating_panel = true
        self.mov_unit = data.unit
    end
end

function TimerInfobox:check_valid()
    if not self.string_id then
        self:Error("\n\nNo string_id for timer\n"..tostring(debug.traceback()).."\nPlease report this to Infobox dev team\n\n")
        return false
    elseif not VoidUI_IB.options.timers or not VoidUI_IB.options["timer_"..self.string_id] then
        return false
    elseif not self.time then
        return false
    end
    return true
end

function TimerInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3
    if VoidUI_IB.options.debug_show_timer_id then
        self:DebugPrint("Attempt add new timer".."\nID: "..tostring(data.id).." with time: "..tostring(data.time).."s"..(data.editor_name and " \nThe editor_name is; "..tostring(data.editor_name) or ""))
    end
    self._init_time = data.time and data.time or 0
    local time = data.time and data.time or 0
    self._icon_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.icon_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_icon") or Color(1,1,1)
    self.string_id_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.text_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_name") or Color(1,1,1)
    self._time_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.text_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_time") or Color(1,1,1)
    self._icon_jammed = self:new_icon("guis/textures/pd2/skilltree/drillgui_icon_restarter")
    self._icon_jammed:set_color(Color(1,0,0))
    self._icon_jammed:set_alpha(0)
    self._name_panel = self:new_text(managers.localization:text("VoidUI_IB_"..self.string_id), "top", "right", "right", true)
    self._name_panel:set_right(self._border:right() - panel_w / 15)

    if self._achievement_id then
        local achievment_info = tweak_data.achievement.visual[self._achievement_id]
        self._name_panel:set_text(managers.localization:text(achievment_info.name_id) or self._achievement_id)
    end
    self._name_panel:set_color(self.string_id_color)
    self._text_panel = self:new_text(tostring(math.ceil(time)).."s", "bottom", "right", "center")
    self._text_panel:set_color(self._time_color)
    self._text_panel:set_font_size(font_size)
    self._icon_jammed:set_center(self._background:center())
    font_size = panel_h / 4
    if VoidUI_IB.options.AnimateTimerBorders then
        self._border:set_render_template(Idstring("VertexColorTexturedRadial"))
        self._jammed_border = self:new_border()
        self._jammed_border:set_color(Color(1,0,0))
        self._jammed_border:set_layer(3)
        self._jammed_border:set_visible(false)
    end
    self:FixFont(self._name_panel, font_size)
end

function TimerInfobox:_set_value(time)
    self.time = time

    if VoidUI_IB.options.timer_minutes_and_seconds and time >= 60 then
        local minutes = math.floor(time / 60)
        local seconds = math.floor(time % 60)
        if seconds < 10 then
            seconds = "0"..seconds
        end

        self._text_panel:set_text(tostring(minutes)..":"..tostring(seconds))    
    else
        if time > 5 then
            self._text_panel:set_text(tostring(math.floor(time)).."s")
        else
            self._text_panel:set_text(tostring(math.round_with_precision(time, 1)).."s")
        end
    end
    if VoidUI_IB.options.AnimateTimerBorders and self._border and self._init_time then
        self:_anim_border()
    end
end

if VoidUI_IB.options.ReverseTimerAnimation then
    function TimerInfobox:_anim_border()
        self._border:stop()
        local ratio = self.time / self._init_time
        
        self._border:set_color(Color(1, 1 - ratio, 1, 1))
    end
else
    function TimerInfobox:_anim_border()
        self._border:stop()
        local ratio = self.time / self._init_time
        
        self._border:set_color(Color(1, ratio, 1, 1))
    end
end

function TimerInfobox:set_jammed(jammed)
    if not self._text_panel then return end
    self._is_jammed = jammed
    self._text_panel:set_color(jammed and Color(1,0,0) or self._time_color)
    self._name_panel:set_color(jammed and Color(1,0,0) or self.string_id_color)
    --self._border:set_color(jammed and Color(1,0,0) or Color(1,1,1))
    if VoidUI_IB.options.AnimateTimerBorders and self._jammed_border then
        self._border:set_visible(jammed and false or true)
        self._border:set_alpha(jammed and 0 or 1)
        self._jammed_border:set_visible(jammed and true or false)
    else
        self._border:set_color(jammed and Color(1,0,0) or Color(1,1,1))
    end
    self._icon:set_alpha(jammed and 0 or 0.6)
    self._icon_jammed:set_alpha(jammed and 0.6 or 0)
    self._background:stop()
    self._background:animate(callback(self, self, "_blink_background"))
end