local actions = require("telescope.actions")
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	pickers = {
		find_files = {
			theme = "ivy",
			hidden = true,
			no_ignore = false,
			no_ignore_parent = false,
		},
		oldfiles = {
			theme = "ivy",
		},
		live_grep = {
			theme = "ivy",
		},
		grep_string = {
			theme = "ivy",
		},
	},
	defaults = {
		file_ignore_patterns = {
			"node_modules",
			".git",
			"dist",
			"build",
			"vendor",
			"%.lock",
			"%.png",
			"%.jpg",
			"%.jpeg",
			"%.gif",
			"%.svg",
		},
		path_display = { "smart" },
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous,
				["<C-j>"] = actions.move_selection_next,
			},
		},
	},
})

-- Fix: Use explicit vim.keymap.set instead of keymap in setup
-- Find files in CWD
vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files()
end, { desc = "Find files in CWD" })

-- Fuzzy find recent files
vim.keymap.set("n", "<leader>fo", function()
	builtin.oldfiles()
end, { desc = "telescope find oldfiles" })

-- Find string in CWD
vim.keymap.set("n", "<leader>fw", function()
	builtin.live_grep()
end, { desc = "telescope live grep" })

-- Find string under cursor
vim.keymap.set("n", "<leader>fb", function()
	builtin.buffers()
end, { desc = "telescope find buffers" })

vim.keymap.set("n", "<leader>fh", function()
	builtin.help_tags()
end, { desc = "telescope help page" })

vim.keymap.set("n", "<leader>ma", function()
	builtin.marks()
end, { desc = "telescope find marks" })

-- Current buffer fuzzy find
vim.keymap.set("n", "<leader>fz", function()
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "telescope find in current buffer" })

-- Open Neovim config files
vim.keymap.set("n", "<leader>cm", function()
	builtin.git_commits()
end, { desc = "telescope git commits" })

vim.keymap.set("n", "<leader>gt", function()
	builtin.git_status()
end, { desc = "telescope git status" })

vim.keymap.set("n", "<leader>th", "<cmd>Telescope colorscheme<CR>", { desc = "telescope themes" })

vim.keymap.set("n", "<leader>fa", function()
	builtin.find_files({
		hidden = true,
		no_ignore = true,
		follow = true,
	})
end, { desc = "telescope find all files" })

-- Setup multigrep
require("config.telescope.multigrep").setup()
-- Silent - no print notifications
