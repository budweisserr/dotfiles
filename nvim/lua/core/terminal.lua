local M = {}
local user = require("config.user")

local state = {
  htoggleTerm = { buf = -1, win = -1 },
  vtoggleTerm = { buf = -1, win = -1 },
  floatTerm = { buf = -1, win = -1 },
}

local function reset_term_state(buf)
  for _, term in pairs(state) do
    if term.buf == buf then
      term.buf = -1
      term.win = -1
    end
  end
end

local function close_term_windows(buf)
  for _, term in pairs(state) do
    if term.buf == buf and vim.api.nvim_win_is_valid(term.win) then
      pcall(vim.api.nvim_win_close, term.win, true)
      term.win = -1
    end
  end
end

local function attach_exit_cleanup(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].nvchad_term_cleanup then
    return
  end

  vim.b[buf].nvchad_term_cleanup = true

  vim.api.nvim_create_autocmd({ "TermClose", "BufWipeout", "BufDelete" }, {
    buffer = buf,
    callback = function(args)
      if args.event == "TermClose" then
        close_term_windows(buf)
      end
      reset_term_state(buf)
    end,
  })
end

local function setup_terminal_window(buf)
  vim.bo[buf].buflisted = false
  vim.bo[buf].bufhidden = "wipe"
  vim.wo.number = false
  vim.wo.relativenumber = false
  attach_exit_cleanup(buf)
  vim.cmd.startinsert()
end

local function open_split(pos, existing_buf)
  if pos == "sp" then
    vim.cmd("botright split")
    vim.cmd("resize " .. math.floor(vim.o.lines * user.terminal.horizontal_ratio))
  elseif pos == "vsp" then
    vim.cmd("botright vsplit")
    vim.cmd("vertical resize " .. math.floor(vim.o.columns * user.terminal.vertical_ratio))
  else
    return nil, nil
  end

  local win = vim.api.nvim_get_current_win()
  local buf

  if vim.api.nvim_buf_is_valid(existing_buf) then
    vim.api.nvim_win_set_buf(win, existing_buf)
    buf = existing_buf
  else
    vim.cmd.terminal()
    buf = vim.api.nvim_get_current_buf()
  end

  setup_terminal_window(buf)
  return win, buf
end

local function open_float(existing_buf)
	local width = math.floor(vim.o.columns * user.terminal.float.width)
	local height = math.floor(vim.o.lines * user.terminal.float.height)
	local col
	local row

	if user.terminal.float.center then
		col = math.floor((vim.o.columns - width) / 2)
		row = math.floor((vim.o.lines - height) / 2)
	else
		col = math.floor(vim.o.columns * (user.terminal.float.col or 0.25))
		row = math.floor(vim.o.lines * (user.terminal.float.row or 0.3))
	end

  local buf = vim.api.nvim_buf_is_valid(existing_buf) and existing_buf or vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = user.terminal.float.border,
    style = "minimal",
  })

  if vim.bo[buf].buftype ~= "terminal" then
    vim.cmd.terminal()
    buf = vim.api.nvim_get_current_buf()
  end

  setup_terminal_window(buf)
  return win, buf
end

function M.new(opts)
  local pos = opts and opts.pos or "sp"
  if pos == "float" then
    open_float(-1)
  else
    open_split(pos, -1)
  end
end

function M.toggle(opts)
  local id = opts and opts.id or "floatTerm"
  local pos = opts and opts.pos or "float"
  local term = state[id]

  if not term then
    state[id] = { buf = -1, win = -1 }
    term = state[id]
  end

  if vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = -1
    return
  end

  if pos == "float" then
    term.win, term.buf = open_float(term.buf)
  else
    term.win, term.buf = open_split(pos, term.buf)
  end
end

function M.pick()
  local choices = {}

  for id, term in pairs(state) do
    if vim.api.nvim_buf_is_valid(term.buf) and vim.bo[term.buf].buftype == "terminal" then
      table.insert(choices, { id = id, term = term })
    end
  end

  if #choices == 0 then
    vim.notify("No hidden terminals", vim.log.levels.INFO)
    return
  end

  vim.ui.select(choices, {
    prompt = "Pick terminal",
    format_item = function(item)
      return item.id
    end,
  }, function(choice)
    if not choice then
      return
    end

    local id = choice.id
    if id == "htoggleTerm" then
      M.toggle({ pos = "sp", id = id })
    elseif id == "vtoggleTerm" then
      M.toggle({ pos = "vsp", id = id })
    else
      M.toggle({ pos = "float", id = id })
    end
  end)
end

return M
