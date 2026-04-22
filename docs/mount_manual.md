# Fedora Setup Guide
## 1. SSD identifizieren
<code>
lsblk -f
</code>
(list block devices)

Suchen der zweiten/dritten SSD (z. B. <code>nvme1n1</code> / <code>sda</code>)

Typische Ausgabe:
<code>/dev/nvme0n1</code> - System-SSD
<code>/dev/nvme1n1</code> - zweite M.2
<code>/dev/sda</code> - SATA SSD

---

## 2. SSD partitionieren & formatieren (falls nötig)

**ACHTUNG**: Löscht alle Daten!

### 2.1. Partitionieren
Arbeitet auf Plattenebene nicht Partitionsebene!

<code>
sudo fdisk /dev/nvme1n1
</code>

<code>
sudo fdisk /dev/sda
</code>

Dann im Tool:
<code>g # Neue GPT-Tabelle erstellen
n # Neue Partition erstellen
Enter Enter Enter # Defaults -> Ganze Platte
w # Speichern
</code>


### 2.2. Formatieren
<code>
sudo mkfs.btrfs /dev/nvme1n1p1
</code>

Anmerkung: Eine Partition wird immer mit <code>pX</code> hinten dran gehängt. Bei <code>sda</code> wird direkt hoch gezählt (<code>sdaX</code>).
**Wichtig!** Wird bei <code>mkfs.X</code> direkt die gesamte Platte verwendet, würde die gesamte Parition überschrieben werden, was zur Folge hätte, dass es keine Partition mehr gäbe (weil Partitionstabelle überschrieben würde)! Deswegen nur mit Zusatz <code>pX</code> oder <code>sdaX</code>.
- <code>mkfs</code> - make file system
- <code>.btrfs</code> - Das zu verwendende File System (oder <code>.ext4</code> / <code>.vfat -F 32</code>)
- <code>/dev/nvme1n1p1</code> - Die Partition, die formatiert werden soll

Kommando bricht ab falls bereits ein Dateisystem erkannt wird. In diesem Fall Option <code>-f</code> verwenden.
**Idee**: zweite M.2 SSD mit <code>ext4</code> formatieren, erste M.2 und SATA SSD mit <code>btrfs</code>.
**Hinweis!** Bei <code>btrfs</code> wird kein klassisches <code>fsck</code> verwendet, da das Dateisystem eigene Integritätsmechanismen besitzt.

Vorschlag:
- primäre SSD (NVME, OS + Games): <code>btrfs</code>
- sekundäre SSD (NVME, Development): <code>ext4</code>
- backup SSD (SATA): <code>btrfs</code>

---

## 3. Mountpunkt erstellen

<code>
sudo mkdir -p /development
</code> - zweite SSD via M.2

<code>
sudo mkdir -p /backup
</code> - erste SSD via SATA

---

## 4. UUID herausfinden

<code>
blkid
</code>

Beispiel:

<code>
/dev/nvme1n1p1: UUID="1234-ABCD" TYPE="btrfs"
</code>

---

## 5. fstab bearbeiten
*Wichtig!* Kommentare in fstab werden am Zeilenanfang mit <code>#</code> eingeläutet! Unbedingt nutzen um Partitionen zu bescheiben!

<code>
sudo nano /etc/fstab
</code>

Neue Zeile hinzufügen (nur exemplarisch, Parameter stehen weiter unten!):

<code>
UUID=1234-ABCD /development btrfs defaults,noatime 0 2
</code> - Parameter je Laufwerk siehe unten

