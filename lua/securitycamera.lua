if VoidUI_IB.options.timer_Tape_loop then
    Hooks:PostHook(SecurityCamera, '_start_tape_loop', 'add_camera_timebox', function(self, tape_loop_t)
        if not tape_loop_t or not TimerInfobox then return end
        local data = {
            id = "loop_"..self._unit:id(),
            name = "Tape_loop",
            time = tape_loop_t,
            operation = "set_time",
            manual_remove = true,
            pos = VoidUI_IB.options.FloatingUTimerBoxes and self._unit:position() or nil
        }
        if not TimerInfobox:child("cu_loop_"..self._unit:id()) then
            managers.hud._hud_assault_corner:add_custom_timer(data)
        else
            TimerInfobox:child("cu_loop_"..self._unit:id()):set_blinking_icon(false)
            managers.hud._hud_assault_corner:add_custom_time(data)
        end
    end)

    Hooks:PreHook(SecurityCamera, '_activate_tape_loop_restart', 'add_camera_restart_timebox', function(self, restart_t)
        if not restart_t or not TimerInfobox then return end
        local data = {
            id = "loop_"..self._unit:id(),
            name = "Tape_loop",
            time = restart_t,
            operation = "set_time",
            pos = self._unit:position()
        }
        managers.hud._hud_assault_corner:add_custom_time(data)
        if TimerInfobox:child("cu_loop_"..self._unit:id()) then
            TimerInfobox:child("cu_loop_"..self._unit:id()):set_blinking_icon(true)
        end
    end)

    Hooks:PostHook(SecurityCamera, '_deactivate_tape_loop', 'remove_camera_timebox2', function(self, ...)
        if not TimerInfobox or not managers.hud or not managers.hud._hud_assault_corner then return end
        managers.hud._hud_assault_corner:remove_custom_timer("loop_"..self._unit:id())
    end)

    Hooks:PreHook(SecurityCamera, '_deactivate_tape_loop_restart', 'remove_camera_timebox3', function(self, ...)
        if not TimerInfobox or not managers.hud or not managers.hud._hud_assault_corner then return end
        
        if TimerInfobox:child("cu_loop_"..self._unit:id()) then
            local time = TimerInfobox:child("cu_loop_"..self._unit:id()).value
            if time and time > 0 then
                --nothing
            else
                managers.hud._hud_assault_corner:remove_custom_timer("loop_"..self._unit:id())
            end
        end
    end)
end
if VoidUI_IB.options.Camera_infobox then
    local camera_count = 0
    Hooks:PreHook(SecurityCamera, 'set_detection_enabled', 'vuib_camera_counter', function(self, state, settings, mission_element)
        self.counted = self.counted or false
        if state and not self.counted then
            self.counted = true
            camera_count = camera_count + 1
        elseif state == false and self.counted then
            self.counted = false
            camera_count = camera_count - 1
        end
        if not CounterInfobox:child("Camera") then
            CounterInfobox:new({
                id = "Camera",
                value = camera_count,
            })
        else
            CounterInfobox:child("Camera"):set_value(camera_count)
        end
    end)
end