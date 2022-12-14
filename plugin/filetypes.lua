--=============================================================================
-------------------------------------------------------------------------------
--                                                                    FILETYPES
--=============================================================================
-- Creates an autocomand that sources the matching file in lua/filetypes
-- when a filetypes is opened for the first time.

vim.api.nvim_create_autocmd("FileType",  {
    callback = function()
        local filetype = vim.bo.filetype
        if package.loaded["filetypes."..filetype] then
            return
        end
        local ok, _ = pcall(require, "filetypes." .. filetype)
        if ok == false then
        package.loaded["filetypes."..filetype] = {}
    end
    end
})
