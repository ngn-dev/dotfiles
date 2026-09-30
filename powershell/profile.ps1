fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

function vzpl {
    & "C:\Program Files\Virtual ZPL Printer\VirtualPrinter.exe"
}

function posh {
    param(
        [string]$Theme
    )

    $themes = @(
        "atomic",
        "cloud-context",
        "cloud-native-azure",
        "cobalt2",
        "jandedobbeleer",
        "lamdba",
        "m365princess",
        "marcduiker",
        "material",
        "mojada",
        "pure",
        "tiwahu",
        "tokyo",
        "zash"
    )
    if ($PSBoundParameters.ContainsKey('Theme') -and -not [string]::IsNullOrWhiteSpace($Theme)) {
        if ($themes -contains $Theme) {
            $selected = $Theme
        } else {
            Write-Host "Theme '$Theme' not found. Available themes: $($themes -join ', ')" -ForegroundColor Yellow
            return
        }
    } else {
        $selected = Get-Random -InputObject $themes
        Write-Host "Randomly selected theme: $selected"
    }

    oh-my-posh init pwsh --config $selected | Invoke-Expression
}
