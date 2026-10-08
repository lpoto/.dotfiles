--=============================================================================
--                                                                      TABLINE
--[[===========================================================================

Simplistic tabline that is always visible, shows all relevant
information and acts as statusline replacement.

-----------------------------------------------------------------------------]]

local api, fn = vim.api, vim.fn
local group = api.nvim_create_augroup("Tabline", { clear = true })
local last_buf, progress
local tasks, git = {}, {}
local fill_hl = "%#TabLineFill#"

local function redraw()
  vim.cmd.redrawtabline()
end

local function filler(width)
  return fill_hl .. string.rep("—", math.max(0, width))
end

-- Adjacent items share a bullet. Measure text before escaping tabline syntax.
local function item(previous, text, highlight, width)
  local edge = previous == "" and 4 or 3
  local size = fn.strdisplaywidth(text)
  if size == 0 or size + edge > width then return previous, width end
  text = text:gsub("%%", "%%%%")
  return previous .. (previous == "" and fill_hl .. "• " or " ")
    .. "%#" .. highlight .. "#" .. text .. fill_hl .. " •", width - size - edge
end

local function eligible(buf)
  if not buf or not api.nvim_buf_is_valid(buf) then return false end
  if vim.bo[buf].buftype == "nofile" or vim.bo[buf].buftype == "prompt" then return false end
  local win = fn.bufwinid(buf)
  return win > 0 and vim.tbl_contains({ "", "quickfix", "loclist" }, fn.win_gettype(win))
end

local function filename(buf, width)
  local name = api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype == "help" then name = "Help"
  elseif vim.bo[buf].buftype == "quickfix" then name = "Quickfix"
  elseif name == "" then name = "[No Name]"
  else name = fn.fnamemodify(name, ":~:.") end
  while fn.strdisplaywidth(name) > width and name:find("[/\\]") do
    name = name:gsub("^.-[/\\]", "", 1)
  end
  if fn.strdisplaywidth(name) > width and name ~= "[No Name]" then
    name = fn.fnamemodify(name, ":e")
  end
  return name
end

local function progress_text(width)
  if not progress then return "" end
  local text, titled = "", false
  local name, title = progress.name, progress.title
  if type(name) == "string" and #name > 0 and fn.strdisplaywidth(name) <= width - 2 then
    text = "[" .. name .. "]"
    width = width - fn.strdisplaywidth(text)
  end
  if width <= 1 then return text end
  if type(title) == "string" and #title > 0 and fn.strdisplaywidth(title) + 1 < width then
    text, titled = text .. " " .. title, true
    width = width - fn.strdisplaywidth(title) - 1
  end
  if type(progress.percentage) == "number" and width >= 5 then
    local percent = (titled and ":" or "") .. string.format(" %3d٪", progress.percentage)
    text, titled = text .. percent, false
    width = width - fn.strdisplaywidth(percent)
  end
  if type(progress.message) == "string" and width > 2 then
    local message = progress.message:gsub("%s+", " "):gsub("%%", "٪")
    local size = fn.strdisplaywidth(message)
    if size > 0 and size < width - 1 then
      text = text .. (titled and size < width - 2 and ":" or "") .. " " .. message
    end
  end
  return text
end

local function show(message, delay)
  progress = message
  if delay then
    vim.defer_fn(function()
      if progress == message then progress = nil; redraw() end
    end, delay)
  end
  redraw()
end

api.nvim_create_autocmd("LspProgress", {
  group = group,
  callback = function(event)
    local id, params = event.data.client_id, event.data.params
    local value = params.value
    if type(value) ~= "table" or not value.kind then return end
    tasks[id] = tasks[id] or {}
    local task = tasks[id][params.token]
    if value.kind == "begin" then
      task = { title = value.title }
      tasks[id][params.token] = task
    elseif value.kind == "end" then
      tasks[id][params.token] = nil
      if not task then show(nil); return end
    elseif value.kind ~= "report" or not task then return end
    local client = vim.lsp.get_client_by_id(id)
    show({
      name = client and client.name,
      title = value.title or task.title,
      message = value.message or (value.kind == "end" and "Done" or nil),
      percentage = value.percentage,
    }, value.kind == "end" and 5000 or nil)
  end,
})

