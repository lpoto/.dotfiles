--=============================================================================
-------------------------------------------------------------------------------
--                                                                 NULL-LS.NVIM
--[[===========================================================================
https://github.com/nvimtools/none-ls.nvim
-----------------------------------------------------------------------------]]

local M = {
  "nvimtools/none-ls.nvim",
}

local init_null_ls
vim.lsp.add_attach_condition({
  priority = 25,
  fn = function(opts)
    local null_ls = require("null-ls")
    local source = nil
    for _, k in ipairs({ "formatting", "diagnostics", "completion" }) do
      source = null_ls.builtins[k][opts.name]
      if source then break end
    end
    if not source then return {
      missing = { opts.name },
    } end
    require("null-ls.sources").register({
      sources = { source },
    })
    init_null_ls()
    return { attached = { opts.name } }
  end,
})

local did_init = false
function init_null_ls()
  if did_init then return end
  did_init = true
  vim.api.nvim_create_autocmd("Filetype", {
    callback = function(opts)
      vim.defer_fn(function()
        if
          type(opts) ~= "table"
          or type(opts.match) ~= "string"
          or type(opts.buf) ~= "number"
        then
          return
        end
        local client_id = require("null-ls.client").get_id()
        if type(client_id) ~= "number" then return end
        local a = require("null-ls.sources").get_filetypes()
        if not vim.tbl_contains(a, opts.match) then return end
        vim.lsp.buf_attach_client(opts.buf, client_id)
      end, 10)
    end,
  })
end

return M
