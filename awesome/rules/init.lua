local awful = require("awful")
local gears = require("gears")
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule({
		id = "global",
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_offscreen,
		},
		callback = function(c)
			local is_telegram_media_viewer = c.class == "TelegramDesktop" and c.name == "Media viewer"
			if is_telegram_media_viewer then
				return
			end

			gears.timer.delayed_call(function()
				if not c.valid or c.fullscreen or c.maximized then
					return
				end

				c.floating = true

				if not c.size_hints.user_position and not c.size_hints.program_position then
					awful.placement.centered(c, {
						honor_workarea = true,
						honor_padding = true,
					})
				end
			end)
		end,
	})

	-- Floating clients.
	ruled.client.append_rule({
		id = "floating",
		rule_any = {
			instance = { "copyq", "pinentry", "floating_terminal" },
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"Sxiv",
				"Tor Browser",
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"feh",
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	})

	-- Add titlebars to normal clients and dialogs, except apps with native CSD/titlebars
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		except_any = {
			class = {
				"Opera",
				"Firefox",
				"discord",
			},
		},
		properties = { titlebars_enabled = true },
	})
	--
	-- ruled.client.append_rule({
	-- 	id = "telegram",
	-- 	rule = { class = "TelegramDesktop" },
	-- 	properties = { titlebars_enabled = false },
	-- })

	ruled.client.append_rule({
		id = "telegram-media-viewer",
		rule = {
			class = "TelegramDesktop",
			name = "Media viewer",
		},
		properties = {
			titlebars_enabled = false,
			fullscreen = true,
		},
	})

	ruled.client.append_rule({
		rule = { class = "Opera" },
		properties = { maximized = true },
	})

	ruled.client.append_rule({
		rule = { class = "Firefox" },
		properties = { maximized = true },
	})

	ruled.client.append_rule({
		rule = { class = "Zen" },
		properties = { maximized = true },
	})

	ruled.client.append_rule({
		rule = { class = "Thunar" },
		properties = { floating = true },
		callback = function(c)
			awful.placement.centered(c, nil)
		end,
	})

	ruled.client.append_rule({
		rule = {
			class = "jetbrains-.*",
			instance = "sun-awt-X11-XWindowPeer",
			name = "win.*",
		},
		properties = {
			floating = true,
			focus = true,
			focusable = false,
			ontop = true,
			placement = awful.placement.restore,
			buttons = {},
			titlebars_enabled = false,
		},
	})

	ruled.client.append_rule({
		rule = {
			class = "jetbrains-.*",
			name = "win.*",
		},
		properties = {
			titlebars_enabled = false,
			floating = true,
		},
	})
end)
