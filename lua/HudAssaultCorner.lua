Hooks:PostHook(HUDAssaultCorner, "init", "VUIBA_HUDAssaultCorner_init", function(self, data)
	if not self._custom_hud_panel then
		return
	end

	local icons_panel = self._custom_hud_panel:child("icons_panel")
	icons_panel:set_w(600 * self._scale)

	FloatingInfobox:setup()
end)

Hooks:PostHook(HUDAssaultCorner, "setup_icons_panel", "VUIBA_HUDAssaultCorner_setup_icons_panel", function(self)
	self._custom_icons = {{},{},{},{},{},{}}
	self._icons_panel:set_w(600 * self._scale)
	self._icons_panel:set_right(self._custom_hud_panel:w())
	if not VoidUIInfobox then return end
	if VoidUI_IB.options.debug_print_level_id then
		local message = "Current Level ID is: "..tostring(Global.game_settings.level_id)
		log("[VoidUI Infoboxes] "..message)
		managers.chat:_receive_message(1, "[VoidUI Infoboxes]", message, Color("fc0394"))
	end
	local int_manager = managers.interaction
	if VoidUI_IB.options.kills_infobox then
		local value
		if VoidUI_IB.options.special_kills and kills_panel and not VoidUI_IB.options.special_kills_infobox then
			value = "0 | x0"
		else
			value = 0
		end
		local kills_panel = CounterInfobox:new({
			id = "kills", value = value
		})
	end
	if VoidUI_IB.options.special_kills and VoidUI_IB.options.special_kills_infobox then
		CounterInfobox:new({
			id = "special_kills"
		})
	end
	if VoidUI_IB.options.enemies_infobox then
		local value
		if not VoidUI_IB.options.special_enemies_infobox then
            value = managers.enemy._enemy_data.nr_units
        else
            value = managers.enemy._enemy_data.nr_units - managers.enemy._enemy_data.nr_special_units
        end
		CounterInfobox:new({
			id = "enemies", value = value
		})
	end
	if VoidUI_IB.options.special_enemies_infobox then
		CounterInfobox:new({
			id = "special_enemies", value = managers.enemy._enemy_data.nr_special_units
		})
	end
 if managers and managers.enemy and managers.enemy.special_counter then
 	for name,value in pairs(managers.enemy.special_counter) do
 		if VoidUI_IB.options["enemy_"..name.."_infobox"] then
 			CounterInfobox:new({
 				id = "enemy_"..name, value = value
	 		})
 		end
 	end
 end
	if VoidUI_IB.options.civs_infobox then
		CounterInfobox:new({
			id = "civs", value = table.size(managers.enemy._civilian_data.unit_data)
		})
	end
	if VoidUI_IB.options.lootbags_infobox then
		local value = VoidUI_IB.options.SeparateBagged and int_manager.bagged.." | x"..int_manager.unbagged or int_manager.bagged + int_manager.unbagged
		CounterInfobox:new({
			id = "lootbags", value = value
		})
	end
	if VoidUI_IB.options.possible_loot_infobox then
		CounterInfobox:new({
			id = "possible_loot", value = #int_manager.possible_loot
		})
	end
	if VoidUI_IB.options.gagepacks_infobox then
		CounterInfobox:new({
			id = "gagepacks"
		})
	end
	if VoidUI_IB.options.Camera_infobox and not CounterInfobox:child("Camera") then
		CounterInfobox:new({
			id = "Camera"
		})
	end

	if VoidUI_IB.options.collectables then
		for name, count in ipairs(int_manager.loot_collectables) do
			CollectableInfobox:new({
				id = name, value = count
			})
		end
	end

	if VoidUI_IB.options.timers then
		for _,unit in ipairs(World:find_units_quick("all", 1)) do
			if tostring(unit:name()) == "Idstring(@IDf2defbb65d875bc0@)"  then
				local data = {id = unit:unit_data().unit_id, name = "Cutter", time = 30}
				managers.mission:add_runned_unit_sequence_trigger(unit:unit_data().unit_id, "interact", callback(self, self, "add_custom_timer", data))
			end
		end
	end
end)

function HUDAssaultCorner:add_custom_timer(data)
	if not VoidUI_IB.options.timers or not VoidUIInfobox then return end
	if VoidUIInfobox:child("cu_"..data.id) then return end --EXISTS!
	if data.time <= 0 then return end
	TimerInfobox:new({
		id = "cu_"..data.id,
		name = data.name and data.name or data.id,
		time = data.time,
		achievement_id = data.achievement_id and data.achievement_id or nil,
		pos = data.pos and data.pos or nil,
		unit = data.unit and data.unit or nil,
	})
	managers.hud:add_updator("update_custom_timer_"..data.id, callback(self, self, "update_custom_timer", data))
	if not self._timer then self._timer = {} end
	self._timer[data.id] = data.time
end

function HUDAssaultCorner:update_custom_timer(data, t, dt)
	local infobox = VoidUIInfobox:child("cu_"..data.id)
	if not self._timer[data.id] or not infobox then return end
	self._timer[data.id] = self._timer[data.id] - dt

	infobox:set_value(self._timer[data.id])

	if self._timer[data.id] <= 0 and not data.manual_remove then
		managers.hud:remove_updator("update_custom_timer_"..data.id)
		infobox:remove()
		self._timer[data.id] = nil
	end
end

function HUDAssaultCorner:remove_custom_timer(id)
	if id and VoidUIInfobox:child("cu_"..id) then
		managers.hud:remove_updator("update_custom_timer_"..id)
		VoidUIInfobox:child("cu_"..id):remove()
		self._timer[id] = nil
	end
