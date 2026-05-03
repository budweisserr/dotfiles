local lspconfig = require("configs.lsp")

local ignore_install = {}

local function table_contains(items, value)
    for _, item in ipairs(items) do
        if item == value then
            return true
        end
    end
    return false
end

local all_servers = {}
for _, server in ipairs(lspconfig.servers) do
    if not table_contains(ignore_install, server) then
        table.insert(all_servers, server)
    end
end

require("mason-lspconfig").setup({
    ensure_installed = all_servers,
    automatic_installation = false,
})
