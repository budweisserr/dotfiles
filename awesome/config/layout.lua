local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
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
