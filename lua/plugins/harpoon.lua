local M = {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    -- 📌 Marcar o arquivo atual
    vim.keymap.set("n", "<leader>ma", function()
      mark.add_file()
      vim.notify(" Arquivo marcado no Harpoon")
    end, { desc = "Harpoon: Marcar Arquivo" })

    -- 🧭 Abrir o menu de navegação do Harpoon
    vim.keymap.set("n", "<TAB>", ui.toggle_quick_menu, { desc = "Harpoon: Menu Rápido" })

    -- 🚀 Navegação rápida entre os arquivos marcados
    vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Harpoon: Ir para o Arquivo 1" })
    vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Harpoon: Ir para o Arquivo 2" })
    vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Harpoon: Ir para o Arquivo 3" })

    -- 🗑️ Remover arquivo atual do Harpoon
    vim.keymap.set("n", "<leader>md", function()
      mark.rm_file()
      vim.notify(" Arquivo removido do Harpoon")
    end, { desc = "Harpoon: Remover Arquivo" })

    -- 🧹 Limpar todos os marcadores
    vim.keymap.set("n", "<leader>mc", function()
      mark.clear_all()
      vim.notify(" Todos os arquivos foram removidos do Harpoon")
    end, { desc = "Harpoon: Limpar Tudo" })
  end
}

return M
