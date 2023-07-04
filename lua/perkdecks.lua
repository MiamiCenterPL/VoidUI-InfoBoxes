if not VoidUI_IB.options.ib_perks then return end

function get_current_perkdeck()
    local current_specialization = managers.skilltree:get_specialization_value("current_specialization")
	local specialization_data = tweak_data.skilltree.specializations[current_specialization]
	local specialization_text = specialization_data and specialization_data.name_id or " "
    return specialization_text
end

if VoidUI_IB.options.skill_ArmorRecovery and RequiredScript == "lib/units/beings/player/playerdamage" then
    Hooks:PostHook(PlayerDamage, "set_regenerate_timer_to_max", "VUIBA_PlayerDamage_set_regenerate_timer_to_max", function(self)
        if get_current_perkdeck() == "menu_st_spec_19" then Hooks:RemovePostHook("VUIBA_PlayerDamage_set_regenerate_timer_to_max") return end
        local data = {id = "ArmorRecovery", type = "Perk", time = self._regenerate_timer}
        managers.hud._hud_objectives:add_buff(data)
    end)
end

if VoidUI_IB.options.skill_StaminaMultiplier and RequiredScript == "lib/units/beings/player/playermovement" then
    Hooks:PostHook(PlayerMovement, "_max_stamina", "VUIBA_PlayerMovement__max_stamina", function(self)
        local value = managers.player:stamina_multiplier() - 1
        if value > 0 then
            local data = {id = "StaminaMultiplier", name_id = "StaminaMultiplier", value = value}
            managers.hud._hud_objectives:add_buff(data)
        elseif PerkInfobox:child("StaminaMultiplier") then
            managers.hud._hud_objectives:remove_buff("StaminaMultiplier")
        end
    end)
end

