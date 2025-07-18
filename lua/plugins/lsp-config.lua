return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "jdtls", "cssls", "yamlls"},
        automatic_installation = true,
        handlers = {
          function(server_name)
            if server_name ~= "gopls" then
              require("lspconfig")[server_name].setup({})
            end
          end,
          ["gopls"] = function() end,
        },
      })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "java-debug-adapter", "java-test", "delve" },
      })
    end,
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup({
        dap_configurations = {
          {
            type = "go",
            name = "Attach remote",
            mode = "remote",
            request = "attach",
          },
        },
        delve = {
          path = "dlv",
          initialize_timeout_sec = 20,
          port = "${port}",
          args = {},
          build_flags = "",
        },
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = {
      "mfussenegger/nvim-dap",
      "ray-x/lsp_signature.nvim",
    },
  },
  {
    "ray-x/lsp_signature.nvim",
    config = function()
      require("lsp_signature").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local dap = require("dap")
      local dapui = require("dapui")

      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })

      -- Configuração específica para YAML Language Server
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              -- Schema para Spring Boot application properties
              ["https://json.schemastore.org/spring-boot-application.json"] = {
                "/application.yml",
                "/application.yaml",
                "/application-*.yml",
                "/application-*.yaml"
              },
              -- Schema para GitHub Actions
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              -- Schema para Docker Compose
              ["https://json.schemastore.org/docker-compose.json"] = {
                "/docker-compose.yml",
                "/docker-compose.yaml",
                "/compose.yml",
                "/compose.yaml"
              },
              -- Schema para Kubernetes
              ["https://json.schemastore.org/kustomization.json"] = "/kustomization.yaml",
            },
            validate = true,
            completion = true,
            hover = true,
            format = {
              enable = true,
              singleQuote = false,
              bracketSpacing = true,
            },
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
          },
        },
      })

      local function setup_gopls_manual()
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "go",
          callback = function(args)
            if #vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" }) > 0 then return end

            local root_dir = vim.fn.getcwd()
            local current_dir = vim.fn.expand("%:p:h")

            for _, pattern in ipairs({ "go.mod", "go.sum", ".git" }) do
              local found = vim.fn.findfile(pattern, current_dir .. ";")
              if found ~= "" then
                root_dir = vim.fn.fnamemodify(found, ":h")
                break
              end
            end

            vim.lsp.start({
              name = "gopls",
              cmd = { "gopls" },
              root_dir = root_dir,
              capabilities = capabilities,
              settings = {
                gopls = {
                  analyses = { unusedparams = true },
                  staticcheck = true,
                  gofumpt = true,
                  usePlaceholders = true,
                  completeUnimported = true,
                  matcher = "fuzzy",
                  deepCompletion = true,
                },
              },
            })
          end,
        })
      end

      setup_gopls_manual()

      -- Configuração específica para arquivos YAML
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "yaml", "yml" },
        callback = function()
          vim.opt_local.shiftwidth = 2
          vim.opt_local.tabstop = 2
          vim.opt_local.softtabstop = 2
          vim.opt_local.expandtab = true
          vim.opt_local.foldmethod = "indent"
        end,
      })

      for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
      end

      -- LSP Keymaps
      vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
      vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
      vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, { desc = "[C]ode Goto [R]eferences" })
      vim.keymap.set("n", "<leader>ci", require("telescope.builtin").lsp_implementations, { desc = "[C]ode Goto [I]mplementations" })
      vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
      vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "[C]ode Goto [D]eclaration" })

      -- DAP Keymaps
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "[D]ebug Toggle [B]reakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]ebug [C]ontinue" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "[D]ebug Step [I]nto" })
      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "[D]ebug Step [O]ver" })
      vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "[D]ebug Step [O]ut" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "[D]ebug [R]EPL" })
      vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "[D]ebug Run [L]ast" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "[D]ebug [T]erminate" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "[D]ebug Toggle [U]I" })
      vim.keymap.set("n", "<leader>de", dapui.eval, { desc = "[D]ebug [E]val" })
      vim.keymap.set("n", "<leader>dgt", function() require("dap-go").debug_test() end, { desc = "[D]ebug [G]o [T]est" })
      vim.keymap.set("n", "<leader>dgl", function() require("dap-go").debug_last_test() end, { desc = "[D]ebug [G]o [L]ast Test" })

      -- C++ DAP Adapter (copiado do dap.lua)
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = "path/to/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
      }
      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          setupCommands = {
            {
              text = "-enable-pretty-printing",
              description = "enable pretty printing",
              ignoreFailures = false,
            },
          },
        },
      }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = args.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = args.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },
}