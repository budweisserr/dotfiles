local lint = package.loaded.lint

local ignore_install = { "luacheck" }

local function table_contains(items, value)
    for _, item in ipairs(items) do
        if item == value then
            return true
        end
    end
    return false
end

local all_linters = {}
for _, linters in pairs(lint.linters_by_ft) do
    for _, linter in ipairs(linters) do
        if not table_contains(ignore_install, linter) then
            table.insert(all_linters, linter)
        end
    end
end

require("mason-nvim-lint").setup({
    ensure_installed = all_linters,
    automatic_installation = false,
})
