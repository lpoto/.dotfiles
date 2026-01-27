--=============================================================================
--                              https://github.com/eclipse-jdtls/eclipse.jdt.ls
--[[===========================================================================

JDTLS is managed by the nvim-java plugin, here we just override
default config to extend formatting settings detection.

-----------------------------------------------------------------------------]]

local jdtls = {}

local did_init = false
function jdtls.init()
  if did_init then
    return
  end
  did_init = true
  return jdtls.get_config()
end

function jdtls.get_config()
  return {
    flags = {
      debounce_text_changes = 500,
    },
    settings = {
      java = {
        import = {
          exclusions = {
            "**/node_modules/**",
            "**/.git/**",
            "**/build/**",
            "**/bin/**",
            "**/target/**",
          },
        },
        format = {
          enabled = true,
          settings = jdtls.detect_format_settings()
        },
        sources = {
          organizeImports = {
            starThreshold = 5,
            staticStarThreshold = 5,
          },
        },
        errors = {
          incompleteClasspath = {
            severity = "ignore",
          },
        },
        configuration = {
          checkProjectSettingsExclusions = false,
        },
      }
    }
  }
end

function jdtls.detect_format_settings()
  local root_dir = vim.fn.getcwd()
  local code_style_xml_files = {
    "code-style.xml",
    ".code-style.xml",
    "style.xml",
    ".style.xml",
    "formatter.xml",
    ".formatter.xml",
    "formatting.xml",
    ".formatting.xml",
    "spotless.xml",
    ".spotless.xml",
  }
  local dirs = {
    root_dir,
    vim.fs.joinpath(root_dir, ".config"),
    vim.fs.joinpath(root_dir, "config"),
    vim.fs.joinpath(vim.fn.stdpath "config", "jdtls")
  }
  for _, dir in ipairs(dirs) do
    for _, filename in ipairs(code_style_xml_files) do
      local ok, v = pcall(function()
        local filepath = vim.fs.joinpath(dir, filename)
        if vim.fn.filereadable(filepath) == 1 then
          local xml = table.concat(vim.fn.readfile(filepath), "\n")
          local profile = xml:match '<profile[^>]*name="([^"]+)"'

          if type(profile) == "string" and profile ~= "" then
            return {
              url = "file://" .. filepath,
              profile = profile,
            }
          end
        end
      end)
      if ok and type(v) == "table" then
        return v
      end
    end
  end
  return {}
end

return jdtls.init()
