local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local ram_widget = wibox.widget{
    {
        id = "icon",
        text = " ", -- FontAwesome icon for RAM
        font = "Font Awesome 5 Free Solid 9", -- Adjust the font size and style as needed
        widget = wibox.widget.textbox,
    },
    {
        id = "text",
        widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
}

local function update_ram_usage()
    awful.spawn.easy_async_with_shell("free -m | awk 'NR==2{printf \"%dMB/%dMB\", $3,$2}'", function(stdout)
        ram_widget.text:set_text(" " .. stdout .. " ")
    end)
end

gears.timer {
    timeout   = 5,
    autostart = true,
    call_now  = true,
    callback  = update_ram_usage
}

return ram_widget

