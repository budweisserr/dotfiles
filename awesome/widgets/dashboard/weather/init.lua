local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local json = require("lib.json")

local CURRENT_WEATHER_URL = "https://api.openweathermap.org/data/2.5/weather?q=Lviv&units=metric&appid="
local FORECAST_URL = "https://api.openweathermap.org/data/2.5/forecast?q=Lviv&units=metric&appid="

local get_weather_command = function(api_key)
    return "curl -X GET '"..CURRENT_WEATHER_URL..api_key.."'"
end

local get_forecast_command = function(api_key)
    return "curl -X GET '"..FORECAST_URL..api_key.."'"
end

local get_icon = function(condition)
    local icon

    if (condition == "Thunderstorm") then
        icon = ""
    elseif (condition == "Drizzle") then
        icon = ""
    elseif (condition == "Rain") then
        icon = ""
    elseif (condition == "Snow") then
        icon = ""
    elseif (condition == "Clear") then
        local time = os.date("*t")
        if time.hour > 6 and time.hour < 18 then
            icon = ""
        else
            icon = ""
        end
    elseif (condition == "Clouds") then
        icon = ""
    else
        icon = "敖"
    end

    return icon
end

local temperature = wibox.widget {
    font = "JetBrains Mono Bold 12",
    widget = wibox.widget.textbox
}

local loading_indicator = wibox.widget {
    font = "Roboto Bold 12",
    markup = "Loading weather data...",
    align = "center",
    widget = wibox.widget.textbox
}

local description = wibox.widget {
    font = "JetBrains Mono 10", 
    widget = wibox.widget.textbox
}

local icon_widget = wibox.widget {
    font = beautiful.glyph_font.." 34",
    forced_width = dpi(54),
    forced_height = dpi(54),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local weather_widget = wibox.widget {
    icon_widget,
    {
        nil, 
        {
            temperature,
            description,
            layout = wibox.layout.fixed.vertical
        }, 
        expand = "none", 
        layout = wibox.layout.align.vertical
    }, 
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}

local forecasts = {}
local forecast_widget = wibox.widget {
    spacing = 24,
    layout = wibox.layout.fixed.horizontal
}

for i = 1, 4 do
    local f = {
        time = wibox.widget {
            font = "Roboto Medium 11",
            align = "center",
            widget = wibox.widget.textbox
        },
        icon = wibox.widget {
            font = beautiful.glyph_font.." Nerd Font 26",
            forced_width = dpi(44),
            forced_height = dpi(64),
            align = "center",
            widget = wibox.widget.textbox
        },
        temp = wibox.widget {
            font = "Roboto Regular 10",
            align = "center",
            widget = wibox.widget.textbox
        },
    }

    forecasts[i] = f
    forecast_widget:add(wibox.widget {
        f.time,
        f.icon,
        f.temp,
        spacing = -12,
        layout = wibox.layout.fixed.vertical
    })
end

local update_weather_widget = function(widget, stdout, stderr)
    local result = json.decode(stdout)

    loading_indicator.visible = false

    temperature.markup = "<span foreground='"..beautiful.fg_normal.."'>"..tostring(result.main.temp).." °C</span>"
    description.markup = "<span foreground='"..beautiful.fg_normal.."'>"..result.weather[1].description.."</span>" 
    
    local condition = result.weather[1].main
    local icon = get_icon(condition)

    icon_widget.markup = "<span foreground='"..beautiful.fg_normal.."'>"..icon.."</span>"
end

local update_forecast_widget = function(_, stdout)
    local result = json.decode(stdout)

    for i = 1, 4 do
        local entry = result.list[i]
        local f = forecasts[i]

        f.time.markup = "<span foreground='"..beautiful.fg_normal.."'>"..string.match(tostring(entry.dt_txt), "%d%d:%d%d").."</span>"
        f.temp.markup = "<span foreground='"..beautiful.fg_normal.."'>"..(math.floor(entry.main.temp * 10) / 10).." °C</span>"
        f.icon.markup = "<span foreground='"..beautiful.fg_normal.."'>"..get_icon(entry.weather[1].main).."</span>"
    end
end

local api_key_path = awful.util.getdir("config") .. "widgets/dashboard/weather/openweathermap.txt"
awful.spawn.easy_async_with_shell("cat "..api_key_path, function(stdout)
    local api_key = stdout:gsub("\n", "")

    -- wait for wifi to connect
    awful.spawn.easy_async_with_shell("sleep 8", function()
        awful.widget.watch(get_weather_command(api_key), 1800, update_weather_widget, weather_widget)
        awful.widget.watch(get_forecast_command(api_key), 1800, update_forecast_widget, forecast_widget)
    end)
end)

return wibox.widget {
    nil,
    {
        loading_indicator,
        {
            nil,
            weather_widget,
            expand = "none", 
            layout = wibox.layout.align.horizontal
        }, 
        forecast_widget,
        spacing = dpi(12),
        layout = wibox.layout.fixed.vertical
    },
    expand = "none", 
    layout = wibox.layout.align.vertical
} 
