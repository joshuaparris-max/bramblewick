$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$output = Join-Path $root "build\web"
$zip = Join-Path $root "build\bramblewick-web.zip"

$godot = Get-Command godot -ErrorAction SilentlyContinue
if (-not $godot) {
    $godot = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "Godot*_console.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $godot) {
    throw "Godot was not found. Install Godot 4.4 or newer, including export templates."
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
Remove-Item -Path "$output\*" -Recurse -Force -ErrorAction SilentlyContinue
$executable = if ($godot.Source) { $godot.Source } else { $godot.FullName }
& $executable --headless --path $root --export-release Web "$output\index.html"
if ($LASTEXITCODE -ne 0 -or -not (Test-Path "$output\index.html")) {
    throw "Web export failed. In Godot, install the matching export templates from Editor > Manage Export Templates."
}

Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
Compress-Archive -Path "$output\*" -DestinationPath $zip
Write-Host "Ready to upload to itch.io: $zip" -ForegroundColor Green
Start-Process "https://itch.io/game/new"
Start-Process explorer.exe -ArgumentList "/select,`"$zip`""
