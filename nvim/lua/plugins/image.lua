--=============================================================================
-------------------------------------------------------------------------------
--                                                                   IMAGE.NVIM
--[[===========================================================================
https://github.com/ssamodostal/image.nvim

Display images as ASCII art in Neovim.

Requires:
  - ascii-image-converter

-----------------------------------------------------------------------------]]
local M = {
  "samodostal/image.nvim",
  dependencies = {
    { "m00qek/baleia.nvim", tag = "v1.3.0" },
  },
}

---NOTE: This plugin requires the `ascii-image-converter` command to be
---      executable. Do not load the plugin if it is not.
function M.cond()
  if vim.fn.executable "ascii-image-converter" == 1 then
    return true
  end
  Util.log(1000):warn(
    "The `ascii-image-converter` command is not executable.",
    "Please install it to use the preview images."
  )
  return false
end

M.extensions = { "png", "jpg", "jpeg", "bmp", "webp" }

function M.init()
  if not M.cond() then
    return
  end
  local id = nil
  -- Load the plugin when Telescope is loaded
  vim.api.nvim_create_autocmd("User", {
    once = true,
    pattern = "TelescopeLoaded",
    callback = function()
      pcall(vim.api.nvim_del_autocmd, id)
      M.config()
      M.telescope_setup()
    end,
  })
  -- Lazy load image.nvim, load it only when opening an image file
  id = vim.api.nvim_create_autocmd("BufRead", {
    callback = function()
      local extension = vim.fn.expand "%:p:e"
      if vim.tbl_contains(M.extensions, extension) then
        pcall(vim.api.nvim_del_autocmd, id)
        if M.config() then
          vim.api.nvim_exec_autocmds("BufRead", {
            group = "ImageOpen",
          })
        end
      end
    end,
  })
end

M.loaded = false
function M.config()
  if M.loaded then
    return false
  end
  M.loaded = true
  Util.require("image", function(image)
    image.setup {
      render = {
        background_color = true,
        foreground_color = true,
      },
    }
  end)
  return true
end

--- Telescope preview hook, which is used to display image previews
--- in Telescope. If the file's extension matches one of the supported
--- image extensions, the file is converted to ASCII art and displayed
--- in the preview window. Otherwise the normal previewer is used.
function M.__telescope_preview_hook(filepath, bufnr, opts)
  if not opts or not opts.ft or opts.ft:len() > 0 then
    return true
  end
  Util.require(
    { "image.config", "image.dimensions", "image.api", "plenary.async" },
    function(config, dimensions, api, async)
      local extension = vim.fn.fnamemodify(filepath, ":e")
      if not vim.tbl_contains(M.extensions, extension) then
        return true
      end

      local o = config.DEFAULT_OPTS

      local win_id = opts.winid
      local buf_path = filepath
      async.run(function()
        local ascii_width, ascii_height =
          dimensions.calculate_ascii_width_height(win_id, buf_path, o)

        local width = vim.api.nvim_win_get_width(win_id)
        local height = vim.api.nvim_win_get_height(win_id)
        for i = 2.5, 1.10, -0.10 do
          -- Try to fine tune the size of the ASCII art
          -- so that it fits the preview window better.
          if ascii_width * i < width and ascii_height * i < height - 1 then
            ascii_width = math.floor(ascii_width * i)
            ascii_height = math.floor(ascii_height * i)
            break
          end
        end
        local padding = math.floor((width - ascii_width) / 2)

        local label = "   " .. vim.fn.fnamemodify(filepath, ":t")

        local ascii_data =
          api.get_ascii_data(buf_path, ascii_width, ascii_height, o)
        if padding > 0 then
          for i = 1, #ascii_data do
            ascii_data[i] = string.rep(" ", padding) .. ascii_data[i]
          end
        end

        table.insert(ascii_data, 1, label)

        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, ascii_data)
      end, function() end)
    end
  )
  return false
end

function M.telescope_setup()
  Util.require("telescope", function(telescope)
    telescope.setup {
      defaults = {
        preview = {
          filetype_hook = M.__telescope_preview_hook,
        },
      },
    }
  end)
end

return M
