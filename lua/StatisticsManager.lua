if not VoidUI_IB.options.kills_infobox and not VoidUI_IB.options.special_kills_infobox then return end

if RequiredScript == "lib/units/enemies/cop/copdamage" then
	CopDamage = CopDamage or class()
	Hooks:PreHook(CopDamage, "_call_listeners", "Infobox_CountVehicleKills", function(self, damage_info)
		if self._unit:character_damage():dead() then
			if damage_info.attacker_unit == managers.player:local_player() then
				managers.statistics:kill_counter(damage_info)
			end
		end
	end)
elseif RequiredScript == "lib/managers/statisticsmanager" then
	Hooks:PostHook(StatisticsManager, "init", "vuib_init", function(self)
		table.insert(self.special_unit_ids, "shadow_spooc")
	end)
	local killed_by_sentry = 0
	local specials_killed_by_sentry = 0
	local kills = 0
	function StatisticsManager:kill_counter(data)
		local stats_name = data.stats_name or data.name
		if alive(data.weapon_unit) and data.weapon_unit.base and data.weapon_unit:base() and data.weapon_unit:base().get_type then
			local weapon_type = data.weapon_unit:base():get_type()
			if weapon_type and weapon_type == "sentry_gun" or weapon_type == "sentry_gun_silent" then
				if table.contains(self.special_unit_ids, stats_name) then
					specials_killed_by_sentry = specials_killed_by_sentry + 1
				else
					killed_by_sentry = killed_by_sentry + 1
				end
			end
		end
		kills = kills + 1
		self._global.session.killed.total.count = kills
		local total_kills = self:session_total_kills() - killed_by_sentry - specials_killed_by_sentry
		local normal_kills = (self:session_total_kills() - killed_by_sentry) - (self:session_total_specials_kills() - specials_killed_by_sentry)
		local special_kills = self:session_total_specials_kills() - specials_killed_by_sentry
		if VoidUI_IB.options.special_kills then
			if VoidUI_IB.options.special_kills_infobox then
				managers.hud._hud_assault_corner:update_box("kills", normal_kills)
				managers.hud._hud_assault_corner:update_box("special_kills", special_kills)
			else
				managers.hud._hud_assault_corner:update_box("kills", special_kills.." | x"..normal_kills)
			end
		else
			managers.hud._hud_assault_corner:update_box("kills", total_kills)
		end
	end
end