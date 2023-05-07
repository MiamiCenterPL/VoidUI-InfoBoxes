if not VoidUI_IB.options.timers then return end
if RequiredScript == "core/lib/managers/mission/coreelementtimer" then
	--Moved tables out of the local functions to prevent recreating them every time the script is loaded
	--[[
		
	]]
	local filter_table = {

		["tRain_returns"] = {"130064", "130164", "130264", "130364", "130464", "130564", "131564", "131814"}, --Train fuse timer
		["wwh"] = {"100590"},
		["pent"] = {"102292", "102293", "102294"},
		["crojob3"] = {"103449", "101577", "101708", "104399", "101099"},
		["mia_2"] = {"130321", "131424", "136321"},
		["chas"] = {"138531", "138831", "139731", "140031", "139431"},
		["des"] = {"136531", "159611"},
		["big"] = {"105990", "105997", "105993", "106006"},
		["dah"] = {"105076", "105083", "145903"},
		["rvd2"] = {"102137"},
		["Xanax"] = {"131017", "100416", "132017"},
		["ranc"] = {"102273", "101062", "102063", "102100"},
		["arm_for"] = {"130664", "130564", "130464", "130364", "130264", "130164", "130064"},
		["shoutout_raid"] = {"132878"},
		["sand"] = {"139108", "103662"},
		["chca"] = {"101362", "150638", "151518", "152025", "151982"},
		["mex"] = {"101721", "196753"},
		["fex"] = {"146490"},
		["bex"] = {"101816"},
		["watchdogs_2"] = {"103729", "101128"},
		["pal"] = {"102290", "100083"},
		["friend"] = {"103457", "103465", "103471", "131444", "131424"},
		["cane"] = {"133328", "134228", "135128", "133028", "136628", "135428", "132728", "136028", "133928", "134528", "134828", "132428"},
		["arena"] = {"135067", "135027", "130527", "134813"},
		["vit"] = {"152362", "134295", "134195", "134395", "134495"},
		["bph"] = {"135953", "142253"},
		["mex_cooking"] = {"199503"},
		--["born"] = {},
		["chew"] = {"143791", "143795", "144291", "144295", "144541", "144545", "144791", "144795"},
		["trai"] = {"140824", "141024", "137899", "137899", "139724", "141673"},
		["spa"] = {"100181", "100540"},
		["framing_frame_1"] = {"103086"},
		["gallery"] = {"103086"},
		["red2"] = {"136002", "136202"}
		--["Election_Funds"] = {'101311', '100019'
	}

	local filter_names_table = {
		--[[
		]]
		["friend"] = {
			["102813"] = "Breaching"
		},
		["born"] = {
			["101033"] = "Assemble"
		},
		["pex"] = {
			["101587"] = "Fire",
			["137324"] = "Hack",
			["135324"] = "Hack"
		},
		["tRain_returns"] = {
			["130023"] = "Time_lock",
			["130123"] = "Time_lock",
			["130223"] = "Time_lock",
			["130323"] = "Time_lock",
			["130423"] = "Time_lock",
			["130523"] = "Time_lock",
			["131523"] = "Time_lock",
			["131773"] = "Time_lock"
		},
		["mad"] = {
			["133167"] = "Analyze",
			["131662"] = "EMP",
			["131362"] = "EMP"
		},
		["spa"] = {
			["101992"] = {"Achievement", "spa_5"},
			["101201"] = "Escape"
		},
		["roberts"] = {
			["105234"] = "Time_lock"
		},
		["modders_devmap"] = {
			["100866"] = "Timer"
		},
		["kenaz"] = {
			["167670"] = "BFD",
			["167717"] = "Water",
			["167718"] = "Water"
		},
		["peta2"] = {
			["101717"] = "Bridge"
		},
		["trai"] = {
			["152295"] = "Crane",
			["152308"] = "Crane"
		},
		["corp"] = {
			["102743"] = {"Achievement", "corp_12"},
			["103656"] = {"Achievement", "corp_12"},
			["101877"] = "Helicopter",
			["102401"] = "Escape",
			["102727"] = {"Achievement", "corp_11"}
		},
		["wwh"] = {
			["100321"] = "Fuel"
		},
		["btms"] = {
			["150099"] = "Fuel",
			["201561"] = "Time_lock"
		},
		["crojob3"] = {
			["130179"] = "Helicopter",
			["102824"] = "Water_pump"
		},
		["pal"] = {
			["101229"] = "Water",
			["102736"] = "Printer",
			["102739"] = "Paper",
			["102740"] = "Ink"
		},
		["mia_1"] = {
			["131335"] = "Barcode_scanner",
			["104931"] = "Breaching",
			["106012"] = "Breaching",
			["104927"] = "Breaching"
		},
		["sah"] = {
			["101874"] = {"Achievement", "sah_9"},
			["100642"] = "ChargeGun",
			["134927"] = "Time_lock"
		},
		["mia_2"] = {
			["101220"] = {"Achievement", "pig_2"},
			["100053"] = "MiaCokeDestroy",
			["101043"] = "MiaCokeDestroy"
		},
		["pbr"] = {
			["150099"] = "Fuel"
		},
		["pbr2"] = {
			["144023"] = "Helicopter",
			["146023"] = "Helicopter",
			["145123"] = "Helicopter",
			["146123"] = "Helicopter",
			["143723"] = "Helicopter",
			["144723"] = "Helicopter",
			["145723"] = "Helicopter",
			["143823"] = "Helicopter",
			["144823"] = "Helicopter",
			["145823"] = "Helicopter",
			["144423"] = "Helicopter",
			["145423"] = "Helicopter",
			["145923"] = "Helicopter",
			["143523"] = "Helicopter",
			["144523"] = "Helicopter",
			["146523"] = "Helicopter",
			["143623"] = "Helicopter",
			["144623"] = "Helicopter",
			["145623"] = "Helicopter",
			["144223"] = "Helicopter",
			["145223"] = "Helicopter",
			["146223"] = "Helicopter",
			["144323"] = "Helicopter",
			["145323"] = "Helicopter",
			["146323"] = "Helicopter",
			["145523"] = "Helicopter",
			["145023"] = "Helicopter",
			["143923"] = "Helicopter",
			["144923"] = "Helicopter",
			["146423"] = "Helicopter",
			["144123"] = "Helicopter"
		},
		["chas"] = {
			["101266"] = {"Achievement", "chas_11"},
			["136031"] = "Time_lock",
			["136013"] = "Time_lock"
		},
		["mex"] = {
			["102677"] = "Fuel",
			["156867"] = "Time_lock"
		},
		["des"] = {
			["101687"] = "Crane"
		},
		["pent"] = {
			["103868"] = {"Achievement", "pent_10"}
		},
		["arm_for"] = {
			["130623"] = "Time_lock",
			["130523"] = "Time_lock",
			["130423"] = "Time_lock",
			["130323"] = "Time_lock",
			["130223"] = "Time_lock",
			["130123"] = "Time_lock",
			["130023"] = "Time_lock"
		},
		["fex"] = {
			["153495"] = "Hack"
		},
		["bex"] = {
			["150464"] = "Hack"
		},
		["nmh"] = {
			["104482"] = {"Achievement", "nmh_11"}
		},
		["brb"] = {
			["100653"] = "Breaching",
			["132976"] = "Cutter"
		},
		["chca"] = {
			["102674"] = "Helicopter"
		},
		["big"] = {
			["103102"] = "Time_lock"
		},
		["cane"] = {
			["135417"] = "Elf",
			["135117"] = "Elf",
			["132417"] = "Elf",
			["134217"] = "Elf",
			["134817"] = "Elf",
			["134517"] = "Elf",
			["133017"] = "Elf",
			["133317"] = "Elf",
			["133917"] = "Elf",
			["136017"] = "Elf",
			["132717"] = "Elf",
			["136617"] = "Elf"
		},
		["mus"] = {
			["130318"] = "Time_lock",
			["130393"] = "Time_lock"
		},
		["kosugi"] = {
			["100953"] = "Time_lock"
		},
		["glace"] = {
			["102333"] = "Plane",
			["100732"] = "Plane"
		}
	}

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
	
	core:module("CoreElementTimer")
	core:import("CoreMissionScriptElement")
	local hide_on_stop = {
		["pent"] = {"103868"},
		["hox_3"] = {"139695"},
		["sah"] = {"101874", "100642"},
		["vit"] = {"103495"}
	}
	ElementTimer = ElementTimer or class(CoreMissionScriptElement.MissionScriptElement)

	Hooks:PostHook(ElementTimer, "init", "VUIBA_ElementTimer_init", function(self, ...)
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
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name
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
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name
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
			InfoboxClass:new({
				name = name, id = "e_"..self._id, time = self._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name
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
						local name, achievement_id = filter_names(id)
						local data = {id = id, name = name, time = element._timer, achievement_id = achievement_id, editor_name = self._editor_name, instance_name = self._values.instance_name}
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