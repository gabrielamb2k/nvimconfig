-- ~/.config/nvim/ftplugin/java.lua

local jdtls = require("jdtls")
local home = os.getenv("HOME")

-- Verificar se o JDTLS está instalado
local mason_jdtls = home .. "/.local/share/nvim/mason/bin/jdtls"
if vim.fn.executable(mason_jdtls) ~= 1 then
  vim.notify("JDTLS não encontrado. Instale com :MasonInstall jdtls", vim.log.levels.ERROR)
  return
end

-- Configurar paths importantes
local path_to_mason_packages = home .. "/.local/share/nvim/mason/packages"
local path_to_jdtls = path_to_mason_packages .. "/jdtls"
local path_to_config = path_to_jdtls .. "/config_linux"

-- Verificar se o diretório de configuração existe
if vim.fn.isdirectory(path_to_config) ~= 1 then
  vim.notify("Diretório de configuração JDTLS não encontrado: " .. path_to_config, vim.log.levels.ERROR)
  return
end

-- Encontrar o JAR do launcher
local jar_pattern = path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar"
local jar_files = vim.fn.glob(jar_pattern, true, true)
local path_to_jar = nil

if #jar_files > 0 then
  path_to_jar = jar_files[1]
else
  vim.notify("JAR do launcher não encontrado em: " .. jar_pattern, vim.log.levels.ERROR)
  return
end

-- Certifique-se de que path_to_mason_packages está definido corretamente e APENAS UMA VEZ
local path_to_mason_packages = home .. "/.local/share/nvim/mason/packages"

-- ... (resto do código do Mason para JDTLS) ...

-- Workspace específico para cada projeto
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
local project_name = vim.fn.fnamemodify(root_dir or vim.fn.getcwd(), ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

-- Criar diretório de workspace se não existir
vim.fn.mkdir(workspace_dir, "p")

-- Configurar bundles para debug, test e format
-- Configurar bundles para debug, test e format
local bundles = {}

-- --- DEBUG ADAPTER BUNDLE ---
local jdebug_server_path = path_to_mason_packages .. "/java-debug-adapter/extension/server/"
-- Nome exato do JAR de debug. CONFIRME ESTE NOME E VERSÃO.
local jdebug_jar_name = "com.microsoft.java.debug.plugin-0.53.1.jar"
local jdebug_full_path = jdebug_server_path .. jdebug_jar_name

if vim.fn.filereadable(jdebug_full_path) == 1 then
    table.insert(bundles, jdebug_full_path)
else
    vim.notify("JAR do Debug Adapter não encontrado: " .. jdebug_full_path, vim.log.levels.ERROR)
end

-- --- TEST PLUGIN BUNDLES ---
local jtest_server_path = path_to_mason_packages .. "/java-test/extension/server/"
-- Adicione APENAS o JAR principal do plugin de teste. CONFIRME ESTE NOME E VERSÃO.
local jtest_plugin_jar = jtest_server_path .. "com.microsoft.java.test.plugin-0.43.1.jar"

if vim.fn.filereadable(jtest_plugin_jar) == 1 then
    table.insert(bundles, jtest_plugin_jar)
else
    vim.notify("JAR do Test Plugin principal não encontrado em: " .. jtest_plugin_jar, vim.log.levels.ERROR)
end



-- Configuração do JDTLS
local config = {
  cmd = {
    "java", -- Usar o Java do sistema
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "--add-opens", "java.base/java.io=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED",
    "--add-opens", "java.base/java.text=ALL-UNNAMED",
    "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED",
    "-jar", path_to_jar,
    "-configuration", path_to_config,
    "-data", workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      eclipse = {
        downloadSources = true,
      },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = "/usr/lib/jvm/java-17-openjdk/",
          },
        },
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      format = {
        enabled = true,
        settings = { -- Reabilitando settings para usar o provider
            provider = "google-java-format", -- Indica para usar o formatador Google
        },
     },
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        importOrder = {
          "java",
          "javax",
          "com",
          "org",
        },
      },
      contentProvider = { preferred = "fernflower" },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
        },
        useBlocks = true,
      },
      imports = {
        gradle = {
          wrapper = {
            checksums = {
              {
                ["sha256"] = "7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172",
                ["allowed"] = true
              }
            }
          }
        }
      }
    },
  },

  init_options = {
    bundles = bundles,
    extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
  },

  on_init = function(client, _)
    print("JDTLS inicializado com sucesso")
  end,

  on_exit = function(code, signal, client_id)
    if code ~= 0 then
      print("JDTLS saiu com código:", code, "sinal:", signal)
    end
  end,

  on_attach = function(client, bufnr)
    -- Configurar capacidades do DAP se disponível
    if vim.fn.exists("*jdtls#setup_dap") then
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
    end

    -- Keybindings padrão do LSP
    local opts = { buffer = bufnr, silent = true }
    
     vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP: Go to [D]efinition" , buffer = bufnr}) -- Adicionado buffer para clareza
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP: Go to [D]eclaration" , buffer = bufnr})
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "LSP: Go to [I]mplementation" , buffer = bufnr})
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "LSP: Go to [R]eferences" , buffer = bufnr})
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Docs" , buffer = bufnr})
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Help" , buffer = bufnr})
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame Symbol" , buffer = bufnr})
    vim.keymap.set("n", "<leader>cj", vim.lsp.buf.code_action, { desc = "LSP: Code [J]ava action " , buffer = bufnr}) -- Já estava aqui, mantido.

    -- Keybindings específicos do JDTLS (usando prefixo <leader>J para Java)
    vim.keymap.set("n", "<leader>Jo", function() require("jdtls").organize_imports() end, { desc = "Java: [O]rganize Imports", buffer = bufnr })
    vim.keymap.set("n", "<leader>Jv", function() require("jdtls").extract_variable() end, { desc = "Java: E[x]tract [V]ariable", buffer = bufnr })
    vim.keymap.set("v", "<leader>Jv", function() require("jdtls").extract_variable(true) end, { desc = "Java: E[x]tract [V]ariable (Visual)", buffer = bufnr })
    vim.keymap.set("n", "<leader>Jc", function() require("jdtls").extract_constant() end, { desc = "Java: E[x]tract [C]onstant", buffer = bufnr })
    vim.keymap.set("v", "<leader>Jc", function() require("jdtls").extract_constant(true) end, { desc = "Java: E[x]tract [C]onstant (Visual)", buffer = bufnr })
    vim.keymap.set("v", "<leader>Jm", function() require("jdtls").extract_method(true) end, { desc = "Java: E[x]tract [M]ethod (Visual)", buffer = bufnr })

    -- Comando para formatar
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "Format current buffer with LSP" })

    -- Highlight do símbolo sob o cursor
    if client.server_capabilities.documentHighlightProvider then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
      vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Integração com lsp_signature se disponível
    local ok, lsp_signature = pcall(require, "lsp_signature")
    if ok then
      lsp_signature.on_attach({
        bind = true,
        padding = "",
        handler_opts = {
          border = "rounded",
        },
        hint_prefix = "󱄑 ",
      }, bufnr)
    end

    print("JDTLS attached to buffer", bufnr)
  end,

  capabilities = require("cmp_nvim_lsp").default_capabilities(),
}

-- Inicia o JDTLS
require("jdtls").start_or_attach(config)
