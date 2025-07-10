return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    local eslint_d_diagnostics = require("none-ls.diagnostics.eslint_d")
    
    null_ls.setup({
      -- Configurações para reduzir warnings
      debug = false,
      log_level = "warn", -- Reduz logs desnecessários
      
      -- Configuração de update_in_insert
      update_in_insert = false,
      
      sources = {
        -- JavaScript/TypeScript
        eslint_d_diagnostics,
        null_ls.builtins.formatting.prettier.with({
          filetypes = { 
            "javascript", "typescript", "javascriptreact", "typescriptreact",
            "css", "scss", "html", "json", "yaml", "markdown"
          },
        }),
        
        -- Lua
        null_ls.builtins.formatting.stylua,
        
        -- C/C++
        null_ls.builtins.formatting.clang_format,
        
        -- Go
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.diagnostics.golangci_lint,
        null_ls.builtins.code_actions.gomodifytags,
        null_ls.builtins.code_actions.impl,
        
        -- Python (opcional - adicione se usar)
        -- null_ls.builtins.formatting.black,
        -- null_ls.builtins.diagnostics.flake8,
        
        -- Shell (opcional - adicione se usar)
        -- null_ls.builtins.formatting.shfmt,
        -- null_ls.builtins.diagnostics.shellcheck,
      },
      
      -- Configuração de on_attach (opcional)
      on_attach = function(client, bufnr)
        -- Desabilita formatação para clientes que não devem formatar
        if client.name == "null-ls" then
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
        end
      end,
    })
    
    -- Keymaps
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
    
    -- Keymap adicional para formatação com range
    vim.keymap.set("v", "<leader>cf", function()
      vim.lsp.buf.format({ range = true })
    end, { desc = "[C]ode [F]ormat range" })
    
    -- Auto-format on save (opcional - descomente se desejar)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   callback = function()
    --     vim.lsp.buf.format({ async = false })
    --   end,
    -- })
  end,
}