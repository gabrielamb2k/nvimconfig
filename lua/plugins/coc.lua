return {
  "neoclide/coc.nvim",
  branch = "release",
  config = function()
    -- Define a extensão global para suporte a C/C++
    vim.g.coc_global_extensions = {'coc-clangd'}

    -- Configurações básicas para coc.nvim
    vim.api.nvim_exec([[
      " Use <c-space> to trigger completion.
      if has('nvim-0.5.1') || has('patch-8.2.2913')
        inoremap <silent><expr> <c-space> coc#refresh()
      endif

      " Make <CR> auto-select the first completion item and notify coc.nvim to
      " format on enter, <cr> could be remapped by other vim plugin
      inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

      " Use `[g` and `]g` to navigate diagnostics
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)
    ]], false)
  end,
}

