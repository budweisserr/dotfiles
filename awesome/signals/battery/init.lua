local beautiful = require("beautiful")
local watch = require("awful.widget.watch")
local dpi = require('beautiful').xresources.apply_dpi

local battery_icons = { [0] = "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", "󰁹" }

local notification


local last_battery_check = os.time()
local warningDisplayed = false

local icon

watch("acpi -i", 10, function(widget, stdout, stderr, exitreason, exitcode)
    local battery_info = {}

    local charging = false

    for s in stdout:gmatch("[^\r\n]+") do
        local status, charge_str, time = string.match(s, '.+: (%a+), (%d?%d?%d)%%,?(.*)')
        
        if status == "Charging" then charging = true end

        if status ~= nil then
            table.insert(battery_info, {status = status, charge = tonumber(charge_str)})
        end
    end

    local charge = 0
    local count = 0
    for _, batt in ipairs(battery_info) do
        charge = charge + batt.charge
        count = count + 1
    end

    charge = math.floor(charge / count)

    if charging then
        icon = "󰂄"
    else
        icon = battery_icons[math.min(math.floor(charge / 10), 10)]

        if charge < 10 then
            if os.difftime(os.time(), last_battery_check) > 300 or not warningDisplayed or charge < 3 then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = os.time()
                warningDisplayed = true

                awesome.emit_signal("evil::battery_warning", charge)
            end
        end
    end
    
    awesome.emit_signal("evil::battery", {
        value = charge,
        image = icon
    })
end,
nil)