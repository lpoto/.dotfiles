--=============================================================================
-------------------------------------------------------------------------------
--                                                            BUFFER RETIREMENT
--[[===========================================================================
Unload inactive buffers

Keymaps:
  <C-l>                Lock current file (it's buffer won't be retired)
  <leader>{i}          Go to locked file with index i
  <leader>0            Go to next locked file

commands:
  :LockedFiles         List locked files

-----------------------------------------------------------------------------]]
local M = {
  dev = true,
  dir = Util.path(
    vim.fn.stdpath "config",
    "lua",
    "plugins",
    "buffer_retirement"
  ),
  event = { "BufRead", "BufNewFile" },
}

local wipe_buffers_patterns = {
  "%.git",
}

local init_autocommands

local LockedFiles = {
  max_locked = 5,
  __locked = {},
}

LockedFiles.__index = LockedFiles
-- Max number of buffers to keep loaded,
-- locked buffers and current buffers will not be unloaded.
local max_buf_count = function()
  return math.max(LockedFiles:size() + 2, 5)
end

function M.config()
  LockedFiles:init()

  vim.keymap.set("n", "<C-l>", function()
    LockedFiles:lock()
  end, {})
  for i = 0, LockedFiles.max_locked do
    vim.keymap.set("n", "<leader>" .. i, function()
      if i == 0 then
        return LockedFiles:goto_next()
      end
      return LockedFiles:goto_next(i)
    end, {})
  end
  vim.api.nvim_create_user_command("LockedFiles", function()
    LockedFiles:list()
  end, {})
  init_autocommands()
end

function LockedFiles:init()
  -- NOTE: use a global variable to store the locked buffers
  -- so that they are stored when saving a session with "globals" option.
  local s = vim.g.Buffer_retirement_locked_files or ""
  self.__locked = vim.tbl_filter(function(f)
    return vim.fn.filereadable(f) == 1
  end, vim.split(s, ";"))
end

function LockedFiles:list()
  if self:size() == 0 then
    Util.log():warn "No locked buffers"
    return
  end
  local t = { "" }
  for i, v in ipairs(self.__locked) do
    table.insert(t, i .. "  ->  " .. v)
  end
  Util.log():info(table.concat(t, "\n"))
end

function LockedFiles:size()
  return #self.__locked
end

function LockedFiles:find(buf)
  local filename = vim.api.nvim_buf_get_name(buf)
  for i, f in ipairs(self.__locked) do
    if f == filename then
      return i
    end
  end
end

function LockedFiles:add(buf)
  if self:size() >= self.max_locked then
    Util.log():warn "Max number of locked buffers reached"
    return false
  end
  local filename = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if type(filename) ~= "string" or filename:len() == 0 or buftype ~= "" then
    Util.log():warn "Cannot lock a non-file"
    return false
  end
  table.insert(self.__locked, filename)
  self:__set(self.__locked)
  return true
end

function LockedFiles:remove(buf)
  local filename = vim.api.nvim_buf_get_name(buf)
  for i, f in ipairs(self.__locked) do
    if f == filename then
      table.remove(self.__locked, i)
      self:__set(self.__locked)
      return true
    end
  end
  return false
end

function LockedFiles:__set(lb)
  if type(lb) == "table" then
    self.__locked = lb
    vim.g.Buffer_retirement_locked_files = table.concat(self.__locked, ";")
  end
end

function LockedFiles:lock()
  local buf = vim.api.nvim_get_current_buf()
  if self:remove(buf) then
    Util.log():info "Unlocked current file"
    return
  end
  if self:add(buf) then
    Util.log():info "Locked current file"
  end
end

function LockedFiles:goto_next(n)
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)

  local next_idx = n
  if type(next_idx) ~= "number" then
    local cur_idx = self:find(buf)
    next_idx = 1
    if cur_idx ~= nil then
      next_idx = cur_idx + 1
    end
    if next_idx > #self.__locked then
      next_idx = 1
    end
    if next_idx == cur_idx then
      next_idx = next_idx + 1
    end
    if not self.__locked[next_idx] then
      Util.log():warn "No next locked file"
      return
    end
  else
    if not self.__locked[next_idx] then
      Util.log():warn("No locked file with index", next_idx)
      return
    elseif self.__locked[next_idx] == filename then
      Util.log():warn("Already on locked file with index", next_idx)
      return
    end
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if name == self.__locked[next_idx] then
      vim.api.nvim_set_current_buf(b)
      return
    end
  end
  vim.api.nvim_exec("edit " .. self.__locked[next_idx], false)
