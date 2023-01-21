--=============================================================================
-------------------------------------------------------------------------------
--                                                                 SIDEBAR-NVIM
--=============================================================================
-- https://github.com/sidebar-nvim/sidebar.nvim
--_____________________________________________________________________________
--[[
display files and docker containers in a sidebar.

Keymaps:
  - "<leader>s" - Toggle sidebar

(use c - create, y - copy, d - delete, ... keymaps in files )
(use e - edit, d - close, w - write, ... keymaps in buffers)
]]

local M = {
  "sidebar-nvim/sidebar.nvim",
}

function M.init()
  vim.keymap.set("n", "<leader>s", function()
    require("sidebar-nvim").toggle()
  end)
  M.hijack_netrw()
end

function M.config()
  local sidebar = require "sidebar-nvim"
  sidebar.setup {
    open = false,
    --hide_statusline = true,
    side = "right",
    sections = { "files", "buffers", "containers" },
    update_interval = 5000,
  }
end

function M.hijack_netrw()
  local netrw_bufname

  -- clear FileExplorer appropriately to prevent netrw from launching on folders
  -- netrw may or may not be loaded before telescope-file-browser config
  -- conceptual credits to nvim-tree
  pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
  vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    once = true,
    callback = function()
      pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup(
      "sidebar-hijack-netrw",
      { clear = true }
    ),
    pattern = "*",
    callback = function()
      vim.schedule(function()
        if vim.bo[0].filetype == "netrw" then
          return
        end
        local bufname = vim.api.nvim_buf_get_name(0)
        if vim.fn.isdirectory(bufname) == 0 then
          _, netrw_bufname = pcall(vim.fn.expand, "#:p:h")
          return
        end

        -- prevents reopening of file-browser if exiting without selecting a file
        if netrw_bufname == bufname then
          netrw_bufname = nil
          return
        else
          netrw_bufname = bufname
        end

        -- ensure no buffers remain with the directory name
        vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")

        local cwd = vim.loop.cwd()
        vim.api.nvim_exec(
          "noautocmd chdir! " .. (vim.fn.expand "%:p:h"),
          true
        )
        require("sidebar-nvim").open()
        vim.api.nvim_exec("noautocmd chdir! " .. cwd, true)
      end)
    end,
    desc = "sidebar.nvim replacement for netrw",
  })
end

return M
