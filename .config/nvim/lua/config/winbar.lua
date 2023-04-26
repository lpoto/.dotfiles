--=============================================================================
-------------------------------------------------------------------------------
--                                                                       WINBAR
--[[===========================================================================

Set up the winbar and statusline.

-----------------------------------------------------------------------------]]
local ignore_filetype_patterns = {
  "Telescope.*",
  "telescope.*",
  "alpha",
}

local set_winbar_and_statusline_callback
local set_inactive_winbar_callback
local autocommands = {}
local timer = nil

--- Set the type of winbar and statusline.
--- This is called only once, when entering a new
--- buffer or file for the first time.
local function init_winbar()
  -- NOTE: make statusline invisible
  vim.opt.laststatus = 0

  table.insert(
    autocommands,
    vim.api.nvim_create_autocmd({
      "WinEnter",
      "BufEnter",
      "ModeChanged",
      "TermEnter",
      "UIEnter",
      "WinResized",
      "BufWrite",
    }, {
      -- this handles the active winbar, and the statusline
      -- that appears between 2 windows in normal split
      callback = set_winbar_and_statusline_callback,
    })
  )

  table.insert(
    autocommands,
    vim.api.nvim_create_autocmd({ "WinLeave" }, {
      -- This handles the inactive winbar when leaving the window
      callback = set_inactive_winbar_callback,
    })
  )

  timer = vim.loop.new_timer()
  timer:start(2000, 2000, function()
    vim.schedule(function()
      set_winbar_and_statusline_callback {
        event = "Timer",
        buf = vim.api.nvim_get_current_buf(),
      }
    end)
  end)
end

local handle_error

--NOTE: initialize winbar only when entering a new
-- file or before reading a new buffer for the first time
vim.api.nvim_create_autocmd({
  "BufNewFile",
  "BufReadPre",
}, {
  once = true,
  callback = function()
    local ok, err = pcall(init_winbar)
    if not ok then
      handle_error(err)
    end
  end,
})

local set_winbar
local set_inactive_winbar
local set_statusline
local mode_changed
local check_buftype
local unset_winbar

function set_winbar_and_statusline_callback(opts)
  if opts.event == "ModeChanged" and not mode_changed(opts.match) then
    -- NOTE: only update winbar when a relevant mode change occurs.
    -- Example: should not update when changing from 'no' to  'n' as
    -- both are 'NORMAL' mode.
    return
  end
  local buf = opts.buf
  if not check_buftype(buf) then
    -- NOTE: do not set winbar for buffers with buftype that is not
    -- empty or terminal or quickfix or help.
    unset_winbar(buf)
    return
  end
  local winid = vim.api.nvim_get_current_win()
  -- NOTE: the active winbar should be set only for the current window
  -- The inactive winbar is handled through the set_inactive_winbar_callback
  -- when the WinLeave event is triggered, so we ignore it here.
  if buf == vim.api.nvim_win_get_buf(winid) then
    -- NOTE: do not set winbar when the event was triggered
    -- in a different window.
    set_winbar(buf, winid)
    -- NOTE: when setting the active winbar, also set the inactive winbar
    -- of all other windows that contain the same buffer
    for _, winid2 in
      ipairs(vim.tbl_filter(function(w)
        return w ~= winid and buf == vim.api.nvim_win_get_buf(w)
      end, vim.api.nvim_list_wins() or {}))
    do
      set_inactive_winbar(buf, winid2)
    end
  end

  if opts.event == "WinResized" then
    -- NOTE: when winResized event is triggered, we need to set the statusline
    -- for all resized windows, their id's are stored in v:event.
    for _, w in ipairs(vim.v.event.windows or {}) do
      set_statusline(w)
    end
  end
end

function set_inactive_winbar_callback(opts)
  -- NOTE: this is called when the WinLeave event is triggered,
  -- so it will run before actually leaving the window,
  -- therefore we can use the current window and buffer numbers.
  -- Using the current buf and win numbers is better than using
  -- the ones passed through the event, as issues may occur when
  -- the same buffer is opened in multiple windows.
  local winid = vim.api.nvim_get_current_win()
  local buf = opts.buf
  if not check_buftype(buf) then
    unset_winbar(buf)
    return
  end
  set_inactive_winbar(buf, winid)
end

local _set_winbar
local editing_winbar = {}

