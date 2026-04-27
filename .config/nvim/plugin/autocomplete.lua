--=============================================================================
--                                                               AUTOCOMPLETION
--[[===========================================================================

Autocompletion configurations, including:
- Completion options
- LSP autcompletions
- Filename completion
- Popup keymaps

-----------------------------------------------------------------------------]]

vim.opt.completeopt = "menu,menuone,noinsert,fuzzy,popup,preview"
vim.opt.pumheight = 20    -- max numbers in popup menu
vim.opt.pummaxwidth = 120 -- max popup window width
vim.opt.pumblend = 15 -- transparency of popup window
vim.opt.pumborder = "rounded"

-- navigate down with tabe when popup is shown
-- or navigate to next snippet field if exists
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 and vim.bo.buftype == "" then
    return vim.keycode "<C-n>"
  end
  if vim.snippet.active { direction = 1 } then
    return vim.snippet.jump(1)
  end
  return vim.keycode "<Tab>"
end, { expr = true, desc = "Completion next" })

-- navigate up with tab when popup is shown
-- Or navigate to previous snippet field if exists
vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 and vim.bo.buftype == "" then
    return vim.keycode "<C-p>"
  end
  if vim.snippet.active { direction = -1 } then
    return vim.snippet.jump(-1)
  end
  return vim.keycode "<S-Tab>"
end, { expr = true, desc = "Completion prev" })

-- trigger file autocompletion with /
vim.keymap.set("i", "/", function()
  if vim.bo.buftype ~= "" then
    return "/"
  end
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.keycode "<C-x><C-f>", "n", true)
  end)
  return "/"
end, { expr = true, desc = "Smart path completion" })

-- Select value in popup with Enter
--
-- If in middle of brackets, insert new line between them
-- when pressing enter
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.bo.buftype == "" then
    return vim.keycode "<C-y>"
  end
  -- NOTE: Split line when pressing enter inside brackets
  ---@diagnostic disable-next-line
  local line = vim.fn.getline "."
  local col = vim.fn.col "."
  ---@diagnostic disable-next-line
  local next = line:sub(col, col)
  if vim.tbl_contains({ "}", "]" }, next) then return "<CR><Esc>ko" end
  return "<CR>"
end, { expr = true })

-- Reopen file autocompletion when selection a file entry that ends with /
vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function()
    if vim.bo.buftype == ""
      and type(vim.v.completed_item) == "table"
      and type(vim.v.completed_item.word) == "string"
      and vim.endswith(vim.v.completed_item.word, "/") then
      vim.api.nvim_feedkeys(vim.keycode "<C-x><C-f>", "n", true)
    end
  end
})

-- Enable LSP autocompletion when lsp client attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local buffer = ev.buf
    if client and vim.bo[buffer].filetype ~= "bigfile" and vim.bo[buffer].buftype == "" then
      if client:supports_method(
          vim.lsp.protocol.Methods.textDocument_completion) then
        vim.bo[buffer].completeopt = "menu,menuone,noinsert,fuzzy,popup"
        local chars = {}
        for i = 32, 126 do
          if string.char(i) ~= "/" then
            table.insert(chars, string.char(i))
          end
        end
        client.server_capabilities.completionProvider.triggerCharacters = chars
        vim.lsp.completion.enable(true, client.id, buffer, { autotrigger = true })
        vim.keymap.set("i", "<C-Space>",
          function()
            vim.lsp.completion.get()
          end,
          { desc = "Trigger lsp completion", buffer = buffer }
        )
        vim.keymap.set("i", "<C-d>", function()
          return vim.lsp.util.scroll_docs(4)
        end, { expr = true, buffer = buffer, desc = "Scroll docs down" })

        vim.keymap.set("i", "<C-u>", function()
          return vim.lsp.util.scroll_docs(-4)
        end, { expr = true, buffer = buffer, desc = "Scroll docs up" })
      end
    end
  end
})
