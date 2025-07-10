return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- Recomendado para ícones
    {
      "MunifTanjim/nui.nvim",
      commit = "8d3bce9764e627b62b07424e0df77f680d47ffdb",
    },
  },
  config = function()
    require("neo-tree").setup({
      renderer = {
        icons = {
          show = {
            file = true,   -- Habilita ícones para arquivos
            folder = true, -- Habilita ícones para pastas
            folder_arrow = true, -- Ícones de setas para expandir/contrair
            git = true,    -- Habilita ícones de status Git
          },
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
      },
    })

    -- Mapeamento para abrir o Neo-tree
    vim.keymap.set("n", "<leader>n", ":Neotree filesystem reveal left<CR>", {})
    vim.keymap.set("n", "<leader>nc", ":Neotree close<CR>", {})
  end,
}