if RequiredScript == "lib/managers/playermanager" then
    --Track PerkDeck individual cards;
    local function track_marathon_man_damage_dampener()
        Hooks:PostHook(PlayerManager, 'activate_temporary_upgrade', 'VUIBA_PlayerManager_activate_temporary_upgrade', function(self, category, upgrade)
            local upgrade_value = self:upgrade_value(category, upgrade)
            local time
            local value = math.abs(1 - self:temporary_upgrade_value("temporary", upgrade, 1))
            if value == 0 then return end
            if type(upgrade_value) == "table" then
                time = upgrade_value[2]
            end
            if not time then return end
            if upgrade == "dmg_dampener_close_contact" then
                local data = {id = "MarathonManDmgDampener", name_id = "MarathonManDmgDampener", type = "Perk", time = time, value = value}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end

    local function track_marathon_man_stamina()
        Hooks:PostHook(PlayerManager, "stamina_multiplier", "VUIBA_PlayerManager_stamina_multiplier", function(self)
            local value = self:team_upgrade_value("stamina", "passive_multiplier", 1) - 1
            local data = {id = "MarathonManStamina", name_id = "MarathonManStamina", value = value}
            if value > 0 then
                managers.hud._hud_objectives:add_buff(data)
            elseif PerkInfobox:child("MarathonManStamina") then
                managers.hud._hud_objectives:remove_buff("MarathonManStamina")
            end
        end)
        
    end

    local function track_MeleeStack()
        --managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0)
        Hooks:PostHook(PlayerManager, "upgrade_value", "VUIBA_PlayerManager_track_MeleeStack", function(self, category, upgrade, default)
            if category == "melee" and upgrade == "stacking_hit_damage_multiplier" then
                if self._global.upgrades[category] and self._global.upgrades[category][upgrade] then
                    local level = self._global.upgrades[category][upgrade]
                    local value = tweak_data.upgrades.values[category][upgrade][level]
                    local data = {id = "InfMeleeStack", name_id = "InfMeleeStack", type = "Perk", time = 1 + value}
                    managers.hud._hud_objectives:add_buff(data)

                    if PerkInfobox:child("InfMeleeStack") then
                        PerkInfobox:child("InfMeleeStack"):set_blinking_icon(true, Color(0,1,0))
                    end
                end    
            end
        end)
    end

    local function track_brute_strength()
        local value = math.abs(1 - managers.player:team_upgrade_value("damage_dampener", "team_damage_reduction", 1))
        local data_bs = {id = "BruteStrength", name_id = "BruteStrength", value = value}
        if managers.player:has_category_upgrade("player", "passive_damage_reduction") and value > 0 then
            managers.hud._hud_objectives:add_buff(data_bs)
        end
        Hooks:PostHook(PlayerManager, "damage_reduction_skill_multiplier", "track_dmg_red_CC_VUIB", function(self, damage_type)
            local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)

            if self:has_category_upgrade("player", "passive_damage_reduction") then
                local health_ratio = self:player_unit():character_damage():health_ratio()
                local min_ratio = self:upgrade_value("player", "passive_damage_reduction")
        
                if health_ratio < min_ratio then
                    dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
                    dmg_red_mul = math.abs(1 - dmg_red_mul)
                    data_bs.value = dmg_red_mul
                end
            end
            if data_bs.value > 0 then
                managers.hud._hud_objectives:add_buff(data_bs)
            end
        end)
    end

    local function track_hostage_situation_count()
        Hooks:PostHook(PlayerManager, "get_hostage_bonus_multiplier", "TrackHostageSituationCounter", function(self, category)
            if self:team_upgrade_value(category, "hostage_multiplier", 1) - 1 == 0 then return end
            local hostages = managers.groupai and managers.groupai:state():hostage_count() or 0
            local minions = self:num_local_minions() or 0
            hostages = hostages + minions
            local value
            if hostages == 0 and PerkInfobox:child("HostageSituationCounter") then
                PerkInfobox:child("HostageSituationCounter"):remove()
            end
            if hostages <= 4 then
                value = tostring(hostages) .. "/4"
            else
                value = "4/4"
            end
            local data = {id = "HostageSituationCounter", name_id = "HostageSituationCounter", value = value}
            managers.hud._hud_objectives:add_buff(data)
        end)
    end

    local function track_life_drain()
        Hooks:PostHook(PlayerManager, 'activate_temporary_upgrade', 'VUIB_track_LifeDrain', function(self, category, upgrade)
            local upgrade_value = self:upgrade_value(category, upgrade)
            local time
            local value = math.abs(1 - self:temporary_upgrade_value("temporary", upgrade, 1))
            if value == 0 then return end
            if type(upgrade_value) == "table" then
                time = upgrade_value[2]
            end
            if not time then return end
            if upgrade == "melee_life_leech" then
                local data = {id = "LifeDrain", name_id = "LifeDrain", type = "Perk", time = time}
                managers.hud._hud_objectives:add_buff(data)
                if PerkInfobox:child("LifeDrain") then
                    PerkInfobox:child("LifeDrain"):set_blinking_icon(true, Color(1,0,0))
                end
            end
        end)
    end

    local function track_grind_armor()
        Hooks:PostHook(PlayerDamage, "_on_damage_armor_grinding", "VUIB_Track_Anarchist_armor_recovery", function(self)
            local time = self._armor_grinding.target_tick

            if time > 0 then
                local data = 
                {id = "GrindArmor", name_id = "GrindArmor", dont_remove_clbk = true, manual_remove = true, type = "Perk", time = time, on_callback = 
                function()
                    local change_timer = {id = "GrindArmor", name_id = "GrindArmor", type = "Perk", time = time, operation = "set_time"}

                    --Somehow self:armor_ratio() == 1 is not working, so I'm using tostring() instead.¯\_(ツ)_/¯
                    if tostring(self:armor_ratio()) == "1" then
                        managers.hud._hud_objectives:remove_buff("GrindArmor")
                    else
                        managers.hud._hud_objectives:change_buff_timer(change_timer)
                    end
                end}
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end

    local function track_auto_shrug()
        local function on_player_dmg()
            local auto_shrug_delay = managers.player:has_category_upgrade("player", "damage_control_auto_shrug") and managers.player:upgrade_value("player", "damage_control_auto_shrug")
            local data = {id = "AutoShrug", name_id = "AutoShrug", type = "Perk", time = auto_shrug_delay}
            managers.hud._hud_objectives:add_buff(data)
        end
        managers.player:register_message(Message.OnPlayerDamage, "VUIB_AutoShrug_listener", on_player_dmg)
    end

        --Track entire PerkDecks;
    local function track_crewchief()
        --Brute Strength
        if VoidUI_IB.options.skill_BruteStrength then
            track_brute_strength()
        end
        --Marathon Man
        if VoidUI_IB.options.skill_MarathonManStamina then
            track_marathon_man_stamina()
        end
        if VoidUI_IB.options.skill_MarathonManDmgDampener then
            track_marathon_man_damage_dampener()
        end
        if VoidUI_IB.options.skill_HostageSituationCounter then
            track_hostage_situation_count()
        end
        
    end

    local function track_armor_invulnerable(deck_str)
        Hooks:PostHook(PlayerManager, 'activate_temporary_upgrade', 'VUIB_update_Armorer', function(self, category, upgrade)
            local upgrade_value = self:upgrade_value(category, upgrade)
            local time
            local time_clbk
            local value = self:temporary_upgrade_value("temporary", upgrade, 1)
            if type(upgrade_value) == "table" then
                time = upgrade_value[1]
                time_clbk = upgrade_value[2]
            else
                time = 0
                time_clbk = 0
            end
            if not time then return end
            if upgrade == "armor_break_invulnerable" then
                local time = 15
                local time_clbk = 20
                local deck_str = "AnarchistInvulnerable"
                local data_clbk = {id = deck_str, name_id = deck_str, type = "Perk", time = time_clbk, operation = "set_time"}
                local data = {id = deck_str, name_id = deck_str, type = "Perk", time = time, on_callback = function()
                    managers.hud._hud_objectives:change_buff_timer(data_clbk)
                    if PerkInfobox:child(deck_str) then
                        PerkInfobox:child(deck_str):set_blinking_icon(false)
                        PerkInfobox:child(deck_str):set_blinking_icon(true, Color(1,0,0))
                    end
                end}
                managers.hud._hud_objectives:add_buff(data)
                if PerkInfobox:child(deck_str) then
                    PerkInfobox:child(deck_str):set_blinking_icon(true, Color(0,1,0))
                end
            end
        end)
    end

    local function track_muscle()
        Hooks:PostHook(PlayerManager, "health_regen", "TrackHealthRegen_VUIB", function(self)
            local data = {id = "GorillaRegen", name_id = "GorillaRegen", type = "Perk", time = 5, manual_remove = true, dont_remove_clbk = true, operation = "set_time", on_callback = function()
                if managers.player:player_unit():character_damage():health_ratio() == 1 then
                    managers.hud._hud_objectives:remove_buff("GorillaRegen")
                end
            end}
            if PerkInfobox:child("GorillaRegen") then
                managers.hud._hud_objectives:change_buff_timer(data)
            else
                managers.hud._hud_objectives:add_buff(data)
            end
        end)
    end

    local function track_infiltrator()
        if VoidUI_IB.options.skill_LifeDrain then
            track_life_drain()
        end
        if VoidUI_IB.options.skill_InfMeleeStack then
            track_MeleeStack()
        end
    end

    local function track_gambler()
        Hooks:PostHook(PlayerManager, 'activate_temporary_upgrade', 'VUIB_update_MedSup', function(self, category, upgrade)
            local upgrade_value = self:upgrade_value(category, upgrade)
            local time
            local time_clbk
            local value = self:temporary_upgrade_value("temporary", upgrade, 1)
            if type(upgrade_value) == "table" then
                time = upgrade_value[1]
                time_clbk = upgrade_value[2]
            else
                time = 0
                time_clbk = 0
            end
            if not time then return end
            if upgrade == "loose_ammo_restore_health" then
                local time = 120
                local data = {id = "MedSup", name_id = "MedSup", type = "Perk", time = time}
                managers.hud._hud_objectives:add_buff(data)
                if PerkInfobox:child("MedSup") then
                    PerkInfobox:child("MedSup"):set_blinking_icon(true, Color(1,0,0))
                end
            end
        end)
    end

    local function track_grinder()
        Hooks:PostHook(PlayerDamage, "add_damage_to_hot", "VUIB_Track_Grinder", function(self)
            local regen_rate = managers.player:upgrade_value("player", "damage_to_hot", 0)
            local ticks_left = (self._doh_data.total_ticks or 1) + managers.player:upgrade_value("player", "damage_to_hot_extra_ticks", 0) - 1
            local data = {id = "Grinder", name_id = "Grinder", type = "Perk", time = ticks_left * regen_rate}
            managers.hud._hud_objectives:add_buff(data)
        end)
    end

    local function track_anarchist()
        --Card 1 - Blitzkrieg Bop
        --Upgrades:
        --[[
            "player_armor_grinding_1",
            "temporary_armor_break_invulnerable_1" -- > armor_grinding
        ]]
        if VoidUI_IB.options.skill_AnarchistInvulnerable then
            track_armor_invulnerable("AnarchistInvulnerable")
        end

        if VoidUI_IB.options.skill_GrindArmor then
            track_grind_armor()
        end
    end

    local function track_stoic()
        if VoidUI_IB.options.skill_AutoShrug then
            track_auto_shrug()
        end
        --player_damage_control_auto_shrug
    end

    local specialization_scripts = {
        menu_st_spec_3 = {permission = VoidUI_IB.options.skill_ArmorerInvulnerable, call_function = function() track_armor_invulnerable("ArmorerInvulnerable") end}, --Armorer
        menu_st_spec_1 = {permission = true, call_function = function() track_crewchief() end}, --Crew Chief
        menu_st_spec_2 = {permission = VoidUI_IB.options.skill_GorillaRegen, call_function = function() track_muscle() end}, --Muscle
        menu_st_spec_8 = {permission = true, call_function = function() track_infiltrator() end}, --Infiltrator
        menu_st_spec_10 = {permission = VoidUI_IB.options.skill_MedSup, call_function = function() track_gambler() end}, --Gambler
        menu_st_spec_11 = {permission = VoidUI_IB.options.skill_Grinder, call_function = function() track_grinder() end}, --grinder
        menu_st_spec_15 = {permission = true, call_function = function() track_anarchist() end}, --Anarchist
        menu_st_spec_19 = {permission = true, call_function = function() track_stoic() end} --Stoic
    }
    Hooks:PostHook(PlayerManager, "spawned_player", "GetCurrentPerkdeck_VUIB", function(self, id, unit)
        local current_specialization = specialization_scripts[get_current_perkdeck()]
        if current_specialization then
            if current_specialization.permission and current_specialization.call_function then
                current_specialization:call_function()
            end
        end

        if VoidUI_IB.options.skill_BruteStrength and VoidUI_IB.options.BruteStrenghtTrackForCCIC then
            track_brute_strength()
        end

        if VoidUI_IB.options.skill_MarathonManStamina and VoidUI_IB.options.MarathonManStaminaTrackForCCIC then
            track_marathon_man_stamina()
        end

        if VoidUI_IB.options.skill_HostageSituationCounter and VoidUI_IB.options.HostageSituationCounterTrackForCCIC then
            track_hostage_situation_count()
        end
    end)
end