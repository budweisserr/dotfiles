local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
    pattern = "*",
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
