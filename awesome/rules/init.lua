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
			-- Float every window from the moment it is managed, so the tile
			-- layout never resizes it. This is what makes windows keep the
			-- size the application asked for (Windows/macOS-like behaviour).
			floating = true,
			-- Respect each app's own min/base/increment size hints. Only has
			-- effect on floating clients, which is now all of them.
			size_hints_honor = true,
			-- Nudges the window on-screen if needed; this only moves, it
			-- never changes the requested size.
			placement = awful.placement.no_offscreen,
		},
		callback = function(c)
			local is_telegram_media_viewer = c.class == "TelegramDesktop" and c.name == "Media viewer"
			if is_telegram_media_viewer then
				return
			end

			-- Defer ONLY the centering until the app has applied its own
			-- geometry. Floating is already set above (immediately, via
			-- properties) so the window is never tiled/resized first.
			-- awful.placement.centered moves the window, it never resizes it.
			gears.timer.delayed_call(function()
				if not c.valid or c.fullscreen or c.maximized then
					return
				end

				if not c.size_hints.user_position and not c.size_hints.program_position then
					awful.placement.centered(c, {
						honor_workarea = true,
						honor_padding = true,
					})
				end
			end)
		end,
	})

	-- Add titlebars to normal clients and dialogs, except apps with native CSD/titlebars
	ruled.client.append_rule({
		id = "titlebars",
		rule_any = { type = { "normal", "dialog" } },
		except_any = {
			class = {
				"discord",
			},
		},
		properties = { titlebars_enabled = true },
	})

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
		callback = function(c)
			-- no_offscreen placement shifts the window into the workarea after
			-- we set fullscreen.  Re-asserting fullscreen is a no-op (already
			-- true), so force the geometry explicitly.
			if c.screen then
				local g = c.screen.geometry
				c:geometry({ x = g.x, y = g.y, width = g.width, height = g.height })
			end
		end,
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
		},
	})
end)
