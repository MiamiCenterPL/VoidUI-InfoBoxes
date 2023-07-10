TrackerInfobox = TrackerInfobox or class(VoidUIInfobox)

function TrackerInfobox:FetchInfo(data)
    self._priority = VoidUI_IB.options.Tracker_priority or 6
    self._type = "Tracker"

    self.value = data.percentage
    self.zone = data.zone and data.zone or "none"
end

function TrackerInfobox:check_valid()
    if not VoidUI_IB.options.trackers or not VoidUI_IB.options["track_"..self.id] then
        return false
    end
    return true
end

function TrackerInfobox:create(data)
    local scale, panel_w, panel_h = self:get_scale_options()
    local font_size = panel_h / 3

    self._text_panel = self:new_text(tostring(self.value.."%"))
    self:FixFont(self._text_panel, font_size)
    self:upd_background()
end


function TrackerInfobox:_set_value(value)
    if self._text_panel then
        self._text_panel:set_text(tostring(value.."%"))
    end
end

function TrackerInfobox:_set_zone(zone)
    if self.zone ~= zone then
        self.zone = zone
        self:upd_background()
    end
end

function TrackerInfobox:upd_background()
    if self.zone == "high" then
        self._background:set_color(Color(1, 0.4, 0.4))
    elseif self.zone == "low" then
        self._background:set_color(Color(0, 0, 0))
    else
        self._background:set_color(Color(0.4, 1, 0.6))
    end
end