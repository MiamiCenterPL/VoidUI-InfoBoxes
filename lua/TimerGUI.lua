if not VoidUI_IB.options.timers then return end
Hooks:PostHook(TimerGui, 'init', 'init_hud_timer', function(self, ...)
	self._unit_names = VoidUI_IB:LoadTweakDataFromFile("tweakdata/TimerGuiTweakData.json")
end)
Hooks:PostHook(TimerGui, '_start', 'add_new_timer', function(self, ...)
	if not self._created and TimerInfobox and alive(self._unit) then
		local editor_name
	    if self._unit:interaction() then
	    	if self._unit:interaction().tweak_data then
				editor_name = self._unit:interaction().tweak_data
	    		self._name = self._unit_names[self._unit:interaction().tweak_data]
				if self._name == nil then
					self._name = "Unknown"
					if VoidUI_IB.options.debug_show_missing_id then
						log("[VoidUI Infoboxes] Missing unit name for interactionID: "..tostring(self._unit:interaction().tweak_data).." With time: "..tostring(self._current_timer).."s")
						managers.chat:_receive_message(1, "[VoidUI Infoboxes]", "Missing unit name for interactionID: "..tostring(self._unit:interaction().tweak_data).." With time: "..tostring(self._current_timer).."s", Color("#fc0352"))
					end
				end
	    	else
	    		self._name = "Timer"
	    	end
	    elseif string.find(self._start_event, "hack") then
			self._name = "Hack"
		else
	    	self._name = "Timer"
	    end
		TimerInfobox:new({
			id = "timer_"..self._unit:id(), name = self._name, time = self._current_timer, type = "Timer", editor_name = editor_name and "U_"..editor_name or nil, pos = VoidUI_IB.options.FloatingUTimerBoxes and self._unit:position() or nil
		})
		self._created = true
    end
end)

Hooks:PostHook(TimerGui, 'update', 'update_timers', function(self, ...)
	if not TimerInfobox then
		return
	end
	if not self._jammed then
		if TimerInfobox:child("timer_"..self._unit:id()) then
			TimerInfobox:child("timer_"..self._unit:id()):set_value(self._time_left)
		end
	end

	if not alive(self._new_gui) and not alive(self._ws) then
		if TimerInfobox:child("timer_"..self._unit:id()) then
			TimerInfobox:child("timer_"..self._unit:id()):remove()
		end
	end
end)

Hooks:PostHook(TimerGui, '_set_jammed', 'set_jammed_VoidUI', function(self, jammed, ...)
	if not TimerInfobox then
		return
	end
	if TimerInfobox:child("timer_"..self._unit:id()) then
		TimerInfobox:child("timer_"..self._unit:id()):set_jammed(jammed)
	end
end)

Hooks:PostHook(TimerGui, 'done', 'remove_timer', function(self, ...)
	if not TimerInfobox then
		return
	end
	if TimerInfobox:child("timer_"..self._unit:id()) then
		TimerInfobox:child("timer_"..self._unit:id()):remove()
	end
	self._created = nil
end)

Hooks:PostHook(TimerGui, '_set_done', 'remove_timer2', function(self, ...)
	if not TimerInfobox then
		return
	end
	if TimerInfobox:child("timer_"..self._unit:id()) then
		TimerInfobox:child("timer_"..self._unit:id()):remove()
	end
	self._created = nil
end)

Hooks:PostHook(TimerGui, 'destroy', 'remove_timer3', function(self, ...)
	if not TimerInfobox then
		return
	end
	if TimerInfobox:child("timer_"..self._unit:id()) then
		TimerInfobox:child("timer_"..self._unit:id()):remove()
	end
	self._created = nil
end)

Hooks:PostHook(TimerGui, '_set_powered', 'jamm_timer', function(self, ...)
	if not TimerInfobox then
		return
	end
	if TimerInfobox:child("timer_"..self._unit:id()) then
		TimerInfobox:child("timer_"..self._unit:id()):set_jammed(not self._powered)
	end
end)

Hooks:PostHook(TimerGui, 'post_event', 'remove_timer4', function(self, ...)
	if not TimerInfobox then
		return
	end
	if event == self._done_event then
		if TimerInfobox:child("timer_"..self._unit:id()) then
			TimerInfobox:child("timer_"..self._unit:id()):remove()
		end
		self._created = nil
	end
end)