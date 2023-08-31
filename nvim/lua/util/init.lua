--=============================================================================
-------------------------------------------------------------------------------
--                                                                         UTIL
--[[===========================================================================
Util functions
-----------------------------------------------------------------------------]]
---@class Util
local util = {}
util.__index = util

---@param opts table|string|number|nil
---@return LogUtil
function util.log(opts)
  return util.require("util.log"):new(opts) --[[ @as LogUtil ]]
end

---@param filetype string?
---@param delay number?
---@return LspUtil
function util.lsp(filetype, delay)
  return util.require("util.lsp"):new(filetype, delay) --[[ @as LspUtil ]]
end

---@return LspUtil
function util.__lsp()
  return util.require("util.lsp") --[[ @as LspUtil ]]
end

---@param opts {log_level:0|1|2|3|4}
---@return Util
function util:init(opts)
  opts = type(opts) == "table" and opts or {}
  self.log():set_level(opts.log_level)
  vim.fn.stdpath = self.stdpath
  vim.api.nvim_create_user_command("NvimSetup", function()
    for _, setup in pairs(self.setup or {}) do
      local ok, e = pcall(setup)
      if not ok then self.log():error("Error in setup:", e) end
    end
  end, {})
  return self
end

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
      util.log("Util"):warn("[require] module must be a string or table")
    end
  end
  local res = {}
  for _, m in ipairs(module) do
    local ok, v = pcall(require, m)
    if not ok then
      if not silent then
        util
          .log({ delay = 250, title = "Util" })
          :warn("[require] Error loading", m, "-", v)
      end
      return
    end
    table.insert(res, v)
  end
  if type(callback) == "function" then
    local ok, v = pcall(callback, unpack(res))
    if not ok then
      if not silent then
        util.log({ delay = 250, title = "Util" }):error("[require]", v)
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
    app_name,
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
      Util.log("Quickfix")
        :warn("There is nothing to display in the quickfix window")
    end
    if navigate_to_quickfix ~= true then vim.fn.win_gotoid(winid) end
  end
end

---A table of function called when NvimSetup is executed.
---This is usually called when building neovim, and the
---neovim may be set up with `nvim --headles +NvimSetup +qall`
---@type function[]
util.setup = {}

return util
