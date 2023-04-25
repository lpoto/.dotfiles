--=============================================================================
-------------------------------------------------------------------------------
--                                                                       WINBAR
--[[===========================================================================

Set up the winbar and statusline.

-----------------------------------------------------------------------------]]
local set_winbar_and_statusline_callback
local set_inactive_winbar_callback

--- Set the type of winbar and statusline.
--- This is called only once, when entering a new
--- buffer or file for the first time.
local function init_winbar()
  -- NOTE: make statusline invisible
  vim.opt.laststatus = 0

  vim.api.nvim_create_autocmd({
    "WinEnter",
    "QuickFixCmdPost",
    "BufEnter",
    "ModeChanged",
    "TermEnter",
    "UIEnter",
    "WinResized",
    "BufModifiedSet",
    "BufWrite",
  }, {
    -- this handles the active winbar, and the statusline
    -- that appears between 2 windows in normal split
    callback = set_winbar_and_statusline_callback,
  })

  vim.api.nvim_create_autocmd({ "WinLeave" }, {
    -- This handles the inactive winbar when leaving the window
    callback = set_inactive_winbar_callback,
  })
end

--NOTE: initialize winbar only when entering a new
-- file or before reading a new buffer for the first time
vim.api.nvim_create_autocmd({
  "BufNewFile",
  "BufReadPre",
}, {
  once = true,
  callback = init_winbar,
})

local set_winbar
local set_inactive_winbar
local set_statusline
local mode_changed

function set_winbar_and_statusline_callback(opts)
  if opts.event == "ModeChanged" and not mode_changed(opts.match) then
    return
  end
  local buf = opts.buf
  -- NOTE: the active winbar should be set only for the current window
  -- The inactive winbar is handled through the set_inactive_winbar_callback
  -- when the WinLeave event is triggered, so we ignore it here.
  set_winbar(vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win())

  if opts.event == "WinResized" then
    -- NOTE: when winResized event is triggered, we need to set the statusline
    -- for all the opened windows, so the statusline's length always matches
    -- the window's width.
    -- NOTE: this is only relevant when there are windows in normal splits,
    -- as when laststatus is set to 0, it only appears in such scenarios.
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      set_statusline(buf, winid)
    end
  end
end

function set_inactive_winbar_callback()
  -- NOTE: this is called when the WinLeave event is triggered,
  -- so it will run before actually leaving the window,
  -- therefore we can use the current window and buffer numbers.
  -- Using the current buf and win numbers is better than using
  -- the ones passed through the event, as issues may occur when
  -- the same buffer is opened in multiple windows.
  local buf = vim.api.nvim_get_current_buf()
  local winid = vim.api.nvim_get_current_win()
  set_inactive_winbar(buf, winid)
end

local _set_winbar
local check_buftype
local editing_winbar = {}

--- @param buf number
--- @param winid number
function set_winbar(buf, winid)
  -- NOTE: edit the winbar after a delay, so it doesn't get
  -- updated multiple times in a short duration of time, as
  -- a single action may trigger multiple events and it would
  -- be redundant to do multiple winbar updates.
  --
  -- NOTE: we use the buffer and window numbers to identify
  -- the winbar that is being edited, so we can still edit
  -- the winbars of different windows at the same time.
  local key = vim.inspect(buf) .. vim.inspect(winid)
  if editing_winbar[key] then
    return
  end
  editing_winbar[key] = true
  vim.defer_fn(function()
    local ok, err = pcall(function()
      if
        vim.api.nvim_get_current_win() ~= winid
        or not vim.api.nvim_win_is_valid(winid)
        or not vim.api.nvim_buf_is_valid(buf)
      then
        return
      end
      _set_winbar(buf, winid)
    end)
    editing_winbar[key] = nil
    if not ok and type(err) == "string" then
      vim.notify(err, vim.log.levels.ERROR, { title = "Winbar" })
    end
  end, 10)
end

local _set_inactive_winbar

--- Set the appearance of winbar before leaving
--- the window. This is called every time when the
--- WinLeave event is triggered.
---
--- This sets the winbar to only display the
--- full filename of the file open in the window.
function set_inactive_winbar(buf, win)
  vim.schedule(function()
    local ok, err = pcall(function()
      if win == vim.api.nvim_get_current_win() then
        return
      end
      if
        not vim.api.nvim_win_is_valid(win)
        or not vim.api.nvim_buf_is_valid(buf)
      then
        return
      end

      if not check_buftype(buf) then
        return
      end
      _set_inactive_winbar(buf, win)
    end)
    if not ok and type(err) == "string" then
      vim.notify(err, vim.log.levels.ERROR, { title = "Inactive Winbar" })
    end
  end)
end

--- Even when laststatus is set to 0, the statusline still
--- appears between 2 windows in a normal split, so we just
--- set the statusline to appear the same as a window separator.
function set_statusline(buf, winid)
  vim.schedule(function()
    local ok, err = pcall(function()
      if
        not vim.api.nvim_win_is_valid(winid)
        or not vim.api.nvim_buf_is_valid(buf)
      then
        return
      end
      local width = vim.fn.winwidth(winid)
      vim.api.nvim_win_set_option(winid, "statusline", string.rep("_", width))
    end)
    if not ok and type(err) == "string" then
      vim.notify(err, vim.log.levels.ERROR, { title = "Statusline" })
    end
  end)
