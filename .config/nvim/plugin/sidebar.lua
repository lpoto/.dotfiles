--=============================================================================
--                                                                      SIDEBAR
--[[===========================================================================

Adds a sidebar to the left side of the screen (when 1 window),
so the focused window is centered in the middle of the screen,
to avoid neck pain :).

It also shows some basic information about the current buffer.

-----------------------------------------------------------------------------]]

local win = nil
local buf = nil
local width = nil
local group_name = "Sidebar"
local last_win = nil

local function close()
  if type(win) == "number" then
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
    win = nil
  end
  if type(buf) == "number" then
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
    buf = nil
  end
  last_win = nil
  vim.api.nvim_del_augroup_by_name(group_name)
end

local function get_min_center_width()
  local w = 120
  if vim.o.columns > 300 then
    w = 150
  end
  return w
end

local function get_width()
  local ok, w = pcall(function()
    local min_center_width = get_min_center_width()
    local columns = vim.o.columns
    local third = math.floor(columns / 3)
    local w = math.min(third, math.floor((columns - min_center_width) / 2))
    if w < 20 then
      return nil
    end
    return w
  end)
  if not ok then
    return nil
  end
  return w
end

local function update_width()
  if type(win) ~= "number" or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local new_width = get_width()
  if new_width == width then
    return false
  end
  width = new_width
  if type(width) ~= "number" or width <= 0 then
    pcall(close)
    return false
  end
  local ok = pcall(vim.api.nvim_win_set_width, win, width)
  return ok
end

---@diagnostic disable-next-line
local function set_content(content)
  pcall(function()
    if type(content) == "string" then
      content = { content }
    end
    if type(content) ~= "table" then
      return
    end
    if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
      return
    end
    vim.schedule(function()
      vim.bo[buf].modifiable = true
      vim.bo[buf].readonly = false
      pcall(function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
      end)
      vim.bo[buf].modifiable = false
      vim.bo[buf].readonly = true
    end)
  end)
end

local function update_content(b)
  if type(win) ~= "number" or not vim.api.nvim_win_is_valid(win) then
    return
  end
  if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.schedule(function()
    if type(b) ~= "number" then
      b = vim.api.nvim_get_current_buf()
    end
    local _, winid = pcall(vim.fn.bufwinid, b)
    if winid < 0 or type(winid) ~= "number" then
      winid = vim.api.nvim_get_current_win()
    end
    if vim.bo[b].buftype == "prompt" then
      return
    end
    local config = vim.api.nvim_win_get_config(winid)
    if config.relative and config.relative ~= "" then
      return
    end
    local content = { "" }
    local filetype = vim.bo[b].filetype
    if type(filetype) == "string" and filetype ~= "" then
      table.insert(content, "  Filetype:  " .. filetype)
    end
    if vim.bo[b].buftype == "" then
      local encoding = vim.bo[b].fileencoding
      local filesize = vim.fn.getfsize(vim.api.nvim_buf_get_name(b))
      if type(filesize) == "number" and filesize >= 0 then
        local size_str = nil
        if filesize > 1024 * 1024 * 1024 then
          size_str = vim.fn.printf("%.2f GB", filesize / (1024 * 1024 * 1024))
        elseif filesize > 1024 * 1024 then
          size_str = vim.fn.printf("%.2f MB", filesize / (1024 * 1024))
        elseif filesize > 1024 then
          size_str = vim.fn.printf("%.2f KB", filesize / 1024)
        else
          size_str = vim.fn.printf("%d B", filesize)
        end
        table.insert(content, "  Filesize:  " .. size_str)
      end
      if type(encoding) == "string" and encoding ~= "" then
        table.insert(content, "  Encoding:  " .. encoding)
      end
      if filetype ~= "bigfile" or filetype == "" then
        -- check if indentation is space or tab
        local indent_str = nil
        if vim.bo[b].expandtab then
          indent_str = vim.bo[b].shiftwidth .. " (spaces)"
        else
          indent_str = vim.bo[b].tabstop .. " (tabs)"
        end
        table.insert(content, "  Indent:    " .. indent_str)

        if type(vim.b[b].gitsigns_status) == "string" and vim.b[b].gitsigns_status ~= "" then
          table.insert(content, "  Git:       " .. vim.b[b].gitsigns_status)
        else
          table.insert(content, "")
        end

        local lsp_clients = vim.lsp.get_clients { bufnr = b }
        if type(lsp_clients) == "table" and #lsp_clients > 0 then
          table.insert(content, "")
          table.insert(content, "")
          table.insert(content, "  LSP clients:")
          local count = 0
          for _, client in ipairs(lsp_clients) do
            table.insert(content, "  - " .. client.name)
            count = count + 1
          end
          if count == 1 then
            table.insert(content, "")
          end
        end
        if package.loaded["spur.manager"] then
          local jobs = require "spur.manager".get_jobs()
          if type(jobs) == "table" and #jobs > 0 then
            local active = {}
            for _, job in ipairs(jobs) do
              if type(job:get_status()) == "string" then
                table.insert(active, job)
              end
            end
            if #active > 0 then
              table.insert(content, "")
              table.insert(content, "")
              table.insert(content, "  Spur:")
              for _, job in ipairs(active) do
                table.insert(content,
                  "  - " .. job:get_name() .. " (" .. job:get_status() .. ")")
              end
            end
          end
        end
      end
    end
    set_content(content)
  end)
