if not VoidUI_IB.options.sentry_infobox then return end
if RequiredScript == "lib/units/weapons/sentrygunweapon" then
	function SentryGunWeapon:get_fire_mode()
		return self._use_armor_piercing
	end

elseif RequiredScript == "lib/units/equipment/sentry_gun/sentrygunequipment" then
	Hooks:PostHook(SentryGunEquipment, 'init', 'listen_to_events', function(self, unit)

		local event_listener = unit:event_listener()
		event_listener:add("VoidUI_IB_spawn_box", {
			"on_setup"
		}, callback(self, self, "VUIB_spawn_box"))
		event_listener:add("VoidUI_IB_health", {
			"on_damage_received"
		}, callback(self, self, "VoidUI_IB_update_sentry"))
		event_listener:add("VoidUI_IB_fire", {
			"on_fire"
		}, callback(self, self, "VoidUI_IB_update_sentry"))
		event_listener:add("VoidUI_IB_death", {
			"on_death"
		}, callback(self, self, "VoidUI_IB_death"))
		event_listener:add("VoidUI_IB_destroy", {
			"on_destroy_unit"
		}, callback(self, self, "VoidUI_IB_remove"))

		event_listener:add("VoidUI_IB_update_firemode", {
			"on_switch_fire_mode"
		}, callback(self, self, "VoidUI_IB_update_sentry"))
		
	end)

	function SentryGunEquipment:VUIB_spawn_box()
		SentryInfobox:new({
			id = "sentry_"..self._unit:id(),
			name_id = self._unit:base():get_type(), 
			color_id = self._unit:base():get_owner_id(), 
			ap_rounds = self._unit:weapon():get_fire_mode(), 
			ammo_ratio = self._unit:weapon():ammo_ratio(),
			health_ratio = self._unit:character_damage():health_ratio(),
			pos = self._unit:position()
		})
	end
	function SentryGunEquipment:VoidUI_IB_update_sentry()
		if SentryInfobox:child("sentry_"..self._unit:id()) then
			--[[
				SentryInfobox:child("sentry_test"):update_info(
					math.random(),
					math.random(),
					1
				)
			]]
			SentryInfobox:child("sentry_"..self._unit:id()):update_info(
				self._unit:character_damage():health_ratio(),
				self._unit:weapon():ammo_ratio(),
				self._unit:weapon():get_fire_mode()
				--self._unit:character_damage():shield_health_ratio()
			)
		end
	end
	
	function SentryGunEquipment:VoidUI_IB_remove()
		if not SentryInfobox or not SentryInfobox:child("sentry_"..self._unit:id()) then return end
		SentryInfobox:child("sentry_"..self._unit:id()):remove()
	end
	
	function SentryGunEquipment:VoidUI_IB_death()
		if not SentryInfobox or not SentryInfobox:child("sentry_"..self._unit:id()) then return end
		SentryInfobox:child("sentry_"..self._unit:id()):update_info(
			0
		)
		SentryInfobox:child("sentry_"..self._unit:id()):remove()
	end
elseif RequiredScript == "lib/units/equipment/sentry_gun/sentrygundamage" then
	Hooks:PostHook(SentryGunDamage, 'sync_health', 'client_sync_health', function(self, health_ratio)
		if not SentryInfobox or not SentryInfobox:child("sentry_"..self._unit:id()) then return end
		SentryInfobox:child("sentry_"..self._unit:id()):update_info(
			self._health_ratio * 100,
			self._unit:weapon():ammo_ratio(),
			self._unit:weapon():get_fire_mode()
			--self._unit:character_damage():shield_health_ratio()
		)
	end)
end