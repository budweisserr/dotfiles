local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    awful.layout.suit.floating,
})

-- Function to handle rounded corners
local function no_rounded_corners(c)
    if c.fullscreen or c.maximized then
        c.shape = function(cr, width, height)
            gears.shape.rectangle(cr, width, height)
        end
    else
        c.shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius or 0)
        end
    end
end

client.connect_signal("property::fullscreen", no_rounded_corners)
client.connect_signal("property::maximized", no_rounded_corners)

-- Prevent floating windows from overlapping the topbar
client.connect_signal("property::geometry", function(c)
    if c.fullscreen or c.maximized then return end
    local wa = c.screen.workarea
    if c.y < wa.y then
        c:geometry({ y = wa.y })
    end
end)

-- Raise focused client to the top of the stack
client.connect_signal("focus", function(c)
    c:raise()
end)
