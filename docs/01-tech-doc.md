# Nota – Tech-Doc

**Projekt:** Nota
**Repo:** github.com/Maks1m-Se/nota
**Lokal:** `C:\Git\nota`
**Letzter Stand:** 14.09.2026

## Was ist Nota

Flutter-basierte Setlist-Management-App für aktive Musiker. Optimiert für Tablet-Nutzung in Probe und Live. Verwaltet Songs, Setlists und Gigs mit Canvas-basierten Notizen pro Song.

**Zielgerät:** Samsung Galaxy Tab S6 Lite (R52NC05R33J), Landscape, Immersive Mode.

## Ziele

- Schneller Zugriff auf Songs, Setlists und Gigs während Live-Auftritten
- Handschriftliche Notizen pro Song (S Pen oder Finger), inkl. Chord Charts als Hintergrund
- Bühnentauglicher Live-Modus: Canvas, Setliste und Songinfos auf einen Blick
- Zentrale Datenspeicherung mit Backup auf eigenem Nextcloud-Server
- Tab-Stop-Layout im Live-Modus für konstante Info-Position

## Stack

- Flutter 3.41.6, Dart 3.11.4, Android SDK 36
- Provider (State Management)
- shared_preferences (Persistenz, JSON-Blob)
- pdfx, file_picker (PDF Import)
- flutter_colorpicker

## Architektur

**State Management:** Ein zentraler `BandProvider` mit allen Daten.

**Datenhierarchie:**
Bands → Songs / Setlists / Gigs (mit SongSlots für Reihenfolge)

**Persistenz:** Alle Daten als ein einziges JSON-Blob in SharedPreferences. Chord Charts liegen seit 07/2026 als PNG-Files unter `documents/charts/`, im Blob steht nur der Dateiname (`chordChartFile`). Service: `lib/services/chart_storage.dart` (ChartStorage, alle Methoden static). Blob-Größe aktuell ~7 MB, nahezu vollständig Strichdaten. Stroke-Save ist debounced (`_scheduleStrokeSave`, 800ms) + Lifecycle-Flush (`flushPendingSave` in `app.dart`); alle anderen Saves sofort.
`practiceItems` (band-scoped) als vierter Top-Level-Key im JSON-Blob. Backwards-compatible: alte Backups ohne den Key laufen (`as Map? ?? {}`), inneres try-catch schützt Songs/Setlists/Gigs vor Practice-Parse-Fehlern.

Zentrale Datums-Logik im `BandProvider`: `isToday()`/`isPastDay()` (tages-genau, statisch), `todayGig()`/`nextUpcomingGig()` (cross-band, `(bandId, gig)`-Record). Screens vergleichen NICHT selbst gegen `DateTime.now()`.

**File-Struktur:**
```
lib/
├── models/        – reine Datenklassen
├── providers/     – State Management (BandProvider)
├── screens/       – pro Feature ein Ordner (bands, library, setlists, gigs, live, settings)
└── widgets/       – wiederverwendbare Widgets (drawing_canvas, drawing_toolbar)
```

- **Practice:** Übungsliste pro Band. Items (Text, optional song-gebunden, Prio H/M/N, erledigt). Capture aus Song-AppBar (vorbelegt) + Practice-FAB (Dropdown). Prio-Sort, Erledigt-Sektion, Filter, Swipe-Delete. Amber-Badges in Library + Nav. Model: `lib/models/practice_item.dart`, Screen: `lib/screens/practice/`.

- **Startscreen (Dashboard):** `band_list_screen.dart`. Widget-Zone (Landscape, zwei Karten): Gig-Widget (heutiger/nächster Gig cross-band) + Practice-Widget (Top-5 offen cross-band, direkt abhakbar). Darunter Band-Grid (3 Spalten). Tap navigiert via `BandScaffold(initialIndex/initialGig)` in die Ziel-Band.

- **Band-Management:** Anlegen über "+"-Kachel im Grid, Long-Press → Bottom Sheet (Edit/Delete). `add_band_dialog.dart`, `edit_band_dialog.dart`. Delete räumt Songs, Setlists, Gigs, Practice-Items und Chart-Files ab.

## Setup / Deployment

**Hardware:** Windows PC unter `C:\Git\nota`, Tablet via USB.

**Run:**
```bash
flutter run -d R52NC05R33J
```

**Hot Restart:** Shift+R im Flutter-Terminal.

**Workflow nach Feature-Abschluss:**
```bash
git add . && git commit -m "..." && git push
```

**Implementierung via Claude Code:** Multi-File-Features werden mit Claude Code gebaut (CLI, editiert Repo direkt). Guardrails in `CLAUDE.md` (Repo-Root). Sparring und Architektur laufen im Nota Management-Hub (siehe Chat-Architektur).


