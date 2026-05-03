local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
    "  ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣭⣿⣶⣿⣦⣼⣆        ",
    "   ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦      ",
    "     ⠈   ⠈⢿⣿⣟⠦⠄⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄    ",
    "          ⣸⣿⣿⢧⠄⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄   ",
    "         ⢠⣿⣿⣿⠈  ⠡⠌⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀  ",
    "  ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿  ",
    " ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷⠄  ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄  ",
    "⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄ ",
    "⠙⠃   ⣼⣿⡟⠌ ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿⠐⣿⣿⡇ ⠛⠻⢷⣄",
    "     ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆   ⠁",
    "      ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣀⣤⣾⡿⠃    ",
    "⢀⣀⠀⣠⣀⣠⣾⣿⣿⡿⠛⠋⠉⠉⠉   ⠉⠉⠉⠉⠛⠻⣿⣿⣷⣄⣀⢿⡽⢻⣦",
    "⠻⠶⠾⠿⠿⠿⠋⠉                 ⠉⠻⠿⠿⠿⠿⠿⠋",
}

dashboard.section.buttons.val = {
    dashboard.button("e", "  New File", "<cmd>ene<CR>"),
    dashboard.button("SPC ff", "󰱼  Find File", "<cmd>Telescope find_files<CR>"),
    dashboard.button("SPC fw", "󰭎  Find Word", "<cmd>Telescope live_grep<CR>"),
    dashboard.button("SPC wr", "󰁯  Restore Session", "<cmd>AutoSession restore<CR>"),
    dashboard.button("q", "󰎙  Quit", "<cmd>qa<CR>"),
}

dashboard.section.footer.val = function()
    return { "", string.format("Loaded %d pack plugins", #vim.pack.get()) }
end

alpha.setup(dashboard.opts)

vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
