--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

--[[
A github copilot plugin. Uses the github copilot API to generate code.
By default it is disabled for all filetypes.
(It is usually enabled for filetypes from ftplugin/ files)

Keymaps:
   - <C-Space> - Select the next suggestion
   - <C-k>     - show the next suggestion
   - <C-j>     - show the previous suggstion

Configure copilot with :Copilot setup
--]]

local M = {
  "github/copilot.vim",
  as = "copilot",
  cmd = "Copilot",
  setup = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
  end,
}

function M.config()
  local mapper = require "util.mapper"

  -- NOTE: disable the copilot for all filetypes by default.
  local tbl = {
    ["*"] = false,
  }
  if vim.g.copilot_filetypes == nil then
    vim.g.copilot_filetypes = tbl
  else
    vim.g.copilot_filetypes =
      vim.tbl_extend("force", vim.g.copilot_filetypes, tbl)
  end

  mapper.map(
    "i",
    "<C-Space>",
    'copilot#Accept("<CR>")',
    { silent = true, expr = true }
  )
  mapper.map("i", "<C-k>", "copilot#Next()", { silent = true, expr = true })
  mapper.map(
    "i",
    "<C-j>",
    "copilot#Previous()",
    { silent = true, expr = true }
  )
end

---Enable copilot for the provided filetype, or the
---current filetype if none is provided.
---If the copilot is not already running, run it.
---NOTE: by default copilot is disabled for all filetypes
---so it will not work for filetype until this is called.
---NOTE: this will be a noop if the :Copilot command is not available.
---Meaning, disabling the plugin will also disable this function.
---NOTE: This will not work if copilot was disabled for the filetype
---with `require('plugins.copilot').disable()`.
---@param filetype string?: the filetype to enable copilot for.
---If this is not provided, it is enabled for current filetype.
function M.enable(filetype)
  if vim.fn.exists ":Copilot" == 0 then
    return
  end
  if filetype == nil then
    filetype = vim.bo.filetype
  end
  -- NOTE: make sure the copilot is enabled for the current filetype.
  if vim.g.copilot_filetypes == nil then
    vim.g.copilot_filetypes = { [filetype] = true }
  else
    vim.g.copilot_filetypes =
      vim.tbl_extend("force", vim.g.copilot_filetypes, {
        [filetype] = true,
      })
  end
  if vim.g.loaded_copilot ~= 1 then
    vim.cmd "Copilot enable"
  end
end

return M
