require("mason-lspconfig").setup({
    ensure_installed = require("configs.lsp").servers,
    automatic_installation = true,
    automatic_enable = false,
})
