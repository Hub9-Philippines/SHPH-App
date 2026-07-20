# Launch the first available Android emulator and run the Flutter app.
# Usage: .\scripts\open-emulator-and-run.ps1
# Optional: .\scripts\open-emulator-and-run.ps1 -Name "Pixel_3a_API_34_extension_level_7_x86_64"

param([string]$Name)

$emulators = flutter emulators |
    Where-Object { $_ -match '^\S+\s+\S' } |
    ForEach-Object { ($_ -split '\s+')[0] }

if (-not $emulators) {
    Write-Host "No emulators found." -ForegroundColor Red
    Write-Host "Create one in Android Studio or run: flutter emulators --create --name flutter_emu"
    exit 1
}

$selected = if ($Name) { $Name } else { $emulators | Select-Object -First 1 }

Write-Host "Launching emulator: $selected" -ForegroundColor Cyan
flutter emulators --launch $selected

Write-Host "Waiting for device to appear..." -ForegroundColor Cyan
$maxWait = 90
$elapsed = 0
while ($elapsed -lt $maxWait) {
    Start-Sleep -Seconds 5
    $elapsed += 5
    $devices = flutter devices | Select-String -Pattern "android|emulator|mobile"
    if ($devices) {
        Write-Host "Device ready. Running app..." -ForegroundColor Green
        flutter run
        exit 0
    }
    Write-Host "Still waiting... ($elapsed / $maxWait)"
}

Write-Host "Emulator did not boot in time. Once it starts, run: flutter run" -ForegroundColor Yellow
exit 1
