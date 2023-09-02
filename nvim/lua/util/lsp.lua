local util = require("util")

---@class LspUtil
---@field filetype string?
---@field delay number?
local Lsp = {}
Lsp.__index = Lsp

function Lsp:new(filetype, delay)
  if type(filetype) ~= "string" then filetype = vim.bo.filetype end
  if type(delay) ~= "number" then delay = 50 end
  return setmetatable({
    filetype = filetype,
    delay = delay,
  }, self)
end

local log_attached = {}

---Attach the provided lsp server.
---@param ... string|table
function Lsp:attach(...)
  local filetype = self.filetype or vim.bo.filetype

  for _, server in ipairs({ select(1, ...) }) do
    if type(server) == "string" then server = {
      name = server,
    } end
    if type(server) ~= "table" then
      Util.log():warn("No server provided")
      return
    end
    if type(server.name) ~= "string" and type(server[1]) == "string" then
      server.name = server[1]
    end
    if type(server.name) ~= "string" then
      Util.log():warn("No language server name provided")
      return
    end
    server[1] = nil
    if server.capabilities == nil then
      server.capabilities = self.autocompletion_capabilities()
    end
    if server.root_dir == nil and type(server.root_patterns) == "table" then
      server.root_dir = self.root_fn(server.root_patterns)
    end
    local name = server.name

    vim.defer_fn(function()
      if self.__attach(server, filetype) == true then
        if log_attached[filetype] == nil then log_attached[filetype] = {} end
        table.insert(log_attached[filetype], name)
        vim.defer_fn(function()
          if not next(log_attached) then return end
          local s = ""
          for k, v in pairs(log_attached) do
            if s:len() > 0 then s = s .. ", " end
            s = s .. k .. ": [" .. table.concat(v, ", ") .. "]"
          end
          log_attached = {}
          util.log("Lsp"):debug("Attached:", s)
        end, 200)
      end
    end, self.delay or 50)
  end
end

---Attach the provided lsp server.
---NOTE: This should be overridden by a plugin.
---@param opts table
---@param filetype string
---@return boolean
---@diagnostic disable-next-line: unused-local
function Lsp.__attach(opts, filetype)
  util.log():warn("'lsp.attach' was not overridden")
  return false
end

---Returns an autocompletion capabilities table.
---NOTE: This should be overridden by plugins that provide autocompletion.
---@return table?
function Lsp.autocompletion_capabilities()
  -- This should be overridden by a plugin.
end

--- Return a function that tries to search upward
--- for the provided patterns and returns the first
--- matching directory containing that pattern.
--- If no match is found, return the default value or
--- the current working directory if no default is provided.
--- @param patterns string[]?
--- @param default string?
--- @param opts table?
--- @return function
function Lsp.root_fn(patterns, default, opts)
  return function()
    opts = opts or {}
    if opts.path == nil then opts.path = vim.fn.expand("%:p:h") end
    local f = nil
    if type(patterns) == "table" and next(patterns) then
      f = vim.fs.find(
        patterns,
        vim.tbl_extend("force", { upward = true }, opts)
      )
    end
    if type(f) ~= "table" or not next(f) then
      if type(default) == "string" then return default end
      return vim.fn.getcwd()
    end
    return vim.fs.dirname(f[1])
  end
end

local severity = {
  "error",
  "warn",
  "info",
  "info",
}
vim.lsp.handlers["window/showMessage"] = function(
  _,
  method,
  params,
  client_id
)
  local client = vim.lsp.get_client_by_id(client_id)
  vim.notify(method.message, severity[params.type], {
    title = (client or {}).name,
  })
end

return Lsp