## Daten / Backup

**Nextcloud WebDAV (manuelles Backup/Restore):**
- Server: `nextcloud.homecloudms.duckdns.org`
- Pfad: `/remote.php/dav/files/MaksimSendetski/Apps/Nota/nota_backup.json`
- Credentials: Bitwarden-Eintrag "Nota App - Nextcloud"

**Pi/Homecloud:**
- Hostname: `boxy3006@HomeCloudMS`, IP `192.168.2.200`

**Vollständiges Backup = ZWEI Artefakte** (seit Chart→Files-Migration):
1. `shared_prefs/FlutterSharedPreferences.xml` — alle Daten außer Charts
2. `app_flutter/charts/` — die Chart-PNGs

adb-Route (PATH ist dauerhaft gesetzt):

    $ts = Get-Date -Format 'yyyy-MM-dd_HHmm'
    cmd /c "adb exec-out run-as com.nota.nota cat shared_prefs/FlutterSharedPreferences.xml > C:\Git\nota_backups\prefs_$ts.xml"
    cmd /c "adb exec-out run-as com.nota.nota tar c app_flutter/charts > C:\Git\nota_backups\charts_$ts.tar"

`cmd /c` ist Pflicht (PowerShells `>` schreibt UTF-16 und zerstört die XML).
Danach Größen prüfen — ein fehlgeschlagener Befehl hinterlässt eine 0-Byte-Datei.

## Bekannte Einschränkungen

- Canvas-Striche als absolute Pixel gespeichert → Sidebar-Modus zeigt Canvas-Ausschnitt. Refactoring zu relativen Koordinaten im Backlog.
- Rotation für Chord Chart bewusst weggelassen, nachrüstbar.
- Nextcloud Backup nur manuell.
- Backup-JSON enthält Charts weiterhin als Base64 (Export-Format bewusst unverändert) → Backup-Datei wächst mit Chart-Zahl.
- Prefs-Blob ~7 MB durch Strichdaten (volle Double-Präzision, Key-Namen pro Punkt) → Save-Spikes.
- Mehrseitige PDFs nicht unterstützt (nur erste Seite).

## Designprinzipien

**Bühnentauglich**
- Auf einen Blick erfassbar, große Schrift
- Klare Farbcodes: Solo=rot (Achtung), Backing=blau (ruhig), Key=lila
- Tab-Stop-Layout: Infos immer an derselben Position bei Songwechsel

**Landscape-first, Immersive Mode**
- Maximale Bildschirmnutzung, keine Ablenkung
- Toolbars/Overlays nur wenn nötig, Auto-Hide nach 3s

**Theming**
- Dunkles Design, Primary Color #7F77DD (Lila)

**Live-Modus-Defaults**
- Standard: WithSidebar (mehr Kontext, Setliste sichtbar)
- Modi: Fullscreen, WithSidebar, SetlistOnly
- Swipe-Schwelle: 120px (verhindert versehentliches Wechseln)

**S Pen**
- Kurzer Klick: Undo
- Halten: Eraser
- Doppelklick: Stift ↔ Marker
- Bewusst nur außerhalb Live aktiv (Bühne = nur Finger)

## Chat-Architektur

Phase 2 aktiv seit 09/2026.

### Ebenen

| Ebene | Chat | Scope |
|---|---|---|
| Portfolio | `Project-Setup-Hub` (eigenes Claude-Projekt) | Priorisierung über alle Projekte, Cross-Projekt-Risiken |
| Projekt | `Nota Management-Hub` | Nota-Priorisierung, Architektur-Entscheidungen, Dispatch in Themen-Chats |
| Thema | `Canvas-Performance`, künftige weitere | Implementation, Bugs, Refactoring in einem abgegrenzten Bereich |

### Repo-Zuordnung (entscheidet das Routing)

| Datei | Repo | Ziel-Chat |
|---|---|---|
| `01-tech-doc.md`, `10-backlog.md`, `11-transferwissen.md` | `nota` | Nota Management-Hub |
| `03-projekte-uebersicht.md` und alle weiteren Hub-Files | `claude-hub` | Project-Setup-Hub |

### Regel für Session-Ende-Übergaben

Jede Übergabe nennt Ziel-Datei UND Ziel-Repo, nicht nur "Hub". Ohne
Repo-Angabe ist bei drei Hub-Ebenen nicht entscheidbar, wohin der Text
geht.

### Cross-Projekt

- Code-Seite von Backup (Flutter ↔ WebDAV) → Nota-Themen-Chat
- Server-/Infra-Seite (Nextcloud, Pi) → Homecloud-Projekt
- Hardware, Rechner, projektübergreifende Risiken → Project-Setup-Hub

