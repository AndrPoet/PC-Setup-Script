<#

 Powershell Windows Setup Script by Andre Pöttgen
 Execution Policy: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

#>

Write-Host "--- PowerShell Windows Setup Skript by Andre Pöttgen ---"
Write-Host "--- WICHTIG!!! ---" -ForegroundColor Red
Write-Host "--- DIESES SCRIPT MUSS ALS ADMINISTRATOR AUSGEFÜHRT WERDEN UND BENÖTIGT DIE NEUSTE WINGET VERSION!!! ---" -ForegroundColor Red
Write-Host "--------------------------------------------------------------------------------------------------------" -ForegroundColor Red

#============================================================================================================================================================================================================
# 1. SYSTEM-CHECKS & LOGGING
#============================================================================================================================================================================================================

#Prüfen, ob Powershell als Administrator ausgeführt wird
if (-not([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Warning "Bitte starte dieses PowerShell Script als ADMINISTRATOR!"
	Pause
	Exit
}

#Wiederherstellungspunkt erstellen
Checkpoint-Computer -Description "Wiederherstellungspunkt 1" -RestorePointType "MODIFY_SETTINGS"

#Logging starten
$LogPath ="$env:USERPROFILE\Desktop\Setup-Log_$(Get-Date -Format 'dd-MM-yyyy_HH-mm').txt"
Start-Transcript -Path $LogPath -Append
Write-Host "=== Einrichtung gestartet am $(Get-Date) ===" -ForegroundColor Cyan

#============================================================================================================================================================================================================
# 2.KONFIGURATION 
#============================================================================================================================================================================================================

# Liste der zu installierenden Programme (Winget IDs)
$AppsToInstall =@(
	"Mozilla.Firefox",
	"Notepad++.Notepad++",
	"RARLab.WinRAR",
	"Google.AntigravityCLI",
	"Audacity.Audacity",
	"Autodesk.Fusion",
	"AutoHotkey.AutoHotkey",
	"BlenderFoundation.Blender",
	"Canneverbe.CDBurnerXP",
	"ChatterinoTeam.Chatterino",
	"CrystalDewWorld.CrystalDiskInfo",
	"DBBrowserForSQLite.DBBrowserForSQLite",
	"Discord.Discord",
	"Docker.DockerDesktop",
	"Mozilla.Firefox.DeveloperEdition",
	"GeoGebra.CalculatorSuite",
	"Git.Git",
	"GoLang.Go",
	"Google.Chrome",
	"HandBrake.HandBrake",
	"REALiX.HWiNFO",
	"Oracle.JavaRuntimeEnvironment",
	"Logitech.GHUB",
	"Microsoft.VisualStudioCode",
	"Mozilla.Thunderbird",
	"Insecure.Nmap",
	"OpenJS.NodeJS",
	"OBSProject.OBSStudio",
	"Oracle.VirtualBox",
	"dotPDN.PaintDotNet",
	"geeksoftwareGmbH.PDF24Creator",
	"Microsoft.PowerToys",
	"Prusa3D.PrusaSlicer",
	"Python.Python.3.14",
	"qBittorrent.qBittorrent",
	"RaspberryPiFoundation.RaspberryPiImager",
	"RealVNC.VNCViewer",
	"ShareX.ShareX",
	"Spotify.Spotify",
	"Valve.Steam",
	"SublimeHQ.SublimeText.4",
	"EpicGames.EpicGamesLauncher",
	"TeamSpeakSystems.TeamSpeakClient",
	"WireGuard.WireGuard",
	"IDRIX.VeraCrypt",
	"WiresharkFoundation.Wireshark",
	"WinDirStat.WinDirStat",
	"ApacheFriends.Xampp.8.2",
	"Zoom.Zoom",
	"Microsoft.Teams",
	"File-New-Project.EarTrumpet",
	"Microsoft.Sysinternals.Suite",
	"Maxon.CinebenchR23",
	"Microsoft.PowerShell",
	"9PF9RTKMMQ69", # Snapchat
    "9NKSQGP7F2NH", # WhatsApp
    "9P7KNL5RWT25", # Sysinternals Suite
    "9NBLGGH5KPQF", # FamilyWall
	# Weitere Programme hier ergänzen...
	"VideoLAN.VLC"
)

#Ordner-Struktur
$FoldersToCreate =@(
	"$env:USERPROFILE\Projekte",
	"$env:USERPROFILE\Schule",
	"C:\Registry-Backups",
	# Weitere Ordner hier ergänzen...
	"$env:USERPROFILE\Zum Sortieren"
)

#============================================================================================================================================================================================================
# 2. ORDNERSTRUKTUR ERSTELLEN
#============================================================================================================================================================================================================

Write-Host "`n[1/5] Erstelle Ordnerstruktur..." -ForegroundColor Yellow
foreach ($Folder in $FoldersToCreate) {
	if (-not (Test-Path -Path $Folder)) {
	    New-Item -ItemType Directory - Path $Folder -Force | Out-Null
	    Write-Host " -> Order erstellt: $Folder" -ForegroundColor Green
	} else {
	    Write-Host " -> Ordner existiert bereits: $Folder" -ForegroundColor Gray
	}
}

#============================================================================================================================================================================================================
# 4. SOFTWARE INSTALLATION (via Winget)
#============================================================================================================================================================================================================

Write-Host "`n[2/5] Installiere Software mit winget..." -ForegroundColor Yellow

# Prüfen, ob winget verfügbar ist
if (Get-Command winget -ErrorAction SilentlyContinue) {
    foreach ($App in $AppsToInstall) {
        Write-Host "  -> Installiere $App..." -ForegroundColor Cyan
        winget install --id $App --exact --silent --accept-package-agreements --accept-source-agreements
    }
} else {
    Write-Warning "winget wurde nicht gefunden! Bitte App-Installer über den Microsoft Store aktualisieren."
}

#============================================================================================================================================================================================================
# 5. WINDOWS EINSTELLUNGEN ANPASSEN
#============================================================================================================================================================================================================

Write-Host "`n[3/5] Passe Windows-Einstellunen an..." -ForegroundColor Yellow

#Registry Backup erstellen
$ZielOrdner = "C:\Registry-Backups"
New-Item -Path $ZielOrdner -ItemType Directory -Force | Out-Null

$Datum = Get-Date -Format "dd-MM-yyyy_HH-mm"
$Datei = "$ZielOrdner\HKCU_Backup_$Datum.reg"

reg export "HKCU" $Datei /y

# Dateiendungen im Explorer immer anzeigen (0 = anzeigen, 1 = ausblenden)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

	Write-Host "  -> Dateiendungen eingeblendet." -ForegroundColor Green

# Versteckte Dateien im Explorer anzeigen (1 = anzeigen, 2 = ausblenden)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

	Write-Host "  -> Versteckte Dateien eingeblendet." -ForegroundColor Green

# Dark Mode für Apps und System aktivieren (0 = Dark, 1 = Light)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0

	Write-Host "  -> Dark Mode aktiviert." -ForegroundColor Green

# Mauszeigerbeschleunigung deaktivieren (Werte müssen Strings sein)
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Type String
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Type String
Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Type String

	Write-Host "  -> Mauszeigergeschleunigung deaktiviert." -ForegroundColor Green

# Suche aus der Taskleiste entfernen (0 = Aus, 1 = Nur Symbol, 2 = Suchfeld)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

	Write-Host "  -> Suche aus Taskleiste entfernt." -ForegroundColor Green

# Taskleiste links ausrichten (Windows 11: 0 = Links, 1 = Zentriert)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord

	Write-Host "  -> Taskleiste Links ausgerichtet." -ForegroundColor Green

# System-Icons aus Taskleiste entfernen (Widgets, Chat, Aktive Anwendungen)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord

	Write-Host "  -> System-Icons aus Taskleiste entfernt." -ForegroundColor Green

# Klassisches Rechtsklick-Menü 
New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value ""

	Write-Host " -> Klassisches Rechtsklick-Menü aktiviert." -ForegroundColor Green

# Sekunden in der Taskleisten-Uhr anzeigen
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSecondsInSystemClock" -Value 1 -Type DWord

	Write-Host " -> Uhrzeit in Sekunden aktiviert." -ForegroundColor Green

# Datei-Explorer mit "Dieser PC" öffnen
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1 -Type DWord

	Write-Host " -> Dieser PC Ansicht in Explorer aktiviert." -ForegroundColor Green

# Bekannte Dateierweiterungen einblenden
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord

	Write-Host " -> Dateiendungen eingeblendet." -ForegroundColor Green

# Versteckte Dateien und Ordner anzeigen
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Type DWord

	Write-Host " -> Versteckte Dateien eingeblendet." -ForegroundColor Green

# Kürzlich verwendete Dateien & Ordner im Schnellzugriff deaktivieren
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0 -Type DWord

	Write-Host " -> Kürzlich verwendete Dateien & Ordner im Schnellzugiff deaktiviert." -ForegroundColor Green

# Bing-Websuche im Startmenü deaktivieren
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord

	Write-Host " -> Bing-Websuche im Startmenü deaktiviert." -ForegroundColor Green

# Werbe-ID deaktivieren
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord

	Write-Host " -> Werbe-ID deaktiviert." -ForegroundColor Green

# Vorgeschlagene Apps und Werbung blockieren
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord

	Write-Host " -> Vorgeschlagene Apps und Werbung blockiert." -ForegroundColor Green

# Windows Copilot vollständig deaktivieren
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

	Write-Host " -> Windows Copilot vollständig deaktiviert." -ForegroundColor Green

# Telemetrie-Datensammlung auf Minimum reduzieren 
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord

	Write-Host " -> Telemetrie und Datensammlung auf ein Minimum reduziert." -ForegroundColor Green

# Menü-Verzögerung auf 0 setzen
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String

	Write-Host " -> Menü-Verzögerung auf 0 gesetzt." -ForegroundColor Green

# Verknüpfung-Suffix entfernen
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "link" -Value ([byte[]](0x00,0x00,0x00,0x00)) -Type Binary

	Write-Host " -> Verknüpfung Suffix entfernt." -ForegroundColor Green

# Zeigt detaillierte Infos beim Starten, Herunterfahren, An-/Abmelden und bei Updates 
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "VerboseStatus" -Value 1 -Type DWord

	Write-Host " -> Detailliertere Informationen aktiviert." -ForegroundColor Green

# Startmenü-Layout: Mehr angeheftete Elemente zeigen (1 = Mehr Pins, 0 = Standard, 2 = Mehr Empfehlungen)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value 1 -Type DWord

	Write-Host " -> Startmenü-Layout verändert." -ForegroundColor Green

# Zuletzt hinzugefügte Apps im Startmenü ausblenden
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0 -Type DWord

	Write-Host " -> Zuletzt hinzugefügte Apps im Startmenü deaktiviert." -ForegroundColor Green

# Empfohlene Dateien / zuletzt geöffnete Elemente im Startmenü & Explorer deaktivieren
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0 -Type DWord

	Write-Host " -> Empfohlene Dateien in Startmenü & Explorer deaktiviert." -ForegroundColor Green

# Kontobezogene Benachrichtigungen (z.B. Microsoft-Konto-Werbung) im Startmenü ausblenden
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Value 0 -Type DWord

	Write-Host " -> Werbebenachichtigungen deaktiviert." -ForegroundColor Green

# Snap-Flyout deaktivieren, wenn man mit der Maus über das Maximieren-Symbol fährt
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableSnapAssistFlyout" -Value 0 -Type DWord

	Write-Host " -> Snap-Flyout deaktiviert." -ForegroundColor Green

# Snap-Leiste am oberen Bildschirmrand deaktivieren, wenn man ein Fenster nach oben zieht
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableSnapBar" -Value 0 -Type DWord

	Write-Host " -> Snap-Leiste deaktiviert." -ForegroundColor Green

# Snap-Assistent (Vorschläge für andere offene Fenster nach dem Andocken) deaktivieren
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 0 -Type DWord

	Write-Host " -> Snap-Assistent deaktiviert." -ForegroundColor Green

# Weitere Einstellungen hier ergänzen...

# DNS-Server ändern
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("1.1.1.1", "1.0.0.1")
Clear-DnsClientCache

	Write-Host " -> DNS-Server auf Cloudflare geändert." -ForegroundColor Green

#Hyper-V aktivieren
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

	Write-Host " -> Hyper-V aktiviert." -ForegroundColor Green
	Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

#WSL installieren
wsl --install -d Debian

	Write-Host " -> WSL installiert. Distribution: Debian(latest)" -ForegroundColor Green

#Transparenzeffekte deaktivieren
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord

	Write-Host " -> Transparenzeffekte deaktiviert." -ForegroundColor Green

#Ausführliche Bluescreen meldungen aktivieren
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "DisplayParameters" -Value 1 -Type DWord

	Write-Host " -> Ausführliche Bluescreen meldungen aktiviert." -ForegroundColor Green

#Sticky Keys deaktivieren
$path = "HKCU:\Control Panel\Accessibility\StickyKeys"
Set-ItemProperty -Path $path -Name "Flags" -Value "506"

	Write-Host " -> Sticky Keys deaktiviert." -ForegroundColor Green

Write-Host "`n[4/5] Starte Windows-Explorer neu, um Änderungen zu übernehmen..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force
Start-Process explorer

#Registry Backup erstellen
$ZielOrdner = "C:\Registry-Backups"
New-Item -Path $ZielOrdner -ItemType Directory -Force | Out-Null

$Datum = Get-Date -Format "dd-MM-yyyy_HH-mm"
$Datei = "$ZielOrdner\HKCU_Backup_$Datum.reg"

reg export "HKCU" $Datei /y

#========================================================
# 6.WÖCHENTLICHES HKCU REGISTRY BACKUP
#=======================================================

# 1. KONFIGURATION 
$SkriptOrdner  = "C:\Registry-Backups"                             
$SkriptName    = "HKCU_Backup.ps1"                         
$BackupZiel    = "C:\Registry-Backups"    
$AufgabenName  = "Woechentliches_HKCU_Backup"              
$Wochentag     = "Sunday"                                  
$Uhrzeit       = "12:00"                                   
$Aufbewahrung  = 30   

# 2. ORDNER ERSTELLEN
New-Item -Path $SkriptOrdner -ItemType Directory -Force | Out-Null
$VollstaendigerSkriptPfad = Join-Path -Path $SkriptOrdner -ChildPath $SkriptName

# 3. BACKUP-SKRIPT GENERIEREN 
$BackupSkriptInhalt = @'
$ZielOrdner = "__BACKUP_ZIEL__"
New-Item -Path $ZielOrdner -ItemType Directory -Force | Out-Null

#Registry-Backup erstellen
$Datum = Get-Date -Format "yyyy-MM-dd_HH-mm"
$Datei = "$ZielOrdner\HKCU_Backup_$Datum.reg"

reg export "HKCU" $Datei /y | Out-Null

# Alte Registry-Backups aufräumen
Get-ChildItem -Path $ZielOrdner -Filter "HKCU_Backup_*.reg" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-__AUFBEWAHRUNG__) } |
    Remove-Item -Force

