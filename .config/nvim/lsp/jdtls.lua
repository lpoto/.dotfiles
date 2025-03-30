--=============================================================================
--                              https://github.com/eclipse-jdtls/eclipse.jdt.ls
--[[===========================================================================

MasonInstall jdtls

-----------------------------------------------------------------------------]]

local jdtls = { cache = {} }

local util = {}

local base_config = {
  cmd = { "jdtls" },
  workspace_required = false,
  filetypes = {
    "java",
  },
  root_markers = {
    "settings.gradle",
    "settings.gradle.kts",
    "pom.xml",
    "build.gradle",
    "mvnw",
    "gradlew",
    "build.gradle",
    "build.gradle.kts",
    ".git",
  },
}

function jdtls.init()
  local config = jdtls.get_config()
  -- init an autocommand that decompiles a class file,
  -- so we may go to definition of external classes
  jdtls.init_decompile_autocmd()
  return config
end

function jdtls.get_config()
  local config = vim.tbl_extend("force", {}, base_config)
  config.cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dosgi.checkConfiguration=true",
    "-Dosgi.sharedConfiguration.area=" .. jdtls.find_jdtls_config_dir(),
    "-Dosgi.sharedConfiguration.area.readOnly=true",
    "-Dosgi.configuration.cascaded=true",
    "-Xms1G",
    "--add-modules=ALL-SYSTEM",

    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",

    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    "-javaagent:" .. jdtls.find_lombok_path(),

    "-jar",
    jdtls.find_equinox_launcher(),

    "-configuration",
    jdtls.get_config_path(),

    "-data",
    jdtls.get_workspace_path(),
  }
  config.single_file_support = true
  config.root_dir = util.find_root(config.root_markers)

  config.init_options = {
    jvm_args = { "-Djdt.ls.classFileContentsSupport=true" },
    extendedClientCapabilities = {
      actionableRuntimeNotificationSupport = true,
      advancedExtractRefactoringSupport = true,
      advancedGenerateAccessorsSupport = true,
      advancedIntroduceParameterRefactoringSupport = true,
      advancedOrganizeImportsSupport = true,
      advancedUpgradeGradleSupport = true,
      classFileContentsSupport = true,
      clientDocumentSymbolProvider = true,
      -- Setting this to true seems to disable hover support
      --clientHoverProvider = true,
      executeClientCommandSupport = true,
      extractInterfaceSupport = true,
      generateConstructorsPromptSupport = true,
      generateDelegateMethodsPromptSupport = true,
      generateToStringPromptSupport = true,
      gradleChecksumWrapperPromptSupport = true,
      hashCodeEqualsPromptSupport = true,
      inferSelectionSupport = {
        "extractConstant",
        "extractField",
        "extractInterface",
        "extractMethod",
        "extractVariableAllOccurrence",
        "extractVariable",
      },
      moveRefactoringSupport = true,
      onCompletionItemSelectedCommand = "editor.action.triggerParameterHints",
      overrideMethodsPromptSupport = true,
    },
    workspace = jdtls.get_workspace_path(),
  }

  return config
end

function jdtls.init_decompile_autocmd()
  local group = vim.api.nvim_create_augroup("JdtlsDecompile", { clear = true })
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "jdt://*",
    group = group,
    callback = function(opts)
      local async = util.async
      local done = false
      async.sync(function()
        local client = jdtls.get_jdtls_client()
        local buffer = opts.buf
        local text = jdtls.java_decompile(client, opts.file)
        local lines = vim.split(text, "\n")
        vim.bo[buffer].modifiable = true
        vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
        vim.bo[buffer].swapfile = false
        vim.bo[buffer].filetype = "java"
        vim.bo[buffer].modifiable = false
        if not vim.lsp.buf_is_attached(buffer, client.id) then
          vim.lsp.buf_attach_client(buffer, client.id)
        end
        done = true
      end)
      vim.wait(10000, function() return done end)
    end,
  })
end

function jdtls.find_equinox_launcher()
  if jdtls.cache.__equinox_launcher_jar ~= nil then
    return jdtls.cache.__equinox_launcher_jar
  end
  local plugins_dir = jdtls.get_jdtls_root() .. "/plugins"
  local launcher_path = plugins_dir .. "/org.eclipse.equinox.launcher.jar"
  if vim.fn.filereadable(launcher_path) == 1 then return launcher_path end
  local files = vim.fn.glob(
    plugins_dir .. "/org.eclipse.equinox.launcher_*.jar",
    false,
    true
  )
  for _, file in ipairs(files) do
    jdtls.cache.__equinox_launcher_jar = file
    return file
  end
  error "Cannot find equinox launcher"
end

function jdtls.get_jdtls_root()
  if jdtls.cache.__jdtls_root ~= nil then return jdtls.cache.__jdtls_root end
  jdtls.cache.__jdtls_root = jdtls.get_mason_packages_root() .. "/jdtls"
  return jdtls.cache.__jdtls_root
end

function jdtls.find_lombok_path()
  if jdtls.cache.__lombok_jar ~= nil then return jdtls.cache.__lombok_jar end
  local mason_packages = jdtls.get_mason_packages_root()
  local lombok_path = mason_packages .. "/lombok-nightly/lombok.jar"

  if vim.fn.filereadable(lombok_path) == 1 then
    jdtls.cache.__lombok_jar = lombok_path
    return jdtls.cache.__lombok_jar
  end
  local jdtls_root = jdtls.get_jdtls_root()
  lombok_path = jdtls_root .. "/lombok.jar"
  if vim.fn.filereadable(lombok_path) == 1 then
    jdtls.cache.__lombok_jar = lombok_path
    return jdtls.cache.__lombok_jar
  end
  error "Cannot find lombok jar"
