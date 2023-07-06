if not _G.VoidUI_IB.options.timer_Pager then return end

Hooks:PreHook(CopBrain, "clbk_alarm_pager", "VUIB_clbk_alarm_pager", function(self, ignore_this, data)
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

Hooks:PostHook(CopBrain, "on_alarm_pager_interaction", "VUIB_on_alarm_pager_interaction", function(self, status, player)
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

--Remove the panel when the pager is gone, e.g. when the heist goes loud.
Hooks:PostHook(CopBrain, "end_alarm_pager", "VUIB_end_alarm_pager", function(self)
    local box = VoidUIInfobox:child("cu_pager_"..self._unit:id())
    if not box then return end
    box:remove()
end)