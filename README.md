# dotfiles

Shell, editor, and desktop config for two machines: an Omarchy (Arch + Hyprland) desktop and a Windows box. Kanagawa Dragon everywhere, JetBrainsMono Nerd Font, Neovim with LazyVim on both.

Managed with [chezmoi](https://www.chezmoi.io/). One source tree mirrors `$HOME`; `.chezmoiignore` decides per OS what gets installed, templates fill in per-machine values.

## New machine

**Omarchy / Arch**

```bash
omarchy pkg add chezmoi && chezmoi init --apply ngn-dev
```

**Windows** (from any PowerShell window; turn on *Developer Mode* first so symlinks work without admin)

```powershell
winget install twpayne.chezmoi; chezmoi init --apply ngn-dev
```

`init` clones this repo to `~/.local/share/chezmoi`, asks for a git name and email, then `apply` installs packages, places every config, and on Windows registers the terminal scheme. Open a new terminal when it finishes. The first Neovim launch installs plugins.

To use an existing checkout instead of letting chezmoi clone:

```bash
chezmoi init --apply --source ~/Projects/dotfiles
```

## Day to day

| Command | Does |
| --- | --- |
| `chezmoi diff` | what `apply` would change on this machine (also shows what an Omarchy update rewrote) |
| `chezmoi apply` | write the repo's version into place |
| `chezmoi edit ~/.config/hypr/bindings.lua --apply` | edit the source file and apply in one go |
| `chezmoi re-add` | you edited the live file; pull it back into the repo |
| `chezmoi add ~/.config/foo/bar` | start tracking a new file |
| `chezmoi unmanaged ~/.config/nvim` | files in a tracked dir that the repo doesn't know about |
| `chezmoi cd` | shell in the source tree, for git |

Files are copied into place, not symlinked, so editing a live file does nothing until `re-add`. That is deliberate: Omarchy upgrades rewrite files under `~/.config`, and `chezmoi diff` makes those rewrites visible instead of silently replacing a symlink.

## Layout

| Source | Target | Where |
| --- | --- | --- |
| `dot_config/nvim/` | `~/.config/nvim` (Windows also links `%LOCALAPPDATA%\nvim` to it) | both |
| `dot_config/bat/themes/` | `~/.config/bat/themes` (Windows links `%APPDATA%\bat` to it) | both |
| `dot_config/git/config.tmpl` | `~/.config/git/config`, identity from `chezmoi init` answers | both |
| `dot_config/hypr/*.lua`, `hyprsunset.conf` | `~/.config/hypr/` user overrides. `monitors.lua.tmpl` picks a block by hostname | linux |
| `dot_config/omarchy/` | `~/.config/omarchy/` bar layout, menu extensions, branding, default agent | linux |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` | linux |
| `dot_bashrc` | `~/.bashrc` | linux |
| `Documents/PowerShell/` | `~\Documents\PowerShell\` profiles | windows |
| `kanagawa-dragon.omp.json` | `~\` oh-my-posh theme | windows |
| `.chezmoidata/windows-terminal.json` | merged into Windows Terminal `settings.json` by the `modify_` script under `AppData/` | windows |
| `.chezmoiscripts/` | winget / PowerShell module / `omarchy pkg add` installs, `bat cache --build`, `mise install` | per OS |

Naming: `dot_` is a leading dot, `private_` is mode 600, `symlink_` holds a link target, `modify_` is a script that rewrites an existing file, `.tmpl` is a Go template. Scripts prefixed `run_once_` run once per machine, `run_onchange_` whenever their rendered content changes.

## Neovim

One LazyVim config on both OSes. Everything Omarchy-specific is gated on `lua/config/omarchy.lua`, which checks for Omarchy's active theme file and is false on Windows:

- `lua/plugins/theme.lua` sets Kanagawa Dragon. On Omarchy this path is a symlink to the active theme's `neovim.lua`, so chezmoi ignores it there and Omarchy's theme switcher keeps working.
- `omarchy-all-themes.lua`, `omarchy-theme-hotreload.lua`, `omarchy-defaults.lua`, and `plugin/after/transparency.lua` are Omarchy's stock extras (hot theme reload, transparent background, no news popups). Omarchy's own copy lives at `/usr/share/omarchy-nvim/config/` if you need to compare.
- `lazy-lock.json` is not tracked; Lazy owns it per machine.

## Omarchy notes

- Only user-override files are tracked. Omarchy's defaults live in `/usr/share/omarchy/` and are loaded before these.
- After `omarchy update`, run `chezmoi diff` to see what it changed. `chezmoi re-add` keeps the upgrade's version, `chezmoi apply` restores yours.
- Hyprland reloads on save. Validate with `hyprctl reload && hyprctl configerrors`.
- `~/.config/omarchy/shell.json` is the bar layout; it hot-reloads.

## Profile cheat sheet (Windows)

Run `Show-Help` in the shell for the full list. Highlights:

| Key / command | Does |
| --- | --- |
| `Ctrl+R` | fuzzy search command history |
| `Ctrl+T` | fuzzy pick a file into the command line |
| `Tab` | menu completion (git, winget, choco aware) |
| `v`, `vim` | Neovim in the terminal |
| `nv` | Neovide (also `$env:EDITOR`) |
| `lg` | lazygit |
| `cat` | bat |
| `grep` | ripgrep |
| `la`, `ll`, `lt` | eza list all / list / tree |
| `z <dir>` | zoxide jump |
