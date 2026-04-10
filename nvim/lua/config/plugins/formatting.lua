local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		svelte = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		graphql = { "prettier" },
		liquid = { "prettier" },
		lua = { "stylua" },
		python = { "isort", "black" },
		sh = { "beautysh" },
		bash = { "beautysh" },
		c_cpp = { "clang-format" },
		c = { "clang_format" },
		cpp = { "clang_format" },
	},
	formatters = {
		clang_format = {
			prepend_args = { "--style=file:" .. vim.fn.expand("~/.config/nvim/.clang-format") },
		},
	},
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype

		if ft == "c" or ft == "cpp" then
			return nil -- disable auto-format
		end

		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end, { desc = "Format file or range (in visual mode)" })
