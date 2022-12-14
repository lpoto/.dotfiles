local log = require "log"

local plugins = {}

---@class Plugin
---@field __packer table
---@field __meta table
local Plugin = {}
Plugin.__index = Plugin

---@param use function: Packer.nvim's use function
function Plugin.use(use)
  for _, plugin in pairs(plugins) do
    use(plugin.__packer)
  end
end

---@return Plugin
function Plugin.new(o)
  local plugin = {
    __packer = {},
    __meta = {
      actions = {},
    },
  }
  setmetatable(plugin, Plugin)

  if type(o[1]) ~= "string" then
    log.warn "Plugin:new: plugin name not provided"
    return plugin
  end
  if o.as == nil then
    log.warn "Plugin:new: `as` field not provided"
    return plugin
  end
  plugins[o.as] = plugin

  plugin.__meta.configs = { o.config }

  for k, v in pairs(o) do
    if k == "config" then
      plugin.__packer.config = function(name)
        local l = require "log"

        local ok, plugin_module = pcall(require, "plugin")
        if ok == false then
          l.warn "'plugin' module not found"
          return
        end

        local pl = plugin_module.get(name)

        if pl.__meta == nil or pl.__meta.configs == nil then
          return
        end
        local module
        ok, module = pcall(require, name)
        if ok == false then
          l.warn("plugin module not found: " .. name)
          return
        end
        for _, config in ipairs(pl.__meta.configs) do
          local e
          ok, e = pcall(config, module)
          if ok == false then
            l.warn(e)
          end
        end
        pl.__meta = nil
      end
    else
      plugin.__packer[k] = v
    end
  end
  return plugin
end

---@param name string
---@return Plugin
function Plugin.get(name)
  if plugins[name] then
    return plugins[name]
  end
  log.warn("Plugin not found: " .. name)
  return {}
end

---Functions added with this method will
---be called after the plugin is loaded, alongside
---the config function added when defining the plugin.
---
---@param f function: Config function
function Plugin:config(f)
  if self.__meta.configs == nil then
    self.__meta.configs = {}
  end
  table.insert(self.__meta.configs, f)
end

---Add an action to the plugin, call it with `Plugin:run(key)`.
---
---@param key string: Key to identify the action by
---@param f function: The action's function
function Plugin:action(key, f)
  self.__meta.actions[key] = f
end

---Run the action identified by the provided key.
---Action should be first added with `Plugin:action(key, f)`.
---
---@param key string: Action's key
function Plugin:run(key, ...)
  if self.__meta.actions[key] then
    self.__meta.actions[key](...)
  end
end

return Plugin
