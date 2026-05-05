# Nota – Tech-Doc

**Projekt:** Nota
**Repo:** github.com/Maks1m-Se/nota
**Lokal:** `C:\Git\nota`
**Letzter Stand:** 05.05.2026

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

**Persistenz:** Alle Daten als ein einziges JSON-Blob in SharedPreferences. Chord Charts als Base64 im JSON.

**File-Struktur:**
```
lib/
├── models/        – reine Datenklassen
├── providers/     – State Management (BandProvider)
├── screens/       – pro Feature ein Ordner (bands, library, setlists, gigs, live, settings)
└── widgets/       – wiederverwendbare Widgets (drawing_canvas, drawing_toolbar)
```

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

## Daten / Backup

**Nextcloud WebDAV (manuelles Backup/Restore):**
- Server: `nextcloud.homecloudms.duckdns.org`
- Pfad: `/remote.php/dav/files/MaksimSendetski/Apps/Nota/nota_backup.json`
- Credentials: Bitwarden-Eintrag "Nota App - Nextcloud"

**Pi/Homecloud:**
- Hostname: `boxy3006@HomeCloudMS`, IP `192.168.2.200`

## Bekannte Einschränkungen

- Canvas-Striche als absolute Pixel gespeichert → Sidebar-Modus zeigt Canvas-Ausschnitt. Refactoring zu relativen Koordinaten im Backlog.
- Rotation für Chord Chart bewusst weggelassen, nachrüstbar.
- Nextcloud Backup nur manuell.
- Bei großen PDFs wächst Backup-Größe (Base64 im JSON).
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

## Chat-Architektur im Claude-Projekt

Phasen-Modell, abhängig vom tatsächlichen Dispatch-Bedarf.

### Phase 1 (aktuell): Ein Chat für alles

Ein Chat `Nota` deckt Code, Bugs, Refactoring, Priorisierung und Architektur-Entscheidungen ab. Keine Chat-Typ-Trennung, kein dedizierter Hub.

**Begründung:** Solo-Code-Projekt. Es läuft fast ausschließlich Code-Arbeit, kein echter Dispatch-Bedarf zwischen Disziplinen. Hub + Implementation-Chats wären Overhead.

**Disziplin im Single-Chat:**
- Scope-Disziplin pro Arbeitssequenz (ein Feature, ein Bug, eine Priorisierung)
- Bei ~150 Nachrichten Session-Ende einleiten und neuen Chat starten
- Knowledge-Updates am Ende jeder inhaltlich wichtigen Session

### Phase 2 (geplant): Hub + Themen-Chats

Wird eingeführt, sobald neue Disziplinen dazukommen, die echten Dispatch-Bedarf erzeugen (z.B. Logo-Design, Marketing). Geplante Struktur:

- `Nota – Hub` – Session-Planung, Priorisierung, Dispatch zwischen Themen
- `Nota – Code` – alle Implementation, Bugs, Refactoring
- `Nota – Design` – Logo, Theming, Visuelles
- weitere Themen-Chats analog

**Beim Phase-2-Switch zu definieren:**
- Anker-Text-Templates für Cross-Chat-Übergaben (Hub → Themen-Chat, Themen-Chat → Hub)
- Status-Update-Format (Themen-Chat → Hub, vermutlich session-basiert statt feature-basiert)
- Anpassung der Projekt-Anweisungen pro Chat (jeder Themen-Chat bekommt eigene Anweisungen mit Scope und Cross-Chat-Hinweisen)

### Phase 3: Weitere Themen

Weitere Themen-Chats analog ergänzen, sobald sich Disziplinen herausbilden, die regelmäßig auftauchen und sich gegenseitig stören würden.

### Cross-Projekt-Regel

- Code-Seite von Backup (Flutter ↔ WebDAV) → Nota-Code-Chat (in Phase 1: einfach im `Nota`-Chat)
- Server-/Infra-Seite (Nextcloud-Konfig, Pi) → Homecloud-Hub, nicht hier duplizieren