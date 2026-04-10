local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local cpu_widget = wibox.widget{
    {
        id = "icon",
        text = " ", -- FontAwesome icon for CPU
        font = "Font Awesome 5 Free Solid 9",
        widget = wibox.widget.textbox,
    },
    {
        id = "text",
        widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.horizontal,
}

local function update_cpu_usage_and_temp()
    awful.spawn.easy_async_with_shell("top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'", function(stdout)
        local cpu_usage = tonumber(stdout)

        -- Reading CPU temperature
        awful.spawn.easy_async_with_shell("cat /sys/class/thermal/thermal_zone0/temp", function(temp_stdout)
            local cpu_temp = tonumber(temp_stdout) / 1000 -- Convert from millidegree to degree

            -- Update widget text with CPU usage and temperature
            cpu_widget.text:set_text(string.format(" %.1f%% | %.0f°C ", cpu_usage, cpu_temp))
        end)
    end)
end

gears.timer {
    timeout   = 5,
    autostart = true,
    call_now  = true,
    callback  = update_cpu_usage_and_temp
}

return cpu_widget

