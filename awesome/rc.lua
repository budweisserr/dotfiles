--
--
-- ▄▄▄       █     █░▓█████   ██████  ▒█████   ███▄ ▄███▓▓█████
-- ▒████▄    ▓█░ █ ░█░▓█   ▀ ▒██    ▒ ▒██▒  ██▒▓██▒▀█▀ ██▒▓█   ▀
-- ▒██  ▀█▄  ▒█░ █ ░█ ▒███   ░ ▓██▄   ▒██░  ██▒▓██    ▓██░▒███
-- ░██▄▄▄▄██ ░█░ █ ░█ ▒▓█  ▄   ▒   ██▒▒██   ██░▒██    ▒██ ▒▓█  ▄
--  ▓█   ▓██▒░░██▒██▓ ░▒████▒▒██████▒▒░ ████▓▒░▒██▒   ░██▒░▒████▒
--  ▒▒   ▓▒█░░ ▓░▒ ▒  ░░ ▒░ ░▒ ▒▓▒ ▒ ░░ ▒░▒░▒░ ░ ▒░   ░  ░░░ ▒░ ░
--   ▒   ▒▒ ░  ▒ ░ ░   ░ ░  ░░ ░▒  ░ ░  ░ ▒ ▒░ ░  ░      ░ ░ ░  ░
--   ░   ▒     ░   ░     ░   ░  ░  ░  ░ ░ ░ ▒  ░      ░      ░
--       ░  ░    ░       ░  ░      ░      ░ ░         ░      ░  ░
--
--

local awful = require("awful")
local beautiful = require("beautiful")

require("config.errorhandling")

beautiful.init(awful.util.getdir("config") .. "theme.lua")

-- init configs
require("config.layout")
require("rules")
require("config.tags")
require("bindings")
require("signals")

-- init widgets
require("widgets.dashboard")
require("widgets.topbar")
require("widgets.popup")

require("awful.autofocus")

-- autorun programs
awful.spawn.with_shell("~/.config/awesome/config/autorun.sh")
