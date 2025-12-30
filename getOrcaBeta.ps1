# Download_Latest_OrcaSlicer_Nightly.ps1
# Now skips download if the exact same nightly build is already installed

$portableDir = "C:\Software-Portable"  # Change to your preferred folder

$repo = "SoftFever/OrcaSlicer"
$tag = "nightly-builds"

# Create portable directory if needed
if (-not (Test-Path $portableDir)) {
    New-Item -ItemType Directory -Path $portableDir | Out-Null
}

# Get release info
$apiUrl = "https://api.github.com/repos/$repo/releases/tags/$tag"
$release = Invoke-RestMethod -Uri $apiUrl -Method Get

Write-Host "Latest Orca Slicer nightly release: $($release.name)"

# Find the Windows portable zip asset
$asset = $release.assets | Where-Object { $_.name -like "*Windows*portable*.zip" } | Select-Object -First 1

if (-not $asset) {
    Write-Error "No Windows portable zip asset found. Check: https://github.com/SoftFever/OrcaSlicer/releases/tag/nightly-builds"
    exit
}

$fileName = $asset.name
Write-Host "Latest asset: $fileName"

# Extract the build identifier from filename (e.g., nightly_20251219_abc123 → 20251219_abc123)
$buildMatch = [regex]::Match($fileName, 'nightly[_-]?([0-9]{8}_[a-f0-9]+)')
if (-not $buildMatch.Success) {
    Write-Warning "Could not parse build identifier from filename. Falling back to date-based version."
    $version = "nightly-$(Get-Date -Format 'yyyyMMdd')"
} else {
    $version = "nightly-$($buildMatch.Groups[1].Value)"
}

$expectedExtractDir = Join-Path $portableDir "OrcaSlicer-$version"

# Check if this exact version is already present
if (Test-Path $expectedExtractDir) {
    # Look for the exe to confirm it's complete
    $existingExe = Get-ChildItem -Path $expectedExtractDir -Filter "orca-slicer.exe" -Recurse | Select-Object -First 1
    if ($existingExe) {
        Write-Host "You already have the latest nightly build ($version). No update needed."
        $exePath = $existingExe.FullName
        $exeDir = Split-Path $exePath

        # Still update the shortcut in case it was deleted
        $shortcutPath = Join-Path $portableDir "OrcaSlicer.lnk"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = $exeDir
        $shortcut.IconLocation = $exePath
        $shortcut.Save()

        Write-Host "Shortcut verified/updated: $shortcutPath"
        explorer $exeDir
        exit
    }
}

# If we get here, need to download/update
$downloadUrl = $asset.browser_download_url
$downloadsFolder = (New-Object -ComObject Shell.Application).Namespace('shell:Downloads').Self.Path
$zipPath = Join-Path $downloadsFolder $fileName

Write-Host "New build detected ($version). Downloading $fileName..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

# Remove old version folders (optional: keeps only the latest; comment out if you want to keep history)
Get-ChildItem -Path $portableDir -Directory -Filter "OrcaSlicer-nightly-*" | ForEach-Object {
    if ($_.FullName -ne $expectedExtractDir) {
        Write-Host "Removing old version: $($_.Name)"
        Remove-Item $_.FullName -Recurse -Force
    }
}

# Extract new version
if (Test-Path $expectedExtractDir) {
    Remove-Item $expectedExtractDir -Recurse -Force
}

Write-Host "Extracting to $expectedExtractDir..."
Expand-Archive -Path $zipPath -DestinationPath $expectedExtractDir -Force

# Clean up zip
Remove-Item $zipPath

# Find the exe
$exePath = Get-ChildItem -Path $expectedExtractDir -Filter "orca-slicer.exe" -Recurse | Select-Object -First 1 -ExpandProperty FullName

if (-not $exePath) {
    Write-Error "orca-slicer.exe not found after extraction."
    exit
}

$exeDir = Split-Path $exePath

# Create/update shortcut
$shortcutPath = Join-Path $portableDir "OrcaSlicer.lnk"
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.WorkingDirectory = $exeDir
$shortcut.IconLocation = $exePath
$shortcut.Save()

Write-Host "Update complete! Orca Slicer nightly ($version) ready."
Write-Host "Shortcut: $shortcutPath"

# Open the app folder
explorer $exeDir
