--=============================================================================
-------------------------------------------------------------------------------
--                                                                     NVIM-CMP
--=============================================================================
-- https://github.com/gpanders/editorconfig.nvim
--_____________________________________________________________________________
--[[
  EditorConfig plugin for Neovim.
  Reads .editorconfig files and applies settings to the current buffer.

  Supported properties:
  
    charset
    end_of_line
    indent_size
    indent_style
    insert_final_newline
    max_line_length
    tab_width
    trim_trailing_whitespace
--]]

return {
  "gpanders/editorconfig.nvim",
  lazy = false,
  --[[
  Add custom with properties:

  config = function()
    require('editorconfig').properties.foo = function(bufnr, val)
      vim.b[bufnr].foo = val
    end
  end

  --]]
}
