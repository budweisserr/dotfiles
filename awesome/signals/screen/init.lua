local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		awful.wallpaper({
			screen = s,
			widget = {
				{
					image = beautiful.wallpaper,
					resize = true,
					widget = wibox.widget.imagebox,
				},
				valign = "center",
				halign = "center",
				tiled = false,
				widget = wibox.container.tile,
			},
		})
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- When a screen is removed (monitor disconnected), move its clients to the
-- remaining screen first, then destroy its tags.
screen.connect_signal("removed", function(s)
	local target = nil
	for i = 1, screen.count() do
		local scr = screen[i]
		if scr ~= s then
			target = scr
			break
		end
	end
	target = target or screen.primary

	local target_tag = target.selected_tag
	for _, t in ipairs(s.tags) do
		for _, c in ipairs(t:clients()) do
			if c.valid then
				c:move_to_tag(target_tag)
			end
		end
	end

	for _, t in ipairs(s.tags) do
		t:delete()
	end
end)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)
end)
