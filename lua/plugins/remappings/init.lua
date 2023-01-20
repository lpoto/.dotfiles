--=============================================================================
-------------------------------------------------------------------------------
--                                                                   REMAPPINGS
--=============================================================================
--[[ Set the default global remappings and user commands
renaming file, scrolling popups, window managing, visual mode, jumping,
undoing breakpoints, moving text, writing,...)
-----------------------------------------------------------------------------]]

return {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "remappings" },
    "/"
  ),
  init = function()
    require "remappings"
  end,
}
