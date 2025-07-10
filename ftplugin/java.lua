-- Ultra-safe java.lua - Solução definitiva para erros de LSP com Debug e Testes

-- Prevent multiple executions
if vim.g.java_ftplugin_loaded then
    return
end

-- Safety check - only proceed for Java files
if vim.bo.filetype ~= 'java' then
    return
end

-- Mark as loaded immediately to prevent re-execution
vim.g.java_ftplugin_loaded = true

-- Create a safe environment for Java operations
local M = {}

-- Utility functions
local function is_jdtls_available()
    local ok, jdtls = pcall(require, 'jdtls')
    return ok and jdtls ~= nil
end

local function is_dap_available()
    local ok, dap = pcall(require, 'dap')
    return ok and dap ~= nil
end

local function get_active_jdtls_client()
    local clients = vim.lsp.get_active_clients({ name = 'jdtls' })
    return clients[1]
end

local function has_jdtls_capability(method)
    local client = get_active_jdtls_client()
    if not client then
        return false
    end
    
    -- Check if client supports the method
    if client.server_capabilities and client.supports_method then
        return client.supports_method(method)
    end
    
    return false
end

-- Safe JDTLS command wrapper
local function safe_jdtls_command(cmd_name, jdtls_method, description)
    vim.api.nvim_buf_create_user_command(0, cmd_name, function(opts)
        if not is_jdtls_available() then
            vim.notify("JDTLS não está disponível", vim.log.levels.WARN)
            return
        end
        
        local client = get_active_jdtls_client()
        if not client then
            vim.notify("JDTLS não está ativo", vim.log.levels.WARN)
            return
        end
        
        local ok, jdtls = pcall(require, 'jdtls')
        if not ok then
            vim.notify("Erro ao carregar JDTLS", vim.log.levels.ERROR)
            return
        end
        
        -- Check if method exists
        if type(jdtls[jdtls_method]) ~= 'function' then
            vim.notify("Método " .. jdtls_method .. " não disponível no JDTLS", vim.log.levels.WARN)
            return
        end
        
        local method_ok, result = pcall(jdtls[jdtls_method], opts.args)
        if not method_ok then
            vim.notify("Erro ao executar " .. cmd_name .. ": " .. tostring(result), vim.log.levels.ERROR)
        end
    end, { 
        nargs = '?', 
        desc = description,
        complete = function() return {} end
    })
end

-- Safe keymap wrapper
local function safe_keymap(mode, lhs, callback_func, opts)
    opts = opts or {}
    opts.buffer = true
    opts.silent = true
    
    vim.keymap.set(mode, lhs, callback_func, opts)
end

-- Test functions
local function run_test_method()
    local client = get_active_jdtls_client()
    if not client then
        vim.notify("JDTLS não está ativo", vim.log.levels.WARN)
        return
    end
    
    -- Get current method name
    local line = vim.api.nvim_get_current_line()
    local method_name = line:match("@Test.-public.-void%s+(%w+)")
    if not method_name then
        -- Try other patterns
        method_name = line:match("public.-void%s+(%w+)%(.-@Test")
        if not method_name then
            vim.notify("Método de teste não encontrado", vim.log.levels.WARN)
            return
        end
    end
    
    -- Run the test
    local params = {
        uri = vim.uri_from_bufnr(0),
        methodName = method_name,
    }
    
    client.request("vscode.java.test.run", params, function(err, result)
        if err then
            vim.notify("Erro ao executar teste: " .. vim.inspect(err), vim.log.levels.ERROR)
        else
            vim.notify("Teste executado: " .. method_name, vim.log.levels.INFO)
        end
    end)
end

local function run_test_class()
    local client = get_active_jdtls_client()
    if not client then
        vim.notify("JDTLS não está ativo", vim.log.levels.WARN)
        return
    end
    
    local params = {
        uri = vim.uri_from_bufnr(0),
    }
    
    client.request("vscode.java.test.run", params, function(err, result)
        if err then
            vim.notify("Erro ao executar testes da classe: " .. vim.inspect(err), vim.log.levels.ERROR)
        else
            vim.notify("Testes da classe executados", vim.log.levels.INFO)
        end
    end)
end

