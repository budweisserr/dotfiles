local beautiful = require("beautiful")

local button = require("lib.button")

local color = beautiful.blue
local color_hover = beautiful.blue_light

return button.create_text(color, color_hover, "", 12, function()
    awesome.emit_signal("dashboard::toggle")
end)