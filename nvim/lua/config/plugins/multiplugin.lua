-- Colorizer
require("colorizer").setup({
  user_default_options = { tailwind = true }
})

-- Bufferline
require("bufferline").setup({
  options = {
    diagnostics = "nvim_lsp",
    mode = "buffers",
    separator_style = "slant",
    always_show_bufferline = true,
    show_tab_indicators = true,
    show_duplicate_prefix = true,
    show_buffer_close_icons = false,
    offsets = {
      {
        filetype = "NvimTree",
        text = "Explorer",
        text_align = "center",
        separator = true,
      },
    },
  },
})

-- Silicon
require("silicon").setup({
  font = "JetBrains Mono Nerd Font=34;Noto Color Emoji=34",
  theme = "Dracula",
  background = "#94e2d5",
  window_title = function()
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  end
})

-- Dressing
vim.api.nvim_create_autocmd("User",{
  pattern = "VeryLazy",
  callback = function() end,
})
