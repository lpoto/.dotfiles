--=============================================================================
-------------------------------------------------------------------------------
--                                                            BUFFER RETIREMENT
--[[===========================================================================
Unload inactive buffers

Keymaps:
  <C-l>                Lock current buffer (it won't be retired)
  <leader>{i}          Go to locked buffer with index i
  <leader>0            Go to next locked buffer

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

-- Max number of buffers to keep locked at the same time
local max_locked_buffers = 9
local locked_buffers = {}
local wipe_buffers_patterns = {
  "%.git",
}
-- Max number of buffers to keep loaded,
-- locked buffers and current buffers will not be unloaded.
local max_buf_count = function()
  return math.max(#locked_buffers + 2, 5)
end

local lock_buffer
local goto_next_locked
local init_autocommands

function M.config()
  vim.keymap.set("n", "<C-l>", lock_buffer, {})
  for i = 0, max_locked_buffers do
    vim.keymap.set("n", "<leader>" .. i, function()
      if i == 0 then
        return goto_next_locked()
      end
      return goto_next_locked(i)
    end, {})
  end
  init_autocommands()
end

function clean_locked_buffers()
  local to_clean = {}
  for i, buf in ipairs(locked_buffers) do
    if type(buf) ~= "number" or not vim.api.nvim_buf_is_valid(buf) then
      table.insert(to_clean, i)
    end
  end
  for i = #to_clean, 1, -1 do
    table.remove(locked_buffers, to_clean[i])
  end
end

function lock_buffer()
  clean_locked_buffers()
  local buf = vim.api.nvim_get_current_buf()
  for i, b in ipairs(locked_buffers) do
    if b == buf then
      table.remove(locked_buffers, i)
      Util.log():info "Unlocked current buffer"
      return
    end
  end
  if #locked_buffers >= max_locked_buffers then
    Util.log()
      :warn("Only", max_locked_buffers, "buffers may be locked at once")
    return
  end

  table.insert(locked_buffers, buf)
  Util.log():info "Locked current buffer"
end

function goto_next_locked(n)
  clean_locked_buffers()
  local buf = vim.api.nvim_get_current_buf()
  local next_idx = n
  if type(next_idx) ~= "number" then
    local cur_idx = nil
    for i, b in ipairs(locked_buffers) do
      if b == buf then
        cur_idx = i
        break
      end
    end
    next_idx = 1
    if cur_idx ~= nil then
      next_idx = cur_idx + 1
    end
    if next_idx > #locked_buffers then
      next_idx = 1
    end
    if next_idx == cur_idx then
      next_idx = next_idx + 1
    end
    if not locked_buffers[next_idx] then
      Util.log():warn "No next locked buffer"
      return
    end
  else
    if not locked_buffers[next_idx] then
      Util.log():warn("No locked buffer with index", n)
      return
    elseif locked_buffers[next_idx] == buf then
      Util.log():warn("Locked buffer with index", n, "is current buffer")
      return
    end
  end
  vim.api.nvim_set_current_buf(locked_buffers[next_idx])
end

local buffer_count = {}
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
        buffer_count[buf] = nil
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
    buffer_count[cur_buf] = (buffer_count[cur_buf] or 0) + 1
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

    --- Buffers opened in windows should never be unloaded.
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
        or locked_buffers[buf]
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
      local a_count = buffer_count[a] or 0
      local b_count = buffer_count[b] or 0
      if a_count ~= b_count then
        return a_count < b_count
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