-- Used by plugin/lsp.lua for short formatting messages.
vim.g.display_message = function(opts)
  if type(opts) == "table" and type(opts.message) == "string" and opts.message ~= "" then
    show({ name = opts.title, message = opts.message }, 2500)
  end
end

local function branch(buf)
  if not git.root then return "" end
  local status = vim.b[buf].gitsigns_status_dict
  if status and status.root == git.root then return status.head or "" end
  -- Gitsigns' global HEAD can lag in linked worktrees; reuse an attached buffer.
  for _, other in ipairs(api.nvim_list_bufs()) do
    status = vim.b[other].gitsigns_status_dict
    if status and status.root == git.root then return status.head or "" end
  end
  return vim.g.gitsigns_head or ""
end

-- Keep Git labels tied to cwd, as before; Gitsigns owns branch observation.
local function refresh_git()
  local cwd = fn.getcwd()
  local head = git.cwd == cwd and git.root and branch(api.nvim_get_current_buf()) or vim.g.gitsigns_head
  if git.cwd == cwd and git.head == head then return end
  local request = { cwd = cwd, head = head, remote = "" }
  git = request
  vim.system({ "git", "rev-parse", "--show-toplevel" }, { cwd = cwd, text = true },
    vim.schedule_wrap(function(result)
      if git ~= request or result.code ~= 0 then redraw(); return end
      request.root = vim.trim(result.stdout)
      vim.system({ "git", "remote" }, { cwd = cwd, text = true },
        vim.schedule_wrap(function(remotes)
          if git ~= request then return end
          for remote in (remotes.stdout or ""):gmatch("[^\r\n]+") do request.remote = remote end
          redraw()
        end))
    end))
end

function _G.Tabline()
  local buf = api.nvim_get_current_buf()
  if eligible(buf) then last_buf = buf
  elseif eligible(last_buf) then buf = last_buf
  else return "" end
  local third = math.floor(vim.o.columns / 3)
  local left, width = "", third
  local tabs = #api.nvim_list_tabpages()
  left, width = item(left, tabs > 1 and ("Tab [%d/%d]"):format(fn.tabpagenr(), tabs) or "",
    "TabLineSel", width)
  left, width = item(left, progress_text(width - (left == "" and 4 or 3)), "TabLine", width)
  left = left .. filler(width)

  local center = ""
  width = third
  center, width = item(center, vim.bo[buf].modified and "[+]" or vim.bo[buf].readonly and "[~]" or "",
    "TabLineFill", width)
  center, width = item(center, filename(buf, width - (center == "" and 4 or 3)), "TabLineSel", width)
  center = filler(math.floor(width / 2)) .. center .. filler(width - math.floor(width / 2))

  local diagnostics, right = "", ""
  width = vim.o.columns - 2 * third
  local counts = vim.diagnostic.count(buf)
  for severity, name in ipairs({ "Error", "Warn", "Info", "Hint" }) do
    local count = counts[severity] or 0
    diagnostics, width = item(diagnostics, count > 0 and name:sub(1, 1) .. ": " .. count or "",
      "Diagnostic" .. name, width)
  end
  right, width = item(right, git.remote or "", "TabLineFill", width)
  right, width = item(right, branch(buf), "TabLineSel", width)
  return left .. center .. filler(math.floor(width / 2)) .. diagnostics
    .. filler(width - math.floor(width / 2)) .. right
end

api.nvim_create_autocmd("User", {
  group = group,
  pattern = "GitSignsUpdate",
  callback = function() vim.schedule(function() refresh_git(); redraw() end) end,
})
api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function() refresh_git(); redraw() end,
})
api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TabEnter", "TabClosed", "VimResized",
  "DiagnosticChanged", "BufModifiedSet" }, { group = group, callback = redraw })
api.nvim_create_autocmd("OptionSet", { group = group, pattern = "readonly", callback = redraw })

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua.Tabline()"
vim.o.laststatus = 0
vim.o.statusline = "%#WinSeparator#%{%v:lua.string.rep('—', v:lua.vim.fn.winwidth(0))%}"
refresh_git()
