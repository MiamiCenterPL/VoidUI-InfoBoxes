
local function chat_debug(str)
	if str and type(str) == "string" then
		log("[VoidUI Infoboxes]: "..str)
		managers.chat:_receive_message(1, "[VoidUI Infoboxes]", str, Color("#94fc03"))
	end
end

if not VoidUI_IB then return end
if VoidUI_IB.options.lootbags_infobox or VoidUI_IB.options.collectables or VoidUI_IB.options.SeparateBagged then
	Hooks:PostHook(ObjectInteractionManager, "init", "VUIBA_ObjectInteractionManager_init", function(self)
		self.custom = {}
		self.unbagged = 0
		self.bagged = 0
		self.lootbag_ids = {"Idstring(@IDd8a53063af19a97f@)", "Idstring(@IDdd162740788712c8@)", "Idstring(@IDee6e75483ec4e88a@)", "Idstring(@ID76162146f9627eb6@)", "Idstring(@ID03777a07c372d31e@)", "Idstring(@ID853940b5f91847cf@)", "Idstring(@ID1a0cd6ee5dfe2aed@)"}
		self.skipped = {"harddrive", "gas", "cas_usb_key", "alarm_clock", "fertilizer", "wire", "diesel", "saw", "car_jack",
		"blueprints", "bottle", "cas_sleeping_gas", "cas_winch_hook", "briefcase", "keychain", "equipment_blueprint", "cargo_strap",
		"stapler", "chavez_key", "server", "ranc_hammer", "ranc_mould", "ranc_sheriff_star", "audio_device", "c4", "ranc_acid",
		"laptop", "ranc_silver_ingot", "tape", "fingerprint", "flammable_liquid", "blood_sample", "blood_sample_verified", "plates",
		"barcode_opa_locka", "barcode_edgewater", "barcode_isles_beach", "barcode_downtown", "barcode_brickell", "c4_x1",
		"lance_part", "chas_keychain_forklift", "laxative", "defibrillator_paddles", "notepad", "adrenaline", "documents", "files",
		"business_card", "hand", "c4_stackable", "evidence", "pex_loaded_card", "pex_unloaded_card", "pex_loaded_card_lvl_2",
		"pex_cutter", "police_uniform", "circle_cutter", "medallion", "chimichanga", "liquid_nitrogen", "c4_x3", "president_key", "cas_bfd_tool"}
		self.skipped_lootbags_id = {"turret_part"}
		self._loot_bags = {}
		self.loot_collectables = {}
		self.possible_loot = {}
		self._skipped_units = {
			des = {"101757", "102204", "400617", "400577", "400515", "400513", "400492"},
			pbr2 = {"100883"},
			big = {"101499"}, --Out of reach, lol
			skm_big2 = {"101499"}, --It's out of the reach anyways.
			skm_cas = {"all"},
			skm_watchdogs_stage2 = {"all"},
			mus = {"300686", "300457", "300458"}, --You can't interact with this unit anyways...
			sah = {"400791", "400792"}, --Decoration only, you can't interact with it.
			firestarter_2 = {"107208"}, --Out of reach
			welcome_to_the_jungle_1 = {"100870", "100871", "100868", "100867", "100866", "100886", "100872"}, --Out of reach
			ranc = {"101286", "101285"},
			mia_1 = {"104526"},
			shoutout_raid = {"103336", "103335", "103346", "101005", "101000", "105005", "103206", "103197", "103194"},
			sand = {"102156"}, --Ouf of reach
			watchdogs_2 = {"100492", "100429", "100491", "100427", "100494", "100495", "100058", "100426", "100054", "100428"},
			rvd2 = {"100277", "100280", "100278", "100279", "100296"},
			family = {"100899", "100900", "100901", "100902"},
			pent = {"500849", "500608"},
			arm_und = {"103835", "103836", "103837", "103838", "101238", "101240", "101237", "101239"},
			fish = {"500533"},
			ukrainian_job = {"100034", "100033"},
			roberts = {"106104"}
			--trai = {""}
		}
		self.name_by_lootID = {
			diamondheist_vault_diamond = "Jewellery", vault_loot_jewels = "Jewellery", vault_loot_ring = "Jewellery",
			diamondheist_big_diamond = "Jewellery", diamondheist_vault_bust = "Jewellery", vault_loot_diamond_chest = "Jewellery",
			vault_loot_diamond_collection = "Jewellery", vault_loot_trophy = "Gold", vault_loot_chest = "Jewellery",
			money_bundle = "Money", vault_loot_banknotes = "Money", vault_loot_cash = "Money", ring_band = "Jewellery", spawn_bucket_of_money = "Gold", gen_atm = "Money",
			vault_loot_gold = "Gold", vault_loot_coins = "Money", equipment_mayan_gold = "Gold", gold_bag_equip = "Gold",
			bank_manager_key = "Keycard", help_keycard = "Keycard", planks = "Planks", boards = "Planks", crowbar = "Crowbar",
			hydrogen_chloride = "HydrogenChloride", caustic_soda = "CausticSoda", acid = "MuriaticAcid",
			paper_roll = "CPaper", printer_ink = "CInk", blow_torch = "BlowTorch", thermite_paste = "Thermite", thermite = "Thermite",
			barrel = "Barrel", receiver = "Receiver", stock = "Stock", slot_machine_payout = "Money", federali_medal = "Gold",
			mus_small_artifact = "Money", lrm_keycard = "Lrm_Keycard"
		}
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

		if table.contains(managers.interaction.lootbag_ids, tostring(unit:name())) then
			return "bagged_loot"
		elseif carry_id then
			if tweak_data.carry[carry_id].skip_exit_secure then
				return "skipped"
			elseif carry_id == "unit:vehicle_falcogini" or carry_id == "vehicle_falcogini" then
				return "skipped"
			end
			return "lootbag"
		elseif interact_type and tweak_data.carry[interact_type] then
			if tweak_data.carry[interact_type].skip_exit_secure then
				return "skipped"
			end
			return "lootbag"
		elseif interact_type == "weapon_case" or interact_type == "crate_loot" or interact_type == "crate_loot_crowbar" then
			return "possible_loot"
		end

		if _get_pickup_id(unit) then
			return "collectable"
		end
	end

	Hooks:RemovePostHook("VoidUI_InfoBox_AddUnit")
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
			if unit_type == "bagged_loot" then
				self._loot_bags[unit:id()] = true
				self.bagged = self.bagged + 1
				self:update_loot_count()
			elseif unit_type == "lootbag" then
				local name = unit:carry_data() and unit:carry_data():carry_id() or interact_type
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