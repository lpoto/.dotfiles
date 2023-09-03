--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]

---@class Util
local util = {}
util.__index = util

--- catch errors from require and display them in a notification,
--- so multiple modules may be loaded even if one fails
---
--- Callback will be called only if all modules are loaded successfully.
---
--- @param module string|table
--- @param callback function?
--- @param silent boolean?
function util.require(module, callback, silent)
  if type(module) == "string" then
    module = { module }
  elseif type(module) ~= "table" then
    if not silent then
      vim.notify(
        "[require] module must be a string or table",
        vim.log.levels.WARN,
        { title = "Util" }
      )
    end
  end
  local res = {}
  for _, m in ipairs(module) do
    local ok, v = pcall(require, m)
    if not ok then
      if not silent then
        vim.notify(
          "[require] Error loading " .. m .. " - " .. v,
          vim.log.levels.WARN,
          { title = "Util", delay = 250 }
        )
      end
      return
    end
    table.insert(res, v)
  end
  if type(callback) == "function" then
    local ok, v = pcall(callback, unpack(res))
    if not ok then
      if not silent then
        vim.notify("[require] " .. v, "warn", { title = "Util", delay = 250 })
      end
      return
    end
    return v
  end
  return unpack(res)
end

local stdpath = vim.fn.stdpath
---@param what string
---@return string|table
function util.stdpath(what)
  local app_name = os.getenv("NVIM_APPNAME")
  if type(app_name) ~= "string" or app_name:len() == 0 then
    app_name = "nvim"
  end
  local base = vim.fs.dirname(stdpath("config"))
  local storage = base .. "/.storage"

  local n = {
    config = base .. "/" .. app_name,
    cache = storage .. "/cache/" .. app_name,
    data = storage .. "/share/" .. app_name,
    log = storage .. "/log/" .. app_name,
    run = storage .. "/state/" .. app_name,
    state = storage .. "/state/" .. app_name,
    config_dirs = {},
    data_dirs = {},
  }
  return n[what] or stdpath(what)
end

---Toggle quickfix window
---@param navigate_to_quickfix boolean?: Navigate to quickfix window after opening it
---@param open_only boolean?: Do not close quickfix if already open
function util.toggle_quickfix(navigate_to_quickfix, open_only)
  if
    #vim.tbl_filter(
      function(winid)
        return vim.api.nvim_buf_get_option(
          vim.api.nvim_win_get_buf(winid),
          "buftype"
        ) == "quickfix"
      end,
      vim.api.nvim_list_wins()
    ) > 0
  then
    if open_only ~= true then vim.api.nvim_exec2("cclose", {}) end
  else
    local winid = vim.api.nvim_get_current_win()
    vim.api.nvim_exec2("noautocmd keepjumps copen", {})
    if
      #vim.tbl_filter(
        function(l) return #l > 0 end,
        vim.api.nvim_buf_get_lines(0, 0, -1, false)
      ) == 0
    then
      vim.api.nvim_exec2("cclose", {})
      navigate_to_quickfix = true
      vim.notify(
        "There is nothing to display in the quickfix window",
        vim.log.levels.WARN,
        { title = "Quickfix" }
      )
    end
    if navigate_to_quickfix ~= true then vim.fn.win_gotoid(winid) end
  end
end

---A table of function called when NvimSetup is executed.
---This is usually called when building neovim, and the
---neovim may be set up with `nvim --headles +NvimSetup +qall`
---@type function[]
util.setup = {}

vim.fn.stdpath = util.stdpath
vim.api.nvim_create_user_command("NvimSetup", function()
  for _, setup in pairs(util.setup or {}) do
    local ok, e = pcall(setup)
    if not ok then
      vim.notify("Error in setup: " .. e, vim.log.levels.ERROR)
    end
  end
end, {})

return util
