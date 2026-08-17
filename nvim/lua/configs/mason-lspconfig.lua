require("mason-lspconfig").setup({
    ensure_installed = require("configs.lspconfig").servers,
    automatic_installation = true,
})
