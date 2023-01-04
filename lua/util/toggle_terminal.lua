--=============================================================================
-------------------------------------------------------------------------------
--                                                              TOGGLE TERMINAL
--=============================================================================

return function()
  if
    vim.g.term_toggle_buf and vim.api.nvim_buf_is_valid(vim.g.term_toggle_buf)
  then
    local winid = vim.fn.bufwinid(vim.g.term_toggle_buf)
    if winid and winid ~= -1 then
      vim.api.nvim_buf_call(vim.g.term_toggle_buf, function()
        local ok, e = pcall(vim.api.nvim_exec, "hide", false)
        if ok == false then
          vim.notify(e, vim.log.levels.ERROR)
        end
      end)
      return
    end

    local ok, e = pcall(vim.api.nvim_exec, "keepjumps vertical new", false)
    if ok == false then
      vim.notify(e, vim.log.levels.ERROR)
      return
    end
    ok, e = pcall(
      vim.api.nvim_exec,
      "keepjumps buf " .. vim.g.term_toggle_buf,
      false
    )
    if ok == false then
      vim.notify(e, vim.log.levels.ERROR)
    end
    return
  end

  local ok, e = pcall(vim.api.nvim_exec, "keepjumps vertical new", false)
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
    return
  end

  ok, e = pcall(vim.api.nvim_exec, "terminal", false)
  if ok == false then
    vim.notify(e, vim.log.levels.ERROR)
  end

  vim.g.term_toggle_buf = vim.fn.bufnr()
end
