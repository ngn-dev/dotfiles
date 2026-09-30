<#
.SYNOPSIS
    Pulls live config files from this machine back into the repo.

.DESCRIPTION
    Only needed when setup.ps1 fell back to copying instead of symlinking. With symlinks
    the repo is the live config and there is nothing to sync.

    Run, review `git diff`, then commit.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot

$Pairs = @(
    @{ Live = Join-Path $HOME 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'; Repo = 'powershell\Microsoft.PowerShell_profile.ps1' }
    @{ Live = Join-Path $HOME 'Documents\PowerShell\profile.ps1';                     Repo = 'powershell\profile.ps1' }
    @{ Live = Join-Path $HOME 'kanagawa-dragon.omp.json';                             Repo = 'oh-my-posh\kanagawa-dragon.omp.json' }
    @{ Live = Join-Path $env:LOCALAPPDATA 'nvim';                                     Repo = 'nvim' }
    @{ Live = Join-Path $env:APPDATA 'bat\themes\Kanagawa.tmTheme';                   Repo = 'bat\Kanagawa.tmTheme' }
)

foreach ($p in $Pairs) {
    $repoPath = Join-Path $Root $p.Repo
    if (-not (Test-Path $p.Live)) { Write-Host "missing: $($p.Live)" -ForegroundColor Yellow; continue }
    $item = Get-Item $p.Live -Force
    if ($item.LinkType -eq 'SymbolicLink') { Write-Host "linked:  $($p.Repo)" -ForegroundColor DarkGray; continue }

    if ($item.PSIsContainer) {
        robocopy $p.Live $repoPath /MIR /XD .git /NFL /NDL /NJH /NJS /NP | Out-Null
    } else {
        Copy-Item $p.Live $repoPath -Force
    }
    Write-Host "synced:  $($p.Repo)" -ForegroundColor Green
}

# Windows Terminal scheme
$wt = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (Test-Path $wt) {
    $scheme = (Get-Content $wt -Raw | ConvertFrom-Json).schemes | Where-Object name -eq 'Kanagawa Dragon'
    if ($scheme) {
        $scheme | ConvertTo-Json | Set-Content (Join-Path $Root 'windows-terminal\kanagawa-dragon.json') -Encoding UTF8
        Write-Host 'synced:  windows-terminal\kanagawa-dragon.json' -ForegroundColor Green
    }
}

Write-Host "`nReview with: git -C `"$Root`" diff"
