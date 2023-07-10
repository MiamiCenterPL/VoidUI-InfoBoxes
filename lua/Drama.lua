if not VoidUI_IB.options.trackers or not VoidUI_IB.options.track_Drama then return end

Hooks:PostHook(GroupAIStateBase, "_add_drama", "VUIB__add_drama", function(self)
	local amount = self._drama_data.amount

    local percentage
    local zone = self._drama_data.zone
    if zone then
        if zone == "high" then
            percentage = 100
        else
            percentage = math.floor(amount / self._drama_data.high_p  * 100)
        end
    else
        percentage = 0
    end
    local box = VoidUIInfobox:child("Drama")
    if box then
        box:_set_value(percentage)
        box:_set_zone(zone)
    else
        local data = {id = "Drama", name = "Drama", percentage = percentage, zone = zone}

        TrackerInfobox:new(data)
    end
end)