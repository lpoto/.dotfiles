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
  vim.schedule(function()
    local ok, e = pcall(function()
      vim.api.nvim_exec("tabnew", false)
      if type(cmd) ~= "string" and type(cmd) ~= "table" then
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
        vim.fn.termopen(
          cmd,
          {
            detach = false,
            env = {
              VISUAL = "nvim",
              EDITOR = "nvim",
            },
          }
        )
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
