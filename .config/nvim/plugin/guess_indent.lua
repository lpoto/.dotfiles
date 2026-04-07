--=============================================================================
--                                                                 GUESS INDENT
--[[===========================================================================
--
-- Some projects don't have .editorconfig file to define a specific
-- indentation style, but may still have a consistent indentation,
-- that may differ from the filetype's default configuration.
--
-- This plugins detects indentation style and configures relevant options
-- to match the existing style, but still preserves options from .editorconfig.
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/nmac427/guess-indent.nvim",
    version = "84a4987"
  }
}

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = function()
    require "guess-indent".setup {}
  end
})
