if RequiredScript == "lib/units/enemies/cop/logics/coplogicarrest" and VoidUI_IB.options.timer_arrest_cooldown then
    Hooks:PostHook(CopLogicArrest, "_verify_arrest_targets", "ArrestCooldown", function(data, my_data)
        local arrest_targets = my_data.arrest_targets
        local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
        if not is_whisper_mode then return end
        for u_key, arrest_data in pairs(arrest_targets) do
            local record = managers.groupai:state():criminal_record(u_key)
            if record and data.t < record.arrest_timeout then
                if u_key == managers.player:local_player():key() then
                    local data = {
                    id = "arrest_cooldown",
                    time = record.arrest_timeout - data.t,
                    operation = "set_time"
                    }
                    if SkillInfobox:child("cu_arrest_cooldown") then
                        managers.hud._hud_assault_corner:add_custom_time(data)
                    else
                        managers.hud._hud_assault_corner:add_custom_timer(data)
                    end
                end
            end
        end
    end)

    Hooks:PostHook(CopLogicArrest, "damage_clbk", "ArrestCooldown_2", function(data, damage_info)
        local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
        local enemy = damage_info.attacker_unit
        if enemy == managers.player:local_player() then
            local record = managers.groupai:state():criminal_record(enemy:key())
            if record and is_whisper_mode then
                local data = {
                id = "arrest_cooldown",
                name = "arrest_cooldown",
                time = record.arrest_timeout - data.t,
                operation = "set_time"
                }
                if SkillInfobox:child("cu_arrest_cooldown") then
                    managers.hud._hud_assault_corner:add_custom_time(data)
                else
                    managers.hud._hud_assault_corner:add_custom_timer(data)
                end
            end
        end
    end)
    
    Hooks:PostHook(CopLogicArrest, "death_clbk", "ArrestCooldown_3", function(data, damage_info)
        if not data.t then return end
        local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
        local enemy = damage_info.attacker_unit
        if enemy == managers.player:local_player() then
            local record = managers.groupai:state():criminal_record(enemy:key())
            if record and is_whisper_mode then
                local data = {
                id = "arrest_cooldown",
                name = "arrest_cooldown",
                time = record.arrest_timeout - data.t,
                operation = "set_time"
                }
                if SkillInfobox:child("cu_arrest_cooldown") then
                    managers.hud._hud_assault_corner:add_custom_time(data)
                else
                    managers.hud._hud_assault_corner:add_custom_timer(data)
                end
            end
        end
    end)
