--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

local copilot = require("util.packer_wrapper").get "copilot"

---The init function for the github copilot.
---This disables the default tab mapping for the plugin.
---Copilot is disabled for all filetypes by default.
---It will rather map:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
copilot:setup(function()
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
end)

---This maps:
---  <C-Space> to select the next suggestion.
---  <C-k> to show the next suggestion.
---  <C-j> to show the previous suggestion.
copilot:setup(function()
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
end, "remappings")

---Enable copilot for the provided filetype, or the
---current filetype if none is provided.
---If the copilot is not already running, run it.
---NOTE: by default copilot is disabled for all filetypes
---so it will not work for filetype until this is called.
---NOTE: this will be a noop if the :Copilot command is not available.
---Meaning, disabling the plugin will also disable this function.
---@param filetype string?: the filetype to enable copilot for.
---If this is not provided, it is enabled for current filetype.
copilot.data.enable = function(filetype)
  if vim.fn.exists ":Copilot" == 0 then
    return
  end
  if filetype == nil then
    filetype = vim.bo.filetype
  end
  local cp = require("util.packer_wrapper").get "copilot"
  if cp.disabled_filetypes == nil then
    cp.disabled_filetypes = {}
  end
  -- NOTE: if the copilot is disabled for the current filetype,
  -- return early.
  if cp.disabled_filetypes[filetype] == true then
    return
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

---Disable copilot for the provided filetype, or the
---current filetype if none is provided.
---This will disable the function `require('plugins.copilot').enable()`
---for the provided filetype.
---NOTE: this will be a noop if the :Copilot command is not available.
---@param filetype string?: the filetype to disable copilot for.
copilot.data.disable =  function(filetype)
  if vim.fn.exists ":Copilot" == 0 then
    return
  end
  if filetype == nil then
    filetype = vim.bo.filetype
  end

  --NOTE: add it to disabled filetypes so that
  --it cannot be enabled with the enable function.
  local cp = require("util.pack_wrapper").get "copilot"
  if cp.disabled_filetypes == nil then
    cp.disabled_filetypes = {}
  end
  cp.disabled_filetypes[filetype] = true

  --NOTE: add it do the copilot filetypes so that
  --the copilot will not be enabled for the filetype.
  if vim.g.copilot_filetypes == nil then
    vim.g.copilot_filetypes = { [filetype] = false }
  else
    vim.g.copilot_filetypes =
      vim.tbl_extend("force", vim.g.copilot_filetypes, {
        [filetype] = false,
      })
  end
end