end

function jdtls.find_jdtls_config_dir()
  if jdtls.cache.__jdtls_config_dir ~= nil then
    return jdtls.cache.__jdtls_config_dir
  end
  local jdtls_root = jdtls.get_jdtls_root()
  local jdtls_config = jdtls_root .. "/config"
  if vim.fn.isdirectory(jdtls_config) == 1 then
    jdtls.cache.__jdtls_config_dir = jdtls_config
    return jdtls.cache.__jdtls_config_dir
  end
  jdtls_config = jdtls_root .. "/config_mac"
  if vim.fn.isdirectory(jdtls_config) == 1 then
    jdtls.cache.__jdtls_config_dir = jdtls_config
    return jdtls.cache.__jdtls_config_dir
  end
  error "Cannot find jdtls config directory"
end

function jdtls.get_mason_packages_root()
  if jdtls.cache.__mason_root ~= nil then return jdtls.cache.__mason_root end
  jdtls.cache.__mason_root = vim.fn.stdpath "data" .. "/mason/packages"
  return jdtls.cache.__mason_root
end

function jdtls.get_config_path()
  if jdtls.cache.__config_path ~= nil then return jdtls.cache.__config_path end
  jdtls.cache.__config_path = vim.fn.stdpath "cache" .. "/jdtls/config"
  return jdtls.cache.__config_path
end

function jdtls.get_workspace_path()
  if jdtls.cache.__workspace_path ~= nil then
    return jdtls.cache.__workspace_path
  end
  local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
  local project_path_hash = string.gsub(project_path, "[/\\:+-]", "_")

  local nvim_cache_path = vim.fn.stdpath "cache"
  jdtls.cache.__workspace_path = nvim_cache_path
    .. "/jdtls/workspaces/"
    .. project_path_hash
  return jdtls.cache.__workspace_path
end

function jdtls.get_jdtls_client()
  local clients = vim.lsp.get_clients { name = "jdtls" }
  if #clients == 0 then error "could not find an active jdtls client" end

  return clients[1]
end

function jdtls.workspace_execute_command(client, command, params, buffer)
  local async = util.async
  return async.execute_lsp_client_request(client, "workspace/executeCommand", {
    command = command,
    arguments = params,
  }, buffer)
end

function jdtls.java_decompile(client, uri)
  return jdtls.workspace_execute_command(client, "java.decompile", { uri })
end

local async = {}

util.async = async

function util.find_root(root_markers)
  local cwd = vim.fn.getcwd()
  for _, marker in ipairs(root_markers) do
    if
      vim.fn.filereadable(cwd .. "/" .. marker) == 1
      or vim.fn.isdirectory(cwd .. "/" .. marker) == 1
    then
      return cwd
    end
  end
  local found = vim.fs.find(
    root_markers,
    { upward = true, path = cwd, stop = os.getenv "$HOME", limit = 1 }
  )
  return found[1] and vim.fs.dirname(found[1]) or cwd
end

function async.execute_lsp_client_request(client, method, params, buffer)
  return async.await(function(callback)
    local on_response = function(err, result) callback(err, result) end
    return client.request(method, params, on_response, buffer)
  end)
end

function async.await(defer)
  local err, value = coroutine.yield(defer)
  if err then error(err) end
  return value
end

function async.sync(func)
  local error_handler = nil
  return async.wrap(function(handler, parent_handler_callback)
    assert(type(handler) == "function", "type error :: expected func")
    local thread = coroutine.create(handler)
    local step = nil

    step = function(...)
      local ok, thunk = coroutine.resume(thread, ...)
      if not ok then
        if error_handler then
          error_handler(thunk)
          return
        end
        if parent_handler_callback then
          parent_handler_callback(thunk)
          return
        end
        error("unhandled error " .. tostring(thunk))
      end
      assert(ok, thunk)
      if coroutine.status(thread) == "dead" then
        if parent_handler_callback then parent_handler_callback(thunk) end
      else
        thunk(step)
      end
    end
    step()
  end)(func)()
end

function async.wrap(func)
  assert(type(func) == "function", "type error :: expected func")
  local factory = function(...)
    local params = { ... }
    local thunk = function(step)
      table.insert(params, step)
      return func(unpack(params))
    end
    return thunk
  end
  return factory
end

function async.run_command(cmd)
  local co = coroutine.running()

  local stdout = {}
  local stderr = {}
  local exit_code = nil

  local jobid = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      data = table.concat(data, "\n")
      if #data > 0 then stdout[#stdout + 1] = data end
    end,
    on_stderr = function(_, data, _)
      stderr[#stderr + 1] = table.concat(data, "\n")
    end,
    on_exit = function(_, code, _)
      exit_code = code
      coroutine.resume(co)
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
  if jobid <= 0 then
    vim.notify(("unable to run cmd: %s"):format(cmd), vim.log.levels.WARN)
    return nil
  end
  coroutine.yield()
  if exit_code ~= 0 then
    vim.notify(
      ("cmd failed with code %d: %s\n%s"):format(
        exit_code,
        cmd,
        table.concat(stderr, "")
      ),
      vim.log.levels.WARN
    )
    return nil
  end

  if next(stdout) == nil then return nil end
  return stdout and stdout or nil
end

return jdtls.init()
