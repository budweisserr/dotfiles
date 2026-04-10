local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

-- Function to update the keyboard layout text
local function update_keyboard_layout(widget, icon_widget)
    awful.spawn.easy_async_with_shell("xkb-switch", function(stdout)
        -- Assuming the stdout is the layout string like 'us' or 'ua'
        local layout = stdout:gsub("\n", "")
        widget:set_markup("<span foreground='"..beautiful.fg_normal.."'>"..layout:upper().."</span>")
        -- Set the icon here if it depends on the layout, otherwise it can be static
        icon_widget:set_markup("<span foreground='"..beautiful.fg_normal.."'> </span>") --  is a Font Awesome keyboard icon
    end)
end

-- Icon widget
local layout_icon_widget = wibox.widget {
    font = beautiful.icon_font or "Font Awesome 5 Free Solid 9", -- Update this with your actual icon font
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Text widget for the layout
local layout_text_widget = wibox.widget {
    font = beautiful.font or "Roboto Medium 10",
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

-- Initialize the widgets
update_keyboard_layout(layout_text_widget, layout_icon_widget)

-- Update the layout widget periodically
gears.timer {
    timeout   = 0.5,
    call_now  = true,
    autostart = true,
    callback  = function()
        update_keyboard_layout(layout_text_widget, layout_icon_widget)
    end
}

-- The complete keyboard layout widget combining the icon and text
local keyboard_layout_widget = wibox.widget {
    layout_icon_widget,
    layout_text_widget,
    spacing = beautiful.spacing or 4,
    layout = wibox.layout.fixed.horizontal,
}

return keyboard_layout_widget