# WinGet Auto-Update inklusive Protokoll im Backup-Ordner
$LogDatei = "$ZielOrdner\WinGet_Update_$Datum.log"
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements | Out-File -FilePath $LogDatei -Encoding UTF8

# Alte WinGet-Logs ebenfalls aufräumen
Get-ChildItem -Path $ZielOrdner -Filter "WinGet_Update_*.log" |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-__AUFBEWAHRUNG__) } |
    Remove-Item -Force
'@

# Platzhalter im generierten Skript durch Konfigurationswerte ersetzen
$BackupSkriptInhalt = $BackupSkriptInhalt.Replace("__BACKUP_ZIEL__", $BackupZiel)
$BackupSkriptInhalt = $BackupSkriptInhalt.Replace("__AUFBEWAHRUNG__", $Aufbewahrung)

# Datei als UTF-8 speichern
Set-Content -Path $VollstaendigerSkriptPfad -Value $BackupSkriptInhalt -Encoding UTF8 -Force

# 4. AUFGABENPLANUNG REGISTRIEREN
$Aktion    = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$VollstaendigerSkriptPfad`""
$Trigger   = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $Wochentag -At $Uhrzeit
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive
$Settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable

Register-ScheduledTask -TaskName $AufgabenName -Action $Aktion -Trigger $Trigger -Principal $Principal -Settings $Settings -Force | Out-Null

Write-Host "[OK] Wöchentliches HKCU-Backup wurde unter '$VollstaendigerSkriptPfad' eingerichtet." -ForegroundColor Green

#============================================================================================================================================================================================================
# 7. WINDOWS-UPDATE
#============================================================================================================================================================================================================

Write-Host "`n[5/5] Installiere alle ausstehenden Windows Updates"

