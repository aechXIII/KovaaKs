$ErrorActionPreference = "Stop"

$RepoUrl = "https://codeload.github.com/aechXIII/KovaaKs/zip/refs/heads/main"
$BackupStamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$StageRoot = Join-Path $env:TEMP ("wapaam-" + [guid]::NewGuid().ToString("N"))

$Selected = [ordered]@{
    Settings = $true
    Palette = $true
    Themes = $true
    Sounds = $true
    Keybinds = $false
    Engine = $false
    Playlists = $false
}

function Resolve-KovaaksFolder {
    param([string]$PathValue)

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $null
    }

    $PathValue = $PathValue.Trim().Trim([char]34)

    if (Test-Path -LiteralPath (Join-Path $PathValue "FPSAimTrainer\Saved\SaveGames")) {
        return (Resolve-Path -LiteralPath $PathValue).Path
    }

    if (Test-Path -LiteralPath (Join-Path $PathValue "Saved\SaveGames")) {
        $Parent = Split-Path -Path $PathValue -Parent
        if (Test-Path -LiteralPath (Join-Path $Parent "FPSAimTrainer\Saved\SaveGames")) {
            return (Resolve-Path -LiteralPath $Parent).Path
        }
    }

    return $null
}

function Get-SteamLibraries {
    $Roots = @()

    $UserSteam = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
    if ($UserSteam) { $Roots += $UserSteam }

    $MachineSteam = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
    if ($MachineSteam) { $Roots += $MachineSteam }

    $ProgramFilesX86 = [Environment]::GetEnvironmentVariable("ProgramFiles(x86)")
    if ($ProgramFilesX86) { $Roots += (Join-Path $ProgramFilesX86 "Steam") }
    if ($env:ProgramFiles) { $Roots += (Join-Path $env:ProgramFiles "Steam") }

    $SteamRoots = @($Roots | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -Unique)
    $Libraries = @($SteamRoots)

    foreach ($SteamRoot in $SteamRoots) {
        $Vdf = Join-Path $SteamRoot "steamapps\libraryfolders.vdf"
        if (-not (Test-Path -LiteralPath $Vdf)) { continue }

        $Text = Get-Content -LiteralPath $Vdf -Raw
        foreach ($Match in [regex]::Matches($Text, '"path"\s+"([^"]+)"')) {
            $Library = $Match.Groups[1].Value.Replace('\\', '\')
            if ($Library -and (Test-Path -LiteralPath $Library)) {
                $Libraries += $Library
            }
        }
    }

    return @($Libraries | Select-Object -Unique)
}

function Find-KovaaksFolder {
    foreach ($Library in Get-SteamLibraries) {
        $Manifest = Join-Path $Library "steamapps\appmanifest_824270.acf"
        if (-not (Test-Path -LiteralPath $Manifest)) { continue }

        $Text = Get-Content -LiteralPath $Manifest -Raw
        $Match = [regex]::Match($Text, '"installdir"\s+"([^"]+)"')
        $InstallDir = if ($Match.Success) { $Match.Groups[1].Value } else { "FPSAimTrainer" }
        $Resolved = Resolve-KovaaksFolder (Join-Path $Library ("steamapps\common\" + $InstallDir))

        if ($Resolved) { return $Resolved }
    }

    return $null
}

function Show-Menu {
    param([string]$KovaaksFolder)

    $Items = @(
        @{ Key = "Settings"; Label = "Main settings" },
        @{ Key = "Palette"; Label = "Palette" },
        @{ Key = "Themes"; Label = "Themes" },
        @{ Key = "Sounds"; Label = "Sounds" },
        @{ Key = "Keybinds"; Label = "Keybinds" },
        @{ Key = "Engine"; Label = "Engine settings" },
        @{ Key = "Playlists"; Label = "Playlists" }
    )

    $Cursor = 0

    while ($true) {
        Clear-Host
        Write-Host "Wapaam KovaaK's setup"
        Write-Host ""
        Write-Host $KovaaksFolder
        Write-Host ""

        for ($Index = 0; $Index -lt $Items.Count; $Index++) {
            $Item = $Items[$Index]
            $Pointer = if ($Index -eq $Cursor) { ">" } else { " " }
            $Mark = if ($Selected[$Item.Key]) { "x" } else { " " }
            Write-Host (" {0} [{1}] {2}" -f $Pointer, $Mark, $Item.Label)
        }

        Write-Host ""
        Write-Host "Arrow keys: move   Space: toggle   Enter: install   Esc: stop"

        $Key = [Console]::ReadKey($true)

        if ($Key.Key -eq [ConsoleKey]::UpArrow) {
            $Cursor = ($Cursor - 1 + $Items.Count) % $Items.Count
            continue
        }

        if ($Key.Key -eq [ConsoleKey]::DownArrow) {
            $Cursor = ($Cursor + 1) % $Items.Count
            continue
        }

        if ($Key.Key -eq [ConsoleKey]::Spacebar) {
            $Item = $Items[$Cursor]
            $Selected[$Item.Key] = -not $Selected[$Item.Key]
            continue
        }

        if ($Key.Key -eq [ConsoleKey]::Enter) {
            if (@($Selected.Values | Where-Object { $_ }).Count -eq 0) {
                Write-Host ""
                Write-Host "Select at least one item."
                Start-Sleep -Milliseconds 800
                continue
            }
            return $true
        }

        if ($Key.Key -eq [ConsoleKey]::Escape) {
            return $false
        }
    }
}

function Test-WriteAccess {
    param([string]$PathValue)

    $TestFile = Join-Path $PathValue (".wapaam-" + [guid]::NewGuid().ToString("N") + ".tmp")

    try {
        [System.IO.File]::WriteAllText($TestFile, "test")
        Remove-Item -LiteralPath $TestFile -Force
        return $true
    }
    catch {
        Remove-Item -LiteralPath $TestFile -Force -ErrorAction SilentlyContinue
        return $false
    }
}

function Ensure-WritableDirectory {
    param([string]$PathValue)

    if (-not (Test-Path -LiteralPath $PathValue -PathType Container)) {
        $Parent = Split-Path -Path $PathValue -Parent
        if (-not (Test-Path -LiteralPath $Parent -PathType Container)) {
            throw "Missing folder: $PathValue. Start KovaaK's once, then run this again."
        }
        if (-not (Test-WriteAccess $Parent)) {
            throw "No write access: $Parent"
        }
        New-Item -ItemType Directory -Path $PathValue -Force | Out-Null
    }

    if (-not (Test-WriteAccess $PathValue)) {
        throw "No write access: $PathValue"
    }
}

function Get-TargetDirectories {
    $Directories = @()
    if ($Selected.Settings -or $Selected.Playlists) { $Directories += $SaveGamesDestination }
    if ($Selected.Palette -or $Selected.Keybinds -or $Selected.Engine) { $Directories += $LocalConfigDestination }
    if ($Selected.Themes) { $Directories += $ThemesDestination }
    if ($Selected.Sounds) { $Directories += $SoundsDestination }
    return @($Directories | Select-Object -Unique)
}

function Download-Profile {
    $Archive = Join-Path $StageRoot "repo.zip"
    $Extracted = Join-Path $StageRoot "repo"

    New-Item -ItemType Directory -Path $StageRoot -Force | Out-Null
    Write-Host "Downloading files..."

    try {
        Invoke-WebRequest -Uri $RepoUrl -OutFile $Archive
        Expand-Archive -LiteralPath $Archive -DestinationPath $Extracted -Force
    }
    catch {
        throw "Download failed: $($_.Exception.Message)"
    }

    $RepoRoot = Get-ChildItem -LiteralPath $Extracted -Directory | Select-Object -First 1
    if (-not $RepoRoot) { throw "Downloaded files are not valid." }

    $ProfileRoot = Join-Path $RepoRoot.FullName "profiles\wapaam"
    if (-not (Test-Path -LiteralPath $ProfileRoot -PathType Container)) {
        throw "The profiles\wapaam folder was not found in the repo."
    }

    return $ProfileRoot
}

function Copy-ProfileFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        throw "Missing file: $Source"
    }

    $DestinationDirectory = Split-Path -Path $Destination -Parent
    if (-not (Test-Path -LiteralPath $DestinationDirectory -PathType Container)) {
        throw "Missing folder: $DestinationDirectory"
    }

    if (Test-Path -LiteralPath $Destination -PathType Leaf) {
        $BackupDirectory = Join-Path $DestinationDirectory "backup\$BackupStamp"
        New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
        Copy-Item -LiteralPath $Destination -Destination (Join-Path $BackupDirectory (Split-Path $Destination -Leaf)) -Force

        $OldFile = Get-Item -LiteralPath $Destination
        if ($OldFile.IsReadOnly) { $OldFile.IsReadOnly = $false }
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Copy-ProfileDirectory {
    param(
        [string]$SourceDirectory,
        [string]$DestinationDirectory
    )

    if (-not (Test-Path -LiteralPath $SourceDirectory -PathType Container)) {
        throw "Missing folder: $SourceDirectory"
    }

    foreach ($File in Get-ChildItem -LiteralPath $SourceDirectory -File | Sort-Object Name) {
        Copy-ProfileFile $File.FullName (Join-Path $DestinationDirectory $File.Name)
    }
}

function Install-Profile {
    param([string]$ProfileRoot)

    $SaveSource = Join-Path $ProfileRoot "settings\SaveGames"
    $LocalSource = Join-Path $ProfileRoot "settings\WindowsNoEditor"

    if ($Selected.Settings) {
        foreach ($Name in @("FovSensConfig.json", "PrimaryUserSettings.json", "UI.json", "weaponsettings.ini")) {
            Copy-ProfileFile (Join-Path $SaveSource $Name) (Join-Path $SaveGamesDestination $Name)
        }
        Write-Host "Main settings done."
    }

    if ($Selected.Palette) {
        Copy-ProfileFile (Join-Path $LocalSource "Palette.ini") (Join-Path $LocalConfigDestination "Palette.ini")
        Write-Host "Palette done."
    }

    if ($Selected.Themes) {
        Copy-ProfileDirectory (Join-Path $ProfileRoot "themes") $ThemesDestination
        Write-Host "Themes done."
    }

    if ($Selected.Sounds) {
        Copy-ProfileDirectory (Join-Path $ProfileRoot "sounds") $SoundsDestination
        Write-Host "Sounds done."
    }

    if ($Selected.Keybinds) {
        Copy-ProfileFile (Join-Path $LocalSource "Input.ini") (Join-Path $LocalConfigDestination "Input.ini")
        Write-Host "Keybinds done."
    }

    if ($Selected.Engine) {
        Copy-ProfileFile (Join-Path $LocalSource "Engine.ini") (Join-Path $LocalConfigDestination "Engine.ini")
        Write-Host "Engine settings done."
    }

    if ($Selected.Playlists) {
        foreach ($Name in @("LocalFavoritePlaylists.json", "PlaylistInProgress.json", "PlaylistOrder.json")) {
            Copy-ProfileFile (Join-Path $SaveSource $Name) (Join-Path $SaveGamesDestination $Name)
        }
        Write-Host "Playlists done."
    }
}

try {
    if (Get-Process -Name "FPSAimTrainer*" -ErrorAction SilentlyContinue) {
        throw "Close KovaaK's and run this again."
    }

    $KovaaksFolder = Find-KovaaksFolder
    if (-not $KovaaksFolder) {
        Write-Host "KovaaK's was not found automatically."
        $ManualPath = Read-Host "Paste the FPSAimTrainer folder, or press Enter to stop"
        if ([string]::IsNullOrWhiteSpace($ManualPath)) {
            Write-Host "Stopped."
            return
        }

        $KovaaksFolder = Resolve-KovaaksFolder $ManualPath
        if (-not $KovaaksFolder) { throw "That folder does not look like KovaaK's." }
    }

    $ContentRoot = Join-Path $KovaaksFolder "FPSAimTrainer"
    $SaveGamesDestination = Join-Path $ContentRoot "Saved\SaveGames"
    $ThemesDestination = Join-Path $SaveGamesDestination "Themes"
    $SoundsDestination = Join-Path $ContentRoot "sounds"
    $LocalConfigDestination = Join-Path $env:LOCALAPPDATA "FPSAimTrainer\Saved\Config\WindowsNoEditor"

    if (-not (Show-Menu $KovaaksFolder)) {
        Write-Host "Stopped."
        return
    }

    if ($Selected.Settings -and -not $Selected.Sounds) {
        Write-Host ""
        Write-Host "Main settings use the custom sounds."
        if ((Read-Host "Install without sounds? [y/N]").Trim().ToLowerInvariant() -ne "y") {
            Write-Host "Stopped."
            return
        }
    }

    Write-Host ""
    Write-Host "Checking folders..."
    foreach ($Directory in Get-TargetDirectories) {
        Ensure-WritableDirectory $Directory
    }

    $ProfileRoot = Download-Profile

    Write-Host "Installing..."
    Install-Profile $ProfileRoot

    Write-Host ""
    Write-Host "Done."
    Write-Host "Replaced files were backed up next to the originals."
}
catch {
    Write-Host ""
    Write-Host ("Error: " + $_.Exception.Message) -ForegroundColor Red
}
finally {
    if (Test-Path -LiteralPath $StageRoot) {
        Remove-Item -LiteralPath $StageRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host ""
    Read-Host "Press Enter to close" | Out-Null
}
