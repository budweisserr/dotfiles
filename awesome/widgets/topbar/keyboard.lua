local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local layout_icon_widget = wibox.widget {
    font = beautiful.icon_font or "Font Awesome 5 Free Solid 9",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}

local layout_text_widget = wibox.widget {
    font = beautiful.font or "Roboto Medium 10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}

local function refresh()
    awful.spawn.easy_async_with_shell("xkb-switch", function(stdout)
        local layout = stdout:gsub("%s+", "")
        layout_text_widget:set_markup(
            "<span foreground='" .. beautiful.fg_normal .. "'>" .. layout:upper() .. "</span>"
        )
        layout_icon_widget:set_markup(
            "<span foreground='" .. beautiful.fg_normal .. "'> </span>"
        )
    end)
end

refresh()

-- AwesomeWM emits xkb::group_changed when the active group flips
-- (Alt+Shift toggle, etc.). Event-driven, no polling.
awesome.connect_signal("xkb::group_changed", refresh)
-- Re-query if the keymap itself changes (e.g. setxkbmap was just invoked).
awesome.connect_signal("xkb::map_changed", refresh)

return wibox.widget {
    layout_icon_widget,
    layout_text_widget,
    spacing = beautiful.spacing or 4,
    layout = wibox.layout.fixed.horizontal,
}
