local lsp = require("configs.lsp")
local on_attach = lsp.on_attach
local on_init = lsp.on_init
local capabilities = lsp.capabilities

lsp.servers = {
    "html",
    "cssls",
    "lua_ls",
    "clangd",
    "pyright",
    "bashls",
    "gopls",
    "rust_analyzer",
    "jsonls",
    "yamlls",
    "dockerls",
}

local default_servers = {
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "bashls",
    "gopls",
    "rust_analyzer",
    "dockerls",
}

for _, server in ipairs(default_servers) do
    vim.lsp.config(server, {
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    })
end

vim.lsp.config("lua_ls", {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                enable = false,
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})

vim.lsp.config("clangd", {
    cmd = {
        "clangd",
        "--background-index",
        "--background-index-priority=low",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=never",
        "--inlay-hints=true",
        "--pch-storage=memory",
        "--cross-file-rename",
        "--malloc-trim",
        "--function-arg-placeholders=false",
        "--fallback-style=none",
        "--suggest-missing-includes",
        "--all-scopes-completion",
        "--include-cleaner-stdlib",
        "-j=4",
    },
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        if client.server_capabilities.documentHighlightProvider then
            local group = vim.api.nvim_create_augroup("lsp_highlight_" .. bufnr, { clear = true })
            vim.api.nvim_create_autocmd("CursorHold", {
                buffer = bufnr,
                group = group,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                buffer = bufnr,
                group = group,
                callback = vim.lsp.buf.clear_references,
            })
        end

        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end,
    on_init = on_init,
    capabilities = capabilities,
})

vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pdm.lock",
        "poetry.lock",
        ".git",
    },
    before_init = function(_, config)
        local root_dir = config.root_dir or vim.fn.getcwd()

        local function find_venv_python()
            for _, name in ipairs({ ".venv", "venv", ".env" }) do
                local candidate = root_dir .. "/" .. name .. "/bin/python"
                if vim.fn.executable(candidate) == 1 then
                    return candidate, root_dir, name
                end
            end
            if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
                return vim.env.VIRTUAL_ENV .. "/bin/python", nil, nil
            end
            return nil
        end

        config.settings = config.settings or {}
        config.settings.python = config.settings.python or {}

        local python_path, venv_path, venv_name = find_venv_python()
        if python_path then
            config.settings.python.pythonPath = python_path
            if venv_path then
                config.settings.python.venvPath = venv_path
                config.settings.python.venv = venv_name
            end
        end
    end,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "standard",
                strictMode = false,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                autoImportCompletions = true,
                diagnosticMode = "openFilesOnly",
                reportMissingImports = "warning",
                reportMissingTypeStubs = "none",
                reportUnusedVariable = "warning",
                reportUnusedImport = "warning",
                reportDuplicateImport = "warning",
                reportPrivateUsage = "warning",
                reportUndefinedVariable = "error",
                reportGeneralTypeIssues = "warning",
                reportOptionalSubscript = "warning",
                reportOptionalMemberAccess = "warning",
                reportOptionalCall = "warning",
                reportIndexIssues = "warning",
                inlayHints = {
                    variableTypes = true,
                    returnTypes = true,
                    functionReturnTypes = true,
                    callArgumentNames = true,
                    pytestParameters = true,
                },
                indexing = false,
                stubPath = vim.fn.stdpath("data") .. "/pyright-stubs",
                completeFunctionParens = true,
            },
        },
    },
})

vim.lsp.enable(lsp.servers)

return lsp
