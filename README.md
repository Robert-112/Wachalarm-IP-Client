# Wachalarm-IP-Client

Hier wird der Quellcode der Client-Anwendung des Wachalarm-IP der Leitstelle Lausitz veröffentlicht.
Die Anwendung wurde mit [Lazarus](https://www.lazarus-ide.org/) programmiert und **kann nicht ohne den Wachalarm-IP-Server betrieben werden**.
Der Wachalarm-IP-Server wird dabei i.d.R. durch die einsatzführende Leitstelle betrieben. Er übersendet die Einsatzdaten an die Clients.
Die Leitstelle Lausitz bietet den Wachalarm-IP akutell nur für ständig besetzte Wachen (Rettungswachen, Feuerwachen mit hauptamtlichen Kräften) an. Freiwillige Feuerwehren werden durch die Leitstelle Lausitz nicht angebunden.

# Installation

Um den Wachalarm-IP-Client nutzen/testen zu können, muss dieser zunächst für das Ziel-Betriebssystem kompiliert werden. Es wird sowohl Windows als auch Linux unterstützt (getestet mit Windows XP, Windows 7 (x86, x64), Windows 10 (x86, x64), Debian 7, Debian 8, Ubuntu, Raspberry Pi 1).
1. Lazarus installieren (siehe [https://www.lazarus-ide.org/](https://www.lazarus-ide.org/))
2. Quelldateien dieses Repositorys herunterladen
3. *.zip-Datei entpacken und in das Verzeichnis wechseln
4. >Optional: in der Datei *"credentials.res"* die Zugangsdaten anpassen
5. *"Wachalarm-IP_Client.lpi"* (Projektdatei) mit Lazarus öffnen
6. Anwendung kompilieren (STRG + F9)
7. In das Verzeichnis wechseln und die erzeugte Anwendung (z.B. *"Wachalarm-IP-Client_win64.exe"*) starten. 
Alternativ kann die Anwendung zuvor auch in ein neues Verzeichnis kopiert werden (z.B. *"C:\Wachalarm"*).

Nachdem der Client gestartet wurde, wartet er auf neue Alarme vom Server. In der Task-Leiste erscheint ein entsprechendes Icon ![Icon](https://user-images.githubusercontent.com/19272095/47442342-80ceff00-d7b2-11e8-8ab0-d1ed2914ec23.png "Tray-Icon") .
Im Client selbst können anschließend noch weitere Einstellungen getätigt werden.

# Netzwerk

Wachalarm-IP-Client und Wachalarm-IP-Server müssen über eine Netzwerkverbindung erreichbar sein. Dies wird i.d.R. dadurch erreicht, dass sich beide:

 - im selben Subnetz befinden
 - durch Routing erreichen können
 - per VPN verbunden sind

Außerdem müssen in den Firewalls (Router, Betriebssystemfirewall) die notwendigen Ports freigegeben werden. Für eine korrekte Funktionsweise werden benötigt:

 - 60132 UDP
 - 60143 & 60144 TCP
 - ICMP (Ping)

# Einstellungen
Im nachfolgenden wird erklärt, welche Einstellungen am Wachalarm-IP-Client getätig werden können. Das entsprechende Menü wird per Doppelklick / Rechtsklick auf das Tray-Icon geöffnet. Alle Einstellungen werden im Unterordner *"config"* in der Datei *"config.ini"* gespeichert.
### Bildschirmanzeige
:ballot_box_with_check: Alarmbild anzeigen
>Legt fest, ob bei einem Einsatzalarm ein Alarmbild über dem gesamten Monitor angezeigt werden soll.

:ballot_box_with_check: Digitaluhr
>Solange kein Einsatz ansteht, werden die aktuelle Uhrzeit und das aktuelle Datum als Bildschirmschoner angezeigt.

:ballot_box_with_check: PopUp
>Zeigt ein PopUp im System-Tray an, wenn ein neuer Einsatzalarm eingeht.

### Ton-Ausgabe
:ballot_box_with_check: Alarmgong ausgeben
>Abhängig von der Einsatzart (Rettungsdienst, Feuer/Hilfeleistung) wird ein Gong bei neuen Einsätzen wiedergegeben.

:ballot_box_with_check: Alarmansage / Text-To-Speech
>Bei neuen Einsätzen werden das Stichwort, die Einsatzart und die beteiligten Einsatzmittel angesagt
>Ab Windows 8.1 (Linux wird aktuell nicht unterstützt) kann der komplette Einsatztext zudem über die synthetische Sprachausgabe angesagt werden. Hierbei wird zusätzlich der Einsatzort und der vollständige Name der Einsatzmittel angesagt. Die Aussprache der Einsatzmittel kann über den Reiter *"Sonstige Einstellungen"* angepasst werden.

:ballot_box_with_check: Einschränkungen (Nachtruhe)

> Sofern gewünscht, können verschiedene Zeiten definiert werden, in denen (abhängig von der Einsatzart) kein Ton ausgegeben werden soll. Dies bietet sich an, wenn die Wache sowohl zu Rettungs- als auch Feuerwehreinsätzen ausrückt.
Beispiel für Nachtruhe von 21:30 Uhr - 7:10 Uhr bei Einsätzen ohne Feuerwehr:

|von Stunde|von Minute|bis Stunde|bis Minute|Brandeinsatz|Hilfeleistung|Rettungsdienst|Krankentransport|Sonstiges|
|--|--|--|--|--|--|--|--|--|
|21|30|07|10|:black_square_button:|:black_square_button:|:white_square_button:|:white_square_button:|:white_square_button:|
### Sonstige Einstellungen
Für die Ansage des Alarmtextes mittels TTS (Text-To-Speech) können hier die gesprochenen Funkrufnamen der Einsatzmittel ausgetauscht werden. Jede Zeile steht für einen neuen Eintrag.
Beispiel um das Einsatzmittel mit der Nummer 01/82-01 als *"NEF 1"* anzusagen:>82==NEF
### Programm beenden
Die Anwendung wird über den Dialog *"Beenden"* (Rechtsklick auf das Tray-Icon) geschlossen.

# Screenshots
## Alarmbild
![alt Alarmbild](https://user-images.githubusercontent.com/19272095/47442148-2766d000-d7b2-11e8-8b40-d80f7318ca1b.png "Beispiel eines Einsatzalarms")
## Digitaluhr
![alt Uhr](https://user-images.githubusercontent.com/19272095/47445560-8419b900-d7b9-11e8-8beb-48ab2da998bb.png "Beispiel Screenshots")

# Lizenz

#### [Creative Commons Attribution Share Alike 4.0 International](https://github.com/Robert-112/Wachalarm-IP-Client/blob/master/LICENSE.md)