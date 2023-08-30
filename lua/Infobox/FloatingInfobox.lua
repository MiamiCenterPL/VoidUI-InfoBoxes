--@class FloatingInfobox
FloatingInfobox = FloatingInfobox or class()

function FloatingInfobox:setup()
    self._floating_boxes = {}
	if managers.hud then
		managers.hud:remove_updator("FloatingInfoboxUpdator")
	end
	local cb = callback(self,self,"update_floating_infoboxes")
    if managers.hud then
		managers.hud:add_updator("FloatingInfoboxUpdator",cb)
	end
end

--Vectors
local ib_pos = Vector3()
local ib_dir = Vector3()
local ib_dir_normalized = Vector3()
local ib_cam_forward = Vector3()
local ib_onscreen_direction = Vector3()
local ib_onscreen_target_pos = Vector3()

function FloatingInfobox:update_floating_infoboxes(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, ib_cam_forward)

	for id, data in pairs(self._floating_boxes) do
		local infobox = data.panel
		local panel = infobox:parent()

		if data.movement then
			if alive(data.movement._unit) then
				data.pos = data.movement:m_head_pos()
			end
		end

		if data.state == "sneak_present" then
			data.current_position = Vector3(panel:center_x(), panel:center_y())

			infobox:set_center_x(data.current_position.x)
			infobox:set_center_y(data.current_position.y)

			data.current_scale = 1
			data.state = "present_ended"
			data.in_timer = 0
			data.target_scale = 1
		else
			mvector3.set(ib_pos, managers.hud._saferect:world_to_screen(cam, data.pos))
			mvector3.set(ib_dir, data.pos)
			mvector3.subtract(ib_dir, cam_pos)
			mvector3.set(ib_dir_normalized, ib_dir)
			mvector3.normalize(ib_dir_normalized)

			local dot = mvector3.dot(ib_cam_forward, ib_dir_normalized)

			if dot < 0 or panel:outside(mvector3.x(ib_pos), mvector3.y(ib_pos)) then
				if data.state ~= "offscreen" then
					data.state = "offscreen"

					data.arrow:set_visible(true)
					infobox:set_alpha(0.75)

					data.off_timer = 0 - (1 - data.in_timer)
					data.target_scale = 0.75
				end

				local direction = ib_onscreen_direction
				local panel_center_x, panel_center_y = panel:center()

				mvector3.set_static(direction, ib_pos.x - panel_center_x, ib_pos.y - panel_center_y, 0)
				mvector3.normalize(direction)

				local distance = data.radius * tweak_data.scale.hud_crosshair_offset_multiplier
				local target_pos = ib_onscreen_target_pos

				mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

				data.off_timer = math.clamp(data.off_timer + dt, 0, 1)

				if data.off_timer ~= 1 then
					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						target_pos,
						target_pos
					}, data.off_timer))

					--[[data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.off_timer)]]

					--infobox:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, target_pos)
				end

				infobox:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
				data.arrow:set_center(infobox:child("background"):center_x() + direction.x * 36, infobox:child("background"):center_y() + direction.y * 36)

				local angle = math.X:angle(direction) * math.sign(direction.y)

				data.arrow:set_rotation(angle)
			else
				if data.state == "offscreen" then
					data.state = "onscreen"

					data.arrow:set_visible(false)
					infobox:set_alpha(1)

					data.in_timer = 0 - (1 - data.off_timer)
					data.target_scale = 1
				end

				local alpha = 0.8

				if dot > 0.99 then
					alpha = math.clamp((1 - dot) / 0.01, 0.4, alpha)
				end

				if infobox:alpha() ~= alpha then
					infobox:set_alpha(alpha)
				end

				if data.in_timer ~= 1 then
					data.in_timer = math.clamp(data.in_timer + dt, 0, 1)

					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						ib_pos,
						ib_pos
					}, data.in_timer))

					data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.in_timer)

					infobox:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, ib_pos)
				end

				infobox:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
			end
		end
	end
end

--- @param data table
--- @param files? table
--- @return table
function FloatingInfobox:add_floating_box(data)
	local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("wp_arrow")
	local w, h = data.panel:size()
	local arrow = data.panel:bitmap({
		layer = 0,
		visible = false,
		rotation = 360,
		name = "arrow" .. data.id,
		texture = arrow_icon,
		texture_rect = arrow_texture_rect,
		color = (data.color or Color.white):with_alpha(0.75),
		w = arrow_texture_rect[3],
		h = arrow_texture_rect[4],
		blend_mode = data.blend_mode
	})
	arrow:set_center(data.panel:center())
    --Temporary fix for when Infoboxes spawn before class beeing initialized.
    if not self._floating_boxes then
         self:setup()
    end
    --
    table.insert(self._floating_boxes, {
        movement = data.mov_unit and data.mov_unit:movement(),
        pos = data.pos,
        panel = data.panel,
        id = data.id,
        state = "sneak_present",
		in_timer = 0,
		target_scale = 1,
		radius = data.radius and data.radius or 340,
		size = Vector3(w, h, 0),
		arrow = arrow
    })
    return id
end

function FloatingInfobox:remove_floating_box(id)
	for i, data in ipairs(self._floating_boxes) do
		if data.id == id then
			table.remove(self._floating_boxes, i)
			break
		end
	end
end