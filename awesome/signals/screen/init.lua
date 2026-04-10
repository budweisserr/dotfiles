local beautiful = require("beautiful")
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		-- local wallpaper = beautiful.wallpaper
		-- -- If wallpaper is a function, call it with the screen
		-- if type(wallpaper) == "function" then
		-- 	wallpaper = wallpaper(s)
		-- end
		-- gears.wallpaper.maximized(wallpaper, s, true)

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

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)
end)
