if not VoidUI_IB.options.jokers_infobox then return end
local function chat_debug(message)
	log("[VoidUI Infoboxes]: "..message)
	managers.chat:_receive_message(1, "[VoidUI Infoboxes]", message, Color("#fc0394"))
end

local function _add_joker_infobox(unit, peer_unit)
	if unit then
		if VoidUI_IB.options.debug_jokers then
			chat_debug("Attempt add Joker".."\nID: "..tostring(unit:id()))
		end
		local player_unit = peer_unit or managers.player:player_unit()
		local unit_data = unit.unit_data and unit:unit_data()
		local color_id = managers.criminals:character_color_id_by_unit(player_unit)
		if unit_data then
			local infobox = MinionInfobox:new({id = "joker_"..unit:id(), color_id = color_id})
			if _G.Jokermon then
				local joker_name
				if infobox then
					local joker = Jokermon.jokers[unit:base()._jokermon_key]
					joker_name = joker and joker.name or managers.localization:text("VoidUI_IB_joker")
					infobox:rename_joker(joker_name)
					infobox:set_value(joker and joker.kills + joker.special_kills or 0)
					infobox:update_info(unit:character_damage():health_ratio(), joker and joker:get_exp_ratio() or 0)
					
					if unit_data.label_id then
						managers.hud:_remove_name_label(unit_data.label_id)
						local panel_id = managers.hud:_add_name_label({ unit = unit, name = joker_name, owner_unit = peer_unit or managers.player:player_unit()})
						unit_data.label_id = panel_id
						local label = managers.hud:_get_name_label(panel_id)
						if VoidUI_IB.options.health_jokers and VoidUI_IB.options.enable_labels and label.panel:child("minmode_panel") then
							label.interact:set_visible(true)
							label.interact_bg:set_visible(true)
							label.panel:child("minmode_panel"):child("min_interact"):set_visible(true)
							label.panel:child("minmode_panel"):child("min_interact_bg"):set_visible(true)
							label.interact:set_w(label.interact_bg:w() * unit:character_damage():health_ratio())
						end
					end
				end
			end
		end
	end
end

if RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then
	Hooks:PostHook(GroupAIStateBase, 'convert_hostage_to_criminal', 'VUIBA_GroupAIStateBase_convert_hostage_to_criminal', function(self, unit, peer_unit)
		_add_joker_infobox(unit, peer_unit)
	end)

	Hooks:PreHook(GroupAIStateBase, 'remove_minion', 'VUIBA_GroupAIStateBase_remove_minion', function(self, minion_key, player_key)
		local minion_unit = self._converted_police[minion_key]
		if minion_unit and MinionInfobox:child("joker_"..minion_unit:id()) then
			MinionInfobox:child("joker_"..minion_unit:id()):remove()
		end
	end)
	
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then

	Hooks:PreHook(UnitNetworkHandler, 'hostage_trade', 'VUIBA_UnitNetworkHandler_hostage_trade', function(self, unit, enable, trade_success, skip_hint)
		if unit and MinionInfobox:child("joker_"..unit:id()) then
			MinionInfobox:child("joker_"..unit:id()):remove()
		end
	end)
	Hooks:PostHook(UnitNetworkHandler, 'mark_minion', 'VUIBA_UnitNetworkHandler_mark_minion', function(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
		local peer_unit = managers.network and managers.network:session() and alive(managers.network:session():peer(minion_owner_peer_id):unit()) and managers.network:session():peer(minion_owner_peer_id):unit()
		_add_joker_infobox(unit, peer_unit)
	end)
	Hooks:PostHook(UnitNetworkHandler, 'remove_minion', 'VUIBA_UnitNetworkHandler_remove_minion', function(self, unit, minion_owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level, sender)
		if unit then
			if VoidUI_IB.options.debug_jokers then
				chat_debug("Attempt remove Joker with localscript".."\nID: "..tostring(unit:id()))
			end
			if MinionInfobox:child("joker_"..unit:id()) then
				MinionInfobox:child("joker_"..unit:id()):remove()
			end
		end
	end)
elseif RequiredScript == "lib/units/enemies/cop/huskcopbrain" then
	
	Hooks:PreHook(HuskCopBrain, 'clbk_death', 'VUIBA_HuskCopBrain_clbk_death', function(self, my_unit, damage_info)
		if self._unit and MinionInfobox:child("joker_"..self._unit:id()) then
			MinionInfobox:child("joker_"..self._unit:id()):remove()	
		end
	end)
	
elseif RequiredScript == "lib/units/enemies/cop/copdamage" then

	Hooks:PostHook(CopDamage, '_on_damage_received', 'VUIBA_CopDamage__on_damage_received', function(self, damage_info)
		if self._unit then
			if MinionInfobox:child("joker_"..self._unit:id()) then
				MinionInfobox:child("joker_"..self._unit:id()):update_info(self._health_ratio)
			end
		end
	end)
	Hooks:PostHook(CopDamage, "damage_mission", "VUIBA_CopDamage_damage_mission", function(self, attack_data)
		if self._unit and MinionInfobox:child("joker_"..self._unit:id()) then
			MinionInfobox:child("joker_"..self._unit:id()):remove()
		end
	end)
	Hooks:PreHook(CopDamage, "_call_listeners", "VUIBA_CopDamage__call_listeners", function (self, damage_info)
		if self._dead then
			local infobox
			if damage_info.attacker_unit then
				infobox = MinionInfobox:child("joker_"..damage_info.attacker_unit:id())
				if VoidUI_IB.options.jokers_kills and infobox then
					infobox:set_value()
					if Jokermon then
						local joker = Jokermon.jokers[damage_info.attacker_unit:base()._jokermon_key]
						infobox:update_info(nil, joker and joker:get_exp_ratio() or 0)
					end
				else
					infobox = VoidUIInfobox:child("sentry_"..damage_info.attacker_unit:id())
					if infobox then
						infobox:set_value()
					end
				end
			else
				infobox = MinionInfobox:child("joker_"..self._unit:id())
				if infobox then
					infobox:remove()
				end
			end
		end
	end)
end