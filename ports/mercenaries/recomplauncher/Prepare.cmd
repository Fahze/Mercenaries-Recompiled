@echo off
rem RecompLauncher setup step: builds the game from the player's own disc image.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-RecompLauncher.ps1" -InstallDir "%~dp0." %*
exit /b %ERRORLEVEL%
