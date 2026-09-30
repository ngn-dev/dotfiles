# dotfiles

Windows shell, editor, and terminal setup. Kanagawa Dragon everywhere, JetBrainsMono Nerd Font, PowerShell 7.

## New machine

From any PowerShell window:

```powershell
irm https://raw.githubusercontent.com/ngn-dev/dotfiles/main/setup.ps1 | iex
```

That clones this repo to `~\source\dotfiles` and runs `setup.ps1` from there. Open a new Windows Terminal tab when it finishes. The first Neovim launch installs plugins.

Turn on **Developer Mode** (Settings > System > For developers) first if you want the config files symlinked rather than copied. Symlinks mean editing a live config edits the repo. Without them the script copies, and `sync.ps1` pulls live changes back into the repo later.

## What it installs

| Category | Tools |
| --- | --- |
| Shell | PowerShell 7, Windows Terminal, oh-my-posh, zoxide, PSReadLine, PSFzf, posh-git, Terminal-Icons |
| Editor | Neovim (LazyVim), Neovide, gcc via WinLibs for treesitter |
| CLI | git, fzf, ripgrep, fd, bat, eza, lazygit, fnm |
| Font | JetBrainsMono Nerd Font |

## What it configures

| Repo path | Installed to |
| --- | --- |
| `powershell/Microsoft.PowerShell_profile.ps1` | `~\Documents\PowerShell\` |
| `powershell/profile.ps1` | `~\Documents\PowerShell\` |
| `oh-my-posh/kanagawa-dragon.omp.json` | `~\` |
| `nvim/` | `%LOCALAPPDATA%\nvim\` |
| `bat/Kanagawa.tmTheme` | `%APPDATA%\bat\themes\` |
| `windows-terminal/kanagawa-dragon.json` | merged into Windows Terminal `settings.json` as the default scheme |

It also sets the git identity if none exists and points `core.editor` at Neovide.

## Re-running

`setup.ps1` is idempotent. Skip stages with `-SkipPackages`, `-SkipModules`, `-SkipConfigs`, or `-SkipTerminal`. Force copies with `-Copy`. Existing config files are backed up next to themselves with a `.bak-<timestamp>` suffix before being replaced.

## Profile cheat sheet

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

## Neovim

Stock [LazyVim](https://www.lazyvim.org/) starter with Kanagawa Dragon and the Nerd Font set for GUI use. `lazy-lock.json` is committed so a fresh install reproduces the same plugin versions. Run `:Lazy update` to move forward and commit the new lockfile.

## Credits

The PowerShell profile started life as [Chris Titus Tech's profile](https://github.com/ChrisTitusTech/powershell-profile) and is maintained here independently. The Neovim config is built on the LazyVim starter (Apache 2.0, see `nvim/LICENSE`). Colors are from [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim).
