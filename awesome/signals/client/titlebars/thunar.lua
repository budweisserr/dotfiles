local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local dpi = beautiful.xresources.apply_dpi

local button = require("lib.button")

local get_widget = function(c)
    return wibox.widget {
        {
            {
                nil,
                {
                    nil,
                    { 
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.vertical
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal
                },
                expand = "none", 
                layout = wibox.layout.align.vertical
            }, 
            bg = beautiful.bg_light,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false, true, false, false, dpi(50))
            end,
            widget = wibox.container.background, 
        }, 
        left = dpi(2),
        widget = wibox.container.margin
    }
end

return get_widget
