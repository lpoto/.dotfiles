--=============================================================================
--                                                  CENTER A SINGLE OPEN BUFFER
--[[===========================================================================

When there is a single buffer, center it horizontally by adding a dummy
window on the left, to avoid having all text on the left side of the screen.

-----------------------------------------------------------------------------]]
if vim.g.did_center or vim.api.nvim_set_var("did_center", true) then return end

local DUMMY_FT = "left_padding_dummy"
local MAX_SCAN_LINES = 1000
local MIN_CONTENT_WIDTH = 120

local function is_real_file_win(win, allow_dummy_ft)
  if not vim.api.nvim_win_is_valid(win) then
    return false
  end
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  if allow_dummy_ft then
    return true
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].filetype == DUMMY_FT then
    return false
  end
  return true
end

local function real_file_windows(allow_dummy_ft)
  local wins = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_real_file_win(win, allow_dummy_ft) then
      table.insert(wins, win)
    end
  end
  return wins
end

local function content_width(buf)
  local lines = math.min(MAX_SCAN_LINES, vim.api.nvim_buf_line_count(buf))
  local max_len = MIN_CONTENT_WIDTH

  for i = 0, lines - 1 do
    local line = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1]
    if line then
      local len = vim.fn.strdisplaywidth(line)
      if len > max_len then
        max_len = len
      end
    end
  end
  return max_len
end

local function has_dummy()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == DUMMY_FT then
      return true
    end
  end
  return false
end

local function remove_dummy()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == DUMMY_FT then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local last_width = -1
local last_pad = -1
local function ensure_left_dummy(main_win)
  local dummy_exists = has_dummy()

  local buf = vim.api.nvim_win_get_buf(main_win)
  local editor_width = vim.o.columns
  local width = content_width(buf)

  local pad = math.floor((editor_width - width) / 2)
  if pad < 2 then
    if dummy_exists then
      remove_dummy()
    end
    return
  end
  if last_width > width and last_width - width <= 30 then
    width = last_width
  elseif last_width > 0 and last_pad > -1 and width - last_pad <= last_width then
    width = last_width
  end
  if last_width == width and dummy_exists then
    return
  end
  local pad_percentage = pad / editor_width
  if pad_percentage < 0.2 then
    pad = math.floor(editor_width * 0.2)
  end

  last_width = width
  last_pad = pad

  if dummy_exists then
    remove_dummy()
  end

  vim.api.nvim_set_current_win(main_win)
  vim.cmd "silent! noautocmd leftabove vsplit"

  local dummy_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(dummy_win, pad)

  local dummy_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(dummy_win, dummy_buf)

  vim.bo[dummy_buf].buftype = "nofile"
  vim.bo[dummy_buf].buflisted = false
  vim.bo[dummy_buf].modifiable = false
  vim.bo[dummy_buf].filetype = DUMMY_FT

  vim.wo[dummy_win].number = false
  vim.wo[dummy_win].relativenumber = false
  vim.wo[dummy_win].signcolumn = "no"
  vim.wo[dummy_win].foldcolumn = "0"
  vim.wo[dummy_win].winfixwidth = true
  vim.wo[dummy_win].cursorline = false
  vim.wo[dummy_win].fillchars =
  "vert: ,vertleft: ,vertright: ,eob: ,horiz: ,horizup: ,horizdown: "
  vim.wo[dummy_win].winfixheight = true
  vim.wo[dummy_win].winfixwidth = true

  vim.api.nvim_set_current_win(main_win)

  -- Create autocmd to move out of window if user enters it
  vim.api.nvim_create_autocmd("WinEnter", {
    buffer = dummy_buf,
    callback = function()
      vim.schedule(function()
        local wins = real_file_windows()
        if #wins > 0 then
          local cur_buf = vim.api.nvim_get_current_buf()
          if cur_buf == dummy_buf then
            vim.api.nvim_set_current_win(main_win)
          end
        end
      end)
    end,
  })
end

local original_fillchars = nil
local function hide_window_separators()
  pcall(function()
    if original_fillchars == nil then
      original_fillchars = vim.o.fillchars or ""
    end
    vim.cmd "set fillchars+=vert:\\ ,vertleft:\\ ,vertright:\\ "
  end)
end

local function restore_window_separators()
  pcall(function()
    vim.o.fillchars = original_fillchars or ""
    original_fillchars = nil
  end)
end

local last_real_count = -1
local last_buf = -1
local processing = false
local function do_center(opts, do_schedule)
  if processing then
    return
  end
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  if not is_real_file_win(vim.fn.bufwinid(buf)) then
    return
  end
  local schedule = do_schedule == true
  local run_centering = function()
    if processing then
      return
    end
    processing = true
    pcall(function()
      local win = vim.api.nvim_get_current_win()
      if not is_real_file_win(win) then
        return
      end
      local wins = real_file_windows()
      local count = #wins
      if count == last_real_count then
        return
      elseif count == 1 then
        win = wins[1]
        buf = vim.api.nvim_win_get_buf(win)
        if buf == last_buf and count == last_real_count then
          return
        end
        last_buf = buf
        hide_window_separators()
        ensure_left_dummy(win)
      elseif count > 1 then
        restore_window_separators()
        remove_dummy()
      end
      last_real_count = count
    end)
    processing = false
  end
  if schedule then
    vim.schedule(run_centering)
  else
    run_centering()
  end
end

vim.api.nvim_create_autocmd({
  "VimEnter",
  "BufWinEnter",
  "WinEnter",
  "WinClosed",
  "VimResized",
}, {
  callback = function(opts) do_center(opts, true) end,
})

vim.api.nvim_create_autocmd({ "WinClosed", }, {
  callback = function(opts)
    vim.schedule(function()
      local wins = real_file_windows(true)
      local count = #wins
      if count ~= 1 then
        return
      end
      local win = wins[1]
      local buf = vim.api.nvim_win_get_buf(win)
      local filetype = vim.bo[buf].filetype
      local buftype = vim.bo[buf].buftype
      if DUMMY_FT ~= filetype or "nofile" ~= buftype then
        return
      end
      local ok, e = pcall(function()
        vim.cmd "silent q"
      end)
      if not ok then
        pcall(function()
          local name = vim.api.nvim_buf_get_name(opts.buf)
          if name ~= "" and name ~= "[No Name]" then
            vim.cmd("silent! edit " .. name)
            remove_dummy()
            ensure_left_dummy(win)
          end
        end)
        vim.notify(e, vim.log.levels.ERROR)
      end
    end)
  end,
})

do_center({}, true)
