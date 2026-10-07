### Nick Neidig's PowerShell profile
### (forked from Chris Titus Tech's profile; owned locally, do not overwrite from upstream)

$poshTheme = Join-Path $Home 'kanagawa-dragon.omp.json'

# ---------------------------------------------------------------------------
# Editor
# ---------------------------------------------------------------------------
# Neovide runs with --no-fork by default, so git and other tools wait for the window to close.
$env:EDITOR = 'neovide'
$env:VISUAL = $env:EDITOR
function v   { nvim @args }
function vim { nvim @args }
function nv  { neovide @args }
function lg  { lazygit @args }

# ---------------------------------------------------------------------------
# Modules
# ---------------------------------------------------------------------------
# Terminal-Icons is slow to import; load it the first time a directory listing runs.
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    function Get-ChildItem {
        Remove-Item Function:Get-ChildItem
        Import-Module Terminal-Icons
        Get-ChildItem @args
    }
}

# git tab completion (oh-my-posh still owns the prompt; it is initialised last)
Import-Module posh-git -ErrorAction SilentlyContinue

# Chocolatey tab completion
$chocoProfile = Join-Path ($env:ChocolateyInstall ?? 'C:\ProgramData\chocolatey') 'helpers\chocolateyProfile.psm1'
if (Test-Path $chocoProfile) { Import-Module $chocoProfile }

# winget tab completion
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $word = $wordToComplete.Replace('"', '""')
    $ast  = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$word" --commandline "$ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# ---------------------------------------------------------------------------
# PSReadLine (Kanagawa Dragon)
# ---------------------------------------------------------------------------
Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -Colors @{
    Command                = '#8ba4b0'   # dragonBlue2
    Parameter              = '#c4b28a'   # dragonYellow
    Operator               = '#c4746e'   # dragonRed
    Variable               = '#c5c9c5'   # dragonWhite
    String                 = '#8a9a7b'   # dragonGreen2
    Number                 = '#a292a3'   # dragonPink
    Type                   = '#8ea4a2'   # dragonAqua
    Member                 = '#949fb5'   # dragonTeal
    Comment                = '#737c73'   # dragonAsh
    Keyword                = '#8992a7'   # dragonViolet
    Error                  = '#e46876'   # bright red
    InlinePrediction       = '#7a8382'   # dragonGray3
    ListPrediction         = '#7a8382'   # dragonGray3
    ListPredictionSelected = "$([char]27)[48;2;40;39;39m"  # bg dragonBlack4
}

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# ---------------------------------------------------------------------------
# fzf: Ctrl+R fuzzy history, Ctrl+T fuzzy file picker (Kanagawa Dragon colors)
# ---------------------------------------------------------------------------
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
$env:FZF_DEFAULT_OPTS = @(
    '--height 40% --layout=reverse --border'
    '--color=bg:#181616,bg+:#282727,fg:#c5c9c5,fg+:#c5c9c5,border:#625e5a'
    '--color=hl:#c4746e,hl+:#e46876,info:#c4b28a,prompt:#8992a7,pointer:#8ba4b0'
    '--color=marker:#87a987,spinner:#8ea4a2,header:#8ea4a2'
) -join ' '
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# ---------------------------------------------------------------------------
# Modern CLI replacements
# ---------------------------------------------------------------------------
$env:BAT_THEME = 'Kanagawa'
Set-Alias -Name cat -Value bat -Option AllScope -Force
function grep { rg @args }
function la   { eza --long --all --git --icons --group-directories-first @args }
function ll   { eza --long --git --icons --group-directories-first @args }
function lt   { eza --tree --level=2 --icons --group-directories-first @args }

# ---------------------------------------------------------------------------
# File / directory utilities
# ---------------------------------------------------------------------------
function touch ($File) {
    if (Test-Path $File) {
        (Get-Item $File).LastWriteTime = Get-Date
    } else {
        New-Item $File -ItemType File | Out-Null
    }
}

function mkcd ($Path) {
    New-Item -Path $Path -ItemType Directory -Force | Out-Null
    Set-Location -Path $Path
}

function trash ($Path) {
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path,'OnlyErrorDialogs','SendToRecycleBin')
    } else {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path,'OnlyErrorDialogs','SendToRecycleBin')
    }
}

function ff ($Name) {
    fd --hidden --exclude .git $Name
}

function head ($Path) {
    Get-Content $Path -Head 10
}

function which ($Name) {
    (Get-Command $Name).Source
}

function pgrep ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue
}

function pkill ($Name) {
    Get-Process -Name $Name -ErrorAction SilentlyContinue | Stop-Process -Force
}

function k9 ($Name) {
    pkill $Name
}

function docs {
    Set-Location -Path ([Environment]::GetFolderPath("MyDocuments"))
}

