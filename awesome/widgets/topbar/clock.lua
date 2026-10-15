local wibox = require("wibox")
local beautiful = require("beautiful")

local clock_format = "%A %B %d, %H:%M"

local clock = wibox.widget.textclock()
clock.font = "Roboto Bold 10"
clock.format = "<span foreground='"..beautiful.fg_dark.."'>"..clock_format.."</span>"

return clock