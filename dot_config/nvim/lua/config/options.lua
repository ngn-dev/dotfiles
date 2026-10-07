-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- GUI font (Neovide, nvim-qt, etc.); terminal Neovim uses the terminal's font
vim.opt.guifont = "JetBrainsMono Nerd Font:h12"

-- Omarchy's OSC 52 clipboard for tmux/SSH sessions; a no-op outside those.
if vim.fn.has("win32") == 0 then
  require("config.remote_clipboard").setup()
end
