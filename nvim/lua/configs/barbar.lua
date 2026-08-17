require("barbar").setup({
    exclude_ft = { "javascript" },
    exclude_name = { "package.json" },
    icons = {
        diagnostics = {
            [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "ﬀ" },
            [vim.diagnostic.severity.HINT] = { enabled = true },
        },
    },
})
