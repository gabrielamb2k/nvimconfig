return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    -- =========================================================

    local home = os.getenv("HOME") 

    null_ls.setup({
      debug = false,
      log_level = "warn",
      update_in_insert = false,

      sources = {
        -- JavaScript/TypeScript
        -- Correção: usando require para importar do none-ls-extras
        require("none-ls.diagnostics.eslint_d"),
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

        -- === GOOGLE JAVA FORMAT ===
        -- Usando shell script inline para contornar o problema
        {
          method = null_ls.methods.FORMATTING,
          filetypes = { "java" },
          generator = null_ls.formatter({
            command = "sh",
            args = {
              "-c",
              "java -jar " .. home .. "/.config/nvim/lang_servers/google-java-format-1.21.0-all-deps.jar -",
            },
            to_stdin = true,
          }),
        },
        -- === FIM DO GOOGLE JAVA FORMAT ===
      },

      on_attach = function(client, bufnr)
        if client.name == "null-ls" then
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentRangeFormattingProvider = true
        end
      end,
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })
    vim.keymap.set("v", "<leader>cf", function()
      vim.lsp.buf.format({ range = true })
    end, { desc = "[C]ode [F]ormat range" })

    -- Auto-format on save (opcional)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   callback = function()
    --     vim.lsp.buf.format({ async = false })
    --   end,
    -- })
  end,
}