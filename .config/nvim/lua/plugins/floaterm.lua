--=============================================================================
-------------------------------------------------------------------------------
--                                                                     FLOATERM
--[[___________________________________________________________________________
https://github.com/voldikss/vim-floaterm
-----------------------------------------------------------------------------]]
local M = {
  "voldikss/vim-floaterm",
  cmd = { "FloatermNew", "FloatermShow", "FloatermToggle" },
}

M.keys = {
  {
    "<C-t>",
    function()
      vim.cmd "FloatermToggle"
    end,
    mode = "n",
  },
}

function M.init()
  vim.g.floaterm_wintype = "vsplit"
  vim.g.floaterm_opener = "vsplit"
  vim.g.floaterm_autoinsert = false
  vim.g.floaterm_width = 0.5
end

function M.floaterm_prompt_command(name, prompt, suffix)
  suffix = vim.fn.input {
    prompt = prompt,
    default = suffix,
    cancelreturn = false,
  }
  if type(suffix) ~= "string" then
    return
  end
  M.floaterm_command(name, prompt .. suffix)
end

function M.floaterm_command(name, cmd)
  pcall(vim.api.nvim_exec, "FloatermKill --name=" .. name, true)
  vim.cmd("FloatermNew --name=" .. name)
  vim.cmd("FloatermSend " .. cmd)
end

return M
