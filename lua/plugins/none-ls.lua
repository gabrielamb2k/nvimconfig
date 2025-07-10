return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    
    local eslint_d_diagnostics = require("none-ls.diagnostics.eslint_d")
    null_ls.setup({
      sources = {
        eslint_d_diagnostics,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.clang_format,
        -- Go
        null_ls.builtins.formatting.gofmt,          -- Formatação padrão do Go
        null_ls.builtins.formatting.goimports,      -- Organizar imports
        null_ls.builtins.diagnostics.golangci_lint, -- Linting avançado
        null_ls.builtins.code_actions.gomodifytags, -- Modificar tags de struct
        null_ls.builtins.code_actions.impl,         -- Implementar interfaces

        
      },
    })
    
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
  end,
}
