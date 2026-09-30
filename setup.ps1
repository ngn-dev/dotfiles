#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstraps a fresh Windows machine with Nick Neidig's shell, editor, and terminal setup.

.DESCRIPTION
    One-liner for a new machine (run from any PowerShell window):

        irm https://raw.githubusercontent.com/ngn-dev/dotfiles/main/setup.ps1 | iex

    When piped through iex the script clones the repo to ~\source\dotfiles and re-runs itself
    from there. When run from a checkout it works in place.

    Steps (each can be skipped with a switch):
      1. Install CLI tools and apps with winget
      2. Install PowerShell modules
      3. Link (or copy) config files into place
      4. Register the Kanagawa Dragon scheme + Nerd Font in Windows Terminal
      5. Build the bat theme cache
      6. Set git identity if none is configured

.PARAMETER Copy
    Copy files instead of symlinking. Symlinks are tried first and need Developer Mode
    or an elevated shell; the script falls back to copying automatically if they fail.
#>
[CmdletBinding()]
param(
    [switch]$SkipPackages,
    [switch]$SkipModules,
    [switch]$SkipConfigs,
    [switch]$SkipTerminal,
    [switch]$Copy,
    [string]$GitUserName,
    [string]$GitUserEmail
)

$ErrorActionPreference = 'Stop'
$RepoUrl   = 'https://github.com/ngn-dev/dotfiles.git'
$RepoDir   = Join-Path $HOME 'source\dotfiles'

function Write-Step  ($m) { Write-Host "`n==> $m" -ForegroundColor Cyan }
function Write-Ok    ($m) { Write-Host "    $m" -ForegroundColor Green }
function Write-Skip  ($m) { Write-Host "    $m" -ForegroundColor DarkGray }
function Write-Warn2 ($m) { Write-Host "    $m" -ForegroundColor Yellow }

# ---------------------------------------------------------------------------
# 0. Make sure we are running from a checkout
# ---------------------------------------------------------------------------
$here = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
if (-not $here -or -not (Test-Path (Join-Path $here 'powershell\Microsoft.PowerShell_profile.ps1'))) {
    Write-Step "Cloning $RepoUrl to $RepoDir"
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
        $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
    }
    if (-not (Test-Path $RepoDir)) {
        New-Item -ItemType Directory -Force (Split-Path $RepoDir) | Out-Null
        git clone $RepoUrl $RepoDir
    }
    & (Join-Path $RepoDir 'setup.ps1') @PSBoundParameters
    return
}
$Root = $here

# ---------------------------------------------------------------------------
# 1. winget packages
# ---------------------------------------------------------------------------
$Packages = @(
    'Microsoft.PowerShell'
    'Microsoft.WindowsTerminal'
    'Git.Git'
    'Neovim.Neovim'
    'Neovide.Neovide'
    'JanDeDobbeleer.OhMyPosh'
    'ajeetdsouza.zoxide'
    'junegunn.fzf'
    'BurntSushi.ripgrep.MSVC'
    'sharkdp.fd'
    'sharkdp.bat'
    'eza-community.eza'
    'JesseDuffield.lazygit'
    'Schniz.fnm'
    'BrechtSanders.WinLibs.POSIX.UCRT'   # gcc, needed by nvim-treesitter to build parsers
    'DEVCOM.JetBrainsMonoNerdFont'
)

if (-not $SkipPackages) {
    Write-Step 'Installing winget packages'
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is not available. Install "App Installer" from the Microsoft Store and re-run.'
    }
    $installed = winget list --accept-source-agreements 2>$null | Out-String
    foreach ($id in $Packages) {
        if ($installed -match [regex]::Escape($id)) {
            Write-Skip "$id (already installed)"
            continue
        }
        Write-Host "    installing $id ..." -NoNewline
        $out = winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0 -or $out -match 'already installed') { Write-Host ' ok' -ForegroundColor Green }
        else { Write-Host ' FAILED' -ForegroundColor Red; Write-Warn2 ($out.Trim() -split "`n" | Select-Object -Last 1) }
    }
    # pick up anything winget added to PATH
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}

# ---------------------------------------------------------------------------
# 2. PowerShell modules
# ---------------------------------------------------------------------------
$Modules = @('PSReadLine', 'Terminal-Icons', 'PSFzf', 'posh-git')

if (-not $SkipModules) {
    Write-Step 'Installing PowerShell modules'
    if (-not (Get-PSRepository PSGallery -ErrorAction SilentlyContinue | Where-Object InstallationPolicy -eq 'Trusted')) {
        Set-PSRepository PSGallery -InstallationPolicy Trusted
    }
    foreach ($m in $Modules) {
        if (Get-Module -ListAvailable -Name $m | Where-Object { $m -ne 'PSReadLine' -or $_.Version -ge '2.2' }) {
            Write-Skip "$m (already installed)"
        } else {
            Install-Module $m -Scope CurrentUser -Force -AcceptLicense
            Write-Ok "$m installed"
        }
    }
}

