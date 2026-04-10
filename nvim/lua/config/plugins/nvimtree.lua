local user = require("config.user")

require("nvim-tree").setup({
	filters = { dotfiles = not user.nvimtree.show_dotfiles },
	disable_netrw = true,
	hijack_netrw = true,
	hijack_cursor = true,
	sync_root_with_cwd = true,
	respect_buf_cwd = true,
	update_focused_file = {
		enable = true,
		update_root = true,
	},
	view = {
		side = user.nvimtree.side or "left",
		width = user.nvimtree.width,
		preserve_window_proportions = true,
		number = false,
		relativenumber = false,
	},
	actions = {
		open_file = {
			resize_window = true,
		},
	},
	renderer = {
		root_folder_label = false,
		highlight_git = true,
		indent_markers = { enable = true },
		icons = {
			show = {
				git = true,
				folder = true,
				file = true,
				folder_arrow = true,
			},
			git_placement = "before",
			glyphs = {
				default = "󰈚",
				folder = {
					default = "",
					empty = "",
					empty_open = "",
					open = "",
					symlink = "",
				},
				git = { unmerged = "" },
			},
		},
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
	},
	git = {
		enable = true,
		ignore = false,
	},
})
