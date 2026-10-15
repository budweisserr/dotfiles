local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local apply_borders = require("lib.borders")
local content = require("widgets.dashboard.content")

local rubato = require "lib.rubato"

local height = 663
local width = 582

local outer_padding = 24
local off_screen = width + outer_padding

local busy = false
local is_open = false

local dashboard = wibox({
    ontop = true,
    type = "dock",
    screen = awful.screen.focused(),
    x = off_screen,
    y = 0,
    width = awful.screen.focused().geometry.width,
    height = awful.screen.focused().geometry.height,
    bg = "#00000000"
})

local timed = rubato.timed {
    pos = off_screen,
    duration = 0.75,
    subscribed = function(pos)
        dashboard.x = pos
    end,
}

dashboard.open = function()
    if busy or is_open then return end
    busy = true
    is_open = true
    dashboard.visible = true
    timed.target = 0
    gears.timer.start_new(timed.duration, function()
        busy = false
        return false
    end)
end

dashboard.close = function()
    if busy or not is_open then return end
    busy = true
    is_open = false
    timed.target = off_screen
    gears.timer.start_new(timed.duration, function()
        dashboard.visible = false
        busy = false
        return false
    end)
end

dashboard.toggle = function()
    if is_open then
        dashboard.close()
    else
        dashboard.open()
    end
end

awesome.connect_signal("dashboard::toggle", dashboard.toggle)
awesome.connect_signal("dashboard::close", dashboard.close)

local background_top = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width,
    forced_height = beautiful.bar_height + 4,
}

local background_bottom = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width,
    forced_height = awful.screen.focused().geometry.height - beautiful.bar_height - 4,
}

local background_left = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = awful.screen.focused().geometry.width - width - 4,
    forced_height = height,
}

local background_right = wibox.widget {
    input_passthrough = true,
    bg = "#00000000",
    forced_width = 4,
    forced_height = height,
}

background_top:connect_signal("button::press", dashboard.toggle)
background_bottom:connect_signal("button::press", dashboard.toggle)
background_left:connect_signal("button::press", dashboard.toggle)
background_right:connect_signal("button::press", dashboard.toggle)

dashboard:setup {
    background_top, 
    {
        background_left, 
        {
            apply_borders({
                content, 
                bg = beautiful.bg_normal,
                widget = wibox.container.background
            }, width, height, 8), 
            forced_width = width,
            widget = wibox.container.background
        }, 
        background_right, 
        layout = wibox.layout.fixed.horizontal
    },
    background_bottom, 
    layout = wibox.layout.fixed.vertical
}
