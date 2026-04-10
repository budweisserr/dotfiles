local M = {}

M.theme = {
	name = "material",
	style = "deep ocean",
	transparent = false,
	bg_dark = "#0d1117",
	comment_fg = "#5c6370",
}

M.nvimtree = {
	width = 32,
	show_dotfiles = true,
	side = "left",
}

M.terminal = {
	horizontal_ratio = 0.32,
	vertical_ratio = 0.38,
	float = {
		width = 0.85,
		height = 0.8,
		center = true,
		border = "rounded",
	},
}

return M
