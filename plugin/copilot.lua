--=============================================================================
-------------------------------------------------------------------------------
--                                                               GITHUB COPILOT
--=============================================================================
-- https://github.com/github/copilot.vim
--_____________________________________________________________________________

---Copilot is disabled for all filetypes by default.
---Call `require('plugin').get('copilot'):run('enable')`
---to enable it for the current filetype.
---
---<C-Space> to select the next suggestion.
---<C-k> to show the next suggestion.
---<C-j> to show the previous suggestion.
local plugin = require("plugin").new {
  "github/copilot.vim",
  as = "copilot",
  cmd = "Copilot",
  setup = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
  end,
  config = function()
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
  end,
}

plugin:config(function()
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
end)

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
plugin:action("enable", function(filetype)
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
end)