end

local buffer_timestamps = {}
local last_buf = nil

local retire_buffers

function init_autocommands()
  local augroup = vim.api.nvim_create_augroup("BufferRetirement", {
    clear = true,
  })
  vim.api.nvim_create_autocmd({ "BufWipeout" }, {
    group = augroup,
    callback = function()
      if vim.bo.buftype == "" then
        local buf = vim.api.nvim_get_current_buf()
        buffer_timestamps[buf] = nil
        return
      end
    end,
  })

  local err_count = 0

  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = function()
      local ok, err = pcall(retire_buffers)
      if not ok then
        err_count = err_count + 1
        Util.log():warn(err)
      end
      if err_count > 5 then
        Util.log():error "Too many errors, disabling buffer retirement"
        pcall(vim.api.nvim_clear_autocmds, { group = augroup })
      end
    end,
  })
end

local included_in_wipe_buffers_patterns
function retire_buffers()
  if vim.bo.buftype ~= "" then
    return
  end
  local cur_buf = vim.api.nvim_get_current_buf()
  if last_buf == cur_buf then
    return
  end
  last_buf = cur_buf

  vim.schedule(function()
    local m = max_buf_count()

    --- Count the times the buffer has been entered recently,
    --- and the last time it was entered, so that we can
    --- unload the least used buffers.
    buffer_timestamps[cur_buf] = vim.loop.now()

    local buffers = vim.api.nvim_list_bufs()
    buffers = vim.tbl_filter(function(buf)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return false
      end
      if vim.fn.bufwinid(buf) ~= -1 then
        return true
      end
      local n = vim.api.nvim_buf_get_name(buf)
      for _, pattern in ipairs(wipe_buffers_patterns) do
        if type(n) == "string" and n:len() > 0 and n:match(pattern) then
          vim.api.nvim_buf_delete(buf, { force = true })
          return false
        end
      end
      return true
    end, buffers)

    --- Files opened in windows should never be unloaded.
    buffers = vim.tbl_filter(function(buf)
      if
        vim.api.nvim_buf_get_option(buf, "buftype") ~= ""
        or not vim.api.nvim_buf_is_loaded(buf)
      then
        return false
      end
      if
        buf == cur_buf
        or vim.fn.bufwinid(buf) ~= -1
        or LockedFiles:find(buf) ~= nil
      then
        m = m - 1
        return false
      end
      return true
    end, buffers)

    m = math.max(m, 1)
    if #buffers < m then
      return
    end
    --- Sort buffers by the number of times they have been entered,
    --- and then by the last time they were entered.
    local sort_fn = function(a, b)
      local a_valid = vim.api.nvim_buf_is_valid(a)
      local b_valid = vim.api.nvim_buf_is_valid(b)
      if a_valid and not b_valid then
        return true
      end
      if not a_valid and b_valid then
        return false
      end
      local a_included = included_in_wipe_buffers_patterns(a)
      local b_included = included_in_wipe_buffers_patterns(b)
      if a_included and not b_included then
        return true
      end
      if not a_included and b_included then
        return false
      end
      local a_timestamp = buffer_timestamps[a] or 0
      local b_timestamp = buffer_timestamps[b] or 0
      return a_timestamp < b_timestamp
    end
    table.sort(buffers, sort_fn)

    -- unload all but first `m` buffers
    for i = m + 1, #buffers do
      local buf = buffers[i]
      pcall(vim.api.nvim_buf_delete, buf, { unload = true })
      for _, client in pairs(vim.lsp.buf_get_clients(buf)) do
        pcall(vim.lsp.buf_detach_client, buf, client.id)
      end
    end
  end)
end

function included_in_wipe_buffers_patterns(name)
  for _, pattern in ipairs(wipe_buffers_patterns) do
    if type(name) == "string" and name:len() > 0 and name:match(pattern) then
      return true
    end
  end
  return false
end

return M
