@echo off
REM Sunshine Configuration Script: Combined Actions
REM This script combines actions from sunshine_config_openport_allow_all.bat, sunshine_setup_webhook_messages.bat, and test8.bat



echo Webhook setup completed.

REM Section 1: Test 8 Actions

echo Executing test actions...
REM Content from test8.bat
@echo off
:: Définir les variables utiles
set "INSTALL_PATH=C:\vdd"
set "VDD_ZIP_PATH=%INSTALL_PATH%\vdd.zip"
set "VDD_EXTRACT_PATH=%INSTALL_PATH%\IddSampleDriver"
set "TARGET_PATH=C:\IddSampleDriver"
set "CHOCOLATEY_INSTALL_SCRIPT=https://community.chocolatey.org/install.ps1"
set "VDD_DOWNLOAD_URL=https://github.com/itsmikethetech/Virtual-Display-Driver/releases/download/23.10.20.2/VDD.23.10.20.2.zip"
set "SRM_DOWNLOAD_PATH=https://github.com/themimi974/Qres_GUI/archive/refs/heads/main.zip"
set "SRM_ZIP_PATH=C:\srm.zip"

:: Fonction de téléchargement du script d'installation Chocolatey et son exécution
echo Installing Chocolatey...
powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command ^
    "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('%CHOCOLATEY_INSTALL_SCRIPT%'))"

:: Vérifier si Chocolatey est installé correctement
if %errorlevel% neq 0 (
    echo [ERREUR] L'installation de Chocolatey a échoué.
    pause
    exit /b 1
)

:: Ajouter Chocolatey au PATH
SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

:: Installer les packages nécessaires via Chocolatey
echo Installing necessary packages via Chocolatey...
choco install sunshine python3 7zip devcon.portable vb-cable -y

:: Vérifier si l'installation des packages a réussi
if %errorlevel% neq 0 (
    echo [ERREUR] L'installation des packages Chocolatey a échoué.
    pause
    exit /b 1
)

:: Créer le dossier d'installation pour VDD
if not exist "%INSTALL_PATH%" (
    mkdir "%INSTALL_PATH%"
)

:: Télécharger le fichier VDD.zip
echo Downloading VDD...
powershell -Command "Invoke-WebRequest %VDD_DOWNLOAD_URL% -OutFile %VDD_ZIP_PATH%"

:: Vérifier si le téléchargement a réussi
if not exist "%VDD_ZIP_PATH%" (
    echo [ERREUR] Le téléchargement de VDD a échoué.
    pause
    exit /b 1
)

:: Extraire le fichier VDD.zip
echo Extracting VDD.zip...
7z x "%VDD_ZIP_PATH%" -o"%INSTALL_PATH%"

:: Vérifier si l'extraction a réussi
if not exist "%VDD_EXTRACT_PATH%" (
    echo [ERREUR] L'extraction de VDD a échoué.
    pause
    exit /b 1
)

:: Copier option.txt à l'emplacement correct
if not exist "%TARGET_PATH%" (
    mkdir "%TARGET_PATH%"
)
copy "%VDD_EXTRACT_PATH%\option.txt" "%TARGET_PATH%\option.txt"

:: Vérifier si option.txt est bien copié
if exist "%TARGET_PATH%\option.txt" (
    echo option.txt a été copié avec succès.
) else (
    echo [ERREUR] option.txt n'a pas été copié. Installation annulée.
    pause
    exit /b 1
)

:: Installer le driver de l'écran virtuel
echo Press Enter to install virtual screen...
pause
call "%VDD_EXTRACT_PATH%\installCert.bat"
devcon64 install "%VDD_EXTRACT_PATH%\iddsampledriver.inf" root\iddsampledriver

:: Vérifier si l'installation du driver a réussi
if %errorlevel% neq 0 (
    echo [ERREUR] L'installation du driver de l'écran virtuel a échoué.
    pause
    exit /b 1
)

:: Télécharger et installer le micrologiciel de gestion de résolution
echo Downloading and installing screen resolution manager...
powershell -Command "Invoke-WebRequest %SRM_DOWNLOAD_PATH% -OutFile %SRM_ZIP_PATH%"
7z x "%SRM_ZIP_PATH%" -oC:\

:: Vérifier si le téléchargement et l'extraction de SRM ont réussi
if not exist "C:\Qres_GUI-main" (
    echo [ERREUR] Le téléchargement ou l'extraction du micrologiciel de gestion de résolution a échoué.
    pause
    exit /b 1
)

:: Créer le script de démarrage pour le gestionnaire de résolution d'écran
set "STARTUP_SCRIPT=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\StartScreenResManager.bat"
(
    echo @echo off
    echo pip install tk
    echo pip install screeninfo
    echo pip install pystray
    echo cd C:\Qres_GUI-main
    echo python C:\Qres_GUI-main\shortcut.py
) > "%STARTUP_SCRIPT%"

:: Vérifier si le script de démarrage a été créé avec succès
if exist "%STARTUP_SCRIPT%" (
    echo Le script de démarrage a été créé avec succès.
) else (
    echo [ERREUR] Le script de démarrage n'a pas été créé. Installation annulée.
    pause
    exit /b 1
)

:: Suppression des fichiers et dossiers temporaires
echo Cleaning up temporary files...
rd /s /q "%INSTALL_PATH%"
rd /s /q "%VDD_EXTRACT_PATH%"
del /q "%SRM_ZIP_PATH%"

REM Section 2: Configuration to Allow All Ports

echo Configuring Sunshine to allow all ports...
REM Content from sunshine_config_openport_allow_all.bat
netsh advfirewall firewall add rule name="Open All Ports" dir=in action=allow protocol=TCP localport=1-65535
netsh advfirewall firewall add rule name="Open All Ports" dir=out action=allow protocol=TCP localport=1-65535

echo Ports configuration completed.

REM Section 3: Setting up Webhook Messages

echo Setting up Sunshine webhook messages...
REM Content from sunshine_setup_webhook_messages.bat
echo {"webhook":"example-webhook-url","events":"all"} > webhook_config.json
curl -X POST -H "Content-Type: application/json" -d @webhook_config.json http://localhost:5000/webhooks/setup

:: Script terminé
echo Installation and cleanup completed.
pause
exit /b 0

REM End of Combined Script
echo All actions have been executed. Exiting...
@pause
