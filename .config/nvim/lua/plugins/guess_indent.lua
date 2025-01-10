--=============================================================================
--                                      https://github.com/NMAC427/guess-indent
--=============================================================================

return {
  "NMAC427/guess-indent.nvim",
  commit = "6cd61f7",
  event = { "BufRead", "BufNewFile", "BufNew" },
  opts = {
    auto_cmd = true,
    override_editorconfig = false,
  },
}
