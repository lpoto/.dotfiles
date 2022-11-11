--=============================================================================
-------------------------------------------------------------------------------
--                                                               FORMATTER.NVIM
--=============================================================================
-- https://github.com/mhartington/formatter.nvim
--_____________________________________________________________________________

local setups = {}

local formatter = {}

---Keymaps used to format
formatter.keymaps = { "<leader>f" }

---Commands used to format
formatter.commands =
  { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" }

---Format on save, remove trailing whitespace when formatter is not set
---@param autocmd boolean?: when true, format on save
function formatter.setup(autocmd)
  require("formatter").setup {
    logging = true,
    log_level = vim.log.levels.INFO,
    filetype = {
      ["*"] = {
        require("formatter.filetypes.any").remove_trailing_whitespace,
      },
    },
  }
  if autocmd == true then
    vim.api.nvim_create_augroup("FormatAutoGroup", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      group = "FormatAutoGroup",
      command = "FormatWriteLock",
    })
  end
  for _, config in ipairs(setups) do
    require("formatter").setup(config)
  end
  formatter.remappings()
end

-- format with "<leader>f""
function formatter.remappings()
  vim.api.nvim_set_keymap(
    "n",
    formatter.keymaps[1],
    "<cmd>FormatWriteLock<CR>",
    {
      noremap = true,
    }
  )
end

---add a setup call to a table instead of calling it
---immediately, so it may be lazy loaded. If the plugin
---has already been loaded, call it instead.
---@param config table: formatter config
local function add_setup(config)
  if package.loaded["formatter"] ~= nil then
    require("formatter").setup(config)
    return
  end
  table.insert(setups, config)
end

local distinct_setups = {}

---Create a distinct setup, identifies by the provided key.
---Once this is called, calling it again with the same key will
---be a no-op, unless override is true.
---
---NOTE: this is useful for setting local configs and ignoring
---the default distinct configs.
---
---@param key string: A string to identify the setup
---@param config table: A formatter config
---@param override boolean?: Override existing config.
function formatter.distinct_setup(key, config, override)
  if override ~= true and distinct_setups[key] ~= nil then
    return
  end
  add_setup(config)

  distinct_setups[key] = true
end

return formatter
