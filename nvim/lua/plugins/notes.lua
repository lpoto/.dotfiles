--=============================================================================
-------------------------------------------------------------------------------
--                                                                        NOTES
--[[===========================================================================
Simple notes sidebar

-----------------------------------------------------------------------------]]
local M = {
  dev = true,
  dir = Util.path(vim.fn.stdpath "config", "lua", "plugins", "notes"),
}

local __notes
local function toggle_notes()
  return __notes()
end

M.keys = { { "<leader>t", toggle_notes, mode = "n" } }

local opts = {
  min_width = math.min(50, math.floor(vim.o.columns / 2)),
  max_width = 0.25,
  notes_file = Util.path(vim.fn.stdpath "data", "notes.md"),
}

local notes_window = nil
local notes_buffer = nil

local function navigate_to_notes_file()
  local file = opts.notes_file
  vim.api.nvim_exec("noautocmd e " .. file, false)
  notes_window = vim.api.nvim_get_current_win()
  notes_buffer = vim.api.nvim_get_current_buf()

  vim.api.nvim_win_set_option(notes_window, "wrap", true)
  vim.api.nvim_win_set_option(notes_window, "winbar", "  NOTES")
  vim.api.nvim_win_set_option(notes_window, "winfixwidth", true)
  vim.api.nvim_buf_set_option(notes_buffer, "buftype", "nofile")
  vim.api.nvim_buf_set_option(notes_buffer, "swapfile", false)
  vim.api.nvim_buf_set_option(notes_buffer, "buflisted", false)
  vim.api.nvim_buf_set_option(notes_buffer, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(notes_buffer, "filetype", "markdown")

  local line_count = vim.api.nvim_buf_line_count(notes_buffer)
  vim.api.nvim_win_set_cursor(notes_window, { line_count, 0 })
end

function __notes()
  if
    type(notes_window) == "number" and vim.api.nvim_win_is_valid(notes_window)
  then
    vim.api.nvim_win_close(notes_window, true)
    notes_window = nil
    return
  end

  local winid = vim.api.nvim_get_current_win()

  vim.api.nvim_exec("normal <C-w>H", false)
  vim.api.nvim_exec("noautocmd keepjumps topleft vs", false)
  navigate_to_notes_file()

  notes_window = vim.api.nvim_get_current_win()
  notes_buffer = vim.api.nvim_get_current_buf()

  local min_width = opts.min_width
  if min_width < 1 then
    min_width = math.floor(vim.o.columns * min_width)
  end
  local max_width = opts.max_width
  if max_width < 1 then
    max_width = math.floor(vim.o.columns * max_width)
  end
  local width = math.max(min_width, max_width)

  vim.api.nvim_win_set_width(notes_window, width)

  local group = vim.api.nvim_create_augroup("NOTES", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    group = group,
    buffer = notes_buffer,
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_buf_set_option, notes_buffer, "buftype", "")
        pcall(vim.api.nvim_buf_call, notes_buffer, function()
          vim.api.nvim_exec("noautocmd w", true)
        end)
        pcall(vim.api.nvim_buf_set_option, notes_buffer, "nofile", "")
      end)
    end,
  })
  local create_buf_replaced_autocmd_id
  local create_buf_replaced_autocmd
  create_buf_replaced_autocmd = function()
    pcall(vim.api.nvim_del_autocmd, create_buf_replaced_autocmd_id)
    if notes_buffer == nil or not vim.api.nvim_buf_is_valid(notes_buffer) then
      return
    end
    create_buf_replaced_autocmd_id =
      vim.api.nvim_create_autocmd("BufWipeout", {
        once = true,
        group = group,
        buffer = notes_buffer,
        callback = function()
          vim.defer_fn(function()
            if vim.api.nvim_get_current_win() ~= notes_window then
              return
            end
            navigate_to_notes_file()
            create_buf_replaced_autocmd()
            Util.log():warn "Cannot replace notes buffer"
          end, 20)
        end,
      })
  end
  create_buf_replaced_autocmd()

  vim.fn.win_gotoid(winid)
end

return M
