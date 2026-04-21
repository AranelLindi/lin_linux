
# Fedora SSD2 Setup Guide
## 1. SSD identifizieren
<code>
lsblk -f
</code>
(list block devices)

Suchen der zweiten/dritten SSD (z. B. <code>nvme1n1</code> / <code>sda1</code>)

Typische Ausgabe:
<code>/dev/nvme0n1</code> - System-SSD
<code>/dev/nvme1n1</code> - zweite M.2
<code>/dev/sda1</code> - SATA SSD

---

## 2. SSD partitionieren & formatieren (falls nötig)

**ACHTUNG**: Löscht alle Daten!

### 2.1. Partitionieren
<code>
sudo fdisk /dev/nvme1n1
</code>

<code>
sudo fdisk /dev/sda1
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
**Wichtig!** Wird bei <code>mkfs.X</code> direkt die gesamte Platte verwendet, würde die gesamte Parition überschrieben werden, was zur Folge hätte, dass es keine Partition mehr gäbe! Deswegen nur mit Zusatz <code>pX</code> oder <code>sdaX</code>.
- <code>mkfs</code> - make file system
- <code>.btrfs</code> - Das zu verwendende File System (oder <code>.ext4</code> / <code>.vfat -F 32</code>)
- <code>/dev/nvme1n1p1</code> - Die Partition, die formatiert werden soll

Kommando bricht ab falls bereits ein Dateisystem erkannt wird. In diesem Fall Option <code>-f</code> verwenden.
**Idee**: zweite M.2 SSD mit <code>btrfs</code> formatieren, erste M.2 und SATA SSD mit <code>ext4</code>.
**Hinweis!** Bei <code>btrfs</code> wird kein klassisches <code>fsck</code> verwendet, da das Dateisystem eigene Integritätsmechanismen besitzt.

---

## 3. Mountpunkt erstellen

<code>
sudo mkdir /mnt/ssd2
</code> - zweite SSD via M.2

<code>
sudo mkdir /mnt/sda1
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

<code>
sudo nano /etc/fstab
</code>

Neue Zeile hinzufügen:

<code>
UUID=1234-ABCD /mnt/ssd2 btrfs defaults,noatime 0 2
</code> - SSD via M.2

<code>
UUID=4321-DCBA /mnt/sda1 ext4 defaults,noatime,nofail 0 2
</code> - SSD via SATA

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
sudo mkdir -p /mnt/ssd2/dev
</code>

<code>
sudo mkdir -p /mnt/ssd2/projects
</code>

<code>
sudo mkdir -p /mnt/ssd2/media
</code>

<code>
sudo mkdir -p /mnt/ssd2/archive
</code>

### Für erste SSD via SATA (Backup):
<code>
sudo mkdir -p /mnt/sda1/backup
</code>

Besitz setzen (angenommen: <code>slin</code>)

<code>
sudo chown -R slin:slin /mnt/ssd2
</code>

<code>
sudo chown -R slin:slin /mnt/sda1
</code>

---

## 8. Symlinks erstellen
<code>~</code> ist eine Abkürzung für <code>/home/slin/</code>. Also würde z.B. <code>~/dev</code> unter <code>/home/slin/dev</code> zu finden sein.

### M.2 SSD:
<code>
ln -s /mnt/ssd2/dev ~/dev
</code>

<code>
ln -s /mnt/ssd2/projects ~/projects
</code>

<code>
ln -s /mnt/ssd2/media ~/media
</code>

### SATA SSD:
<code>
ln -s /mnt/sda1/backup ~/backup
</code>

Hinweis: Falls ein Zielordner bereits existiert, schlägt <code>ln -s</code> fehl.

---

## Ergebnis

Die zweite SSD ist unter <code>/mnt/ssd2</code> eingebunden.

Zugriff erfolgt bequem über:

<code>
~/dev
</code>

<code>
~/projects
</code>

<code>
~/media
</code>

Die SATA SSD ist unter <code>/mnt/sda1</code> eingebunden.

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