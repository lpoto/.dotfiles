--=============================================================================
-------------------------------------------------------------------------------
--                                                                      FOLDING
--=============================================================================
-- Fold or unfold the current context with <CR>
--_____________________________________________________________________________

local folding = {}

folding.initialized = {}

function folding.fold()
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
  if buftype:len() > 0 then
    return
  end
  if not folding.initialized[buf] then
    folding.initialized[buf] = true
    pcall(vim.api.nvim_exec, "e", true)
  end
  local ok, e = pcall(vim.api.nvim_exec, "normal! za", false)
  if not ok then
    vim.notify(e, vim.log.levels.WARN, {
      title = "Folding",
    })
  end
end

function folding.config()
  vim.opt.foldmethod = "expr" -- enable folding (default 'foldmarker')
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldlevel = 9999 -- open a file fully expanded, set to
  vim.keymap.set("n", "<CR>", folding.fold)
end

return folding
