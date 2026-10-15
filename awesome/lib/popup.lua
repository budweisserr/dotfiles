local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local popup = {}

popup.separator = function()
    return wibox.widget {
        widget = wibox.widget.separator,
        color  = '#b8d2f82a',
        forced_height = dpi(1),
    }
end

return popup
