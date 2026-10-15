require("tokyonight").setup({
    style = "night",
    transparent = false,
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
    },
})

vim.cmd.colorscheme("tokyonight-night")
