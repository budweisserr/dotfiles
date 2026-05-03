local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        c_cpp = { "clang-format" },
        c = { "clang_format" },
        cpp = { "clang_format" },
    },
    formatters = {
        clang_format = {
            prepend_args = { "--style=file:" .. vim.fn.stdpath("config") .. "/.clang-format" },
        },
    },
    format_on_save = false,
}

local defaults = {
    formatters_by_ft = { lua = { "stylua" } },
}

options = vim.tbl_deep_extend("force", defaults, options)

require("conform").setup(options)

return options
