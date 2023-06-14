if RequiredScript == "lib/managers/playermanager" then
_G.VoidUI_IB = _G.VoidUI_IB or {}

VoidUI_IB.mod_path = ModPath

VoidUI_IB.menus = {}
VoidUI_IB.options_path = SavePath .. "VoidUI_IB.txt"
VoidUI_IB.options = {}

DB:create_entry(Idstring("texture"), Idstring("guis/textures/VoidUI_IB/hud_timer_border"), VoidUI_IB.mod_path.. "textures/hud_timer_border.texture")
Application:reload_textures({Idstring("guis/textures/VoidUI_IB/hud_timer_border")})
--[[texture = tweak_data.skilltree:get_specialization_icon_data(1)
texture_rect = select(2, tweak_data.skilltree:get_specialization_icon_data(1))
log(tostring(texture).." "..tostring(texture_rect))]]

VoidUI_IB._sentry_kills = {}
VoidUI_IB._player_boxes = { --Yeah, I know this sucks but I have to do that otherwise sorting wouldn't work :P
	{{}, {}, {}, {}},
	{{}, {}, {}, {}},
	{{}, {}, {}, {}},
	{{}, {}, {}, {}},
	{{}, {}, {}, {}},
	{{}, {}, {}, {}}
}

local function get_texture_by_achievement(achievement_id)
	local achievment_info = tweak_data.achievement.visual[achievement_id]
	texture, texture_rect = tweak_data.hud_icons:get_icon_or(achievment_info.icon_id, nil)
	return {texture = texture, texture_rect = texture_rect}
end

function VoidUI_IB:get_texture_rect(size, x, row)
	return {
	size*(x-1),
	size*(row-1),
	size,
	size
	}
end

