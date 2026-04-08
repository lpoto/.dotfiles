--=============================================================================
--                                                                   TREESITTER
--[[===========================================================================
--
-- Configures nvim-treesitter, that provides configurations and queries
-- for treesitter parsers.
--
-- NOTE: Also adds logic for optioally installing missing parsers
-- when opening a file of a given type, with a confirmation prompt.
--
-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "c82bf96"
  }
}

vim.opt.foldlevelstart = 99

require "nvim-treesitter".setup {}

local processed = {}
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local bufnr = args.buf
    local ft = vim.bo[bufnr].filetype
    if ft == "bigfile" or ft == "" then
      return
    end
    local l = vim.treesitter.language.get_lang(ft)
    if l then
      local ok = pcall(vim.treesitter.start, bufnr, ft)
      if not ok then
        if processed[l] then
          return
        end
        processed[l] = true
        pcall(function()
          vim.schedule(function()
            local ts = require "nvim-treesitter"
            local installed = ts.get_installed(l)
            if type(installed) == "table" and vim.tbl_contains(installed, l) then
              return
            end
            local available = ts.get_available(2)
            if type(available) == "table" and vim.tbl_contains(available, l) then
              local result = vim.fn.confirm(
                string.format(
                  "Treesitter parser for %s is not installed. Install?", l),
                "&Yes\n&No",
                1
              )
              if result == 1 then
                ok = pcall(function() ts.install(l):wait(60000) end)
                if ok then
                  pcall(vim.treesitter.start, bufnr, ft)
                end
              end
            end
          end)
        end)
      end
    end
  end,
})
