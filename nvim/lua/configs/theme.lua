require("tokyonight").setup({
    style = "night",
    transparent = true,
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "dark",
        floats = "dark",
    },
})

vim.cmd.colorscheme("tokyonight-night")
