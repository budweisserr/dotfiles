vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap
local terminal = require("core.terminal")

local function comment_parts()
	local commentstring = vim.bo.commentstring ~= "" and vim.bo.commentstring or "# %s"
	local left, right = commentstring:match("^(.*)%%s(.*)$")
	return vim.trim(left or "#"), vim.trim(right or "")
end

local function escape_pattern(text)
	return text:gsub("([^%w])", "%%%1")
end

local function toggle_comments(line1, line2)
	local left, right = comment_parts()
	local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

	for i, line in ipairs(lines) do
		local indent = line:match("^%s*") or ""
		local content = line:sub(#indent + 1)
		local uncommented = content:gsub("^" .. escape_pattern(left) .. "%s?", "", 1)

		if right ~= "" then
			uncommented = uncommented:gsub("%s?" .. escape_pattern(right) .. "$", "", 1)
		end

		if uncommented ~= content then
			lines[i] = indent .. uncommented
		else
			local suffix = right ~= "" and (" " .. right) or ""
			lines[i] = string.format("%s%s %s%s", indent, left, content, suffix)
		end
	end

	vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

keymap.set("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
keymap.set("i", "<C-e>", "<End>", { desc = "move end of line" })
keymap.set("i", "<C-h>", "<Left>", { desc = "move left" })
keymap.set("i", "<C-l>", "<Right>", { desc = "move right" })
keymap.set("i", "<C-j>", "<Down>", { desc = "move down" })
keymap.set("i", "<C-k>", "<Up>", { desc = "move up" })

keymap.set("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

keymap.set("n", ";", ":", { desc = "CMD enter command mode" })
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
keymap.set("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

keymap.set("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
keymap.set("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
keymap.set("n", "<leader>ch", function()
	require("which-key").show({ global = true })
end, { desc = "toggle nvcheatsheet" })

keymap.set({ "n", "x" }, "<leader>fm", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "general format file" })

keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

keymap.set("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })
keymap.set("n", "<tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
keymap.set("n", "<S-tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })
keymap.set("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "buffer close" })
keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "tab new" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "tab close" })
keymap.set("n", "<leader>tl", "<cmd>tabnext<CR>", { desc = "tab next" })
keymap.set("n", "<leader>th", "<cmd>tabprevious<CR>", { desc = "tab previous" })

keymap.set("n", "<leader>/", function()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	toggle_comments(line, line)
end, { desc = "toggle comment" })

keymap.set("v", "<leader>/", function()
	toggle_comments(vim.fn.line("'<"), vim.fn.line("'>"))
end, { desc = "toggle comment" })

keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
keymap.set("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

keymap.set("t", "<C-x>", [[<C-\><C-n>]], { desc = "terminal escape terminal mode" })
keymap.set("n", "<leader>h", function()
	terminal.new({ pos = "sp" })
end, { desc = "terminal new horizontal term" })

keymap.set("n", "<leader>v", function()
	terminal.new({ pos = "vsp" })
end, { desc = "terminal new vertical term" })

keymap.set({ "n", "t" }, "<A-v>", function()
	terminal.toggle({ pos = "vsp", id = "vtoggleTerm" })
end, { desc = "terminal toggleable vertical term" })

keymap.set({ "n", "t" }, "<A-h>", function()
	terminal.toggle({ pos = "sp", id = "htoggleTerm" })
end, { desc = "terminal toggleable horizontal term" })

keymap.set({ "n", "t" }, "<A-i>", function()
	terminal.toggle({ pos = "float", id = "floatTerm" })
end, { desc = "terminal toggle floating term" })

keymap.set("n", "<leader>pt", function()
	terminal.pick()
end, { desc = "terminal pick hidden term" })

keymap.set("n", "<leader>wK", "<cmd>WhichKey<CR>", { desc = "whichkey all keymaps" })
keymap.set("n", "<leader>wk", function()
	vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Show LazyGit UI" })
keymap.set("n", "<leader>uv", "<cmd>ASToggle<CR>", { desc = "Toggle autosave" })
