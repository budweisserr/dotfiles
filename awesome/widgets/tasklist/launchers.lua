local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar_utils = require("menubar.utils")

local helpers = require("lib.helpers")

local favourites = require("widgets.tasklist.favourites")
local icons = require("widgets.tasklist.icons")
local get_app_widget = require("widgets.tasklist.app-widget")

local layout = wibox.layout.fixed.horizontal()
local widgets = {}
layout.spacing = 0

local clientIsApp = function(c, app)
    if app == "intellij" and c.class == "jetbrains-idea" then
        return true
    elseif c.class ~= nil then
        return string.lower(c.class) == string.lower(app)
    elseif c.instance ~= nil then
        return string.lower(c.instance) == string.lower(app)
    elseif c.name ~= nil then
        return string.lower(c.name) == string.lower(app)
    else
        return false
    end
end

for i, v in pairs(favourites) do
    layout:add(wibox.widget{
        widget = wibox.container.background
    })
end

for i, v in pairs(favourites) do
    local widget = wibox.widget {
        get_app_widget(false),
        widget = wibox.container.background
    }

    local custom_icon = widget:get_children_by_id("custom_icon")[1]
    local default_icon = widget:get_children_by_id("default_icon")[1]
    local icon_data = icons[v["name"]]
    
    if icon_data and icon_data["icon"] and icon_data["icon"] ~= "" then
        -- Use custom nerd font icon
        if custom_icon then
            custom_icon.markup = "<span foreground='"..icon_data["color"].."'>"..icon_data["icon"].."</span>"
            custom_icon.visible = true
        end
        if default_icon then
            default_icon.visible = false
        end
    else
        -- Use default app icon from desktop file
        if custom_icon then
            custom_icon.visible = false
        end
        if default_icon then
            local app_icon = menubar_utils.lookup_icon(v["icon"]) or menubar_utils.lookup_icon(v["command"]) or menubar_utils.lookup_icon(v["class"]) or menubar_utils.lookup_icon(v["name"])
            if app_icon then
                default_icon.image = app_icon
            end
            default_icon.visible = true
        end
    end

    local selected_indicator = widget:get_children_by_id("selected_indicator")[1]
    if selected_indicator then
        selected_indicator.bg = beautiful.bg_normal
    end

    widget.count = 0

    widget:connect_signal("button::release", function()
        if widget.count > 0 then
            for _, tag in pairs(root.tags()) do
                for _, c in pairs(tag:clients()) do
                    if clientIsApp(c, v["class"]) then
                        c:jump_to(false)
                        return
                    end
                end
            end
        else
            awful.spawn(v["command"])
        end
    end)

    helpers.hover_pointer(widget)

    layout:remove(v["index"])
    layout:insert(v["index"], widget)

    widgets[i] = widget
end

client.connect_signal("manage", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["class"]) then
            local widget = widgets[i]
            widget.count = widget.count + 1

            local selected_indicator = widget:get_children_by_id("selected_indicator")[1]
            if selected_indicator then
                selected_indicator.bg = beautiful.misc1
                if c.active then
                    selected_indicator.bg = beautiful.fg_urgent
                end
            end
        end
    end
end)

client.connect_signal("unmanage", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["class"]) then
            local widget = widgets[i]
            widget.count = widget.count - 1

            local selected_indicator = widget:get_children_by_id("selected_indicator")[1]
            if selected_indicator and widget.count == 0 then
                selected_indicator.bg = beautiful.bg_normal
            end
        end
    end
end)

client.connect_signal("focus", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["class"]) then
            local widget = widgets[i]
            local selected_indicator = widget:get_children_by_id("selected_indicator")[1]
            if selected_indicator then
                selected_indicator.bg = beautiful.fg_urgent
            end
        end
    end
end)

client.connect_signal("unfocus", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["class"]) then
            local widget = widgets[i]
            local selected_indicator = widget:get_children_by_id("selected_indicator")[1]
            if selected_indicator then
                selected_indicator.bg = beautiful.misc1
            end
        end
    end
end)

return layout