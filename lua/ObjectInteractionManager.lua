
local function chat_debug(str)
	if str and type(str) == "string" then
		log("[VoidUI Infoboxes]: "..str)
		managers.chat:_receive_message(1, "[VoidUI Infoboxes]", str, Color("#94fc03"))
	end
end

if not VoidUI_IB then return end
if VoidUI_IB.options.lootbags_infobox or VoidUI_IB.options.collectables or VoidUI_IB.options.SeparateBagged then
	Hooks:PostHook(ObjectInteractionManager, "init", "VUIBA_ObjectInteractionManager_init", function(self)
		local tweakdata = VoidUI_IB:LoadTweakDataFromFile("tweakdata/ObjectInteractionTweakData.json")
		self.custom = {}
		self.unbagged = 0
		self.bagged = 0
		self.lootbag_ids = tweakdata.lootbag_ids
		self.skipped_lootbags_id = tweakdata.skipped_lootbags_id
		self._skipped_units = tweakdata.skipped_units
		self.name_by_lootID = tweakdata.name_by_lootID
		self.skipped = tweakdata.skipped
		self._loot_bags = {}
		self.loot_collectables = {}
		self.possible_loot = {}
		self.custom.loot_collectables = {}
	end)
	
	local function _get_pickup_id(unit)
		local pickup_id = unit:base() and unit:base().small_loot

		if not pickup_id and unit:interaction().tweak_data then
			int_data = tweak_data.interaction[unit:interaction().tweak_data]
			pickup_id = unit:interaction()._special_equipment and unit:interaction()._special_equipment or (int_data and int_data.special_equipment_block) and int_data.special_equipment_block or nil
		end
		return pickup_id
	end
	
	local function _get_unit_type(unit)
		local carry_id = unit:carry_data() and unit:carry_data():carry_id()
		local interact_type = unit:interaction().tweak_data
		local counted_possible_by_int = {"grenade_briefcase", "money_briefcase", "gen_pku_warhead_box", "weapon_case", "weapon_case_axis_z", "crate_loot", "crate_loot_crowbar"}
		local counted_by_int = {"hold_take_helmet", "take_weapons_axis_z"}

		if table.contains(managers.interaction.lootbag_ids, tostring(unit:name())) then
			return "bagged_loot"
		elseif carry_id then
			if tweak_data.carry[carry_id].skip_exit_secure then
				return "skipped"
			elseif carry_id == "unit:vehicle_falcogini" or carry_id == "vehicle_falcogini" then
				return "skipped"
			end
			return "lootbag"
		elseif interact_type then
			if table.contains(counted_possible_by_int, interact_type) then
				return "possible_loot"
			elseif tweak_data.carry[interact_type] and not tweak_data.carry[interact_type].skip_exit_secure then
				return "lootbag"
			elseif table.contains(counted_by_int, interact_type) then
				return "lootbag"
			end
		end

		if _get_pickup_id(unit) then
			return "collectable"
		end
	end
	
	Hooks:PostHook(ObjectInteractionManager, "add_unit", "VUIBA_ObjectInteractionManager_add_unit", function(self, unit)
		if alive(unit) then
			local carry_id = unit:carry_data() and unit:carry_data():carry_id()
			local interact_type = unit:interaction().tweak_data
			local level_id = managers.job:current_level_id()
			local unit_id = unit:unit_data() and unit:unit_data().unit_id
			if (level_id and self._skipped_units[level_id] and unit_id) and (table.contains(self._skipped_units[level_id], tostring(unit_id)) or table.contains(self._skipped_units[level_id], "all")) then
				return
			end
			local unit_type = _get_unit_type(unit)
			if not unit_type or unit_type == "skipped" then
				return
			end
			if unit_type == "bagged_loot" then --Has any value?
				--Due to bags not having Carry Data in the exact moment when Interaction is created, we need to add a little delay...
				DelayedCalls:Add("delay_cnt_"..unit_id, 0.01, function()
					local carry_id = unit:carry_data():carry_id()
					if tweak_data.carry[carry_id].bag_value then
						self._loot_bags[unit:id()] = true
						self.bagged = self.bagged + 1
						self:update_loot_count()
					else
						return
					end
				end)
			elseif unit_type == "lootbag" then
				local name = carry_id or interact_type
				if table.contains(self.skipped_lootbags_id, name) then
					return
				end
				self._loot_bags[unit:id()] = true
				if VoidUI_IB.options.debug_lootbags then
					chat_debug("Adding unbagged bag to counter. Name = "..tostring(name).."\nID = "..tostring(unit:unit_data().unit_id).."\nUnit name: "..tostring(unit:name()))
				end
				self.unbagged = self.unbagged + 1
				self:update_loot_count()
			elseif unit_type == "collectable" then
				local pickup_id = _get_pickup_id(unit)
				if self.name_by_lootID[pickup_id] then
					local name = self.name_by_lootID[pickup_id]
					if not self.custom.loot_collectables[name] then 
						self.custom.loot_collectables[name] = 0
					end
					self.loot_collectables[unit:id()] = name
					self:update_collectable_count(name, 1)
				elseif not table.contains(self.skipped, pickup_id) and VoidUI_IB.options.debug_show_missing_id then
					chat_debug("Missing collectable ID: "..pickup_id)
				end
			elseif unit_type == "possible_loot" then
				table.insert(self.possible_loot, unit:id())
				self:update_possible_loot()
			end
		end
	end)

	Hooks:PostHook(ObjectInteractionManager, "remove_unit", "VUIBA_ObjectInteractionManager_remove_unit", function(self, unit)
		if self._loot_bags[unit:id()] then
			self._loot_bags[unit:id()] = nil
			if not table.contains(self.lootbag_ids, tostring(unit:name())) then
				self.unbagged = self.unbagged - 1
			else
				self.bagged = self.bagged - 1
			end
			self:update_loot_count()
		end
		if self.loot_collectables[unit:id()] then
			local name = self.loot_collectables[unit:id()]
			self.loot_collectables[unit:id()] = nil
			self:update_collectable_count(self.name_by_lootID[name] and self.name_by_lootID[name] or tostring(name), -1)
		end
		if table.contains(self.possible_loot, unit:id()) then
			table.remove(self.possible_loot, table.index_of(self.possible_loot, unit:id()))
			self:update_possible_loot()
		end
	end)

	function ObjectInteractionManager:update_possible_loot()
		if not managers.hud or not managers.hud._hud_assault_corner then
			return --HUDAssaultCorner will fetch the count on its own while initializing
		end
		local count = #self.possible_loot
		managers.hud._hud_assault_corner:update_box("possible_loot", count)
	end

	function ObjectInteractionManager:update_loot_count()
		if not managers.hud or not managers.hud._hud_assault_corner then
			return --HUDAssaultCorner will fetch the count on its own while initializing
		end
		if VoidUI_IB.options.SeparateBagged then
			local string = tostring(self.bagged).." | x"..tostring(self.unbagged)
			managers.hud._hud_assault_corner:update_box("lootbags", string)
		else
			managers.hud._hud_assault_corner:update_box("lootbags", self.bagged + self.unbagged)
		end
	end

	function ObjectInteractionManager:update_collectable_count(name_id, value)
		if not managers.hud or not managers.hud._hud_assault_corner then
			self.custom.loot_collectables[name_id] = self.custom.loot_collectables[name_id] + value
			--Store the value for later
			return --HUDAssaultCorner will fetch the count on its own while initializing
		end
		self.custom.loot_collectables[name_id] = self.custom.loot_collectables[name_id] + value
		managers.hud._hud_assault_corner:update_box(name_id, self.custom.loot_collectables[name_id], "Collectable")
	end
end