VoidUI_IB.get_texture_by_name = {
		--Infoboxes
		["kills"] = {texture = "units/payday2_cash/safes/cop/sticker/dw_skull_df"},
		["special_kills"] = get_texture_by_achievement("gage3_11"),
		["enemies"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {2,319,64,64}},
		["special_enemies"] = get_texture_by_achievement("im_a_healer_tank_damage_dealer"),
		["enemy_spooc"] = get_texture_by_achievement("gage2_8"),
		["enemy_medic"] = get_texture_by_achievement("halloween_4"),
		["enemy_tank"] = get_texture_by_achievement("iron_man"),
		["enemy_sniper"] = get_texture_by_achievement("armored_6"),
		["enemy_taser"] = get_texture_by_achievement("halloween_5"),
		["enemy_shield"] = get_texture_by_achievement("gage3_10"),
		["civs"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {386,447,64,64}},
		["lootbags"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {128,192,64,64}},
		["possible_loot"] = get_texture_by_achievement("bob_4"),
		["gagepacks"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {3,515,64,64}},
		["Camera"] = {texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = VoidUI_IB:get_texture_rect(48,1,1)},
		--Timers
		["Pager"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,2,5)},
		["Drill"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = {320,320,64,64}},
		["Hack"] = {texture = "guis/textures/pd2/pd2_waypoints", texture_rect = VoidUI_IB:get_texture_rect(32,3,2)},
		["Timer"] = {texture = "guis/textures/pd2/skilltree/drillgui_icon_faster"},
		["Saw"] = {texture = "guis/textures/pd2/pd2_waypoints", texture_rect = VoidUI_IB:get_texture_rect(32,7,3)},
		["Cutter"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,3,5)},
		["Fuel"] = {texture = "guis/textures/pd2/pd2_waypoints", texture_rect = VoidUI_IB:get_texture_rect(32,4,4)},
		["Tape_loop"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,5,3)},
		["Upload"] = {texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = VoidUI_IB:get_texture_rect(48,8,5)},
		["Analyze"] = {texture = "units/gui/gui_generic_search_df"},
		["Breaching"] = {texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = VoidUI_IB:get_texture_rect(48,7,2)},
		["Barcode_scanner"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,1,4)},
		["Helicopter"] = {texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = VoidUI_IB:get_texture_rect(48,7,3)},
		["Printer"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,2,8)},
		["Paper"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,3,8)},
		["Ink"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,1,8)},
		["ChargeGun"] = {texture = "guis/textures/pd2/pd2_waypoints", texture_rect = VoidUI_IB:get_texture_rect(32,1,2)},
		["Elf"] = get_texture_by_achievement("cane_4"),
		["MiaCokeDestroy"] = get_texture_by_achievement("spa_5"),
		["RatVanFlee"] = get_texture_by_achievement("hot_wheels"),
		["Bridge"] = get_texture_by_achievement("bph_10"),
		["Escape"] = get_texture_by_achievement("bph_10"),
		["Plane"] = get_texture_by_achievement("charliesierra_5"),
		["EMP"] = get_texture_by_achievement("cow_10"),
		["Crane"] = {texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/preplan_icon_types", texture_rect = VoidUI_IB:get_texture_rect(42,8,1)},
		["Assemble"] = {texture = "guis/textures/pd2/hud_pickups", texture_rect = VoidUI_IB:get_texture_rect(32,4,3)},
		["Fire"] = {texture = "guis/textures/pd2/pd2_waypoints", texture_rect = VoidUI_IB:get_texture_rect(32,5,2)},
		["Achievement"] = {texture = "guis/textures/pd2/mission_briefing/difficulty_icons", texture_rect = VoidUI_IB:get_texture_rect(32,1,2)},
		["arrest_cooldown"] = tweak_data.hud_icons.crime_spree_cloaker_arrest,
		["Unknown"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,1,1)},
		--Collectables
		["Jewellery"] = {texture = "guis/dlcs/dah/textures/pd2/achievements_atlas_dah", texture_rect = VoidUI_IB:get_texture_rect(85,1,2)},
        ["Money"] = {texture = "guis/dlcs/trk/textures/pd2/achievements_atlas6", texture_rect = {609, 0, 85, 85}},
		["Lrm_Keycard"] = tweak_data.hud_icons.equipment_rfid_tag_01,
		["Keycard"] = tweak_data.hud_icons.equipment_bank_manager_key,
		["Planks"] = tweak_data.hud_icons.equipment_planks,
		["MuriaticAcid"] = tweak_data.hud_icons.equipment_muriatic_acid,
		["HydrogenChloride"] = tweak_data.hud_icons.equipment_hydrogen_chloride,
		["CausticSoda"] = tweak_data.hud_icons.equipment_caustic_soda,
		["Crowbar"] = tweak_data.hud_icons.equipment_crowbar,
		["BlowTorch"] = tweak_data.hud_icons.equipment_blow_torch,
		["Thermite"] = tweak_data.hud_icons.equipment_thermite,
		["Gold"] = tweak_data.hud_icons.equipment_mayan_gold,
		["Receiver"] = tweak_data.hud_icons.equipment_receiver,
		["Barrel"] = tweak_data.hud_icons.equipment_barrel,
		["Stock"] = tweak_data.hud_icons.equipment_stock,
        --Skills
        ["Inspire"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,5,10)},
        ["BloodThirst"] = {texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = VoidUI_IB:get_texture_rect(80,12,7)},
        ["Berserker"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,3,3)},
        ["Overkill"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,4,3)},
        ["SixthSense"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,7,11)},
        ["Bulletstorm"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,5,6)},
        ["ForcedFriendship"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,5,8)},
        ["MedicCombat"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,6,8)},
        ["PainKillers"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,1,11)},
        ["QuickFix"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,2,12)},
        ["UnseenStrike"] = {texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = VoidUI_IB:get_texture_rect(80,11,12)},
        ["PartnersInCrime"] = {texture = "guis/textures/pd2/skilltree_2/icons_atlas_2", texture_rect = VoidUI_IB:get_texture_rect(80,2,11)},
        ["TotalSpeedBonus"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,3,5)},
		--Perks
		["GrindArmor"] = {texture = "guis/dlcs/opera/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,1,1)},
		["ArmorerInvulnerable"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,7,2)},
		["AnarchistInvulnerable"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,7,2)},
		["ArmorRecovery"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,6,1)},
		["StaminaMultiplier"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,8,4)},
		["MarathonManStamina"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,3,1)},
		["MarathonManDmgDampener"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,3,1)},
		["BruteStrength"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,1,1)},
		["GorillaRegen"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,6,7)},
		["LifeDrain"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,8,5)},
		["InfMeleeStack"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,5,11)},
		["MedSup"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,1,7)},
		["Grinder"] = {texture = "guis/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,6,7)},
		["AutoShrug"] = {texture = "guis/dlcs/myh/textures/pd2/specialization/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,3,1)},
		
		
		["sentry_gun"] = {texture = "guis/textures/pd2/equipment", texture_rect = VoidUI_IB:get_texture_rect(32,2,2)},
		["sentry_gun_silent"] = {texture = "guis/textures/pd2/equipment", texture_rect = VoidUI_IB:get_texture_rect(32,4,4)},
		["joker"] = {texture = "guis/textures/pd2/skilltree/icons_atlas", texture_rect = VoidUI_IB:get_texture_rect(64,7,9)}
	}
	VoidUI_IB.get_texture_by_name["Time_lock"] = deep_clone(VoidUI_IB.get_texture_by_name["Timer"])
	VoidUI_IB.get_texture_by_name["Download"] = deep_clone(VoidUI_IB.get_texture_by_name["Upload"])
	VoidUI_IB.get_texture_by_name["The_Beast"] = deep_clone(VoidUI_IB.get_texture_by_name["Drill"])
	VoidUI_IB.get_texture_by_name["BFD"] = deep_clone(VoidUI_IB.get_texture_by_name["Drill"])
	VoidUI_IB.get_texture_by_name["Thermal_drill"] = deep_clone(VoidUI_IB.get_texture_by_name["Drill"])
	VoidUI_IB.get_texture_by_name["Water"] = deep_clone(VoidUI_IB.get_texture_by_name["Fuel"])
	VoidUI_IB.get_texture_by_name["Water_pump"] = deep_clone(VoidUI_IB.get_texture_by_name["Fuel"])

	VoidUI_IB.get_texture_by_name["CInk"] = deep_clone(VoidUI_IB.get_texture_by_name["Ink"])
	VoidUI_IB.get_texture_by_name["CPaper"] = deep_clone(VoidUI_IB.get_texture_by_name["Paper"])

	VoidUI_IB.get_texture_by_name["Power"] = deep_clone(VoidUI_IB.get_texture_by_name["ChargeGun"])

    VoidUI_IB.get_texture_by_name["AcedBerserker"] = deep_clone(VoidUI_IB.get_texture_by_name["Berserker"])
    VoidUI_IB.get_texture_by_name["AcedPartnersInCrime"] = deep_clone(VoidUI_IB.get_texture_by_name["PartnersInCrime"])
	
	function VoidUI_IB:DefaultConfig()
		local file = io.open(VoidUI_IB.mod_path.. "options/default/VoidUI_IB.json", "r")
		if file then
			local data = json.decode(file:read("*all"))
			file:close()
			return data
		end
		log("[VoidUI_IB] Error: Could not load default config!")
	return {}
	end
	
	function VoidUI_IB:Save()
		local file = io.open( self.options_path, "w+" )
		if file then
			file:write( json.encode( self.options ) )
			file:close()
		end
	end

	function VoidUI_IB:Load()
		local file = io.open( self.options_path, "r" )
		if file then
			self.options_temp = json.decode( file:read("*all") )
			file:close()
			for k,v in pairs(self.options_temp) do 
				self.options[k] = v 
			end
			self.options_temp = nil
		else
			self.options = self:DefaultConfig()
			self:Save()
		end
	end

	VoidUI_IB:Load()
else

	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_VoidUI_IB", function(menu_manager, nodes)

		local menus = file.GetFiles(VoidUI_IB.mod_path.. "options/")
		table.insert(VoidUI.menus, VoidUI_IB.mod_path .. "lua/Menu/options.json")
		for i= 1, #menus do
			table.insert(VoidUI_IB.menus, VoidUI_IB.mod_path .. "options/"..menus[i])
		end

		--Add the custom menu to VoidUI menu;

		VoidUI_IB:Load()
		local custom_defaults = VoidUI_IB:DefaultConfig()
		
		local need_save = false
		local need_save_ib = false
		for i,val in pairs(custom_defaults) do
			if VoidUI.options[i] ~= nil then
				log("Moving option; "..tostring(i).." to IB")
				VoidUI_IB.options[i] = VoidUI.options[i]
				VoidUI.options[i] = nil
				need_save = true
				need_save_ib = true
			end
			if VoidUI_IB.options[i] == nil then
				log("Saving option; "..tostring(i))
				VoidUI_IB.options[i]=val
				need_save_ib = true
			end
		end
		if need_save then
			VoidUI:Save()
		end
		if need_save_ib then
			VoidUI_IB:Save()
		end
	end)

	Hooks:Add("LocalizationManagerPostInit", "VoidUI_IB_Localization", function(loc)
		local loc_path = VoidUI_IB.mod_path .. "loc/"

		if file.DirectoryExists(loc_path) then
			if BLT.Localization._current == 'cht' or BLT.Localization._current == 'zh-cn' then
				loc:load_localization_file(loc_path .. "chinese.json")
			elseif BLT.Localization._current == 'chs' then
				loc:load_localization_file(loc_path .. "schinese.json")
			else
				for _, filename in pairs(file.GetFiles(loc_path)) do
					local str = filename:match('^(.*).json$')
					if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
						loc:load_localization_file(loc_path .. filename)
						break
					end
				end
			end
			loc:load_localization_file(loc_path .. "english.json", false)
		else
			log("Localization folder seems to be missing!")
		end
	end)
	Hooks:PreHook(VoidUIMenu, 'CreateMenu', 'support_custom_menus', function(self, params)
		if self._options_panel:child("menu_"..tostring(params.menu_id)) or self._menus[params.menu_id] then
			return self._menus[params.menu_id]
		end
	end)
end