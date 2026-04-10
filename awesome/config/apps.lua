local apps = {
    terminal = "kitty", 
    launcher = "sh $HOME/.config/rofi/launch.sh", 
    switcher = require("widgets.alt-tab"),
    xrandr = "lxrandr", 
    screenshot = "flameshot gui",
    volume = "pavucontrol", 
    appearance = "lxappearance", 
    browser = "zen-browser",
    fileexplorer = "thunar",
    musicplayer = "pragha", 
    settings = "code $HOME/awesome/"
}

user = {
    terminal = "kitty", 
    floating_terminal = "kitty"
}

return apps