-- Debug functions
local function debug_test_method()
    if not is_dap_available() then
        vim.notify("DAP não está disponível. Instale nvim-dap", vim.log.levels.WARN)
        return
    end
    
    local client = get_active_jdtls_client()
    if not client then
        vim.notify("JDTLS não está ativo", vim.log.levels.WARN)
        return
    end
    
    -- Similar to run_test_method but with debug
    local line = vim.api.nvim_get_current_line()
    local method_name = line:match("@Test.-public.-void%s+(%w+)")
    if not method_name then
        method_name = line:match("public.-void%s+(%w+)%(.-@Test")
        if not method_name then
            vim.notify("Método de teste não encontrado", vim.log.levels.WARN)
            return
        end
    end
    
    local params = {
        uri = vim.uri_from_bufnr(0),
        methodName = method_name,
        debug = true,
    }
    
    client.request("vscode.java.test.run", params, function(err, result)
        if err then
            vim.notify("Erro ao debugar teste: " .. vim.inspect(err), vim.log.levels.ERROR)
        else
            vim.notify("Debug do teste iniciado: " .. method_name, vim.log.levels.INFO)
        end
    end)
end

-- Create safe Java commands and keymaps
local function setup_java_commands()
    -- Basic JDTLS commands
    safe_jdtls_command("JdtCompile", "compile", "Compile Java project")
    safe_jdtls_command("JdtUpdateConfig", "update_project_config", "Update project configuration")
    safe_jdtls_command("JdtBytecode", "javap", "Show bytecode")
    safe_jdtls_command("JdtJshell", "jshell", "Open JShell")
    
    -- Test commands
    vim.api.nvim_buf_create_user_command(0, "JdtTestMethod", run_test_method, { desc = "Run test method" })
    vim.api.nvim_buf_create_user_command(0, "JdtTestClass", run_test_class, { desc = "Run test class" })
    vim.api.nvim_buf_create_user_command(0, "JdtDebugTest", debug_test_method, { desc = "Debug test method" })
    
    -- Keymaps for JDTLS functions
    safe_keymap('n', '<leader>Jo', function()
        if not is_jdtls_available() then
            vim.notify("JDTLS não está disponível", vim.log.levels.WARN)
            return
        end
        
        local ok, jdtls = pcall(require, 'jdtls')
        if ok and type(jdtls.organize_imports) == 'function' then
            jdtls.organize_imports()
        else
            -- Fallback to LSP organize imports
            vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
            })
        end
    end, { desc = "[J]ava [O]rganize Imports" })
    
    safe_keymap('v', '<leader>Jv', function()
        if not is_jdtls_available() then
            vim.notify("JDTLS não está disponível", vim.log.levels.WARN)
            return
        end
        
        local ok, jdtls = pcall(require, 'jdtls')
        if ok and type(jdtls.extract_variable) == 'function' then
            jdtls.extract_variable()
        else
            vim.notify("Extract variable não disponível", vim.log.levels.WARN)
        end
    end, { desc = "[J]ava Extract [V]ariable" })
    
    safe_keymap('v', '<leader>JC', function()
        if not is_jdtls_available() then
            vim.notify("JDTLS não está disponível", vim.log.levels.WARN)
            return
        end
        
        local ok, jdtls = pcall(require, 'jdtls')
        if ok and type(jdtls.extract_constant) == 'function' then
            jdtls.extract_constant()
        else
            vim.notify("Extract constant não disponível", vim.log.levels.WARN)
        end
    end, { desc = "[J]ava Extract [C]onstant" })
    
    -- Test keymaps
    safe_keymap('n', '<leader>Jt', run_test_method, { desc = "[J]ava [T]est Method" })
    safe_keymap('n', '<leader>JT', run_test_class, { desc = "[J]ava [T]est Class" })
    safe_keymap('n', '<leader>Jd', debug_test_method, { desc = "[J]ava [D]ebug Test" })
    
    -- Debug keymaps
    safe_keymap('n', '<leader>Jb', function()
        if not is_dap_available() then
            vim.notify("DAP não está disponível. Instale nvim-dap", vim.log.levels.WARN)
            return
        end
        require('dap').toggle_breakpoint()
    end, { desc = "[J]ava Toggle [B]reakpoint" })
    
    safe_keymap('n', '<leader>Jr', function()
        if not is_dap_available() then
            vim.notify("DAP não está disponível. Instale nvim-dap", vim.log.levels.WARN)
            return
        end
        require('dap').continue()
    end, { desc = "[J]ava [R]un/Continue Debug" })
    
    -- Special keymap for update config
    safe_keymap('n', '<leader>Ju', function()
        vim.cmd('JdtUpdateConfig')
    end, { desc = "[J]ava [U]pdate Config" })
