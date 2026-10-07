return {
  -- Windows default. Under Omarchy this file is a symlink to the active theme.
  { "rebelot/kanagawa.nvim", lazy = false, priority = 1000 },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "kanagawa-dragon" },
  },
}
