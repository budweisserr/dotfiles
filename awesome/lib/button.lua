local wibox = require("wibox")
local beautiful = require("beautiful")

local button = {}

button.create_image = function(image, image_hover)
    local image_widget = wibox.widget {
        image = image, 
        widget = wibox.widget.imagebox
    }
    
    local old_cursor, old_wibox
    image_widget:connect_signal("mouse::enter", function() 
        image_widget.image = image_hover 
        
        -- change cursor
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand2" 
    end)
    image_widget:connect_signal("mouse::leave", function() 
        image_widget.image = image 

        -- reset cursor
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    return image_widget
end

button.create_image_onclick = function(image, image_hover, onclick)
    local image = button.create_image(image, image_hover)

    local container = wibox.widget {
        image, 
        widget = wibox.container.background
    }

    container:connect_signal("button::press", onclick)

    return container
end

button.create_text = function(color, color_hover, text, font_size, onclick)
    local textWidget = wibox.widget {
        font = beautiful.glyph_font .. " " .. font_size, 
        align = "center",
        valign = "center",
        markup = "<span foreground='"..color.."'>"..text.."</span>", 
        forced_width = font_size + 4,
        widget = wibox.widget.textbox
    }

    local old_cursor, old_wibox
    textWidget:connect_signal("mouse::enter", function() 
        textWidget.markup = "<span foreground='"..color_hover.."'>"..text.."</span>" 
        
        -- change cursor
        local wb = mouse.current_wibox

        if wb then
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = "hand2"
        end 
    end)
    textWidget:connect_signal("mouse::leave", function() 
        textWidget.markup = "<span foreground='"..color.."'>"..text.."</span>" 
        
        -- reset cursor
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    if onclick ~= nil then
        textWidget:connect_signal("button::press", onclick)
    end

    return textWidget
end

return button
