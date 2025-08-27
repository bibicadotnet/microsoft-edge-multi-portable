@echo off
setlocal
echo Microsoft Edge {CHANNEL} Portable Updater v1.0
echo ==========================================
echo.
(
echo # Microsoft Edge {CHANNEL} Updater
echo $ErrorActionPreference = "Stop"
echo $edgePath = Join-Path "%~dp0" "msedge.exe"
echo $apiUrl = "https://api.github.com/repos/{REPOSITORY}/releases"
echo $tempDir = Join-Path $env:TEMP "Edge{CHANNEL_TITLE}Update"
echo.
echo try {
echo   $currentVersion = if ^(Test-Path $edgePath^) { ^(Get-Item $edgePath^).VersionInfo.ProductVersion } else { "Not installed" }
echo   $allReleases = Invoke-RestMethod -Uri $apiUrl
echo   $channelReleases = $allReleases ^| Where-Object { $_.tag_name -like "edge-{CHANNEL}-portable-x64_*" }
echo   $latestRelease = $channelReleases ^| Sort-Object { if ^($_.tag_name -match "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"^) { [System.Version]$matches[1] } else { [System.Version]"0.0.0.0" } } -Descending ^| Select-Object -First 1
echo   $latestVersion = ^($latestRelease.tag_name -split "_"^)^[1^]
echo   $downloadUrl = $latestRelease.assets^[0^].browser_download_url
echo   if ^($downloadUrl -like "https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download/*"^) {
echo     $downloadUrl = $downloadUrl -replace "https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download/", "https://edge.bibica.net/"
echo   }
echo.
echo   Write-Host "Current version: $currentVersion" -ForegroundColor Yellow
echo   Write-Host "Latest version: $latestVersion" -ForegroundColor Yellow
echo   Write-Host
echo.
echo   $confirm = Read-Host "Do you want to update? (y/N)"
echo   if ^($confirm -ne 'y' -and $confirm -ne 'Y'^) { exit }
echo.
echo   if ^(Test-Path $edgePath^) {
echo     Write-Host "Stopping processes..."
echo     Stop-Process -Name msedge,MicrosoftEdgeUpdate,edgeupdate,edgeupdatem,MicrosoftEdgeSetup -Force -ErrorAction SilentlyContinue
echo     Start-Sleep 2
echo   }
echo.
echo   if ^(Test-Path $tempDir^) { Remove-Item $tempDir -Recurse -Force }
echo   New-Item -ItemType Directory -Path $tempDir -Force ^| Out-Null
echo   $zipFile = Join-Path $tempDir "update.zip"
echo.
echo   Write-Host "Downloading from: $downloadUrl"
echo   ^(New-Object System.Net.WebClient^).DownloadFile^($downloadUrl, $zipFile^)
echo.
echo   Write-Host "Extracting..."
echo   Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
echo.
echo   $extractedDir = Get-ChildItem $tempDir -Recurse -Directory ^| Where-Object { $_.Name -eq "Edge" } ^| Select-Object -First 1
echo   $currentDir = "%~dp0"
echo.
echo   Write-Host "Updating files..."
echo   if ^(Test-Path "msedge.exe"^) { Remove-Item "msedge.exe" -Force }
echo   if ^(Test-Path "version.dll"^) { Remove-Item "version.dll" -Force }
echo   if ^(Test-Path $currentVersion^) { Remove-Item $currentVersion -Recurse -Force }
echo.
echo   Get-ChildItem $extractedDir.FullName -Recurse ^| ForEach-Object {
echo     $relativePath = $_.FullName.Substring^($extractedDir.FullName.Length + 1^)
echo     $destPath = Join-Path $currentDir $relativePath
echo     if ^($_.PSIsContainer^) {
echo       New-Item -ItemType Directory -Path $destPath -Force ^| Out-Null
echo     } else {
echo       $protectedFiles = @^("chrome++.ini","debloater.reg","default-apps-multi-profile.bat"^)
echo       if ^($_.Name -in $protectedFiles -and ^(Test-Path $destPath^)^) {
echo         Write-Host "Skipping: " $_.Name
echo       } else {
echo         $destFolder = Split-Path $destPath -Parent
echo         if ^(-not ^(Test-Path $destFolder^)^) { New-Item -ItemType Directory -Path $destFolder -Force ^| Out-Null }
echo         Copy-Item $_.FullName -Destination $destPath -Force
echo       }
echo     }
echo   }
echo.
echo   Remove-Item $tempDir -Recurse -Force
echo   $newCurrentVersion = if ^(Test-Path $edgePath^) { ^(Get-Item $edgePath^).VersionInfo.ProductVersion } else { "Not installed" }
echo   if ^($newCurrentVersion -eq $latestVersion^) {
echo     Write-Host "Update completed successfully! Version: $newCurrentVersion" -ForegroundColor Green
echo   } else {
echo     Write-Host "Update may not be successful. Expected: $latestVersion, Actual: $newCurrentVersion" -ForegroundColor Yellow
echo   }
echo.
echo } catch {
echo   Write-Host "Error: $_" -ForegroundColor Red
echo }
echo.
echo Read-Host "Press Enter to exit"
) > "%TEMP%\edge_{CHANNEL}_update.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\edge_{CHANNEL}_update.ps1"
del "%TEMP%\edge_{CHANNEL}_update.ps1" 2>nul
