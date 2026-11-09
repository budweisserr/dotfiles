local cmp = require("cmp")

cmp.register_source("buffer", require("cmp_buffer"))
cmp.register_source("path", require("cmp_path").new())
cmp.register_source("luasnip", require("cmp_luasnip").new())
require("cmp_nvim_lsp").setup()
require("cmp_nvim_lsp")._on_insert_enter()

-- cmp-nvim-lsp only registers a source on InsertEnter. Register it as soon as
-- a server attaches so a slow one (e.g. rust-analyzer) is usable immediately.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("cmp_nvim_lsp_attach", { clear = true }),
    callback = function()
        require("cmp_nvim_lsp")._on_insert_enter()
    end,
})

return {
    completion = { completeopt = "menu,menuone,noselect" },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "path" },
        { name = "buffer" },
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
            item.menu = ({
                nvim_lsp = "[LSP]",
                path = "[Path]",
                buffer = "[Buf]",
            })[entry.source.name] or ("[" .. entry.source.name .. "]")
            return item
        end,
    },
    experimental = {
        ghost_text = true,
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
}
