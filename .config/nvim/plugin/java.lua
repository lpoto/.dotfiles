--=============================================================================
--                                                                         JAVA
--[[===========================================================================

This file is responsible for setting up Java development environment
in Neovim, using the java plugin. This uses JDTLS, that is mostly configured
by the Java plugin, but has additional config in lsp/jdtls.lua.

On top of managing JDTLS, this also adds some features like running, testing
or debugging Java applications.

NOTE: Integrates with spur.nvim plugin, and registers debug actions as
spur jobs (Ex. when spring boot app is found, a job for starting that
applications with a debugger will be added to spur manager).


Relevant commands:
- :Java*

-----------------------------------------------------------------------------]]

vim.pack.add {
  {
    src = "https://github.com/MunifTanjim/nui.nvim",
    version = "0.4.0",
  },
  {
    src = "https://github.com/nvim-java/nvim-java",
    version = "v4.1.0",
  }
}

local register_dap_spur_actions
vim.api.nvim_create_autocmd({ "FileType" }, {
  once = true,
  pattern = { "java" },
  callback = function()
    require "java".setup {
      jdk = {
        auto_install = false,
      },
      lombok = {
        enable = true,
      },
      java_debug_adapter = {
        enable = true,
      },
      java_test = {
        enable = false,
      },
      spring_boot_tools = {
        enable = false,
      },
    }
    --- NOTE: Try to register any found java jobs to spur
    --- manager after a delay, with increasing backoff,
    --- as it might take awhile for jdtls to starts
    --- and provide the debug configurations in larger projects.
    vim.defer_fn(register_dap_spur_actions, 500)
  end
})

local did_register = false
function register_dap_spur_actions(retries)
  retries = retries or 20
  if retries <= 0 then
    return
  end
  local defer = 500
  if retries <= 20 then
    defer = defer + (500 * (20 - retries))
  end
  vim.schedule(function()
    if did_register then
      return
    end
    local ok, dap = pcall(require, "dap")
    if not ok then
      return
    end
    local manager
    ok, manager = pcall(require, "spur.manager")
    if not ok then
      return
    end
    local conf = dap.configurations
    local adapters = dap.adapters
    if type(conf) ~= "table"
      or type(conf.java) ~= "table"
      or #conf.java == 0
      or type(adapters) ~= "table"
      or type(adapters.java) ~= "function"
    then
      vim.defer_fn(
        function() register_dap_spur_actions(retries - 1) end,
        defer)
      return
    end
    if did_register then
      return
    end
    did_register = true
    local java_configs_dup = conf.java
    local java_configs = {}
    for _, c in ipairs(java_configs_dup) do
      local is_dup = false
      for _, existing in ipairs(java_configs) do
        if vim.deep_equal(conf, existing) then
          is_dup = true
          break
        end
      end
      if not is_dup then
        if type(c) == "table"
          ---@diagnostic disable-next-line
          and type(c.projectName) == "string"
          ---@diagnostic disable-next-line
          and not c.projectName:lower():find "pronet"
        then
          table.insert(java_configs, c)
        end
      end
    end
    table.sort(java_configs, function(a, b)
      local pa = type(a.projectName) == "string" and a.projectName or ""
      local pb = type(b.projectName) == "string" and b.projectName or ""
      local na = type(a.name) == "string" and a.name or ""
      local nb = type(b.name) == "string" and b.name or ""
      if pa:lower():find "pharmacy" and not pb:lower():find "pharmacy" then
        return true
      end
      if pb:lower():find "pharmacy" and not pa:lower():find "pharmacy" then
        return false
      end
      if pa:len() == pb:len() then
        return na:len() < nb:len()
      end
      return pa:len() < pb:len()
    end)
    local order = 1
    for _, c in ipairs(java_configs) do
      local job = {
        order = order,
        job = {
          cmd = "dap",
        },
        dap = {
          configuration = c,
        }
      }
      order = order + 1
      manager.add_job(job)
    end
  end)
end
