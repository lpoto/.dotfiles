--=============================================================================
-------------------------------------------------------------------------------
--                                                  TELESCOPE-FILE_BROWSER.NVIM
--[[===========================================================================
https://github.com/nvim-telescope/telescope-file-browser.nvim

Keymaps:
 - "<leader>b"   - file browser relative to current file
 - "<leader>B"   - file browser relative to current directory

-----------------------------------------------------------------------------]]

local M = {
  "nvim-telescope/telescope-file-browser.nvim",
}

local function file_browser()
  require("telescope").extensions.file_browser.file_browser()
end

local function relative_file_browser()
  require("telescope").extensions.file_browser.file_browser({
    path = "%:p:h",
    prompt_title = "File Browser (Relative)",
  })
end

M.keys = {
  { "<leader>b", relative_file_browser, mode = "n" },
  { "<leader>B", file_browser, mode = "n" },
}

function M.init()
  local id
  id = vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(_)
      if
        vim.bo.filetype ~= ""
        or vim.bo.buftype ~= "" and vim.bo.buftype ~= "nofile"
        or vim.fn.isdirectory(vim.fn.expand("%:p")) ~= 1
      then
        return
      end
      pcall(vim.api.nvim_del_autocmd, id)
      relative_file_browser()
    end,
  })
end

function M.config()
  local ok, telescope = pcall(require, "telescope")
  if not ok then return end
  telescope.setup({
    extensions = {
      file_browser = {
        --theme = "ivy",
        hidden = true,
        initial_mode = "normal",
        hijack_netrw = true,
        no_ignore = true,
        grouped = true,
        file_ignore_patterns = {},
        dir_icon = "",
        respect_gitignore = false,
      },
    },
  })

  telescope.load_extension("file_browser")
end

return M
