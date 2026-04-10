local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

-- The command to get both volume and mute status using pamixer
local GET_VOLUME_AND_MUTE_CMD = 'pamixer --get-volume --get-mute'

-- Function to handle the output of the combined command
local function handle_volume_and_mute(stdout)
    local is_muted, volume = string.match(stdout, "(%a+) (%d?%d?%d)")

    -- Decide on the icon based on the volume level and mute status
    local icon
    if is_muted == "true" then
        icon = "󰝟"  -- FontAwesome icon for muted volume
    elseif tonumber(volume) == 0 then
        icon = "󰖁"  -- FontAwesome icon for no volume
    elseif tonumber(volume) <= 50 then
        icon = "󰕿"  -- FontAwesome icon for low volume
    else
        icon = "󰕾"  -- FontAwesome icon for high volume
    end

    -- Emit a signal that your volume widget can listen to for updates
    awesome.emit_signal("evil::volume", {
        value = tonumber(volume) or 0,
        is_muted = is_muted == "true",
        image = icon
    })
end

-- Create a watch to run the GET_VOLUME_AND_MUTE_CMD every second and process the output
watch(GET_VOLUME_AND_MUTE_CMD, 1, function(_, stdout, _, _, _)
    handle_volume_and_mute(stdout)
end, nil)