elseif RequiredScript == "lib/managers/playermanager" then
    if not VoidUI_IB.options.skills then return end
    if VoidUI_IB.options.UnseenStrike then
        Hooks:PostHook(PlayerManager, "init", "Initialize_UnseenStrike_Tracker_VUIB", function(self)
            local unseenstrike_original = PlayerAction.UnseenStrike.Function
    
            function PlayerAction.UnseenStrike.Function(player_manager, min_time, ...)
                local function on_player_damage()
                    if not player_manager:has_activate_temporary_upgrade("temporary", "unseen_strike") then
                        local is_aced = player_manager._global.upgrades.temporary.unseen_strike == 2
                        local data = {id = "UnseenStrike", is_aced = is_aced, time = min_time, manual_remove = true}
                        managers.hud._hud_objectives:add_buff(data)
                        if SkillInfobox:child("UnseenStrike") then
                            SkillInfobox:child("UnseenStrike"):set_blinking_icon(true, Color(1,0,0))
                        end
                    end
                end
        
                player_manager:register_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener", on_player_damage)
                unseenstrike_original(player_manager, min_time, ...)
                player_manager:unregister_message(Message.OnPlayerDamage, "unseen_strike_debuff_listener")
            end
        end)
    end
    if VoidUI_IB.options.skill_Inspire then
        Hooks:PostHook(PlayerManager, 'disable_cooldown_upgrade', 'VUIB_inspire_box', function(self, category, upgrade)
            if upgrade == "long_dis_revive" then
                local upgrade_value = self:upgrade_value(category, upgrade)
                local time = upgrade_value[2]
                if not time then return end
                local data = {id = "Inspire", is_aced = true, time = time}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end
    if VoidUI_IB.options.skill_BloodThirst then
        Hooks:PostHook(PlayerManager, 'set_melee_dmg_multiplier', "VUIB_update_Bloodthirst", function(self, value)
            if not self:has_category_upgrade("player", "melee_damage_stacking") then return end
            if self._melee_dmg_mul ~= 1 then
                local data = {id = "BloodThirst", value = self._melee_dmg_mul}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
        Hooks:PostHook(PlayerManager, 'reset_melee_dmg_multiplier', "VUIB_reset_Bloodthirst", function(self)
            if not self:has_category_upgrade("player", "melee_damage_stacking") then return end
            managers.hud._hud_objectives:remove_buff("BloodThirst")
        end)
    end
    if VoidUI_IB.options.skill_PartnersInCrime or VoidUI_IB.options.skill_AcedPartnersInCrime then
        Hooks:PostHook(PlayerManager, 'upgrade_value', "VUIB_upgrade_value", function(self, category, upgrade, default)
            if upgrade == "minion_master_speed_multiplier" then
                if self._global.upgrades[category] and self._global.upgrades[category][upgrade] then
                    local level = self._global.upgrades[category][upgrade]
                    local value = tweak_data.upgrades.values[category][upgrade][level]
                    if value ~= default then
                        local data = {id = "PartnersInCrime", value = value}
                        managers.hud._hud_objectives:add_buff(data)
                    elseif value == default then
                        managers.hud._hud_objectives:remove_buff("PartnersInCrime")
                    end
                end
            elseif upgrade == "minion_master_health_multiplier" then
                if self._global.upgrades[category] and self._global.upgrades[category][upgrade] then
                    local level = self._global.upgrades[category][upgrade]
                    local value = tweak_data.upgrades.values[category][upgrade][level]
                    if value ~= default then
                        local data = {id = "AcedPartnersInCrime", is_aced = true, value = value}
                        managers.hud._hud_objectives:add_buff(data)
                    elseif value == default then
                        managers.hud._hud_objectives:remove_buff("AcedPartnersInCrime")
                    end
                end
            end
        end)
        Hooks:PostHook(PlayerManager, "count_down_player_minions", "VUIB_num_local_minions", function(self)
            if self._local_player_minions == 0 then
                managers.hud._hud_objectives:remove_buff("PartnersInCrime")
                managers.hud._hud_objectives:remove_buff("AcedPartnersInCrime")
            end
        end)
    end
    if VoidUI_IB.options.skill_TotalSpeedBonus then
        Hooks:PostHook(PlayerManager, "update", "VUIB_babalajka_update", function(self, t, dt)
            self.speed_modifier = self.speed_modifier or 0
            if not self:player_unit() or not self:player_unit():movement() or not self:player_unit():character_damage() then return end
            local morale_boost_bonus = self:player_unit():movement():morale_boost()
            local multiplier = managers.player:movement_speed_multiplier("run", morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, self:player_unit():character_damage():health_ratio()) - 1
            if self.speed_multiplier ~= multiplier then
                local data = {id = "TotalSpeedBonus", value = multiplier}
                if SkillInfobox:child("TotalSpeedBonus") then
                    if multiplier == 0 then
                        managers.hud._hud_objectives:remove_buff("TotalSpeedBonus")
                    else
                        managers.hud._hud_objectives:add_buff(data)
                    end
                else
                    managers.hud._hud_objectives:add_buff(data)
                end
                self.speed_multiplier = multiplier
            end
        end)
    end
    if VoidUI_IB.options.skill_Overkill or VoidUI_IB.options.skill_MedicCombat or VoidUI_IB.options.skill_QuickFix or VoidUI_IB.options.skill_UnseenStrike then
        Hooks:PostHook(PlayerManager, 'activate_temporary_upgrade', 'VUIB_update_overkill', function(self, category, upgrade)
            local upgrade_value = self:upgrade_value(category, upgrade)
            local time
            if type(upgrade_value) == "table" then
                time = upgrade_value[2]
            else
                time = 0
            end
            if not time then return end
            if upgrade == "overkill_damage_multiplier" then
                local data = {id = "Overkill", time = time, value = self:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1), is_aced = self:has_category_upgrade("player", "overkill_all_weapons") and true or nil}
                managers.hud._hud_objectives:add_buff(data)
            elseif upgrade == "revive_damage_reduction" then
                local data = {id = "MedicCombat", time = time, value = self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)}
                managers.hud._hud_objectives:add_buff(data)
            elseif upgrade == "first_aid_damage_reduction" then
                local data = {id = "QuickFix", time = time, value = self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)}
                managers.hud._hud_objectives:add_buff(data)
            elseif upgrade == "unseen_strike" then
                local is_aced = self._global.upgrades.temporary.unseen_strike == 2
                local data = {id = "UnseenStrike", is_aced = is_aced, time = time}
                managers.hud._hud_objectives:add_buff(data)
                SkillInfobox:child("UnseenStrike"):set_blinking_icon(true, Color(0,1,0))
            end
        end)
        Hooks:PostHook(PlayerManager, 'set_property', 'vuib_update_medic_combat2', function(self, name, value)
            if name == "revive_damage_reduction" then
                local data = {id = "MedicCombat", value = value}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
        Hooks:PostHook(PlayerManager, 'remove_property', 'vuib_update_medic_combat3', function(self, name, value)
            if name == "revive_damage_reduction" then
                local data = {id = "MedicCombat", value = value}
                managers.hud._hud_objectives:remove_buff("MedicCombat")
            end
        end)
    end
    if VoidUI_IB.options.skill_PainKillers then
        Hooks:PostHook(PlayerManager, 'activate_temporary_property', 'VUIB_update_medic_combat', function(self, name, time, value)
            if name == "revived_damage_reduction" then
                local is_aced = false
                local aced_value = tweak_data.upgrades.first_aid_kit.revived_damage_reduction[1][1]
                if value == aced_value then
                    is_aced = true
                end
                local data = {id = "PainKillers", is_aced = is_aced, time = time, value = value}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end
    if VoidUI_IB.options.skill_Bulletstorm then
        Hooks:PostHook(PlayerManager, 'add_to_temporary_property', 'VUIB_update_overkill', function(self, name, time, value)
            if name == "bullet_storm" then
                if not time then return end
                local data = {id = "Bulletstorm", time = time}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end
    if VoidUI_IB.options.skill_ForcedFriendship then
        Hooks:PostHook(PlayerManager, 'set_damage_absorption', 'VUIB_update_triathlete', function(self, key, value)
            if key == "hostage_absorption" then
                if value ~= 0 then
                    local data = {id = "ForcedFriendship", is_aced = true, value = value}
                    managers.hud._hud_objectives:add_buff(data)
                elseif value == 0 then
                    managers.hud._hud_objectives:remove_buff("ForcedFriendship")
                end
            end
        end)
    end
    --managers.hud._hud_objectives._hud_panel
elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
    if not VoidUI_IB.options.skills then return end
    if VoidUI_IB.options.skill_SixthSense then
        Hooks:PostHook(PlayerStandard, "_update_omniscience", "VUIB_update_sixth_sense", function(self, t, dt)
            if not SkillInfobox then return end
            local once = true
            local action_forbidden = not managers.player:has_category_upgrade("player", "standstill_omniscience") or managers.player:current_state() == "civilian" or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not managers.groupai:state():whisper_mode() or not tweak_data.player.omniscience
            if action_forbidden then
                managers.hud._hud_objectives:remove_buff("SixthSense")
                return
            end
            if not SkillInfobox:child("SixthSense") then
                local data = {id = "SixthSense", time = tweak_data.player.omniscience.start_t, manual_remove = true}
                managers.hud._hud_objectives:add_buff(data)
            elseif SkillInfobox:child("SixthSense") and SkillInfobox:child("SixthSense").value and SkillInfobox:child("SixthSense").value <= 0 then
                local data = {id = "SixthSense", operation = "set_time", time = tweak_data.player.omniscience.interval_t, manual_remove = true}
                managers.hud._hud_objectives:change_buff_timer(data)
            end
        end)
    end
elseif RequiredScript == "lib/units/beings/player/playerdamage" then
    if not VoidUI_IB.options.skills then return end
    if VoidUI_IB.options.skill_Berserker or VoidUI_IB.options.skill_AcedBerserker then
        function PlayerDamage:update_berserker_ib()
            if managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
                local max_berserker = managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0)
                local health_ratio = managers.player:get_damage_health_ratio(self:health_ratio(), "melee")
                local berserker_multiplier = max_berserker * health_ratio
                if berserker_multiplier > 0 then
                    local data = {id = "Berserker", value = berserker_multiplier}
                    managers.hud._hud_objectives:add_buff(data)
                end
            end
            if managers.player:has_category_upgrade("player", "damage_health_ratio_multiplier") then
                local max_berserker = managers.player:upgrade_value("player", "damage_health_ratio_multiplier", 0)
                local health_ratio = managers.player:get_damage_health_ratio(self:health_ratio(), "damage")
                local berserker_multiplier = max_berserker * health_ratio
                if berserker_multiplier > 0 then
                    local data = {id = "AcedBerserker", is_aced = true, value = berserker_multiplier}
                    managers.hud._hud_objectives:add_buff(data)
                end
            end
        end
        Hooks:PostHook(PlayerDamage, '_on_revive_event', 'VUIB_track_berserker', function(self)
            self:update_berserker_ib()
        end)
        Hooks:PostHook(PlayerDamage, 'change_health', 'VUIB_track_berserker2', function(self)
            self:update_berserker_ib()
        end)
        Hooks:PostHook(PlayerDamage, 'on_downed', 'VUIB_track_berserker3', function(self)
            if managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") then
                managers.hud._hud_objectives:remove_buff("Berserker")
                managers.hud._hud_objectives:remove_buff("AcedBerserker")
            end
        end)
    end
end