end

-- Setup basic commands immediately
setup_java_commands()

-- Function to find Mason path
local function get_mason_path()
    local possible_paths = {
        vim.fn.stdpath("data") .. "/mason",
        vim.fn.expand("~/.local/share/nvim/mason"),
        vim.fn.expand("~/.local/share/nvim-data/mason"),
        os.getenv("HOME") .. "/.local/share/nvim/mason"
    }
    
    for _, path in ipairs(possible_paths) do
        if vim.fn.isdirectory(path) == 1 then
            return path
        end
    end
    return nil
end

-- Function to setup DAP for Java
local function setup_java_dap()
    if not is_dap_available() then
        return false
    end
    
    if not is_jdtls_available() then
        return false
    end
    
    local dap = require('dap')
    local jdtls = require('jdtls')
    
    -- Setup DAP configurations for Java
    dap.configurations.java = {
        {
            type = 'java',
            request = 'launch',
            name = "Launch Java Application",
            program = "${file}",
        },
        {
            type = 'java',
            request = 'attach',
            name = "Attach to Java Process",
            hostName = "localhost",
            port = 5005,
        },
    }
    
    -- Setup JDTLS DAP
    pcall(function()
        local jdtls_dap = require('jdtls.dap')
        jdtls_dap.setup_dap_main_class_configs()
    end)
    
    return true
end

-- Function to setup JDTLS (only if not already running)
local function setup_jdtls()
    -- Check if JDTLS is already running
    if get_active_jdtls_client() then
        return true
    end
    
    -- Check if jdtls plugin is available
    if not is_jdtls_available() then
        return false
    end
    
    local jdtls = require('jdtls')
    
    -- Find Mason installation
    local mason_path = get_mason_path()
    if not mason_path then
        return false
    end
    
    -- Find JDTLS installation
    local jdtls_path = mason_path .. "/packages/jdtls"
    if vim.fn.isdirectory(jdtls_path) ~= 1 then
        return false
    end
    
    -- Find required files
    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local config = jdtls_path .. "/config_linux"
    local lombok = jdtls_path .. "/lombok.jar"
    
    if launcher == "" or vim.fn.isdirectory(config) ~= 1 then
        return false
    end
    
    -- Setup workspace
    local home = os.getenv("HOME")
    if not home then
        return false
    end
    
    local workspace_path = home .. "/code/workspace/"
    pcall(vim.fn.mkdir, workspace_path, "p")
    
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = workspace_path .. project_name
    pcall(vim.fn.mkdir, workspace_dir, "p")
    
    -- Find root directory
    local root_dir = jdtls.setup.find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' })
    or vim.fn.getcwd()
    
    -- Setup capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if cmp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end
    
    -- Setup command
    local cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', launcher,
        '-configuration', config,
        '-data', workspace_dir
    }
    
    if vim.fn.filereadable(lombok) == 1 then
        table.insert(cmd, 11, '-javaagent:' .. lombok)
    end
    
    -- Configuration
    local config_table = {
        cmd = cmd,
        root_dir = root_dir,
        capabilities = capabilities,
        settings = {
            java = {
                signatureHelp = { enabled = true },
                contentProvider = { preferred = 'fernflower' },
                eclipse = {
                    downloadSources = true,
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
                format = {
                    enabled = true,
                },
                saveActions = {
                    organizeImports = false, -- Desabilita para evitar conflitos
                },
                completion = {
                    favoriteStaticMembers = {
                        "org.hamcrest.MatcherAssert.assertThat",
                        "org.hamcrest.Matchers.*",
                        "org.hamcrest.CoreMatchers.*",
                        "org.junit.jupiter.api.Assertions.*",
                        "java.util.Objects.requireNonNull",
                        "java.util.Objects.requireNonNullElse",
                        "org.mockito.Mockito.*",
                    }
                },
                sources = {
                    organizeImports = {
                        starThreshold = 9999,
                        staticStarThreshold = 9999,
                    }
                },
                codeGeneration = {
                    toString = {
                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                    },
                    hashCodeEquals = {
                        useJava7Objects = true,
                    },
                    useBlocks = true,
                },
                configuration = {
                    runtimes = {
                        {
                            name = "JavaSE-17",
                            path = "/usr/lib/jvm/java-17-openjdk/",
                        },
                        {
                            name = "JavaSE-11",
                            path = "/usr/lib/jvm/java-11-openjdk/",
                        },
                    }
                }
            }
        },
        init_options = {
            bundles = {}
        },
        on_attach = function(client, bufnr)
            -- Disable VS Code specific commands
            if client.server_capabilities then
                client.server_capabilities.executeCommandProvider = {
                    commands = vim.tbl_filter(function(command)
                        return not vim.startswith(command, "vscode.")
                    end, client.server_capabilities.executeCommandProvider and client.server_capabilities.executeCommandProvider.commands or {})
                }
            end
            
            -- Setup DAP
            setup_java_dap()
            
            -- Setup additional functionality after attach
            pcall(function()
                local jdtls_dap = require('jdtls.dap')
                jdtls_dap.setup_dap_main_class_configs()
            end)
            
            pcall(function()
                local jdtls_setup = require('jdtls.setup')
                jdtls_setup.add_commands()
            end)
            
            -- Refresh codelens
            pcall(vim.lsp.codelens.refresh)
            
            -- Auto-organize imports on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    pcall(function()
                        vim.lsp.buf.code_action({
                            context = { only = { "source.organizeImports" } },
                            apply = true,
                        })
                    end)
                end,
            })
        end,
    }
    
    -- Start JDTLS
    local success, err = pcall(jdtls.start_or_attach, config_table)
    return success
