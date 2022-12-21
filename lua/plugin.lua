--=============================================================================
-------------------------------------------------------------------------------
--                                                                       PLUGIN
--=============================================================================
--  A Plugin object that stores plugin configs that are parsed by Packer.nvim.
--  This allows dynamic definition of plugins, adding configs and disabling
--  the plugins.
--  NOTE: Once the plugin is loaded, it may not be disabled. Configs and may
--  actions may still be added though.
--_____________________________________________________________________________

local log = require "log"

---@class Plugin
---@field __packer table
---@field __meta table
---@field __actions table
local Plugin = {}
Plugin.__index = Plugin

local plugins = {}

---Run the packer.nvim's use function on all the
---enabled plugins.
---
---@param use function: Packer.nvim's use function
function Plugin.use(use)
  local ok, e = pcall(function()
    for _, plugin in pairs(plugins) do
      if plugin.__meta.disabled ~= true then
        use(plugin.__packer)
      end
    end
  end)
  if ok == false then
    log.warn("Failed to load plugins: " .. e)
  end
end

---Create a new plugin with the packer.nvim's config.
---Not the `as` field should always be set.
---
---@return table: Packer.nvim's config table.
function Plugin.new(o)
  local plugin = {
    __packer = {},
    __meta = {},
    __actions = {},
  }
  setmetatable(plugin, Plugin)

  local ok, e = pcall(function()
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
          for _, config in ipairs(pl.__meta.configs) do
            local ok2, e = pcall(config, name)
            if ok2 == false then
              l.warn(e)
            end
          end
          pl.__meta = nil
        end
      else
        plugin.__packer[k] = v
      end
    end
  end)
  if ok == false then
    log.warn("Failed to create plugin: " .. e)
  end
  return plugin
end

---Returns true if a plugin identified with the
---provided name exists, false otherwise.
---
---@param name string
---@return boolean
function Plugin.exists(name)
  return plugins[name] ~= nil
end

---Get the plugin identified by the provided name.
---The name should match the `as` field in the config.
---
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
---If the plugin is already loaded, the function will be called
---immediately.
---
---@param f function: Config function
function Plugin:config(f)
  if package.loaded[self.__packer.as] then
    f()
    return
  end
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
  self.__actions[key] = f
end

---Run the action identified by the provided key.
---Action should be first added with `Plugin:action(key, f)`.
---
---@param key string: Action's key
function Plugin:run(key, ...)
  if self.__actions[key] then
    self.__actions[key](...)
  end
end

---Disable the plugin.
---The plugin then won't be passed to Packer.nvim.
function Plugin:disable()
  if not self.__meta then
    self.__meta = {}
  end
  self.__meta.disabled = true
end

return Plugin
