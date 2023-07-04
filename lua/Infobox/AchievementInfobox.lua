AchievementInfobox = AchievementInfobox or class(TimerInfobox)

if VoidUI_IB.options.AnimateAchievementBorders then
    function AchievementInfobox:new_border()
        local highlight_texture = "guis/textures/VoidUI_IB/hud_timer_border"
        local scale, panel_w, panel_h = self:get_scale_options()
        local new_border = self._panel:bitmap({
            name = "border",
            texture = highlight_texture,
            texture_rect = {0,0,171,150},
            layer = 2,
            w = panel_w,
            h = panel_h
            --render_template = "VertexColorTexturedRadial"
        })
        return new_border
    end
else
    AchievementInfobox.new_border = VoidUIInfobox.new_border
end

local function change_timer(id)
    if tostring(id) == "0" then return end
    if AchievementInfobox:child("e_103656") then
        AchievementInfobox:child("e_103656"):remove()
        AchievementInfobox:new({name = "Achievement", id = "e_102743", time = 10, achievement_id = "corp_12"})
    end 
end
local function valid_corp_12(data)
    local _Net = _G.LuaNetworking
    local num = _Net:GetNumberOfPeers()
    if not table.contains({"overkill_145", "easy_wish", "overkill_290", "sm_wish"}, Global.game_settings.difficulty) then
        return false
    end
    if data.id == "e_103656" then
        managers.mission:add_global_event_listener("corp_12_achiev", {"on_peer_dropin"}, change_timer)
        
    end
    return data.id == "e_102743" and num > 0 or data.id == "e_103656" and num == 0 or false
end

local ahiev_req = {
    ["corp_12"] = valid_corp_12
}
function AchievementInfobox:get_texture_by_name()
    if not VoidUI_IB or not self._achievement_id then
        self:Error("This Achievement infobox is missing the achievement_id! (This is a bug, please report it!)")
        log(tostring(debug.traceback()))
        self:Error("Please report message above to VoidUI Infobox mod page on modworkshop.net")
        self:remove()
        return
    end
    if self._achievement_id then
        local achievment_info = tweak_data.achievement.visual[self._achievement_id]
        local texture, texture_rect = tweak_data.hud_icons:get_icon_or(achievment_info.icon_id, nil)
        return texture, texture_rect
    end
end

function AchievementInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Achievement_priority or 6
    self._type = "Achievement"

    self._achievement_id = data.achievement_id
    local time = data.value or data.time or 0
    self.string_id = "Achievement"
    self._icon_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.icon_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_icon") or Color(1,1,1)
    self.string_id_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.text_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_name") or Color(1,1,1)
    self._time_color = VoidUI_HMV and VoidUI_HMV.options.generic_colors and self.text_color or VoidUI_HMV and VoidUI_HMV:GetColor(self.string_id.."_time") or Color(1,1,1)
end

function AchievementInfobox:check_valid(data)
    if not VoidUI_IB.options.Achievement then
        return false
    elseif ahiev_req[self._achievement_id] then
        return ahiev_req[self._achievement_id](data)
    end
    return true
end

function AchievementInfobox:create(data)
    if VoidUI_IB.options.debug_show_timer_id then
        self:DebugPrint("Attempt add new timer".."\nID: "..tostring(data.id and data.id or data.name).." with time: "..tostring(data.time).."s"..(data.editor_name and " \nThe editor_name is; "..tostring(data.editor_name) or ""))
    end
    self._init_time = data.time
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 4
    self._name_panel = self:new_text("", "top", "right", "right", true)
    self._name_panel:set_w(panel_w * 0.9)
    self._name_panel:set_h(panel_h * 0.7)
    self._name_panel:set_center(self._background:center())
    self._name_panel:set_top(self._background:top() + panel_h / 20)
    if self._achievement_id then
        local achievment_info = tweak_data.achievement.visual[self._achievement_id]
        self._name_panel:set_text(managers.localization:text(achievment_info.name_id) or self._achievement_id)
        self:FixFont(self._name_panel, font_size)
    end
    self._icon_jammed = self:new_icon("guis/textures/pd2/skilltree/drillgui_icon_restarter")
    self._icon_jammed:set_color(Color(1,0,0))
    self._icon_jammed:set_alpha(0)
    self._name_panel:set_color(self.string_id_color)
    self._text_panel = self:new_text(tostring(math.ceil(data.time)).."s", "bottom", "right", "center")
    self._text_panel:set_color(self._time_color)
    self._text_panel:set_font_size(font_size)
    self._icon_jammed:set_center(self._background:center())
    if VoidUI_IB.options.AnimateAchievementBorders then
        self._border:set_render_template(Idstring("VertexColorTexturedRadial"))
        self._jammed_border = self:new_border()
        self._jammed_border:set_color(Color(1,0,0))
        self._jammed_border:set_layer(3)
        self._jammed_border:set_visible(false)
    end
    self:FixFont(self._name_panel, font_size)
end

function AchievementInfobox:award()
    self:set_blinking_icon(true, Color(0,1,0))
    self._name_panel:set_color(Color(0,1,0))
    DelayedCalls:Add(self._achievement_id, 5, function()
        self:remove()
    end)
end

function AchievementInfobox:set_valid(value)
    if not self or not self._name_panel then return end
    if value then
        self._name_panel:set_color(Color.white)
    else
        self._name_panel:set_color(Color(1,0,0))
        --self._border:set_color(Color(1,0,0))
        if VoidUI_IB.options.AnimateAchievementBorders and self._jammed_border then
            self._border:set_visible(jammed and false or true)
            self._border:set_alpha(jammed and 0 or 1)
            self._jammed_border:set_visible(jammed and true or false)
        else
            self._border:set_color(jammed and Color(1,0,0) or Color(1,1,1))
        end
        self:set_blinking_icon(true, Color(1,0,0))
        if VoidUI_IB.options.send_failed_warning then
            local achiev_name = tweak_data.achievement.visual[self._achievement_id].name_id or self._achievement_id
            self:DebugPrint("Achievement: "..managers.localization:text(achiev_name).."' failed!")
        end
        DelayedCalls:Add(self.string_id, 5, function()
            self:remove()
        end)
    end
end