# ---------------------------------------------------------------------------
# System utilities
# ---------------------------------------------------------------------------
function uptime {
    (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime | Select-Object Days, Hours, Minutes, Seconds
}

# ---------------------------------------------------------------------------
# Git shortcuts
# ---------------------------------------------------------------------------
function gs    { git status }
function ga    { git add . }
function gp    { git push }
function gpush { git push }
function gpull { git pull }
function gcl   { git clone $args }

function gcom {
    git add .
    git commit -m "$args"
}

function lazyg {
    git add .
    git commit -m "$args"
    git push
}

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
Set-Alias -Name unzip -Value Expand-Archive

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
function Show-Help {
    $title    = $PSStyle.Foreground.BrightMagenta
    $section  = $PSStyle.Foreground.BrightBlue
    $command  = $PSStyle.Foreground.BrightGreen
    $desc     = $PSStyle.Foreground.BrightWhite
    $accent   = $PSStyle.Foreground.BrightYellow
    $dim      = $PSStyle.Foreground.BrightBlack
    $reset    = $PSStyle.Reset

    Write-Host @"
${title}󰘳 PowerShell Profile Help${reset}
${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}

${section}󰌌 Keys${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}Ctrl+R${reset}             ${accent}→${reset} ${desc}Fuzzy search command history${reset}
  ${command}Ctrl+T${reset}             ${accent}→${reset} ${desc}Fuzzy pick a file into the command line${reset}
  ${command}Tab${reset}                ${accent}→${reset} ${desc}Menu completion (git, winget, choco aware)${reset}

${section}󰨞 Editor${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}v / vim${reset}            ${accent}→${reset} ${desc}Neovim in the terminal${reset}
  ${command}nv${reset}                 ${accent}→${reset} ${desc}Neovide (also the default EDITOR)${reset}
  ${command}lg${reset}                 ${accent}→${reset} ${desc}lazygit${reset}

${section}󰊢 Git Shortcuts${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}ga${reset}                 ${accent}→${reset} ${desc}git add .${reset}
  ${command}gcl <repo>${reset}         ${accent}→${reset} ${desc}git clone${reset}
  ${command}gcom <message>${reset}     ${accent}→${reset} ${desc}add + commit${reset}
  ${command}gp / gpush${reset}         ${accent}→${reset} ${desc}git push${reset}
  ${command}gpull${reset}              ${accent}→${reset} ${desc}git pull${reset}
  ${command}gs${reset}                 ${accent}→${reset} ${desc}git status${reset}
  ${command}lazyg <message>${reset}    ${accent}→${reset} ${desc}add + commit + push${reset}

${section}󰘴 System Shortcuts${reset}
${dim}────────────────────────────────────────────────────${reset}
  ${command}cat <file>${reset}         ${accent}→${reset} ${desc}bat (syntax highlighted)${reset}
  ${command}docs${reset}               ${accent}→${reset} ${desc}Documents folder${reset}
  ${command}ff <name>${reset}          ${accent}→${reset} ${desc}Find files (fd)${reset}
  ${command}grep <pattern> [path]${reset} ${accent}→${reset} ${desc}Search text (ripgrep)${reset}
  ${command}head <file>${reset}        ${accent}→${reset} ${desc}First lines${reset}
  ${command}k9 <name>${reset}          ${accent}→${reset} ${desc}Kill process by name${reset}
  ${command}la / ll / lt${reset}       ${accent}→${reset} ${desc}List all / list / tree (eza)${reset}
  ${command}mkcd <dir>${reset}         ${accent}→${reset} ${desc}Create + enter dir${reset}
  ${command}pgrep <name>${reset}       ${accent}→${reset} ${desc}Find process by name${reset}
  ${command}pkill <name>${reset}       ${accent}→${reset} ${desc}Stop process by name${reset}
  ${command}touch <file>${reset}       ${accent}→${reset} ${desc}Create file${reset}
  ${command}trash <path>${reset}       ${accent}→${reset} ${desc}Send to Recycle Bin${reset}
  ${command}unzip <file>${reset}       ${accent}→${reset} ${desc}Extract zip${reset}
  ${command}uptime${reset}             ${accent}→${reset} ${desc}System uptime${reset}
  ${command}which <name>${reset}       ${accent}→${reset} ${desc}Locate command${reset}
  ${command}z <dir>${reset}            ${accent}→${reset} ${desc}Jump to a frequent directory (zoxide)${reset}

${dim}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${reset}
"@
}

# ---------------------------------------------------------------------------
# Init commands (keep these at the end)
# ---------------------------------------------------------------------------
if ((Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and (Test-Path $poshTheme)) {
    Invoke-Expression (& { (oh-my-posh init pwsh --config $poshTheme | Out-String) })
}
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
}
