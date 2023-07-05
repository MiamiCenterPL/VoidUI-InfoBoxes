if not VoidUI_IB.options.timers then return end
if RequiredScript == "core/lib/managers/mission/coreelementtimer" then
	local tweakdata = VoidUI_IB:LoadTweakDataFromFile("tweakdata/TimersTweakData.json")

	local filter_table = tweakdata.filter_table
	local filter_names_table = tweakdata.filter_names_table
	local hide_on_stop = tweakdata.hide_on_stop

	local function get_level_id()
		return Global.game_settings.level_id
	end

	local function filter_timer(id)
		if filter_table[get_level_id()] then
			if table.contains(filter_table[get_level_id()], tostring(id)) then
				return false
			end
		end
		return true
	end

	local function filter_names(id)
		id = tostring(id)
		local achievement_id
		if not get_level_id() then return "Timer" end
		if filter_names_table[get_level_id()] and filter_names_table[get_level_id()][id] then
			if type(filter_names_table[get_level_id()][id]) == "table" then
				name = filter_names_table[get_level_id()][id][1]
				achievement_id = filter_names_table[get_level_id()][id][2]
			else
				name = filter_names_table[get_level_id()][id]
			end
		else
			name = "Unknown"
		end
		return name, achievement_id
	end
	
	local function get_pos(self)
		local pos
		if VoidUI_IB.options.FloatingETimerBoxes then
			if self._digital_gui_units and self._digital_gui_units[1] then
				local unit = self._digital_gui_units[1]
				if alive(unit) then
					pos = unit:position()
				end
			elseif self._values.position then
				pos = self._values.position
			end
		end
		return pos
	end

	core:module("CoreElementTimer")
	core:import("CoreMissionScriptElement")

	ElementTimer = ElementTimer or class(CoreMissionScriptElement.MissionScriptElement)

	Hooks:PostHook(ElementTimer, "init", "VUIBA_ElementTimer_init", function(self, ...)
		VoidUI_IB = _G.VoidUI_IB
		TimerInfobox = _G.TimerInfobox
		AchievementInfobox = _G.AchievementInfobox
		self._created = false
	end)

	Hooks:PostHook(ElementTimer, '_start_digital_guis_count_down', 'VUIBA_ElementTimer_start_timer', function(self, ...)
		if not self._created and self._values.enabled and filter_timer(self._id) and TimerInfobox then
			local name, achievement_id = filter_names(self._id)
			local InfoboxClass = TimerInfobox
			if achievement_id then
				InfoboxClass = AchievementInfobox
			end
			local pos = get_pos(self)
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name, pos = pos
			})
			self._created = true
		end
	end)

	Hooks:PostHook(ElementTimer, 'timer_operation_start', 'VUIBA_ElementTimer_operation_start', function(self, ...)
		if not self._created and self._values.enabled and filter_timer(self._id) and TimerInfobox then
			local name, achievement_id = filter_names(self._id)
			local InfoboxClass = TimerInfobox
			if achievement_id then
				InfoboxClass = AchievementInfobox
			end
			local pos = get_pos(self)
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name, pos = pos
			})
			self._created = true
		elseif self._created and self._values.enabled and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):set_jammed(false)
		end
	end)

	Hooks:PostHook(ElementTimer, "timer_operation_add_time", "VUIBA_ElementTimer_operation_add_time", function(self, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			local init_time = TimerInfobox:child("e_"..self._id)._init_time
			if self._timer > init_time then
				TimerInfobox:child("e_"..self._id)._init_time = self._timer
			end
		end
	end)
	Hooks:PostHook(ElementTimer, "timer_operation_reset", "VUIBA_ElementTimer_operation_reset", function(self, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id)._init_time = self._timer
		end
	end)
	Hooks:PostHook(ElementTimer, "timer_operation_set_time", "VUIBA_ElementTimer_operation_set_time", function(self, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id)._init_time = self._timer
		end
	end)

	Hooks:PostHook(ElementTimer, 'timer_operation_pause', 'VUIBA_ElementTimer_operation_pause', function(self, ...)
		local level_id = Global.game_settings.level_id
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):set_jammed(true)
		end
		
		if hide_on_stop[level_id] and table.contains(hide_on_stop[level_id], tostring(self._id)) and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):remove()
		end
	end)
	
	Hooks:PostHook(ElementTimer, 'set_enabled', 'VUIBA_ElementTimer_set_enabled', function(self, enabled, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) and not enabled then
			TimerInfobox:child("e_"..self._id):remove()
			self:remove_updator()
		end
	end)

	Hooks:PostHook(ElementTimer, "remove_updator", "VUIBA_ElementTimer_remove_updator", function(self)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):set_jammed(true)
		end
	end)

	Hooks:PostHook(ElementTimer, 'add_updator', 'VUIBA_ElementTimer_add_updator', function(self, ...)
		if not self._created and self._values.enabled and filter_timer(self._id) then
			local name, achievement_id = filter_names(self._id)
			local InfoboxClass = TimerInfobox
			if achievement_id then
				InfoboxClass = AchievementInfobox
			end
			local pos = get_pos(self)
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name, pos = pos
			})
			self._created = true
		end
	end)

	Hooks:PostHook(ElementTimer, 'on_executed', "VUIBA_ElementTimer_on_executed", function(self, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):remove()
			self._created = false
		end
	end)
	Hooks:PostHook(ElementTimer, 'client_on_executed', "VUIBA_ElementTimer_client_on_executed", function(self, ...)
		if self._created and TimerInfobox and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):remove()
			self._created = false
		end
	end)

	Hooks:PostHook(ElementTimer, 'update_timer', 'VUIBA_ElementTimer_update_timer', function(self, ...)
		if not self._values.enabled and TimerInfobox then
			return
		end
		if self._created and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):set_value(self._timer)
		end
		if self._timer <= 0 and TimerInfobox:child("e_"..self._id) then
			TimerInfobox:child("e_"..self._id):remove()
			self._created = false
		end
	end)

	ElementTimerOperator = ElementTimerOperator or class(CoreMissionScriptElement.MissionScriptElement)

	Hooks:PostHook(ElementTimerOperator, 'client_on_executed', "VUIBA_ElementTimerOperator_client_on_executed", function(self)
		if not self._values.enabled or not TimerInfobox then
			return
		end
		local time = self:get_random_table_value_float(self:value("time"))
		local level_id = Global.game_settings.level_id
		local hud = managers.hud._hud_assault_corner
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)
			
			if element and filter_timer(id) then
				if self._values.operation == "pause" then
					local data = {id = id, jammed = true}
					hud:set_custom_jammed(data)
					if hide_on_stop[level_id] and table.contains(hide_on_stop[level_id], tostring(self._id)) and TimerInfobox:child("cu_e_"..self._id) then
						TimerInfobox:child("cu_e_"..self._id):remove()
					end
				elseif self._values.operation == "start" then
					if not self._created then
						local pos = get_pos(element)

						local name, achievement_id = filter_names(id)
						local data = {id = id, name = name, time = element._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name, pos = pos}
						hud:add_custom_timer(data)
						self._created = true
					else
						local data = {id = id, jammed = false}
						hud:set_custom_jammed(data)
					end
				elseif self._values.operation == "add_time" then
					local data = {id = id, time = time, operation = "add"}
					hud:add_custom_time(data)
				elseif self._values.operation == "subtract_time" then
					local data = {id = id, time = -1 * time, operation = "add"}
					hud:add_custom_time(data)
				elseif self._values.operation == "reset" then
					local data = {id = id, time = time, operation = "reset"}
					hud:add_custom_time(data)
				elseif self._values.operation == "set_time" then
					local data = {id = id, time = time, operation = "set_time"}
					hud:add_custom_time(data)
				end
			end
		end
	end)
end