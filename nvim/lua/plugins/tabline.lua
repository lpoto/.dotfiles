--=============================================================================
-------------------------------------------------------------------------------
--                                                                      TABLINE
--[[===========================================================================

Disables statusline completely and always displays the tabline, like a winbar,
but global.

-----------------------------------------------------------------------------]]
local M = {
  dev = true,
  dir = Util.path(vim.fn.stdpath "config", "lua", "plugins", "tabline"),
  event = "VeryLazy",
}

local setup_statusline
local setup_tabline

function M.config()
  setup_statusline()
  setup_tabline()

  vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
    group = vim.api.nvim_create_augroup("RedrawTabline", { clear = true }),
    callback = function()
      -- NOTE: sometimes the tabline is not redrawn when we want it to be
      -- so we force it to redraw here.
      vim.api.nvim_exec("redrawtabline", false)
    end,
  })
end

local trim
local width
local get_mode
local align_center
local pad_right
local pad_left

local width_left = 0.10
local width_diagnostic_info = 0.04
local width_diagnostic_warn = 0.04
local width_diagnostic_warn_add = 0
local width_diagnostic_error = 0.05
local width_diagnostic_error_add = 0
local width_right1 = 0.18
local width_right2 = 0.10
local width_center1 = 0.40
local width_center2 = 0.10

function M.left()
  local w = width(width_left)
  local cur_w = w
  local s = ""
  local mode = get_mode()
  local n = vim.fn.strchars(mode)
  if n > 0 and cur_w >= n then
    s = s .. mode
    cur_w = cur_w - n
  end
  return pad_left(pad_right(s, w - 2), w)
end

local diagnostic
function M.diagnostic_info()
  local s = diagnostic(width(width_diagnostic_info), "I", {
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT,
  }, pad_left)
  if trim(s):len() == 0 then
    width_diagnostic_warn_add = width_diagnostic_info
  else
    width_diagnostic_warn_add = 0
  end
  return s
end

function M.diagnostic_warn()
  local s = diagnostic(
    width(width_diagnostic_warn) + width_diagnostic_warn_add,
    "W",
    { vim.diagnostic.severity.WARN },
    align_center
  )
  if trim(s):len() == 0 then
    width_diagnostic_error_add = width_diagnostic_warn
      + width_diagnostic_warn_add
  else
    width_diagnostic_error_add = 0
  end
  return s
end

function M.diagnostic_error()
  return diagnostic(
    width(width_diagnostic_error) + width_diagnostic_error_add,
    "E",
    { vim.diagnostic.severity.ERROR },
    pad_right
  )
end

function diagnostic(w, sign, severity, pad)
  local cur_w = w
  local s = ""
  local diagnostics = 0
  for _, sev in ipairs(severity) do
    diagnostics = diagnostics + #vim.diagnostic.get(0, { severity = sev })
  end
  local diag_string = ""
  if diagnostics > 0 then
    diag_string = string.format(" %s%d", sign, diagnostics)
  end
  local n = vim.fn.strchars(diag_string)
  if n > 0 and cur_w >= n then
    s = s .. diag_string
    cur_w = cur_w - n
  end
  return pad(s, w)
end

function M.right1()
  local w = width(width_right1)
  local cur_w = w
  local s = ""
  local branch = vim.g.gitsigns_head or ""
  local n = vim.fn.strchars(branch)
  if n > 0 and cur_w >= n then
    s = s .. branch
    cur_w = cur_w - n
  end
  local status = vim.b.gitsigns_status or ""
  n = vim.fn.strchars(status)
  if n > 0 and cur_w >= n + 1 then
    s = s .. " " .. status
    cur_w = cur_w - n - 1
  end
  return align_center(s, w)
end

function M.right2()
  local w = width(width_right2)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_str = string.format("[%d,%d]", cursor[1], cursor[2] + 1)
  local s = pad_left(cursor_str, w - 2, true)
  if trim(s):len() > 0 then
    return pad_right(s, w)
  end
  return s
end

