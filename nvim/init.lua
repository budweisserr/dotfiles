require("core")
require("config")

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.opt.termguicolors = true

vim.opt.fileencodings = {
	"utf-8",
	"koi8-u",
	"cp1251",
}

vim.g.gitblame_enabled = 0
