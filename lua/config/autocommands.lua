--=============================================================================
-------------------------------------------------------------------------------
--                                                                 AUTOCOMMANDS
--[[===========================================================================

-----------------------------------------------------------------------------]]
---------------- Set relative number and cursorline only for the active window,
------------------------------------- and disable them when leaving the window.
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = true
      vim.wo.cursorline = true
    end
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave" }, {
  callback = function()
    if vim.wo.number then
      vim.wo.relativenumber = false
      vim.wo.cursorline = false
    end
  end,
})
--------------------------------------------------------- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    require("vim.highlight").on_yank {
      higroup = "IncSearch",
      timeout = 40,
    }
  end,
})

-------------------------------------------------------------------------------
--- This is a temporary hack to fix the issue with auto entering
--- insert mode

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    vim.defer_fn(function()
      vim.api.nvim_exec("stopinsert", false)
    end, 10)
  end,
})

---------------------------------------- Unload buffers when there are too many
--- Also detach active lsp clients from unloaded buffers.

--- min(1, `max_buf_count` - #union(windows - locked_buffers)) buffers will be kept
--- loaded (+ all buffers with active windows and all locked buffers)
local max_buf_count = 6

local buffer_count = {}
local buffer_timestamps = {}
local locked_buffers = {}
local locked_count = 0
local last_buf = nil

--- (Un)lock the current buffer with <C-l>. Locked buffers will
--- not be unloaded
vim.keymap.set("n", "<C-l>", function()
  local buf = vim.api.nvim_get_current_buf()

  if locked_buffers[buf] then
    locked_buffers[buf] = nil
    locked_count = locked_count - 1
    vim.notify("Unlocked current buffer", vim.log.levels.INFO, {
      title = "Buffer Lock",
    })
    return
  end
  locked_buffers[buf] = true
  locked_count = locked_count + 1
  vim.notify("Locked current buffer", vim.log.levels.INFO, {
    title = "Buffer Lock",
  })
end, {})

vim.api.nvim_create_autocmd({ "BufWipeout" }, {
  callback = function()
    if vim.bo.buftype == "" then
      local buf = vim.api.nvim_get_current_buf()
      buffer_count[buf] = nil
      buffer_timestamps[buf] = nil
      return
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    local cur_buf = vim.api.nvim_get_current_buf()
    if last_buf == cur_buf then
      return
    end
    last_buf = cur_buf

    vim.schedule(function()
      local m = max_buf_count

      --- Count the times the buffer has been entered recently,
      --- and the last time it was entered, so that we can
      --- unload the least used buffers.
      buffer_count[cur_buf] = (buffer_count[cur_buf] or 0) + 1
      buffer_timestamps[cur_buf] = vim.loop.now()

      --- Buffers opened in windows should never be unloaded.
      local buffers = vim.tbl_filter(function(buf)
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
      end, vim.api.nvim_list_bufs())

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
  end,
})
