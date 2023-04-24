--=============================================================================
-------------------------------------------------------------------------------
--                                                               NVIM-UNCEPTION
--[[___________________________________________________________________________
https://github.com/samjwill/nvim-unception
-------------------------------------------------------------------------------
Open files from neovim's terminal emulator without nesting sessions
------------------------------------------------------------------------------]]
local M = {
  "samjwill/nvim-unception",
  event = "VeryLazy",
}

function M.init()
  vim.g.unception_block_while_host_edits = true
  vim.g.unception_enable_flavor_text = false
end

function M.config()
  vim.api.nvim_create_autocmd("User", {
    pattern = "UnceptionEditRequestReceived",
    callback = function()
      vim.schedule(function()
        if vim.bo.buftype ~= "" or vim.bo.filetype:match "^git" then
          vim.bo.bufhidden = "wipe"
          vim.bo.swapfile = false
        end
      end)
    end,
  })
end

---@param cmd string
function M.run_command(cmd)
  local new_tab = true
  if vim.b.terminal_job_id then
    local r = vim.fn.jobwait({ vim.b.terminal_job_id }, 0)
    local _, n = next(r)
    if n == -3 then
      new_tab = false
    end
  end
  vim.schedule(function()
    local ok, e = pcall(function()
      if new_tab then
        vim.api.nvim_exec("keepjumps tabnew", false)
      else
        vim.api.nvim_buf_set_option(0, "modified", false)
      end
      vim.fn.termopen(cmd, {
        detach = true,
        env = {
          VISUAL = "nvim",
          EDITOR = "nvim",
        },
      })
    end)
    if not ok and type(e) == "string" then
      vim.notify(e, vim.log.levels.WARN, {
        title = "Terminal Command",
      })
    end
  end)
end

function M.run_command_with_prompt(cmd, suffix)
  suffix = vim.fn.input {
    prompt = cmd,
    default = suffix,
    cancelreturn = false,
  }
  if type(suffix) ~= "string" then
    return
  end
  M.run_command(cmd .. " " .. suffix)
end

return M