end

-- Utility commands
vim.api.nvim_create_user_command('JdtlsStatus', function()
    local client = get_active_jdtls_client()
    if client then
        vim.notify("✓ JDTLS está ativo (ID: " .. client.id .. ")", vim.log.levels.INFO)
        if is_dap_available() then
            vim.notify("✓ DAP está disponível", vim.log.levels.INFO)
        else
            vim.notify("✗ DAP não está disponível", vim.log.levels.WARN)
        end
    else
        vim.notify("✗ JDTLS não está ativo", vim.log.levels.WARN)
    end
end, { desc = "Check JDTLS status" })

vim.api.nvim_create_user_command('JdtlsRestart', function()
    local client = get_active_jdtls_client()
    if client then
        client.stop()
        vim.notify("Parando JDTLS...", vim.log.levels.INFO)
        
        vim.defer_fn(function()
            vim.g.java_ftplugin_loaded = false
            vim.notify("Reiniciando JDTLS...", vim.log.levels.INFO)
            if setup_jdtls() then
                vim.g.java_ftplugin_loaded = true
                vim.notify("✓ JDTLS reiniciado com sucesso", vim.log.levels.INFO)
            else
                vim.notify("✗ Falha ao reiniciar JDTLS", vim.log.levels.ERROR)
            end
        end, 2000)
    else
        vim.notify("JDTLS não está executando", vim.log.levels.WARN)
    end
end, { desc = "Restart JDTLS" })

vim.api.nvim_create_user_command('JdtlsInstall', function()
    vim.notify("Para instalar JDTLS execute: :MasonInstall jdtls", vim.log.levels.INFO)
    vim.notify("Para debug instale também: :MasonInstall java-debug-adapter", vim.log.levels.INFO)
end, { desc = "Install JDTLS" })

-- Setup JDTLS with delay to ensure everything is loaded
vim.defer_fn(function()
    if not get_active_jdtls_client() then
        local success = setup_jdtls()
        if success then
            vim.notify("✓ JDTLS iniciado com sucesso", vim.log.levels.INFO)
        elseif get_mason_path() then
            vim.notify("JDTLS não encontrado. Execute: :MasonInstall jdtls", vim.log.levels.WARN)
        else
            vim.notify("Mason não encontrado. Instale o plugin Mason primeiro.", vim.log.levels.WARN)
        end
    end
end, 500)

-- Prevent any remaining vscode.java.resolveMainClass calls
vim.api.nvim_create_autocmd("BufEnter", {
    buffer = 0,
    callback = function()
        -- Override any dangerous calls
        local function safe_resolve_main_class()
            local client = get_active_jdtls_client()
            if client and has_jdtls_capability("vscode.java.resolveMainClass") then
                -- Only call if properly supported
                local ok, result = pcall(vim.lsp.buf_request, 0, "vscode.java.resolveMainClass", {})
                if not ok then
                    -- Silently ignore errors
                    return
                end
                return result
            end
        end
        
        -- Store the safe version globally
        _G.safe_resolve_main_class = safe_resolve_main_class
    end,
})

return M