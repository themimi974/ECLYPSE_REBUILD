@echo off
:: Configuration
setlocal enabledelayedexpansion

:: Définissez l'URL de votre répo GitHub (RAW)
set GITHUB_REPO_RAW=https://raw.githubusercontent.com/themimi974/ECLYPSE_REBUILD/refs/heads/main

:: Nom du fichier script principal sur GitHub
set SCRIPT_NAME=eclypse.bat

:: Téléchargement du script depuis GitHub
set OUTPUT_FILE=%SCRIPT_NAME%
echo Téléchargement du script depuis GitHub...
curl -s -o %OUTPUT_FILE% %GITHUB_REPO_RAW%/%SCRIPT_NAME%

if exist %OUTPUT_FILE% (
    echo Script téléchargé avec succès : %OUTPUT_FILE%
    echo Exécution du script...
    call %OUTPUT_FILE%
) else (
    echo Échec du téléchargement du script.
    exit /b 1
)

endlocal
