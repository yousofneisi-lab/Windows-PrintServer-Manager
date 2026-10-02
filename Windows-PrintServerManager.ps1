# ==========================================================
#  Windows-PrintServerManager
#  Autor: Yousof
#  Website: Neisitech.de
# ==========================================================

# Administratorrechte prüfen
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "HINWEIS: Dieses Skript erfordert Administratorrechte. Bitte starte die PowerShell als Administrator." -ForegroundColor Red
    Pause
    exit
}

function Show-Header {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "             WINDOWS PRINT SERVER MANAGER                " -ForegroundColor Green
    Write-Host "  Autor: Yousof | Website: Neisitech.de                  " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "Ein zentrales Verwaltungstool für Windows-Druckumgebungen." -ForegroundColor Gray
    Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

function Install-PrintServerRole {
    Show-Header
    Write-Host "[1] Print-Server Rolle & RSAT-Tools installieren" -ForegroundColor Yellow
    Write-Host ""
    try {
        Write-Host "Installiere Server-Rolle und Verwaltungswerkzeuge..." -ForegroundColor Cyan
        Install-WindowsFeature -Name Print-Server, RSAT-Print-Services -IncludeManagementTools
        Write-Host "`nErfolgreich installiert!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler bei der Installation: $_" -ForegroundColor Red
    }
    Pause
}

function Add-CustomPrinter {
    Show-Header
    Write-Host "[2] Neuen TCP/IP-Drucker anlegen & freigeben" -ForegroundColor Yellow
    Write-Host ""

    $printerName = Read-Host "Druckername eingeben (z.B. PRN-Office-01)"
    $ipAddress   = Read-Host "IP-Adresse des Druckers eingeben (z.B. 192.168.1.50)"
    $driverName  = Read-Host "Exakter Name des installierten Treibers"
    $shareName   = Read-Host "Freigabename (oder Enter für '$printerName')"

    if ([string]::IsNullOrWhiteSpace($shareName)) { $shareName =$printerName }

    $portName = "IP_$ipAddress"

    try {
        # Port prüfen / anlegen
        if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
            Write-Host "Erstelle Druckerport '$portName'..." -ForegroundColor Cyan
            Add-PrinterPort -Name $portName -PrinterHostAddress$ipAddress
        }

        # Drucker anlegen
        Write-Host "Erstelle Drucker '$printerName'..." -ForegroundColor Cyan
        Add-Printer -Name $printerName -DriverName $driverName -PortName$portName

        # Freigabe aktivieren
        Write-Host "Gibt Drucker frei als '$shareName'..." -ForegroundColor Cyan
        Set-Printer -Name $printerName -Shared $true -ShareName$shareName

        Write-Host "`nDrucker erfolgreich eingerichtet und freigegeben!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler beim Erstellen des Druckers: $_" -ForegroundColor Red
    }
    Pause
}

function Publish-PrinterToAD {
    Show-Header
    Write-Host "[3] Drucker im Active Directory veröffentlichen" -ForegroundColor Yellow
    Write-Host ""

    $printerName = Read-Host "Name des freigegebenen Druckers"
    $location    = Read-Host "Standortangabe (z.B. Gebaeude A, Etage 2)"

    try {
        Set-Printer -Name $printerName -Location $location -Published$true
        Write-Host "`nDrucker '$printerName' wurde erfolgreich im AD veröffentlicht!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler: Stelle sicher, dass der Server Mitglied einer Domäne ist. Details: $_" -ForegroundColor Red
    }
    Pause
}

function Set-SpoolDirectory {
    Show-Header
    Write-Host "[4] Spooler-Verzeichnis ändern" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Das Verschieben des Spool-Ordners auf eine eigene Partition verhindert Speicherengpässe auf C:." -ForegroundColor Gray
    Write-Host ""

    $newPath = Read-Host "Neuer Pfad für den Druckspooler (z.B. D:\Spooler)"

    if (-not (Test-Path -Path $newPath)) {
        New-Item -Path $newPath -ItemType Directory -Force | Out-Null
    }

    try {
        Write-Host "Stoppe Druckspooler-Dienst..." -ForegroundColor Cyan
        Stop-Service -Name Spooler -Force

        Write-Host "Setze neuen Registry-Eintrag..." -ForegroundColor Cyan
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers" -Name "DefaultSpoolDirectory" -Value $newPath

        Write-Host "Starte Druckspooler-Dienst neu..." -ForegroundColor Cyan
        Start-Service -Name Spooler

        Write-Host "`nSpooler-Verzeichnis erfolgreich auf '$newPath' geändert!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler beim Ändern des Spooler-Verzeichnisses: $_" -ForegroundColor Red
    }
    Pause
}

