local awful = require("awful")
local gears = require("gears")

local function refresh()
    awful.spawn.easy_async_with_shell("brightnessctl info", function(stdout)
        local pct = string.match(stdout, "%d+%%")
        if not pct then return end
        local value = tonumber(string.match(pct, "%d+"))
        if not value then return end

        awesome.emit_signal("evil::brightness", {
            value = value,
            image = "󰃠",
        })
    end)
end

-- Initial state.
refresh()

-- Refresh whenever the brightness keybindings fire (instant feedback).
awesome.connect_signal("brightness::refresh", refresh)

-- Safety poll in case brightness is changed outside of awesome (e.g. via
-- power-management daemon). Far less aggressive than the original 1s.
gears.timer({
    timeout = 30,
    autostart = true,
    callback = refresh,
})