- <code>UUID=</code> - welches Gerät
- <code>/mnt/ssd2</code> - wohin mounten
- <code>btrfs</code> - Dateisystem
- <code>options</code> - Mount-Optionen
- <code>0</code> - dump (irrelevant!)
- <code>0</code> - fsck Reihenfolge (0 = wird nie geprüft, 1 = zuerst (Root-Dateisystem), 2 = Neben-Prio (Standard für Datenlaufwerke) *[* <code>Btrfs</code> *hat eigene Mechanismen und sollte deswegen hier auf 0 gesetzt werden!]*

Wichtige Optionen erklärt:
- <code>defaults</code> - Standardwerte (rw, auto, exec, etc. [normales Verhalten])
- <code>noatime</code> - Verhindert, dass bei jedem Lesen die Zugriffszeit gespeichert wird
- <code>nofail</code> - System bootet auch wenn diese SSD nicht gefunden werden kann
- <code>compress=zstd</code> - Komprimiert Daten beim schreiben / entkomprimiert sie beim Lesen. Spart Speicherplatz und belastet CPU nur marginal.
- <code>data=ordered</code> - Nur für ext4 relevant und quasi Standardverhalten (Daten werden vor Metadaten geschrieben)

Vorschlag:
- primäre SSD: <code>compress=zstd,noatime,ssd,space_cache=v2 0 0</code>
- sekundäre SSD: <code>noatime,data=ordered 0 2</code>
- backup SSD: <code>compress=zstd:3,noatime,ssd,space_cache=v2 0 0</code>

---

## 6. Mount aktivieren

<code>
sudo mount -a
</code>

Wenn kein Fehler erscheint, ist alles korrekt

---

## 7. Ordnerstruktur anlegen

### Für zweite SSD (M.2):
<code>
sudo mkdir -p /development/projects
</code>

<code>
sudo mkdir -p /development/yocto
</code>

### Für erste SSD via SATA (Backup):
<code>
sudo mkdir -p /backup/snapshots
</code>

<code>
sudo mkdir -p /backup/custom_backup
</code>

Besitz setzen (angenommen: <code>slin</code>)

<code>
sudo chown -R slin:slin /development
</code>

<code>
sudo chown -R slin:slin /backup
</code>

---

## 8. Symlinks erstellen (Kann übersprungen werden wenn Laufwerke direkt gemountet werden und nicht in /mnt/...)
<code>~</code> ist eine Abkürzung für <code>/home/slin/</code>. Also würde z.B. <code>~/development</code> unter <code>/home/slin/development</code> zu finden sein.

---

## Ergebnis

Die zweite SSD ist unter <code>/development</code> eingebunden.

Zugriff erfolgt bequem über:

<code>
~/development
</code>

Die SATA SSD ist unter <code>/backup</code> eingebunden.

Zugriff erfolgt über:

<code>
~/backup
</code>

---

## Hinweise

- Symlinks sind einfache Verknüpfungen.
- pwd zeigt immer den echten Pfad (<code>/mnt/ssd2/...</code>), also - <code>cd ~/dev</code> bringt tatsächlich nach <code>/mnt/ssd2/dev</code>.
- Kein Neustart nötig nach Änderungen in fstab.
- <code>ls -l ~</code> zeigt die Symlinks, die unter <code>/home/slin/</code> liegen direkt an.
- <code>find ~ -type l</code> sucht nach allen Symlinks im <code>/home</code> Verzeichnis und darunter.
## SSD-Optimierung mit fstrim (TRIM)

Moderne SSDs benötigen sogenannte **TRIM-Operationen**, damit sie wissen, welche Speicherbereiche nicht mehr verwendet werden. Ohne TRIM kann die Schreibperformance langfristig schlechter werden.

`fstrim` teilt der SSD mit, welche Blöcke frei sind. Es werden **keine Daten verschoben** (also keine Defragmentierung), sondern nur Metadaten aktualisiert.

### Status prüfen

<code>systemctl status fstrim.timer</code>

Wenn der Timer aktiv ist, wird TRIM automatisch regelmäßig ausgeführt (typisch: 1x pro Woche).

### Manuell ausführen

<code>sudo fstrim -av</code>

Zeigt an, wie viele Daten freigegeben wurden.

### Aktivieren (falls deaktiviert)

<code>sudo systemctl enable fstrim.timer</code>

### Empfehlung

- `fstrim.timer` verwenden (Standard und effizient)
- **kein `discard`** in `/etc/fstab` setzen (kann Performance kosten)

### Anzeige von freiem Speicherplatz
<code>df -h</code>
