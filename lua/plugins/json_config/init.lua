--=============================================================================
-------------------------------------------------------------------------------
--                                                                  JSON_CONFIG
--=============================================================================
-- Safely source local .nvim.json files, those files should contain
-- filetype keys or a plugin key.
--_____________________________________________________________________________

local M = {
  dir = table.concat(
    { vim.fn.stdpath "config", "lua", "plugins", "json_config" },
    "/"
  ),
  event = "VeryLazy",
}

function M.config()
  require("json_config").config()
end

return M
