local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
    pattern = "*",
    callback = function(ev)
        local ok = pcall(vim.treesitter.start, ev.buf)
        if not ok then
            return
        end

        if vim.bo[ev.buf].buftype == "" then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

autocmd("FileType", {
    pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
    callback = function(ev)
        local b = vim.bo[ev.buf]
        b.shiftwidth = 2
        b.tabstop = 2
        b.softtabstop = 2
        b.expandtab = true
        b.cinoptions = "l1,g0,N-s,E-s,(0,W2,m1,j1,J1,)20,*20,#1s"
    end,
})

autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
