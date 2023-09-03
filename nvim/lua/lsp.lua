--=============================================================================
-------------------------------------------------------------------------------
--                                                                          LSP
--[[===========================================================================
Lsp utility functions
-----------------------------------------------------------------------------]]

---@class LspUtil
---@field filetype string?
---@field delay number?
local Lsp = {}
Lsp.__index = Lsp

local _m = {}
function _m:__call(filetype, delay)
  if type(filetype) ~= "string" then filetype = vim.bo.filetype end
  if type(delay) ~= "number" then delay = 50 end
  return setmetatable({
    filetype = filetype,
    delay = delay,
  }, Lsp)
end

setmetatable(Lsp, _m)

local logs = {}

---Attach the provided lsp server.
---@param ... string|table
function Lsp:attach(...)
  local filetype = self.filetype or vim.bo.filetype

  for _, server in ipairs({ select(1, ...) }) do
    if type(server) == "string" then server = {
      name = server,
    } end
    if type(server) ~= "table" then
      vim.notify("No server provided", "warn", "LSP")
      return
    end
    if type(server.name) ~= "string" and type(server[1]) == "string" then
      server.name = server[1]
    end
    if type(server.name) ~= "string" then
      vim.notify("No language server name provided", "warn", "LSP")
      return
    end
    server[1] = nil
    if server.capabilities == nil then
      server.capabilities = self.autocompletion_capabilities()
    end
    if server.root_dir == nil and type(server.root_patterns) == "table" then
      server.root_dir = self.root_fn(server.root_patterns)
    end
    vim.defer_fn(function()
      local t = self.__attach(server, filetype)
      if type(t) == "table" and next(t) then
        local attached = t.attached
        if type(attached) == "string" then attached = { attached } end
        if type(attached) == "table" and next(attached) then
          if logs.attached == nil then logs.attached = {} end
          for _, v in ipairs(attached) do
            table.insert(logs.attached, v)
          end
        end
        local missing = t.missing
        if type(missing) == "string" then missing = { missing } end
        if type(missing) == "table" and next(missing) then
          if logs.missing == nil then logs.missing = {} end
          for _, v in ipairs(missing) do
            table.insert(logs.missing, v)
          end
        end
        local non_executable = t.non_executable
        if type(non_executable) == "string" then
          non_executable = { non_executable }
        end
        if type(non_executable) == "table" and next(non_executable) then
          if logs.non_executable == nil then logs.non_executable = {} end
          for _, v in ipairs(non_executable) do
            table.insert(logs.non_executable, v)
          end
        end
        vim.defer_fn(function()
          if not next(logs) then return end
          local l = "info"
          local s = ""
          if next(logs.attached or {}) then
            s = "Attached: [" .. table.concat(logs.attached, ", ") .. "]"
          end
          if next(logs.non_executable or {}) then
            if s:len() > 0 then s = s .. ", " end
            s = s
              .. "No executables found for: ["
              .. table.concat(logs.non_executable, ", ")
              .. "]"
            l = "warn"
          end
          if next(logs.missing or {}) then
            if s:len() > 0 then s = s .. ", " end
            s = s
              .. "No server/linter/formatter found for: ["
              .. table.concat(logs.missing, ", ")
              .. "]"
            l = "warn"
          end
          if s:len() > 0 then vim.notify(s, l, "LSP") end
          logs = {}
        end, 300)
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
  vim.notify("'lsp.attach' was not overridden", "warn")
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

return Lsp
