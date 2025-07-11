local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local opts = {
    change_dectection = {
        notify = false,
    },
    checker = {
        enabled = true,
        notify = false,
    },
}

require("config.vim-options")
require("config.vim-keymap")
require("config.autocmds")

require("lazy").setup("plugins", opts)
vim.lsp.set_log_level("warn")

-- Silenciar erros de document highlight
vim.lsp.handlers["textDocument/documentHighlight"] = function() end
vim.lsp.handlers["textDocument/documentHighlightClear"] = function() end