end

function HUDAssaultCorner:set_custom_jammed(data)
	local infobox = VoidUIInfobox:child("cu_"..data.id)
	if not infobox then return end
	if infobox._is_jammed == data.jammed then return end
	if data.jammed then
		managers.hud:remove_updator("update_custom_timer_"..data.id)
	elseif data.jammed == false then
		managers.hud:add_updator("update_custom_timer_"..data.id, callback(self, self, "update_custom_timer", data))
	end
	infobox:set_jammed(data.jammed)
end

function HUDAssaultCorner:add_custom_time(data)
	if not self._timer then self._timer = {} end
	local infobox = VoidUIInfobox:child("cu_"..data.id)
	if not infobox then return end
	if data.time and self._timer[data.id] then
		if data.operation then
			if data.operation == "add" then
				self._timer[data.id] = self._timer[data.id] + data.time
				if infobox._init_time < data.time then
					infobox._init_time = self._timer[data.id]
				end
			elseif data.operation == "reset" or data.operation == "set_time" then
				self._timer[data.id] = data.time
				infobox._init_time = data.time
			elseif data.operation == "pause" then
				managers.hud:remove_updator("update_custom_timer_"..data.id)
			end
		else
			VoidUIInfobox:Error("No operation specified for timer: "..data.id)
		end
	end
end

function HUDAssaultCorner:update_box(id, value, _type)
	local infobox = VoidUIInfobox:child(id)
	if VoidUI_IB.options.remove_empty and value == 0 or value == "0 | x0" then
		if infobox then
			infobox:remove()
		end
		return
	end
	if not infobox then
		local InfoboxClass = _type == "Collectable" and CollectableInfobox or CounterInfobox
		InfoboxClass:new({
			id = id,
			value = value
		})
	else
		if value and value ~= infobox.value then
			infobox:set_value(value)
		end
	end
end

Hooks:PostHook(HUDAssaultCorner, 'whisper_mode_changed', 'VUIBA_HUDAssaultCorner_whisper_mode_changed', function(self, data)
	local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
	--Since these panels are animated, we need some delay to wait for them to achieve alpha 0 or 1
	DelayedCalls:Add("delay_sorting", 0.6, function()
		self:sort_boxes()
	end)
	if not is_whisper_mode and VoidUIInfobox and VoidUIInfobox:child("cu_arrest_cooldown") then
		VoidUIInfobox:child("cu_arrest_cooldown"):remove()
	end
end)

Hooks:PostHook(HUDAssaultCorner, 'show_casing', 'VUIBA_HUDAssaultCorner_show_casing', function(self, is_offseted, hostage_panel, big_logo)
	self:sort_boxes()
end)
Hooks:PostHook(HUDAssaultCorner, '_set_hostage_offseted', 'VUIBA_HUDAssaultCorner__set_hostage_offseted', function(self, is_offseted, big_logo, ...)
	self:sort_boxes()
end)
Hooks:PostHook(HUDAssaultCorner, '_offset_hostage', 'VUIBA_HUDAssaultCorner__offset_hostage', function(self, is_offseted, big_logo, ...)
	self:sort_boxes()
end)

Hooks:PostHook(HUDAssaultCorner, '_hide_hostages', 'VUIBA_HUDAssaultCorner__hide_hostages', function(self, ...)
	self:sort_boxes()
end)

Hooks:PostHook(HUDAssaultCorner, '_show_hostages', 'VUIBA_HUDAssaultCorner__show_hostages', function(self, ...)
	self:sort_boxes()
end)

function HUDAssaultCorner:sort_boxes()
	if not self._custom_icons then return end
	--count visible VoidUI boxes;
	local visible_panels = 0
	local y_offset = 0 --Global row
	if not VoidUI_IB.options.row_one_for_vanilla then
		if self._icons then
			for i, k in ipairs(self._icons) do
				if k.panel and k.panel:visible() and k.panel:alpha() == 1 then
					visible_panels = visible_panels + 1
					k.position = visible_panels
				end
			end
		end
	else
		y_offset = 1
	end
	local icons_panel = self._custom_hud_panel:child("icons_panel")
    
    for priority, panels in pairs(self._custom_icons) do
        local row_size = VoidUI_IB.options[priority.."_row_size"] or 7
		if y_offset == 0 and priority > 1 and VoidUI_IB.options.row_one_only_one_priority then
			y_offset = 1
		end
		local row = 1 --Row in priority segment
		local use_visible_panels = false
        for i,panel in ipairs(self._custom_icons[priority]) do
			--Sorts priority segment
			local idx
			if y_offset == 0 or use_visible_panels then
				idx = (i + visible_panels) - ((row - 1) * row_size)
				use_visible_panels = true
			else
				idx = i - ((row - 1) * row_size)
			end
			if alive(panel) then
				local x = icons_panel:w() - panel:w() * idx - (y_offset * 3)
				local y = (panel:h() + 3) * (y_offset)
				local panel_y = panel:y()
				local panel_x = panel:x()
				panel:stop()
				panel:animate(function(o)
					over(0.4, function(p)
						if alive(panel) then
							panel:set_y(math.lerp(panel_y, y, p))
							panel:set_x(math.lerp(panel_x, x, p))
						end
					end)
				end)
			end
			if idx == row_size or i == #self._custom_icons[priority] then
				row = row + 1
                y_offset = y_offset + 1
            end
        end
    end
end