# ---------------------------------------------------------------------------
# 3. Config files
# ---------------------------------------------------------------------------
function Install-Config {
    param([string]$Source, [string]$Target)

    $targetDir = Split-Path $Target
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Force $targetDir | Out-Null }

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Source) {
            Write-Skip "$Target (already linked)"
            return
        }
        $backup = "$Target.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Move-Item $Target $backup -Force
        Write-Warn2 "backed up existing -> $backup"
    }

    if (-not $Copy) {
        try {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -ErrorAction Stop | Out-Null
            Write-Ok "$Target -> linked"
            return
        } catch {
            Write-Warn2 'symlink failed (needs Developer Mode or admin); copying instead'
        }
    }
    Copy-Item $Source $Target -Recurse -Force
    Write-Ok "$Target -> copied"
}

if (-not $SkipConfigs) {
    Write-Step 'Placing config files'
    $psDir = Join-Path $HOME 'Documents\PowerShell'
    Install-Config (Join-Path $Root 'powershell\Microsoft.PowerShell_profile.ps1') (Join-Path $psDir 'Microsoft.PowerShell_profile.ps1')
    Install-Config (Join-Path $Root 'powershell\profile.ps1')                     (Join-Path $psDir 'profile.ps1')
    Install-Config (Join-Path $Root 'oh-my-posh\kanagawa-dragon.omp.json')       (Join-Path $HOME 'kanagawa-dragon.omp.json')
    Install-Config (Join-Path $Root 'nvim')                                       (Join-Path $env:LOCALAPPDATA 'nvim')
    Install-Config (Join-Path $Root 'bat\Kanagawa.tmTheme')                       (Join-Path $env:APPDATA 'bat\themes\Kanagawa.tmTheme')

    if (Get-Command bat -ErrorAction SilentlyContinue) {
        bat cache --build | Out-Null
        Write-Ok 'bat theme cache rebuilt'
    }
}

# ---------------------------------------------------------------------------
# 4. Windows Terminal
# ---------------------------------------------------------------------------
if (-not $SkipTerminal) {
    Write-Step 'Configuring Windows Terminal'
    $wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (-not (Test-Path $wt)) {
        Write-Warn2 'settings.json not found. Launch Windows Terminal once, then re-run with -SkipPackages -SkipModules -SkipConfigs.'
    } else {
        $scheme   = Get-Content (Join-Path $Root 'windows-terminal\kanagawa-dragon.json') -Raw | ConvertFrom-Json
        $settings = Get-Content $wt -Raw | ConvertFrom-Json

        if (-not $settings.PSObject.Properties['schemes']) { $settings | Add-Member schemes @() }
        $settings.schemes = @($settings.schemes | Where-Object name -ne $scheme.name) + $scheme

        if (-not $settings.profiles.PSObject.Properties['defaults']) { $settings.profiles | Add-Member defaults ([pscustomobject]@{}) }
        $d = $settings.profiles.defaults
        if ($d.PSObject.Properties['colorScheme']) { $d.colorScheme = $scheme.name } else { $d | Add-Member colorScheme $scheme.name }
        if (-not $d.PSObject.Properties['font']) { $d | Add-Member font ([pscustomobject]@{}) }
        if ($d.font.PSObject.Properties['face']) { $d.font.face = 'JetBrainsMono Nerd Font' } else { $d.font | Add-Member face 'JetBrainsMono Nerd Font' }

        Copy-Item $wt "$wt.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
        $settings | ConvertTo-Json -Depth 32 | Set-Content $wt -Encoding UTF8
        Write-Ok "scheme '$($scheme.name)' registered and set as default with JetBrainsMono Nerd Font"
    }
}

# ---------------------------------------------------------------------------
# 5. git identity
# ---------------------------------------------------------------------------
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Step 'git identity'
    $name  = if ($GitUserName)  { $GitUserName }  else { git config --global user.name }
    $email = if ($GitUserEmail) { $GitUserEmail } else { git config --global user.email }
    if (-not $name)  { $name  = Read-Host '    git user.name' }
    if (-not $email) { $email = Read-Host '    git user.email' }
    if ($name)  { git config --global user.name  $name }
    if ($email) { git config --global user.email $email }
    git config --global core.editor 'neovide --no-fork'
    Write-Ok "$name <$email>, editor = neovide"
}

Write-Host "`nDone. Open a new Windows Terminal tab to load the profile." -ForegroundColor Cyan
Write-Host "First Neovim launch will install plugins; run :Lazy sync if anything is missing.`n"
