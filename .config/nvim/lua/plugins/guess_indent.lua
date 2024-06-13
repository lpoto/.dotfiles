--=============================================================================
--                                      https://github.com/NMAC427/guess-indent
--=============================================================================

return {
  "NMAC427/guess-indent.nvim",
  event = { "BufRead", "BufNewFile", "BufNew" },
  opts = {
    auto_cmd = true,
    override_editorconfig = false,
  },
}
