local map = vim.keymap.set

local function open_terminal(split_cmd)
    vim.cmd(split_cmd)
    if split_cmd == "vsplit" then
        vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.2))
    else
        vim.cmd("resize " .. math.floor(vim.o.lines * 0.3))
    end
    vim.cmd.terminal()
    vim.cmd.startinsert()
end

map("i", "<C-b>", "<ESC>^i", { desc = "Move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "Move end of line" })
map("i", "<C-h>", "<Left>", { desc = "Move left" })
map("i", "<C-l>", "<Right>", { desc = "Move right" })
map("i", "<C-j>", "<Down>", { desc = "Move down" })
map("i", "<C-k>", "<Up>", { desc = "Move up" })

map("n", "<C-h>", "<C-w>h", { desc = "Switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "Copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle relative number" })

map({ "n", "x" }, "<leader>fm", function()
    require("configs.conform").format({ lsp_fallback = true })
end, { desc = "Format file" })

map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "Diagnostic loclist" })

map("n", "<leader>b", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close buffer" })

map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree toggle" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "NvimTree focus" })

map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "Find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Current buffer search" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "Find all files" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>cd", "<cmd>Cord toggle<CR>", { desc = "Toggle cord presence" })
map("n", "<leader>ci", "<cmd>Cord idle toggle<CR>", { desc = "Toggle cord idle" })

map("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
map("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" })

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Show LazyGit UI" })
map("n", "<leader>h", function()
    open_terminal("split")
end, { desc = "New horizontal terminal" })
map("n", "<leader>v", function()
    open_terminal("vsplit")
end, { desc = "New vertical terminal" })
map("n", "<leader>uv", "<cmd>ASToggle<CR>", { desc = "Toggle autosave" })
