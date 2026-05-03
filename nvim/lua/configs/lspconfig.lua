local lsp = require("configs.lsp")
local on_attach = lsp.on_attach
local on_init = lsp.on_init
local capabilities = lsp.capabilities
local lspconfig = lsp

lspconfig.servers = {
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
    "pyright",
    "clangd"
}

for _, lsp in ipairs(default_servers) do
    vim.lsp.config(lsp, {
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
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gI", vim.lsp.buf.implementation, "Go to implementation")
        map("gr", vim.lsp.buf.references, "Go to references")
        map("K", vim.lsp.buf.hover, "Hover docs")

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
    before_init = function(_, config)
        local function systemlist_ok(cmd, cwd)
            local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
            if result.code ~= 0 or not result.stdout or result.stdout == "" then
                return nil
            end

            return vim.split(vim.trim(result.stdout), "\n", { plain = true })
        end

        local root_dir = config.root_dir or vim.fn.getcwd()

        config.settings = config.settings or {}
        config.settings.python = config.settings.python or {}

        if vim.fn.executable("pdm") == 1 then
            local python_lines = systemlist_ok({
                "pdm",
                "run",
                "python",
                "-c",
                "import sys; print(sys.executable)",
            }, root_dir)

            local python_path = python_lines and python_lines[1] or nil
            if python_path and python_path ~= "" then
                config.settings.python.pythonPath = python_path
            end

            local venv_lines = systemlist_ok({ "pdm", "venv", "list" }, root_dir)
            if venv_lines and #venv_lines > 0 then
                config.settings.python.venvPath = root_dir
                config.settings.python.venv = ".venv"
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
                indexing = true,
                stubPath = vim.fn.stdpath("data") .. "/pyright-stubs",
                completeFunctionParens = true,
            },
        },
    },
})

vim.o.updatetime = 200
