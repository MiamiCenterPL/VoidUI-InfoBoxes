--[[Hooks:PostHook(CopBrain, "begin_alarm_pager", "VUIB_TrackPagers", function(self, reset)
    if not reset and self._alarm_pager_has_run then
        local function calcule_aprx_pager_time()
            local first_call = math.lerp(tweak_data.player.alarm_pager.first_call_delay[1], tweak_data.player.alarm_pager.first_call_delay[2], math.random())
            local total_nr_calls = math.random(tweak_data.player.alarm_pager.nr_of_calls[1], tweak_data.player.alarm_pager.nr_of_calls[2])
            local duration_settings = tweak_data.player.alarm_pager.call_duration[1]
            local call_delay = math.lerp(duration_settings[1], duration_settings[2], math.random())
            return first_call + total_nr_calls * call_delay
        end
        local unit = self._unit
        if not VoidUIInfobox:child("cu_pager_"..self._unit:id()) then
            local data = {id = "pager_"..self._unit:id(), name = "Unknown", time = calcule_aprx_pager_time(), unit = self._unit}

            managers.hud._hud_assault_corner:add_custom_timer(data)
        end
    end
end)]]
Hooks:PreHook(CopBrain, "clbk_alarm_pager", "CHANGEME_CopBrain_clbk_alarm_pager", function(self, ignore_this, data)
    local pager_data = self._alarm_pager_data
    if pager_data.nr_calls_made == 0 then
        if managers.groupai:state():is_ecm_jammer_active("pager") then
            return
        end
        if not VoidUIInfobox:child("cu_pager_"..self._unit:id()) then
            local time = 2 * tweak_data.player.alarm_pager.call_duration[1][1]
            local data = {id = "pager_"..self._unit:id(), name = "Pager", time = time, unit = self._unit}
            managers.hud._hud_assault_corner:add_custom_timer(data)
        end
    elseif pager_data.nr_calls_made == pager_data.total_nr_calls - 1 then
        local box = VoidUIInfobox:child("cu_pager_"..self._unit:id())
        if box then
            box:set_blinking_icon(true, Color(1,0,0))
        end
    end
end)


Hooks:PostHook(CopBrain, "on_alarm_pager_interaction", "CHANGEME_CopBrain_on_alarm_pager_interaction", function(self, status, player)
    local box = VoidUIInfobox:child("cu_pager_"..self._unit:id())
    if not box then return end
	if status == "started" then
        box:set_blinking_icon(true, Color(0,1,0))

        local data = {id = "pager_"..self._unit:id(), operation = "pause", time = 0}
        managers.hud._hud_assault_corner:add_custom_time(data)
    elseif status == "complete" or status == "interrupted" then
        box:remove()
    end
end)