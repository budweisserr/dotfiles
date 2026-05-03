require("material").setup({
    contrast = {
        terminal = true,
        sidebars = true,
        floating_windows = true,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
    },
    plugins = {
        "gitsigns",
        "nvim-cmp",
        "nvim-tree",
        "telescope",
        "which-key",
        "nvim-web-devicons",
    },
    disable = {
        background = true,
        term_colors = false,
    },
    lualine_style = "default",
    high_visibility = {
        lighter = false,
        darker = true,
    },
})

vim.g.material_style = "deep ocean"
vim.cmd.colorscheme("material")
