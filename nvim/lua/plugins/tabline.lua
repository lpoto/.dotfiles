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
  lazy = false,
}

local setup_statusline
local setup_tabline
local group_id = nil

function M.config()
  setup_statusline()
  setup_tabline()

  group_id = vim.api.nvim_create_augroup("RedrawTabline", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "ModeChanged" }, {
    group = group_id,
    callback = function()
      -- NOTE: sometimes the tabline is not redrawn when we want it to be
      -- so we force it to redraw here.
      vim.api.nvim_exec("redrawtabline", false)
    end,
  })
end

function setup_statusline()
  vim.o.laststatus = 0
  -- NOTE: in normal splits, statusline is still visible
  -- even when laststatus=0, so we make it appear the same
  -- as the window separator.
  vim.opt.statusline =
    "%-5{%v:lua.string.rep('_', v:lua.vim.fn.winwidth(0))%}"
end

local append_to_tabline
local append_tabline_section_separator
local section_count = 1
local empty_section = false

function setup_tabline()
  vim.o.showtabline = 2

  append_to_tabline("mode", "TabLine")
  append_tabline_section_separator()
  append_to_tabline("diagnostic_info", "DiagnosticInfo", 0.20)
  append_to_tabline("diagnostic_warn", "DiagnosticWarn", 0.30)
  append_to_tabline("diagnostic_error", "DiagnosticError", 0.40)
  append_tabline_section_separator()
  append_to_tabline("filename", "TabLineSel")
  append_tabline_section_separator()
  append_to_tabline("tabcount", "TabLineFill")
  append_to_tabline("gitsigns", "TabLine", nil, 20)
  append_tabline_section_separator()
  append_to_tabline("cursor", "TabLine")
end

function append_to_tabline(section, highlight, width, padding)
  if type(highlight) == "string" then
    vim.opt.tabline:append(string.format("%%#%s#", highlight))
  end
  padding = padding or 8
  vim.opt.tabline:append(
    "%"
      .. padding
      .. "{%v:lua.require('plugins.tabline').tabline_sections.get('"
      .. section
      .. "', "
      .. (width or 1)
      .. ")%}"
  )
  empty_section = false
end

function append_tabline_section_separator()
  vim.opt.tabline:append " %= "
  if empty_section then
    return
  end
  section_count = section_count + 1
  empty_section = true
end

local get_width
local get_mode
local pad_left
local align_center

M.tabline_sections = {}

function M.tabline_sections.get(name, width)
  local section = M.tabline_sections[name]
  if not section then
    Util.log():error("Tabline section does not exist:", name)
    return ""
  end
  local ok, result = pcall(section, width)
  if not ok then
    Util.log():error("Error in tabline section:", name, result)
    return ""
  end
  return result
end

function M.tabline_sections.mode()
  local w = get_width() - 10
  local mode = get_mode()
  local n = vim.fn.strchars(mode)
  if n > 0 and w > n then
    return mode
  end
  return ""
end

local diagnostic
function M.tabline_sections.diagnostic_info(n)
  return diagnostic(get_width(n), "I", {
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT,
  })
end

function M.tabline_sections.diagnostic_warn(n)
  return diagnostic(get_width(n), "W", { vim.diagnostic.severity.WARN })
end

function M.tabline_sections.diagnostic_error(n)
  return diagnostic(get_width(n), "E", { vim.diagnostic.severity.ERROR })
end

function diagnostic(w, sign, severity)
  local s = ""
  local diagnostics = 0
  for _, sev in ipairs(severity) do
    diagnostics = diagnostics + #vim.diagnostic.get(0, { severity = sev })
  end
  local diag_string = ""
  if diagnostics > 0 then
    diag_string = string.format("%s%d", sign, diagnostics)
  else
    diag_string = "   "
  end
  local n = vim.fn.strchars(diag_string)
  if n > 0 and w > n then
    s = s .. diag_string
  end
  return s
end

function M.tabline_sections.gitsigns()
  local w = get_width() - 5
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
  else
    s = align_center(s, math.min(w, vim.fn.strchars(s) + 6))
  end
  return s
end

function M.tabline_sections.cursor()
  local w = get_width() - 5
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_str = string.format("[%d,%d]", cursor[1], cursor[2] + 1)
  local n = vim.fn.strchars(cursor_str)
  if n > w then
    return ""
  end
  return align_center(cursor_str, 10)
end

function M.tabline_sections.filename()
  local w = math.max(15, get_width() + 25)
  local cur_w = w
  local s = ""
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  if buftype ~= "" and buftype ~= "terminal" then
    return s
  end
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified") and " [+]"
    or ""
  local readonly = vim.api.nvim_buf_get_option(bufnr, "readonly") and " [~]"
    or ""
  local name = vim.api.nvim_buf_get_name(bufnr) or ""
  if name:len() == 0 then
    name = "[No Name]"
  else
    local ok, v = pcall(vim.fn.fnamemodify, name, ":~:.")
    if ok then
      name = v
    end
  end

  local n = vim.fn.strchars(name)
  local tail = vim.fn.fnamemodify(name, ":t")
  local tail_n = vim.fn.strchars(tail)
  local c = 0
  while n + 3 >= cur_w and tail_n + 3 < n do
    name = string.format("...%s", string.sub(name, 3 + c))
    c = 3
    n = vim.fn.strchars(name)
  end
  if n >= cur_w then
    local ok, v = pcall(vim.fn.fnamemodify, name, ":t")
    if ok then
      name = v
    end
  end
  local x = 4
  name = pad_left(name, vim.fn.strchars(name) + x)

  n = vim.fn.strchars(name)
  if n <= cur_w then
    s = name
    cur_w = cur_w - n
  end
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
    elseif 4 >= n then
      s = s .. string.rep(" ", 4)
    end
  end
  return s
end

function M.tabline_sections.tabcount()
  local w = get_width() - 5
  local tabs = #vim.api.nvim_list_tabpages()
  local s = ""
  if tabs > 1 then
    s = "Tab [" .. vim.api.nvim_tabpage_get_number(0) .. "/" .. tabs .. "]  "
  end
  local n = vim.fn.strchars(s)
  if n < 0 or w < n then
    s = ""
  end
  return s
end

function get_width(n)
  local w = vim.o.columns
  w = math.floor(w / section_count)
  if type(n) == "number" and n > 0 and n <= 1 then
    w = math.floor(w * n)
  end
  return w - 3
end

function pad_left(s, w)
  local n = vim.fn.strchars(s)
  if n < w then
    return string.rep(" ", w - n) .. s
  end
  return s
end

function align_center(s, w)
  local n = vim.fn.strchars(s)
  if n < w then
    local l = math.floor((w - n) / 2)
    local r = w - n - l
    return string.rep(" ", l) .. s .. string.rep(" ", r)
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

return M
