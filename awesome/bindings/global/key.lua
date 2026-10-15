local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local apps = require("config.apps")
local mod = require("bindings.mod")

local function move_focused_to_screen(idx)
	local c = client.focus
	if c then
		awful.client.movetoscreen(c, idx)
	end
end

local function snap(side)
	local c = client.focus
	if not c then return end
	c.maximized = false
	local wa = c.screen.workarea
	c:geometry({
		x = side == "right" and (wa.x + wa.width / 2) or wa.x,
		y = wa.y,
		width = wa.width / 2,
		height = wa.height,
	})
end

awful.keyboard.append_global_keybindings({
	-- awesome
	awful.key({
		modifiers = { mod.super },
		key = "s",
		description = "show help",
		group = "awesome",
		on_press = hotkeys_popup.show_help,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "w",
		description = "move window to second screen",
		group = "awesome",
		on_press = function() move_focused_to_screen(2) end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "q",
		description = "move window to primary screen",
		group = "awesome",
		on_press = function() move_focused_to_screen(1) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "r",
		description = "reload awesome",
		group = "awesome",
		on_press = awesome.restart,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "q",
		description = "quit awesome",
		group = "awesome",
		on_press = awesome.quit,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "x",
		description = "lua execute prompt",
		group = "awesome",
		on_press = function()
			awful.prompt.run({
				prompt = "Run Lua code: ",
				textbox = awful.screen.focused().promptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval",
			})
		end,
	}),

	-- launcher
	awful.key({
		modifiers = {},
		key = "Print",
		description = "take screenshot",
		group = "launcher",
		on_press = function() awful.spawn("flameshot gui", false) end,
	}),
	awful.key({
		modifiers = { "Shift", "Mod1" },
		key = "Mode_switch",
		description = "change keyboard layout",
		group = "launcher",
		on_press = function()
			awful.spawn("setxkbmap -layout us,ua -option 'grp:alt_shift_toggle'", false)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Return",
		description = "open a terminal",
		group = "launcher",
		on_press = function()
			awful.spawn(apps.user.floating_terminal, { floating = true })
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "r",
		description = "run launcher",
		group = "launcher",
		on_press = function()
			awful.spawn(os.getenv("HOME") .. "/.config/rofi/launch.sh", false)
		end,
	}),

	-- audio
	awful.key({
		modifiers = {},
		key = "XF86AudioLowerVolume",
		description = "lower volume",
		group = "launcher",
		on_press = function()
			awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ -3%", function()
				awesome.emit_signal("popup::volume", { amount = -3 })
				awesome.emit_signal("volume::refresh")
			end)
		end,
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioRaiseVolume",
		description = "raise volume",
		group = "launcher",
		on_press = function()
			awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +3%", function()
				awesome.emit_signal("popup::volume", { amount = 3 })
				awesome.emit_signal("volume::refresh")
			end)
		end,
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioMute",
		description = "mute",
		group = "launcher",
		on_press = function()
			awful.spawn.easy_async_with_shell("pamixer -t", function()
				awesome.emit_signal("popup::volume")
				awesome.emit_signal("volume::refresh")
			end)
		end,
	}),

	-- media
	awful.key({
		modifiers = {},
		key = "XF86AudioNext",
		description = "next track",
		group = "launcher",
		on_press = function() awful.spawn("playerctl next", false) end,
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioPlay",
		description = "play/pause",
		group = "launcher",
		on_press = function() awful.spawn("playerctl play-pause", false) end,
	}),
	awful.key({
		modifiers = {},
		key = "XF86AudioPrev",
		description = "previous track",
		group = "launcher",
		on_press = function() awful.spawn("playerctl previous", false) end,
	}),

	-- brightness
	awful.key({
		modifiers = {},
		key = "XF86MonBrightnessDown",
		description = "lower brightness",
		group = "launcher",
		on_press = function()
			awful.spawn.easy_async_with_shell("brightnessctl info", function(stdout)
				local value = tonumber(string.match(string.match(stdout, "%d+%%") or "0", "%d+")) or 0
				local decrease = 3
				if value == 3 then
					decrease = 2
				elseif value == 2 then
					decrease = 1
				elseif value < 2 then
					decrease = 0
				end
				awful.spawn.easy_async_with_shell("brightnessctl set " .. decrease .. "%- > /dev/null", function()
					awesome.emit_signal("popup::brightness", { amount = -decrease })
					awesome.emit_signal("brightness::refresh")
				end)
			end)
		end,
	}),
	awful.key({
		modifiers = {},
		key = "XF86MonBrightnessUp",
		description = "raise brightness",
		group = "launcher",
		on_press = function()
			awful.spawn.easy_async_with_shell("brightnessctl set 3%+ > /dev/null", function()
				awesome.emit_signal("popup::brightness", { amount = 3 })
				awesome.emit_signal("brightness::refresh")
			end)
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "XF86MonBrightnessDown",
		description = "night shift",
		group = "launcher",
		on_press = function() awful.spawn("redshift -P -O 3500", false) end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "XF86MonBrightnessUp",
		description = "turn off night shift",
		group = "launcher",
		on_press = function() awful.spawn("redshift -P -O 6500", false) end,
	}),

	-- window snap / max / min
	awful.key({ mod.super }, "Left", function() snap("left") end),
	awful.key({ mod.super }, "Right", function() snap("right") end),
	awful.key({ mod.super }, "Up", function()
		local c = client.focus
		if c then
			c.maximized = not c.maximized
			c:raise()
		end
	end),
	awful.key({ mod.super }, "Down", function()
		local c = client.focus
		if c then c.minimized = true end
	end),

	-- tag history
	awful.key({
		modifiers = { mod.super },
		key = "Escape",
		description = "go back",
		group = "tag",
		on_press = awful.tag.history.restore,
	}),

	-- focus
	awful.key({
		modifiers = { mod.alt },
		key = "Tab",
		description = "open app switcher forward",
		group = "client",
		on_press = function() apps.switcher.switch(1, "Mod1", "Alt_L", "Shift", "Tab") end,
	}),
	awful.key({
		modifiers = { mod.alt, mod.shift },
		key = "Tab",
		description = "open app switcher backwards",
		group = "client",
		on_press = function() apps.switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab") end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "Tab",
		description = "go back",
		group = "client",
		on_press = function()
			awful.client.focus.history.previous()
			if client.focus then client.focus:raise() end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "j",
		description = "focus the next screen",
		group = "screen",
		on_press = function() awful.screen.focus_relative(1) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "n",
		description = "restore minimized",
		group = "client",
		on_press = function()
			local c = awful.client.restore()
			if c then c:activate({ raise = true, context = "key.unminimize" }) end
		end,
	}),

	-- layout
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "j",
		description = "swap with next client by index",
		group = "client",
		on_press = function() awful.client.swap.byidx(1) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "k",
		description = "swap with previous client by index",
		group = "client",
		on_press = function() awful.client.swap.byidx(-1) end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "u",
		description = "jump to urgent client",
		group = "client",
		on_press = awful.client.urgent.jumpto,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "l",
		description = "increase master width factor",
		group = "layout",
		on_press = function() awful.tag.incmwfact(0.05) end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "h",
		description = "decrease master width factor",
		group = "layout",
		on_press = function() awful.tag.incmwfact(-0.05) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "h",
		description = "increase the number of master clients",
		group = "layout",
		on_press = function() awful.tag.incnmaster(1, nil, true) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "l",
		description = "decrease the number of master clients",
		group = "layout",
		on_press = function() awful.tag.incnmaster(-1, nil, true) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "h",
		description = "increase the number of columns",
		group = "layout",
		on_press = function() awful.tag.incncol(1, nil, true) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		key = "l",
		description = "decrease the number of columns",
		group = "layout",
		on_press = function() awful.tag.incncol(-1, nil, true) end,
	}),
	awful.key({
		modifiers = { mod.super },
		key = "space",
		description = "select next",
		group = "layout",
		on_press = function() awful.layout.inc(1) end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		key = "space",
		description = "select previous",
		group = "layout",
		on_press = function() awful.layout.inc(-1) end,
	}),

	-- tag numrow / numpad
	awful.key({
		modifiers = { mod.super },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local tag = awful.screen.focused().tags[index]
			if tag then tag:view_only() end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local tag = awful.screen.focused().tags[index]
			if tag then tag:viewtoggle() end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.shift },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then client.focus:move_to_tag(tag) end
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super, mod.ctrl, mod.shift },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then client.focus:toggle_tag(tag) end
			end
		end,
	}),
	awful.key({
		modifiers = { mod.super },
		keygroup = "numpad",
		description = "select layout directly",
		group = "layout",
		on_press = function(index)
			local tag = awful.screen.focused().selected_tag
			if tag then tag.layout = tag.layouts[index] or tag.layout end
		end,
	}),
})