--- @param buf number
--- @param winid number
function set_winbar(buf, winid)
  local key = vim.inspect(buf) .. vim.inspect(winid)
  if editing_winbar[key] then
    return
  end
  -- note memorize which windows and buffers' winbars are currently
  -- being  edited, so that we don't perform multiple redundant
  -- edits in a short span, as multiple events may be triggered
  -- by a single action.
  editing_winbar[key] = true
  vim.schedule(function()
    local ok, err = pcall(function()
      -- NOTE: check whether the window and buffer are still valid
      -- as there may be a delay between the time the event is triggered
      -- and the time the function is called, due to the scheduling.
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
    if not ok then
      handle_error(err, "Winbar")
    end
  end)
end

local _set_inactive_winbar
local editing_inactive_winbar = {}

--- This sets the winbar to only display the
--- full filename of the file open in the window.
--- @param buf number
--- @param winid number
function set_inactive_winbar(buf, winid)
  local key = vim.inspect(buf) .. vim.inspect(winid)
  if editing_inactive_winbar[key] then
    return
  end
  -- note memorize which windows and buffers' winbars are currently
  -- being  edited, so that we don't perform multiple redundant
  -- edits in a short span, as multiple events may be triggered
  -- by a single action.
  editing_inactive_winbar[key] = true
  vim.schedule(function()
    local ok, err = pcall(function()
      if winid == vim.api.nvim_get_current_win() then
        return
      end
      -- NOTE: check whether the window and buffer are still valid
      -- as there may be a delay between the time the event is triggered
      -- and the time the function is called, due to the scheduling.
      if
        not vim.api.nvim_win_is_valid(winid)
        or not vim.api.nvim_buf_is_valid(buf)
      then
        return
      end

      _set_inactive_winbar(buf, winid)
    end)
    editing_inactive_winbar[key] = nil
    if not ok then
      handle_error(err, "Winbar")
    end
  end)
end

local editing_statusline = {}

--- Even when laststatus is set to 0, the statusline still
--- appears between 2 windows in a normal split, so we just
--- set the statusline to appear the same as a window separator.
function set_statusline(winid)
  if editing_statusline[winid] then
    return
  end
  -- note memorize which windows' statuslines are currently
  -- being  edited, so that we don't perform multiple redundant
  -- edits in a short span.
  editing_statusline[winid] = true
  vim.schedule(function()
    local ok, err = pcall(function()
      -- NOTE: check whether the window is still valid
      -- as there may be a delay between the time the event is triggered
      -- and the time the function is called, due to the scheduling.
      if not vim.api.nvim_win_is_valid(winid) then
        return
      end

      local width = vim.fn.winwidth(winid)
      vim.api.nvim_win_set_option(winid, "statusline", string.rep("_", width))
    end)
    editing_statusline[winid] = nil
    if not ok then
      handle_error(err, "Winbar")
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

local function get_right_winbar(width, buf)
  local s = ""
  local git_head = vim.g.gitsigns_head
  local has_git_status, git_status =
    pcall(vim.api.nvim_buf_get_var, buf, "gitsigns_status")

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
  width = width - vim.fn.strchars(m)
  return m .. string.rep("─", width)
end

local get_diagnostics_string

---@param buf number
---@param winid number
function _set_winbar(buf, winid)
  local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
  for _, pattern in ipairs(ignore_filetype_patterns) do
    if filetype:match(pattern) then
      vim.api.nvim_win_set_option(winid, "winbar", "")
      return
    end
  end
  local width = vim.fn.winwidth(winid)
  local name = get_name(buf, true, width)

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
    .. get_right_winbar(right_n, buf)
  vim.api.nvim_win_set_option(winid, "winbar", bar)
end

function mode_changed(match)
  if
    match == "i:ic"
    or match == "ic:i"
    or match == "n:no"
    or match == "n:ntT"
    or match == "ntT:n"
    or match == "n:niV"
    or match == "niV:n"
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
    end
    if readonly == true and vim.fn.strchars(name) + 11 <= width then
      name = name .. " [Readonly]"
    end
    local d = get_diagnostics_string(buf, width - 1)
    if
      d:len() > 0
      and vim.fn.strchars(name) + vim.fn.strchars(d) + 1 <= width
    then
      name = name .. " " .. d
    end
  end
  return name
end

--- Check whether the provided buffer number is valid and has
--- a buftype of either "", terminal, quickfix or help.
function check_buftype(buf)
  if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if
    buftype == "terminal"
    or buftype == "quickfix"
    or buftype == "help"
    or buftype == ""
  then
    return true
  end
  return false
end

function get_diagnostics_string(buf, max_width)
  local diagnostics = #vim.diagnostic.get(buf)
  local s = ""
  if diagnostics > 0 then
    s = "!" .. diagnostics
  end
  if max_width < vim.fn.strchars(s) then
    return ""
  end
  return s
end

function unset_winbar(buf)
  pcall(function()
    vim.api.nvim_win_set_option(vim.fn.bufwinid(buf), "winbar", "")
  end)
end

function handle_error(msg, title)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.ERROR, {
      title = title,
    })
    vim.defer_fn(function()
      vim.notify(
        "Error occured, unsetting winbar and statusline",
        vim.log.levels.ERROR,
        {
          title = title,
        }
      )
      pcall(function()
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          vim.api.nvim_win_set_option(winid, "winbar", "")
          vim.api.nvim_win_set_option(winid, "statusline", "")
        end
      end)
      pcall(function()
        if timer ~= nil then
          timer:close()
        end
      end)
      if type(autocommands) == "table" and next(autocommands) then
        for _, autocommand in ipairs(autocommands) do
          pcall(function()
            vim.api.nvim_del_autocmd(autocommand)
          end)
        end
      end
    end, 100)
  end)
end
