# Windows-PrintServer-Manager
Ein interaktives PowerShell-Tool zur zentralen Verwaltung, Konfiguration und Automatisierung von Windows-Druckservern, -Treibern, -Freigaben und -Spooler-Einstellungen.

# Windows-PrintServer-Manager

Ein interaktives PowerShell-Werkzeug zur zentralen Automatisierung, Konfiguration und Verwaltung von Windows-Druckservern.

## Autor & Impressum

* **Autor:** Yousof
* **Website:** [Neisitech.de](https://neisitech.de)



## Funktionsumfang

Das Skript bietet ein strukturierte, farbige Konsoleoberfläche mit folgenden Funktionen:

* **Rolleninstallation:** Schnelle Installation der Windows Server `Print-Server`-Rolle inklusive RSAT-Verwaltungswerkzeugen.
* **Druckereinrichtung:** Automatische Erstellung von TCP/IP-Druckerports, Hinzufügen von Druckern und Konfiguration von Netzwerkfreigaben.
* **Active Directory Integration:** Veröffentlichen von Druckern im AD inklusive Standortangaben zur leichten Auffindbarkeit für Benutzer.
* **Spooler-Optimierung:** Pfadänderung des Druckspooler-Verzeichnisses zur Entlastung des Systemlaufwerks.
* **Treiber-Management:** Einfacher Wechsel von zugewiesenen Druckertreibern für bestehende Drucker.
* **Wartung & Test:** Ausführen von Testdrucken über CIM/WMI.
* **Printer Pooling:** Zusammenschluss mehrerer physischer Ports zu einem Drucker-Pool für Lastverteilung.
* **Übersicht:** Schnelle Anzeige aller installierten Drucker, Ports und des Spooler-Pfads.



## Voraussetzungen

* **Betriebssystem:** Windows Server 2016, 2019, 2022 oder höher.
* **Rechte:** PowerShell muss mit **Administratorrechten** gestartet werden.
* **PowerShell Version:** Windows PowerShell 5.1 oder PowerShell 7+.



## Installation & Nutzung

1. Repository klonen oder Skript herunterladen:

   git clone [https://github.com/DEIN-USERNAME/Windows-PrintServer-Manager.git](https://github.com/DEIN-USERNAME/Windows-PrintServer-Manager.git)


PowerShell als Administrator öffnen.

Skript ausführen:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process .\Windows-PrintServerManager.ps1


## Lizenz
Dieses Projekt steht unter der MIT-Lizenz. Freie Nutzung für administrative und kommerzielle Zwecke.
