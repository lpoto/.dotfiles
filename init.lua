--=============================================================================
-------------------------------------------------------------------------------
--                                                                         INIT
--=============================================================================
local util = require "config.util"

----------------------------------------------------------- Load custom options
util.require "config.options"
----------------------------------------------------------- Load custom keymaps
util.require "config.keymaps"
------------------------------------------------------ Load custom autocommands
util.require "config.autocommands"
---------------------------------------------------------- Source local configs
util.require "config.local_config"
----------------------------------------------- Load the plugins with lazy.nvim
util.require "config.lazy"
--------------------------------------------- Load automatic session management
util.require "config.sessions"
