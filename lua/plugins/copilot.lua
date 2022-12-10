--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

local M = {}

---The init function for the github copilot.
---This disables the default tab mapping for the plugin.
---Copilot is disabled for all filetypes by default.
---Call `require('plugins.copilot').enable()`
---to enable it for the current filetype.
---It will rather map:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
function M.init()
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
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
  M.remappings()
end

---This maps:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
function M.remappings()
  vim.api.nvim_set_keymap(
    "i",
    "<C-Space>",
    'copilot#Accept("<CR>")',
    { silent = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "i",
    "<C-k>",
    "copilot#Next()",
    { silent = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "i",
    "<C-j>",
    "copilot#Previous()",
    { silent = true, expr = true }
  )
end

---Enable copilot for the current filetype.
---If the copilot is not already running, run it.
---NOTE: by default copilot is disabled for all filetypes
---so it will not work for filetype until this is called.
---NOTE: this will be a noop if the :Copilot command is not available.
---Meaning, disabling the plugin will also disable this function.
function M.enable()
  if vim.fn.exists ":Copilot" == 0 then
    return
  end
  if vim.g.copilot_filetypes == nil then
    vim.g.copilot_filetypes = { [vim.o.filetype] = true }
  else
    vim.g.copilot_filetypes =
      vim.tbl_extend("force", vim.g.copilot_filetypes, {
        [vim.o.filetype] = true,
      })
  end
  if vim.g.loaded_copilot ~= 1 then
    vim.cmd "Copilot enable"
  end
end

return M