end

local get_name

function _set_inactive_winbar(buf, winid)
  local width = vim.fn.winwidth(winid)
  local name = get_name(buf, false, width)

  if width < 5 then
    vim.api.nvim_win_set_option(winid, "winbar", "-")
    return
  end
  if vim.fn.strchars(name) > width then
    name = name:sub(name:len() - width + 1, name:len())
  end
  vim.api.nvim_win_set_option(winid, "winbar", name)
end

local waiting = {}

local function get_right_winbar(width, buf, winid)
  local s = ""
  local git_head = vim.g.gitsigns_head
  local has_git_status, git_status =
    pcall(vim.api.nvim_buf_get_var, buf, "gitsigns_status")

  if git_head == nil or git_head == "" or not has_git_status then
    if not waiting[buf] then
      waiting[buf] = true
      vim.defer_fn(function()
        if not waiting[buf] then
          return
        end
        if
          vim.api.nvim_get_current_buf() == buf
          and vim.api.nvim_get_current_win() == winid
        then
          set_winbar(buf, winid)
        end
      end, 1000)
    end
  else
    waiting[buf] = false
  end

  if
    git_head ~= nil
    and git_head ~= ""
    and vim.fn.strchars(git_head) < width - 2
  then
    s = s .. "•  " .. git_head
    if
      has_git_status
      and git_status ~= ""
      and vim.fn.strchars(s) + 4 < width
    then
      s = s .. " [~]"
    end
    width = width - vim.fn.strchars(s)
  end
  if width <= 1 then
    return s
  end
  if vim.fn.strchars(s) > 0 then
    return string.rep("─", width - 1) .. s .. " "
  else
    return string.rep("─", width)
  end
end

local modes = {
  ["n"] = "NORMAL",
  ["nt"] = "NORMAL",
  ["no"] = "NORMAL",
  ["v"] = "VISUAL",
  ["V"] = "VISUAL LINE",
  [""] = "VISUAL BLOCK",
  ["s"] = "SELECT",
  ["S"] = "SELECT LINE",
  ["i"] = "INSERT",
  ["ic"] = "INSERT",
  ["R"] = "REPLACE",
  ["Rv"] = "VISUAL REPLACE",
  ["c"] = "COMMAND",
  ["cv"] = "VIM EX",
  ["ce"] = "EX",
  ["r"] = "PROMPT",
  ["rm"] = "MOAR",
  ["r?"] = "CONFIRM",
  ["!"] = "SHELL",
  ["t"] = "TERMINAL",
}

local function mode()
  local current_mode = vim.api.nvim_get_mode().mode
  current_mode = modes[current_mode]
  if not current_mode then
    return ""
  end
  return string.format(" %s ", current_mode):upper()
end

local function get_left_winbar(width)
  local m = mode()
  if m:len() > 0 then
    m = " " .. (mode() or "") .. " •"
  end
  if vim.fn.strchars(m) > width then
    return string.rep("─", width)
  end
  return m .. string.rep("─", width - vim.fn.strchars(m))
end

---@param buf number
---@param winid number
function _set_winbar(buf, winid)
  if not check_buftype(buf) then
    pcall(vim.api.nvim_win_set_option, winid, "winbar", "")
    return
  end

  local width = vim.fn.winwidth(winid)
  local name = get_name(buf, true, width)
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

  if vim.fn.strchars(name) <= width - 4 then
    name = "• " .. name .. " •"
  end
  if width < vim.fn.strchars(name) then
    vim.api.nvim_win_set_option(winid, "winbar", filetype)
    return
  end
  local n = width - vim.fn.strchars(name)
  if n <= 2 then
    vim.api.nvim_win_set_option(winid, "winbar", name)
    return
  end
  local left_n = math.floor(n / 2)
  local right_n = n - left_n
  local bar = get_left_winbar(left_n)
    .. name
    .. get_right_winbar(right_n, buf, winid)
  vim.api.nvim_win_set_option(winid, "winbar", bar)
end

function mode_changed(match)
  if
    match == "i:ic"
    or match == "ic:i"
    or match == "n:no"
    or match == "no:n"
    or match == "nt:n"
    or match == "n:nt"
  then
    return false
  end
  return true
end

---@param buf number
---@param tail boolean
---@param width number
---@return string
function get_name(buf, tail, width)
  local name = vim.api.nvim_buf_get_name(buf)
  if tail then
    name = vim.fn.fnamemodify(name, ":t")
  end
  local modified = vim.api.nvim_buf_get_option(buf, "modified")
  local readonly = vim.api.nvim_buf_get_option(buf, "readonly")
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if buftype == "quickfix" then
    name = "Quickfix"
  elseif buftype == "help" then
    name = "Help"
  elseif name == "" then
    name = "[No Name]"
  end
  if buftype == "" then
    if modified == true and vim.fn.strchars(name) + 4 <= width then
      name = name .. " [+]"
    elseif readonly == true and vim.fn.strchars(name) + 11 <= width then
      name = name .. " [Readonly]"
    end
  end
  return name
end

--- Check whether the provided buffer number belongs
--- to a buffer with buftype equal to terminal, quickfix,
--- help or "".
function check_buftype(buf)
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if
    buftype == "terminal"
    or buftype == ""
    or buftype == "quickfix"
    or buftype == "help"
  then
    return true
  end
  return false
end
