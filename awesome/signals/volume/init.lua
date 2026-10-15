local awful = require("awful")

-- Resolve volume + mute via pamixer, emit evil::volume.
local function refresh()
    awful.spawn.easy_async_with_shell("pamixer --get-volume --get-mute", function(stdout)
        local is_muted, volume = string.match(stdout, "(%a+)%s+(%d+)")
        if not volume then return end

        local v = tonumber(volume) or 0
        local muted = is_muted == "true"

        local icon
        if muted then
            icon = "󰝟"
        elseif v == 0 then
            icon = "󰖁"
        elseif v <= 50 then
            icon = "󰕿"
        else
            icon = "󰕾"
        end

        awesome.emit_signal("evil::volume", {
            value = v,
            is_muted = muted,
            image = icon,
        })
    end)
end

-- Initial state.
refresh()

-- Refresh whenever the volume keybindings fire.
awesome.connect_signal("volume::refresh", refresh)

-- Refresh on any pulseaudio sink change (catches changes from pavucontrol,
-- another app, headphones plugged in, etc.). One long-running child process,
-- ~zero CPU when idle.
awful.spawn.with_line_callback("pactl subscribe", {
    stdout = function(line)
        if line:match("sink") then
            refresh()
        end
    end,
})
