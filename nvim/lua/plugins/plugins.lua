return {
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons", config = function() require("nvim-web-devicons").setup({}) end },
    { "rafamadriz/friendly-snippets" },

    {
        "marko-cerovac/material.nvim",
        lazy = false,
        config = function()
            require("configs.theme")
        end,
    },

    {
        "goolord/alpha-nvim",
        lazy = false,
        dependencies = { "nvim-web-devicons" },
        config = function()
            require("configs.alpha")
        end,
        init = function()
            if vim.fn.argc() == 0 then
                vim.defer_fn(function()
                    require("pack").load({ "alpha-nvim" })
                end, 5)
            end
        end,
    },

    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("configs.auto-session")
        end,
    },

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-web-devicons" },
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            require("nvim-tree").setup(require("configs.nvimtree"))
        end,
    },

    {
        "folke/which-key.nvim",
        event = { "CursorHold", "CursorHoldI" },
        config = function()
            require("which-key").setup({})
        end,
    },

    {
        "kdheepak/lazygit.nvim",
        dependencies = { "plenary.nvim" },
        cmd = { "LazyGit" },
    },

    {
        "vyfor/cord.nvim",
        cmd = { "Cord" },
        config = function()
            require("configs.cord")
        end,
    },

    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        config = function()
            require("mason").setup(require("configs.mason"))
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        dependencies = { "mason.nvim" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        cmd = { "MasonInstall" },
        dependencies = { "mason.nvim", "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },

    {
        "zapling/mason-conform.nvim",
        cmd = { "MasonInstall" },
        dependencies = { "mason.nvim", "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost" },
        config = function()
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
            require("ibl").setup({
                indent = { char = "│" },
                scope = { char = "│" },
            })
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost" },
        config = function()
            require("gitsigns").setup(require("configs.gitsigns"))
        end,
    },

    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost" },
        config = function()
            require("configs.comment")
        end,
    },

    {
        "windwp/nvim-autopairs",
        event = { "InsertEnter" },
        config = function()
            require("nvim-autopairs").setup({
                fast_wrap = {},
                disable_filetype = { "TelescopePrompt", "vim" },
            })
        end,
    },

    {
        "Pocco81/auto-save.nvim",
        event = { "InsertLeave", "TextChanged" },
        cmd = { "ASToggle" },
        config = function()
            require("auto-save").setup({ debounce_delay = 5000 })
        end,
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("configs.conform")
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        config = function()
            require("configs.lint")
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost" },
        dependencies = { "mason-lspconfig.nvim" },
        config = function()
            local lsp_defaults = require("configs.lsp")
            lsp_defaults.defaults()
            require("configs.lspconfig")
        end,
    },

    {
        "hrsh7th/nvim-cmp",
        event = { "InsertEnter" },
        dependencies = {
            "LuaSnip",
            "cmp_luasnip",
            "cmp-nvim-lsp",
            "cmp-nvim-lua",
            "cmp-buffer",
            "cmp-async-path",
            "friendly-snippets",
            "nvim-autopairs",
        },
        config = function()
            require("cmp").setup(require("configs.cmp"))
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    {
        "L3MON4D3/LuaSnip",
        event = { "InsertEnter" },
        config = function()
            require("luasnip").config.set_config({ history = true, updateevents = "TextChanged,TextChangedI" })
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    { "saadparwaiz1/cmp_luasnip", event = { "InsertEnter" } },
    { "hrsh7th/cmp-nvim-lsp",     event = { "InsertEnter" } },
    { "hrsh7th/cmp-nvim-lua",     event = { "InsertEnter" } },
    { "hrsh7th/cmp-buffer",       event = { "InsertEnter" } },
    {
        "cmp-async-path",
        [1] = "https://codeberg.org/FelipeLema/cmp-async-path.git",
        name = "cmp-async-path",
        event = { "InsertEnter" },
    },

    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "plenary.nvim" },
        cmd = { "Telescope" },
        config = function()
            require("telescope").setup(require("configs.telescope"))
            pcall(require("telescope").load_extension, "lazygit")
        end,
    },
}
