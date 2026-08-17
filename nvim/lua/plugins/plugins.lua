return {
    { "nvim-lua/plenary.nvim", event = { "BufReadPost" } },
    { "rafamadriz/friendly-snippets", event = { "InsertEnter" } },
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "FileType" },
        config = function()
            require("configs.treesitter").setup()
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = { "InsertEnter" },
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = false,
        config = function()
            require("nvim-web-devicons").setup({})
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        config = function()
            require("configs.theme")
        end,
    },
    {
        "goolord/alpha-nvim",
        lazy = false,
        dependencies = { "nvim-web-devicons" },
        cmd = { "Alpha" },
        init = function()
            if vim.fn.argc() == 0 then
                vim.defer_fn(function()
                    require("pack").load({ "alpha-nvim" })
                end, 5)
            end
        end,
        config = function()
            require("configs.alpha")
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
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost" },
        config = function()
            require("gitsigns").setup(require("configs.gitsigns"))
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
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("configs.cord")
        end,
    },

    {
        "mason-org/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate" },
        config = function()
            require("mason").setup(require("configs.mason"))
            require("pack").load({ "mason-lspconfig.nvim", "mason-nvim-lint", "mason-conform.nvim" })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },
    {
        "rshkarin/mason-nvim-lint",
        dependencies = { "mason.nvim", "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },
    {
        "zapling/mason-conform.nvim",
        dependencies = { "mason.nvim", "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo", "Format" },
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
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "mason-lspconfig.nvim" },
        config = function()
            local lsp_defaults = require("configs.lsp")
            lsp_defaults.defaults()
            require("configs.mason-lspconfig")
            require("configs.lspconfig")
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
        "Pocco81/auto-save.nvim",
        event = { "InsertLeave", "TextChanged" },
        cmd = { "ASToggle" },
        config = function()
            require("auto-save").setup({ debounce_delay = 5000 })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        lazy = false,
        event = { "InsertEnter" },
        dependencies = {
            "cmp-nvim-lsp",
            "cmp-buffer",
            "cmp-path",
            "LuaSnip",
            "cmp_luasnip",
        },
        config = function()
            require("cmp").setup(require("configs.cmp"))
        end,
    },
    {
        "L3MON4D3/LuaSnip",
        event = { "InsertEnter" },
        dependencies = { "friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
    { "saadparwaiz1/cmp_luasnip", event = { "InsertEnter" } },
    { "hrsh7th/cmp-nvim-lsp", event = { "InsertEnter" } },
    { "hrsh7th/cmp-buffer", event = { "InsertEnter" } },
    { "hrsh7th/cmp-path", event = { "InsertEnter" } },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "plenary.nvim", "nvim-web-devicons" },
        cmd = { "Telescope" },
        config = function()
            require("telescope").setup(require("configs.telescope"))
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("configs.lualine")
        end,
    },
    {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function()
            vim.g.barbar_auto_setup = false
        end,
        config = function()
            require("configs.barbar")
        end,
        -- opts = {
        --     -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
        --     -- animation = true,
        --     -- insert_at_start = true,
        --     -- …etc.
        -- },
    },
    {
        "jake-stewart/multicursor.nvim",
        branch = "1.0",
        config = function()
            local mc = require("multicursor-nvim")

            mc.setup()

            -- Select next occurrence
            vim.keymap.set({ "n", "v" }, "<C-g>", function()
                mc.matchAddCursor(1)
            end)

            -- Add cursor above/below
            vim.keymap.set({ "n", "v" }, "<A-k>", function()
                mc.lineAddCursor(-1)
            end)

            vim.keymap.set({ "n", "v" }, "<A-j>", function()
                mc.lineAddCursor(1)
            end)
        end,
    },
}
