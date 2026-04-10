local user = require("config.user")

require("material").setup({
	style = "deep ocean",
	custom_colors = function(colors)
		colors.editor.bg = user.theme.bg_dark
	end,
	contrast = {
		sidebars = true,
		floating_windows = true,
	},
	disable = {
		italic_comment = false,
	},
	lualine_style = "default",
	async_loading = false,
})

vim.cmd.colorscheme("material")

vim.api.nvim_set_hl(0, "HarpoonWindow", { link = "NormalNC" })
vim.api.nvim_set_hl(0, "HarpoonBorder", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "HarpoonCurrentFile", { link = "Visual" })