Write-Host "Starte Vorbereitung für Windows Updates..." -ForegroundColor Cyan

# 1. TLS 1.2 für sichere Verbindung zur PowerShell Gallery erzwingen
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. NuGet PackageProvider prüfen und bei Bedarf installieren 
if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Write-Host "Installiere NuGet PackageProvider..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
}

# 3. PSGallery als vertrauenswürdig einstufen
$repo = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
if ($repo -and $repo.InstallationPolicy -ne 'Trusted') {
    Write-Host "Setze PSGallery auf 'Trusted'..." -ForegroundColor Yellow
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}"

# 4. PSWindowsUpdate Modul prüfen, ggf. installieren und importieren
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host " Installiere Modul 'PSWindowsUpdate'..." -ForegroundColor Yellow
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber
}
Import-Module PSWindowsUpdate

# 5. Nach Updates suchen und installieren
Write-Host "Suche nach Windows- und Microsoft-Updates..." -ForegroundColor Cyan
$Updates = Get-WindowsUpdate -MicrosoftUpdate

if ($Updates.Count -eq 0) {
    Write-Host "Das System ist auf dem neuesten Stand. Keine Updates gefunden." -ForegroundColor Green
} else {
    Write-Host "$($Updates.Count) Update(s) gefunden. Starte Download und Installation..." -ForegroundColor Yellow
    
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot
}

#============================================================================================================================================================================================================
# 8. ABSCHLUSS & AUFRÄUMEN
#============================================================================================================================================================================================================

Write-Host "Alle Programme erfolgreich installiert!"
Write-Host "Alle Ordner erfolgreich erstellt!"
Write-Host "Alle Einstellungen erfolgreich übernommen!"

Write-Host "`n=== Einrichtung abgeschlossen! ===" -ForegroundColor Cyan
Write-Host "Das Protokoll wurde gespeichert unter: $LogPath"
Stop-Transcript

Write-Host "Der Computer startet jetzt neu um alle änderungen sauber zu übernehmen!" -ForegroundColor Red
Write-Host "Viel Spaß mit einem voll Eingerichteten sauberen Windows! :)"

Start-Sleep -Seconds 10
Restart-Computer -Force

