return{
   "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    priority = 1000,
    config = function()
      require('nvim-treesitter.configs').setup {
        aunto_install = true,
        highlight = {
          enable = true,
        },
        indent = {  -- Corrigi "ident" para "indent"
          enable = true,
        },
      }
    end
}