end

local function win_is_full_height(winid)
  if type(winid) ~= "number" or not vim.api.nvim_win_is_valid(winid) then
    return false
  end
  return vim.api.nvim_win_get_height(winid) + 3 >= vim.o.lines
end

local function win_is_not_max_width(winid)
  if type(winid) ~= "number" or not vim.api.nvim_win_is_valid(winid) then
    return false
  end
  return vim.api.nvim_win_get_width(winid) + 3 <= vim.o.columns - width
end

local function get_window_splits()
  return vim.tbl_filter(function(w)
    local cfg = vim.api.nvim_win_get_config(w)
    return win ~= w and not (cfg.relative and cfg.relative ~= "")
  end, vim.api.nvim_list_wins())
end

local function get_focused_buf()
  local splits = get_window_splits()
  if #splits ~= 1 then
    return 0
  end
  return vim.api.nvim_win_get_buf(splits[1])
end

local function show()
  if type(win) == "number" and vim.api.nvim_win_is_valid(win) then
    return update_width()
  end
  width = get_width()
  if type(width) ~= "number" or width <= 0 then
    pcall(close)
    return false
  end
  pcall(close)
  vim.cmd "silent noautocmd topleft vsplit"
  win = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_width(win, width)

  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "sidebar"

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].cursorline = false
  vim.wo[win].winfixwidth = true
  vim.wo[win].wrap = true
  vim.wo[win].listchars = "tab: ,"
  vim.wo[win].fillchars = "vert: ,horiz: ,stl: ,stlnc: ,wbr: ,trunc: ,"
    .. "diff: ,msgsep: ,lastline: ,truncrl: ,fold: ,eob: "
  vim.wo[win].winhighlight = "Normal:NonText"

  local group = vim.api.nvim_create_augroup(group_name, { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    buffer = buf,
    callback = function()
      vim.cmd "silent noautocmd wincmd l"
    end,
  })
  vim.api.nvim_create_autocmd(
    { "BufEnter", "LspAttach", "BufWritePost", "User" }, {
      group = group,
      callback = function(opts)
        if opts.event == "BufEnter" then
          if vim.bo[opts.buf].buftype == "prompt" then
            return
          end
        end
        if "User" == opts.event and
          not vim.tbl_contains({ "Spur", "GitSignsUpdate" }, opts.match) then
          return
        end
        local to_run = function()
          local b = get_focused_buf()
          if opts.match == "GitSignsUpdate" and b ~= vim.api.nvim_get_current_buf() then
            return
          end
          pcall(update_content, b)
        end
        vim.schedule(to_run)
      end,
    })
  vim.api.nvim_create_autocmd({ "QuitPre", "ExitPre" }, {
    group = group,
    callback = function()
      local splits = get_window_splits()
      if #splits == 1 then
        pcall(close)
        return
      end
      if type(win) == "number" and vim.api.nvim_win_is_valid(win) then
        for _, w in ipairs(splits) do
          if win_is_full_height(w) or win_is_not_max_width(w) then
            pcall(close)
            return
          end
        end
      end
    end,
  })
  vim.cmd "silent noautocmd wincmd l"
  update_content()
  return true
end

local function try_show()
  local winid = vim.api.nvim_get_current_win()
  if winid == last_win or winid == win and win ~= nil then
    return
  end
  local config = vim.api.nvim_win_get_config(winid)
  if config.relative and config.relative ~= "" then
    return
  end
  local splits = get_window_splits()
  last_win = winid
  if #splits == 1 then
    vim.schedule(function()
      pcall(show)
    end)
    return
  end
  if type(win) == "number" and vim.api.nvim_win_is_valid(win) then
    for _, w in ipairs(splits) do
      if win_is_full_height(w) or win_is_not_max_width(w) then
        pcall(close)
        return
      end
    end
  end
end

local reigstration_group_name = "SidebarRegistration"
local function register()
  local group = vim.api.nvim_create_augroup("SidebarRegistration",
    { clear = true })
  vim.api.nvim_create_autocmd({ "WinEnter" }, {
    group = group,
    callback = try_show
  })
end

local function init()
  vim.schedule(function()
    register()
    try_show()
  end)
end

vim.api.nvim_create_user_command("Sidebar", function()
  if type(win) == "number" and vim.api.nvim_win_is_valid(win) then
    pcall(close)
    pcall(vim.api.nvim_del_augroup_by_name, reigstration_group_name)
  else
    init()
  end
end, { desc = "Toggle sidebar" })

init()