function Update-PrinterDriver {
    Show-Header
    Write-Host "[5] Druckertreiber eines bestehenden Druckers wechseln" -ForegroundColor Yellow
    Write-Host ""

    $printerName = Read-Host "Name des Druckers"
    $newDriver   = Read-Host "Exakter Name des neuen, auf dem System vorhandenen Treibers"

    try {
        Set-Printer -Name $printerName -DriverName$newDriver
        Write-Host "`nTreiber für '$printerName' erfolgreich auf '$newDriver' aktualisiert!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler beim Aktualisieren des Treibers: $_" -ForegroundColor Red
    }
    Pause
}

function Test-PrinterPage {
    Show-Header
    Write-Host "[6] Testseite drucken" -ForegroundColor Yellow
    Write-Host ""

    $printerName = Read-Host "Name des Druckers für den Testdruck"

    try {
        $printer = Get-CimInstance -ClassName Win32_Printer \vert{} Where-Object Name -eq$printerName
        if ($printer) {
            Invoke-CimMethod -InputObject $printer -MethodName PrintTestPage | Out-Null
            Write-Host "`nTestseite für '$printerName' wurde erfolgreich an den Drucker gesendet!" -ForegroundColor Green
        } else {
            Write-Host "`nDrucker '$printerName' wurde nicht gefunden." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "`nFehler beim Senden der Testseite: $_" -ForegroundColor Red
    }
    Pause
}

function Add-PrinterPooling {
    Show-Header
    Write-Host "[7] Drucker-Pool (Printer Pooling) einrichten" -ForegroundColor Yellow
    Write-Host ""

    $printerName = Read-Host "Name des Hauptdruckers"
    $ports       = Read-Host "Kommagetrennte Liste der Ports (z.B. IP_192.168.1.50,IP_192.168.1.51)"

    try {
        $portList = $ports -replace '\s+', ''
        rundll32.exe printui.dll,PrintUIEntry /Xs /n "$printerName" Portname "$portList"
        Write-Host "`nDrucker-Pool für '$printerName' mit den Ports '$portList' eingerichtet!" -ForegroundColor Green
    }
    catch {
        Write-Host "`nFehler beim Erstellen des Drucker-Pools: $_" -ForegroundColor Red
    }
    Pause
}

function Show-PrinterOverview {
    Show-Header
    Write-Host "[8] Systemübersicht anzeigen" -ForegroundColor Yellow
    Write-Host ""

    Write-Host "--- INSTALLIERTE DRUCKER ---" -ForegroundColor Cyan
    Get-Printer | Format-Table Name, DriverName, PortName, Shared, Published -AutoSize

    Write-Host "--- DRUCKERPORTS ---" -ForegroundColor Cyan
    Get-PrinterPort | Select-Object Name, PrinterHostAddress | Format-Table -AutoSize

    Write-Host "--- SPOOLER VERZEICHNIS ---" -ForegroundColor Cyan
    $spoolDir = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers").DefaultSpoolDirectory
    Write-Host "Aktueller Pfad: $spoolDir`n" -ForegroundColor White

    Pause
}

# Hauptschleife (Menü)
do {
    Show-Header
    Write-Host "Bitte wähle eine Option:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1) Print-Server Rolle & RSAT installieren" -ForegroundColor Gray
    Write-Host "  2) Neuen TCP/IP-Drucker anlegen & freigeben" -ForegroundColor Gray
    Write-Host "  3) Drucker im Active Directory veröffentlichen" -ForegroundColor Gray
    Write-Host "  4) Spooler-Verzeichnis ändern" -ForegroundColor Gray
    Write-Host "  5) Druckertreiber wechseln" -ForegroundColor Gray
    Write-Host "  6) Testseite drucken" -ForegroundColor Gray
    Write-Host "  7) Drucker-Pool einrichten" -ForegroundColor Gray
    Write-Host "  8) System- und Druckerübersicht anzeigen" -ForegroundColor Gray
    Write-Host "  Q) Beenden" -ForegroundColor Red
    Write-Host ""
    $selection = Read-Host "Auswahl"

    switch ($selection.ToUpper()) {
        '1' { Install-PrintServerRole }
        '2' { Add-CustomPrinter }
        '3' { Publish-PrinterToAD }
        '4' { Set-SpoolDirectory }
        '5' { Update-PrinterDriver }
        '6' { Test-PrinterPage }
        '7' { Add-PrinterPooling }
        '8' { Show-PrinterOverview }
        'Q' { Show-Header; Write-Host "Auf Wiedersehen!" -ForegroundColor Green; Start-Sleep -Seconds 1 }
        default { Write-Host "Ungültige Auswahl, bitte erneut versuchen." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($selection.ToUpper() -ne 'Q')
