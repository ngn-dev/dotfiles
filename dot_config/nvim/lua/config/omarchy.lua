-- Detects whether this Neovim is running under Omarchy (Linux). Plugin specs
-- and after-plugins that only make sense there check `present` and bail out
-- elsewhere, so the same config works on Windows.
local M = {}

M.theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
M.present = vim.fn.has("win32") == 0 and vim.fn.filereadable(M.theme_file) == 1

return M
