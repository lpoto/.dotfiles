--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-UNCEPTION
--=============================================================================
--[[---------------------------------------------------------------------------

When opening files in a neovim terminal, open them in current session instead
of opening another neovim in the terminal.

Keymaps:
  - <C-t> - Open terminal in a new tab
-----------------------------------------------------------------------------]]

local M = {
  "samjwill/nvim-unception",
  event = "VeryLazy",
}

function M.init()
  vim.g.unception_block_while_host_edits = 1
  vim.keymap.set("n", "<C-t>", M.toggle_term)
end

function M.toggle_term(cmd)
  if cmd ~= nil and type(cmd) ~= "string" then
    vim.notify("'cmd' should be a string", vim.log.levels.WARN, {
      title = "Toggle Terminal",
    })
    return
  end
  local new_tab = true
  if vim.b.terminal_job_id then
    local r = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)
    local _, n = next(r)
    if n == -3 then
      new_tab = false
    end
  end
  vim.schedule(function()
    local ok, e = pcall(function()
      if new_tab then
        vim.api.nvim_exec("tabnew", false)
      else
        vim.api.nvim_buf_set_option(0, "modified", false)
      end
      if not cmd then
        vim.api.nvim_exec("term", false)
        local bufnr = vim.api.nvim_get_current_buf()
        local winid = vim.api.nvim_get_current_win()
        for i = 0, 100 do
          local name = "term"
          if i > 0 then
            name = name .. "_" .. i
          end
          local ok, _ = pcall(vim.api.nvim_buf_set_name, bufnr, name)
          if ok then
            break
          end
        end
        vim.api.nvim_create_autocmd("TermClose", {
          buffer = bufnr,
          callback = function()
            vim.schedule(function()
              pcall(function()
                vim.api.nvim_buf_delete(bufnr, { force = true })
                vim.api.nvim_win_close(winid, true)
              end)
            end)
          end,
        })
      else
        vim.fn.termopen(cmd, {
          detach = false,
          env = {
            VISUAL = "nvim",
            EDITOR = "nvim",
          },
        })
      end
    end)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = "Toggle Terminal",
      })
    end
  end)
end

return M
