-- Omarchy only (see lua/config/omarchy.lua); returns nothing elsewhere.
if not require("config.omarchy").present then
  return {}
end

-- Omarchy's stock opinions: no LazyVim/Neovim news popups, no scroll animation.
return {
  {
    "LazyVim/LazyVim",
    opts = { news = { lazyvim = false, neovim = false } },
  },
  {
    "folke/snacks.nvim",
    opts = { scroll = { enabled = false } },
  },
}
