local M = {}

M.parsers = {
    "bash",
    "c",
    "cpp",
    "css",
    "dockerfile",
    "go",
    "html",
    "json",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "rust",
    "toml",
    "vim",
    "vimdoc",
    "yaml",
}

function M.setup()
    local treesitter = require("nvim-treesitter")

    treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
    })

    local installed = treesitter.get_installed("parsers")
    local missing = vim.tbl_filter(function(parser)
        return not vim.list_contains(installed, parser)
    end, M.parsers)

    if #missing > 0 then
        vim.schedule(function()
            treesitter.install(missing)
        end)
    end
end

return M
