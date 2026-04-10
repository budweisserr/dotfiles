local awful = require("awful")
local beautiful = require("beautiful")

local apps = require("config.apps")
local button = require("lib.button")

local launcher = button.create_text(beautiful.fg_dark, beautiful.fg_focus, "", 14, function()
    awful.spawn(os.getenv("HOME") .. "/.config/rofi/launch.sh", false)
end)

return launcher