function M.center1()
  local w = width(width_center1)
  local cur_w = w
  local s = ""
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  if buftype ~= "" and buftype ~= "terminal" then
    return pad_right(s, w)
  end
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified") and " [+]"
    or ""
  local readonly = vim.api.nvim_buf_get_option(bufnr, "readonly") and " [~]"
    or ""
  local name = vim.api.nvim_buf_get_name(bufnr) or ""
  if name:len() == 0 then
    name = "[No Name]"
  else
    name = vim.fn.fnamemodify(name, ":~:.")
  end

  local n = vim.fn.strchars(name)
  if n >= cur_w then
    name = vim.fn.fnamemodeify(name, ":t")
  elseif n < cur_w / 3 then
    name = pad_right(name, math.max(math.floor(cur_w / 4), 5))
  end
  n = vim.fn.strchars(name)
  if n <= cur_w then
    s = name
    cur_w = cur_w - n
  end
  local x = 4
  n = vim.fn.strchars(modified)
  if n > 0 and cur_w >= n then
    s = s .. modified
    cur_w = cur_w - n
    x = x - n
  else
    n = vim.fn.strchars(readonly)
    if n > 0 and cur_w >= n then
      s = s .. readonly
      cur_w = cur_w - n
      x = x - n
    end
  end

  return pad_right(pad_left(s, w - x), w)
end

function M.center2()
  local w = width(width_center2)
  local tabs = #vim.api.nvim_list_tabpages()
  local s = ""
  if tabs > 1 then
    s = "Tab [" .. vim.api.nvim_tabpage_get_number(0) .. "/" .. tabs .. "]"
  end
  return align_center(s, w)
end

function setup_statusline()
  vim.o.laststatus = 0
  -- NOTE: in normal splits, statusline is still visible
  -- even when laststatus=0, so we make it appear the same
  -- as the window separator.
  vim.opt.statusline =
    "%-5{%v:lua.string.rep('_', v:lua.vim.fn.winwidth(0))%}"
end

function setup_tabline()
  vim.o.showtabline = 2

  vim.opt.tabline:append "%#TabLine#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').left()%}"
  vim.opt.tabline:append "%#DiagnosticInfo#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').diagnostic_info()%}"
  vim.opt.tabline:append "%#DiagnosticWarn#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').diagnostic_warn()%}"
  vim.opt.tabline:append "%#DiagnosticError#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').diagnostic_error()%}"
  vim.opt.tabline:append "%#TabLineSel#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').center1()%}"
  vim.opt.tabline:append " %= "
  vim.opt.tabline:append "%#TabLineFill#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').center2()%}"
  vim.opt.tabline:append "%#TabLine#"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').right1()%}"
  vim.opt.tabline:append "%{%v:lua.require('plugins.tabline').right2()%}"
end

function width(n)
  local w = vim.o.columns
  return math.floor(w * n)
end

function align_center(s, n, empty_when_too_large)
  local s_len = vim.fn.strchars(s)
  if s_len + 2 > n and empty_when_too_large then
    if n <= 0 then
      return ""
    end
    return string.rep(" ", n)
  end
  local n1 = math.floor((n - s_len) / 2)
  if n1 > 0 then
    s = string.rep(" ", n1) .. s
  end
  local n2 = n - s_len - n1
  if n2 > 0 then
    s = s .. string.rep(" ", n2)
  end
  return s
end

function pad_right(s, n, empty_when_too_large)
  local s_len = vim.fn.strchars(s)
  if s_len > n and empty_when_too_large then
    if n <= 0 then
      return ""
    end
    return string.rep(" ", n)
  end
  local x = n - s_len
  if x > 0 then
    s = s .. string.rep(" ", x)
  end
  return s
end

function pad_left(s, n, empty_when_too_large)
  local s_len = vim.fn.strchars(s)
  if s_len > n and empty_when_too_large then
    if n <= 0 then
      return ""
    end
    return string.rep(" ", n)
  end
  local x = n - s_len
  if x > 0 then
    s = string.rep(" ", x) .. s
  end
  return s
end

function get_mode()
  local m = vim.api.nvim_get_mode().mode
  local mapping = {
    n = "NORMAL",
    no = "NORMAL",
    nov = "NORMAL",
    noV = "NORMAL",
    niI = "NORMAL",
    niR = "NORMAL",
    niV = "NORMAL",
    nt = "NORMAL",
    ntT = "NORMAL",
    v = "VISUAL",
    V = "VLINE",
    Vs = "VLINE",
    [""] = "VBLOCK",
    ["s"] = "VBLOCK",
    S = "SLINE",
    s = "SELECT",
    [""] = "SBLOCK",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    R = "REPLACE",
    Rc = "REPLACE",
    Rx = "REPLACE",
    Rv = "REPLACE",
    Rvx = "REPLACE",
    Rvc = "REPLACE",
    c = "COMMAND",
    cv = "EX",
    r = "PROMPT",
    rm = "PROMPT",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    t = "TERMINAL",
  }
  return mapping[m] or m
end

function trim(s)
  return s:match "^%s*(.-)%s*$"
end

return M
