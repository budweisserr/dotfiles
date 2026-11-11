-- gruber-darker
require("gruber-darker").setup({
    bold = true,
    italic = {
        comments = true,
        strings = false,
    },
})

vim.cmd.colorscheme("gruber-darker")

-- tokyonight (commented out, kept as a fallback)
-- require("tokyonight").setup({
--     style = "night",
--     transparent = false,
--     styles = {
--         comments = { italic = false },
--         keywords = { italic = false },
--         sidebars = "dark",
--         floats = "dark",
--     },
-- })
--
-- vim.cmd.colorscheme("tokyonight")
