local options = {
    format_on_save = false,
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        json = { "prettier" },
        yaml = { "yamlfmt" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        c = { "clang_format" },
        cpp = { "clang_format" },
        objc = { "clang_format" },
        objcpp = { "clang_format" },
        cuda = { "clang_format" },
    },
    formatters = {
        clang_format = {
            prepend_args = { "--style=file:" .. vim.fn.stdpath("config") .. "/.clang-format" },
        },
    },
}

require("conform").setup(options)

vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
        range = { start = { args.line1, 0 }, ["end"] = { args.line2, 0 } }
    end
    require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true })

return options
