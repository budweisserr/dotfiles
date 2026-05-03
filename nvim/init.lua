vim.g.mapleader = " "

require("pack").setup()
require("core.options")
require("core.autocmds")
require("core.keymaps")

vim.opt.fileencodings = {
    "utf-8",
    "koi8-u",
    "cp1251",
}
