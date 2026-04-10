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

-- window decorations (titlebars)
--require("decorations")

-- init configs
--require("config.wallpaper")
require("config.layout")
require("rules")
require("config.tags")
require("bindings")
require("signals")

-- init daemons
--require("evil")

-- init widgets
require("widgets.dashboard")
require("widgets.topbar")
require("widgets.popup")
--require("widgets.tasklist")
--require("widgets.dock")
--require("widgets.notifications")

require("awful.autofocus")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Function to check if a process is running
local function process_exists(process_name)
	local process = io.popen("pgrep -x " .. process_name)
	local process_id = process:read("*a")
	process:close()
	return process_id ~= ""
end

-- Autostart applications only if they are not already running
local function run_once(process_name, command)
	if not process_exists(process_name) then
		awful.spawn.with_shell(command)
	end
end

-- autorun programs
awful.spawn.with_shell("~/.config/awesome/config/autorun.sh")

-- use run_once
--[[run_once("Telegram", "Telegram")
run_once("firefox", "firefox")]]
