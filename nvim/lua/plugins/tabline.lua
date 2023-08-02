--=============================================================================
-------------------------------------------------------------------------------
--                                                                      TABLINE
--[[===========================================================================

Disables statusline completely and always displays the tabline, like a winbar,
but global.

-----------------------------------------------------------------------------]]
local M = {
  dev = true,
  dir = Util.path()
    :new(vim.fn.stdpath("config"), "lua", "plugins", "tabline"),
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
      vim.schedule(function()
        vim.api.nvim_exec("redrawtabline", false)
      end)
    end,
  })
end

function setup_statusline()
  vim.o.laststatus = 0
  -- NOTE: in normal splits, statusline is still visible
  -- even when laststatus=0, so we make it appear the same
  -- as the window separator.
  vim.opt.statusline =
    "%-5{%v:lua.string.rep('—', v:lua.vim.fn.winwidth(0))%}"
end

local append_to_tabline
local append_tabline_section_separator
local section_count = 1
local empty_section = false

function setup_tabline()
  vim.o.showtabline = 2

  append_to_tabline("mode", "TabLine", 0.10, 0.10, nil, "left")
  append_to_tabline("diagnostic_info", "DiagnosticInfo", 5, 0.05)
  append_to_tabline("diagnostic_warn", "DiagnosticWarn", 5, 0.05)
  append_to_tabline("diagnostic_error", "DiagnosticError", 5, 0.05)
  append_tabline_section_separator()
  append_to_tabline("filename", "TabLineSel", 0.45, 0.45, 50, "center")
  append_to_tabline("tabcount", "TabLineFill", 0.20, 0.20, 20)
  append_to_tabline("cursor", "TabLine", 0.10, 0.10, nil, "right")
end

function append_to_tabline(
  section,
  highlight,
  width,
  max_width,
  min_width,
  align
)
  if type(highlight) == "string" then
    vim.opt.tabline:append(string.format("%%#%s#", highlight))
  end
  vim.opt.tabline:append(
    "%"
      .. "{%v:lua.require('util').misc().tabline_sections.get('"
      .. section
      .. "', "
      .. (width or 0)
      .. ", "
      .. (max_width or 0)
      .. ", "
      .. (min_width or 0)
      .. ", '"
      .. (align or "center")
      .. "')%}"
  )
  empty_section = false
end

function append_tabline_section_separator()
  vim.opt.tabline:append(" %= ")
  if empty_section then
    return
  end
  section_count = section_count + 1
  empty_section = true
end

local get_width
local get_mode
local pad_left
local pad_right
local align_center

local tabline_sections = {}

function tabline_sections.get(name, w, max_w, min_w, align)
  local max_width = math.max(min_w, get_width(max_w))
  local width = get_width(w)
  local section = tabline_sections[name]
  if not section then
    Util.log():error("Tabline section does not exist:", name)
    return align_center("", width)
  end
  local ok, result = pcall(section, width, max_width)
  if not ok then
    Util.log():error("Error in tabline section:", name, result)
    return align_center("", width)
  end
  if type(result) ~= "string" then
    Util.log():error("Tabline section did not return a string:", name, result)
    return align_center("", width)
  end
  local n = vim.fn.strchars(result)
  if n > max_width then
    return align_center("", width)
  end
  if align == "center" then
    return align_center(result, width)
  end
  if align == "left" then
    return pad_right(result, width)
  end
  if align == "right" then
    return pad_left(result, width)
  end
end

function tabline_sections.spacer(width)
  if type(width) ~= "number" or width <= 0 then
    width = 1
  elseif width < 1 then
    local columns = vim.opt.columns
    width = math.floor(columns * width)
  end
  return align_center("", width)
end

function tabline_sections.mode(w)
  local s = get_mode()
  return pad_left(pad_right(s, w - 2), w)
end

local diagnostic
function tabline_sections.diagnostic_info(w)
  return diagnostic(w, "I", {
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT,
  }, pad_left)
end

function tabline_sections.diagnostic_warn(w)
  return diagnostic(w, "W", { vim.diagnostic.severity.WARN }, align_center)
end

function tabline_sections.diagnostic_error(w)
  return diagnostic(w, "E", { vim.diagnostic.severity.ERROR }, pad_right)
end

function diagnostic(w, sign, severity, pad)
  local diagnostics = 0
  for _, sev in ipairs(severity) do
    diagnostics = diagnostics + #vim.diagnostic.get(0, { severity = sev })
  end
  local diag_string = ""
  if diagnostics > 0 then
    diag_string = string.format("%s%d", sign, diagnostics)
  end
  return pad(diag_string, w)
end

function tabline_sections.cursor(w)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_str = string.format("[%d,%d]", cursor[1], cursor[2] + 1)
  return pad_right(pad_left(cursor_str, w - 2), w)
end

function tabline_sections.filename(w)
  local s = ""
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  local wintype = vim.fn.win_gettype()
  if wintype ~= "" or buftype ~= "" and buftype ~= "terminal" then
    return s
  end
  local name = vim.api.nvim_buf_get_name(bufnr) or ""
  local no_name = false
  if name:len() == 0 then
    name = "[No Name]"
    no_name = true
  else
    local ok, v = pcall(vim.fn.fnamemodify, name, ":~:.")
    if ok then
      name = v
    else
      no_name = true
    end
  end

  local n = vim.fn.strchars(name)
  local h = name
  if n >= w and not no_name and h:len() > 1 then
    name = vim.fn.fnamemodify(name, ":t")
    local tail = name
    while vim.fn.strchars(tail) < w do
      name = tail
      h = vim.fn.fnamemodify(h, ":h")
      tail = Util.path():new(vim.fn.fnamemodify(h, ":t"), tail)
    end
  end

  local m = tabline_sections.modified()
  if m:len() > 0 then
    name = string.format("%s %s", name, m)
  end
  return name
end

function tabline_sections.modified()
  local modified = vim.api.nvim_buf_get_option(0, "modified") and "[+]" or ""
  if modified:len() > 0 then
    return modified
  end
  return vim.api.nvim_buf_get_option(0, "readonly") and "[~]" or ""
end

function tabline_sections.tabcount()
  local tabs = #vim.api.nvim_list_tabpages()
  if tabs > 1 then
    return "Tab ["
      .. vim.api.nvim_tabpage_get_number(0)
      .. "/"
      .. tabs
      .. "]  "
  end
  return ""
end

Util.misc().tabline_sections = tabline_sections

function get_width(n)
  local w = vim.o.columns
  if type(n) == "number" and n > 0 and n <= 1 then
    w = math.floor(w * n)
  elseif type(n) == "number" and n > 1 then
    w = n
  end
  return w
end

function pad_left(s, w)
  local n = vim.fn.strchars(s)
  if n < w then
    return string.rep(" ", w - n) .. s
  end
  return s
end

function pad_right(s, w)
  local n = vim.fn.strchars(s)
  if n < w then
    return s .. string.rep(" ", w - n)
  end
  return s
end

function align_center(s, w)
  local n = vim.fn.strchars(s)
  if n < w then
    local l = math.ceil((w - n) / 2)
    if l > 0 then
      s = string.rep(" ", l) .. s
    end
    local r = w - n - l
    if r > 0 then
      s = s .. string.rep(" ", r)
    end
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
