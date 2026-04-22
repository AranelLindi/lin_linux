# Fedora Btrfs Subvolume Guide

## Ziel

Dieses Setup trennt System und Benutzerdaten logisch:

- `@` → Root (`/`)
- `@home` → Home (`/home`)

Vorteile:
- saubere Snapshots
- einfaches Rollback
- bessere Backup-Strategien

---

# 1. Subvolumes während der Fedora Installation erstellen (empfohlen)

## Schritt 1: Custom Partitioning wählen
- Im Fedora Installer: **"Custom" / "Benutzerdefiniert"**
- Ziel: Btrfs als Dateisystem wählen

---

## Schritt 2: Btrfs Volume erstellen
- SSD auswählen
- Mountpoint `/` setzen
- Fedora erstellt automatisch Subvolumes:
  - `root`
  - `home`

---

## Schritt 3: Subvolumes umbenennen

Ändere:

| Standard | Ziel |
|----------|------|
| `root`   | `@`  |
| `home`   | `@home` |

---

## Ergebnis

| Subvolume | Mountpoint |
|-----------|-----------|
| `@`       | `/`       |
| `@home`   | `/home`   |

---

## Ergebnis in `/etc/fstab`

<code>
UUID=XXXX /     btrfs subvol=@,compress=zstd:1,noatime 0 0
UUID=XXXX /home btrfs subvol=@home,compress=zstd:1,noatime 0 0
</code>

# 2. Subvolumes-Befehle

Liste aller Subvolumes
<code>
btrfs subvolume list /
</code>

Neues Subvolume erstellen
<code>
btrfs subvolume create /pfad/zum/subvolume
</code>

Subvolume löschen
<code>
btrfs subvolume delete /pfad/zum/subvolume
</code>

# 3. Snapshots erstellen (read-only empfohlen)
<code>
# Root [@]
btrfs subvolume snapshot -r / /.snapshots/root_$(date +%F)
# Home [@home]
btrfs subvolume snapshot -r /home /.snapshots/home_$(date +%F)
</code>

Es wird nie mit <code>@</code>-Namen gearbeitet sondern über <code>/</code> und <code>/home</code>.

Snapshot ohne read-only
<code>
btrfs subvolume snapshot /home /.snapshots/home_test
</code>

Snapshot löschen
<code>
btrfs subvolume delete /.snapshots/root_2026-04-22
</code>

# 4. Backup mit send / receive

Erstes Backup (vollständig)
<code>
btrfs send /.snapshots/home_2026-04-22 | btrfs receive /backup/home
</code>
Snapshot wird gelesen, Datenstrom erzeugt und über Pipe <code>|</code> auf Ziel aufgebaut. Es wird nichts überschrieben sondern ein neues Subvolume erstellt.

Inkrementelles Backup (Nur Änderungen zwischen Snapshot1 und Snapshot2)
<code>
btrfs send -p old_snapshot new_snapshot | btrfs receive /backup/home
</code>

Parameter <code>-p</code> steht für parent snapshot: Hier werden nur Änderungen von <code>old_snapshot</code> und <code>new_snapshot</code> übertragen. (Sehr schnell, sehr wenig Daten)

Beispiel:
<code>
btrfs send -p home_2026-04-21 home_2026-04-22 | btrfs receive /backup/home
</code>

# 5. Snapshot Verzeichnis anlegen
<code>
sudo mkdir /.snapshots
sudo mkdir /.snapshots/home
</code>

# 6. Typischer Workflow

Vor Update:
<code>
# 1. Snapshot [/ -> Quelle (Root), /.snapshots/root_pre_update -> Ziel, -r -> read-only]
btrfs subvolume snapshot -r / /.snapshots/root_pre_update
# 2. senden
btrfs send /.snapshots/root_pre_update | btrfs receive /backup/root
# 3. optional löschen
btrfs subvolume delete /.snapshots/root_pre_update
</code>

Regelmäßiges Backup:
1. Snapshot erstellen
2. Snapshost übertragen <code>send/receive</code>

# 7. Wichtige Hinweise
- Snapshots sind keine Backups
- Immer zusätzlich auf andere SSD sichern
- /home sollte immer eigenes Subvolume sein
- Subvolumes sind keine normalen Ordner

# 8. Empfehlung

Best Practice für lokale Snapshots (nicht unter /backup !): <code>/.snapshots</code> zur Sicherung von Snapshots verwenden!

Minimal-Setup
- <code>@</code> -> root
- <code>@home</code> -> home

Alles andere später hinzufügen

# 9. Anwendungen

## Methode 1: Einzelne Datei zurückholen
<code>
cp /.snapshots/home_2026-04-22/meinedatei.txt ~/
</code>

Es kann ganz normal im Ordner manövriert werden.

## Methode 2: Subvolume ersetzen (Rollback)
Mit Live-USB Stick:
<code>
# 1. /backup mounten
mount /dev/sda1 /backup
# 2. zurückholen (send/recieve nutzt man nur zwischen System oder File Systemen)
btrfs subvolume snapshot /backup/home/home_2026-04-22 /home
</code>
