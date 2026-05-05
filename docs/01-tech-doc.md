# Nota – Tech-Doc

**Projekt:** Nota
**Repo:** github.com/Maks1m-Se/nota
**Lokal:** `C:\Git\nota`
**Letzter Stand:** 04.05.2026

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

Drei Chat-Arten mit klaren Rollen:

### Management-Hub (Haupt-Chat)

**Zweck:** Priorisierung, Architektur-Entscheidungen, Status-Tracking, Backlog-Pflege.

**Verwendung:** Start jeder Session. Bei Feature-Beginn: Hub generiert Prompt für Implementation-Chat (siehe unten). Bei Feature-Ende: Implementation-Chat übergibt Briefing zurück.

**Was hier NICHT passiert:** Keine konkrete Code-Arbeit. Keine Bug-Jagd.

### Implementation-Chat

**Zweck:** Konkrete Implementierung **eines** Features.

**Regel:** Pro größerem Feature ein neuer Chat. Verhindert 200+ Nachrichten-Chats.

**Was hier NICHT passiert:** Keine Priorisierungs-Diskussion (das macht der Hub). Keine parallelen Features.

### Bug-Chat (optional)

**Zweck:** Spezifische Bug-Jagd mit viel Kontext.

**Wann:** Nur wenn ein Bug länger dauert und Implementation-Chat sonst verschmutzt wird. Sonst Bug direkt im Implementation-Chat.

## Kommunikations-Prompts zwischen Chats

### Hub → Implementation (Feature starten)

Im Management-Hub generieren, dann in neuen Implementation-Chat einfügen:

---

> Du bist mein Implementation-Chat für das Feature **[FEATURE-NAME]** der Nota-App.
>
> **Scope dieses Chats:** Nur dieses Feature implementieren. Keine anderen Aufgaben.
>
> **Kontext:** Siehe Knowledge-Base (Tech-Doc, Backlog, Transferwissen) für Stack, Konventionen und bisherige Entscheidungen.
>
> **Konkretes Ziel:** [ZIEL aus dem Hub]
>
> **Akzeptanzkriterien:**
> - [Kriterium 1]
> - [Kriterium 2]
>
> **Out of Scope:** [was bewusst NICHT angefasst wird]
>
> **Bekannte Berührungspunkte:** [Files, Modelle, Provider die wahrscheinlich angefasst werden]
>
> Arbeitsweise: schrittweise, nach Kontext fragen wenn unklar, exakte Stellen nennen ("such X, ersetze mit Y"), bei längeren Refactorings ganzen Block. Hot Restart via Shift+R. Nach jedem Feature-Step: Bestätigung abwarten.
>
> Bei Abschluss generierst du mir ein Hub-Briefing (siehe Format in Tech-Doc).

---

### Implementation → Hub (Feature abschließen)

Am Ende des Implementation-Chats abfragen, dann ins Hub einfügen:

---

> Erstelle ein Hub-Briefing für das Feature **[FEATURE-NAME]**. Format:
>
> 1. **Was wurde gebaut:** kompakte Liste der Änderungen
> 2. **Welche Dateien wurden angefasst:** Pfad + kurze Beschreibung
> 3. **Neue Architektur-Entscheidungen:** mit Begründung (für Transferwissen)
> 4. **Verworfene Ansätze in diesem Feature:** mit Grund
> 5. **Neue Edge-Cases / Bugs gefunden:** wie gelöst
> 6. **Neue Konventionen oder Patterns:** falls etabliert
> 7. **Nicht erledigt / verschoben:** was war geplant, kam aber nicht durch
> 8. **Hub-Updates nötig:**
>    - Tech-Doc: [welche Sektion ergänzen]
>    - Backlog: [was erledigt, was neu, was umpriorisiert]
>    - Transferwissen: [welche Sektion ergänzen]
>
> Sei präzise, kurz, vollständig.

---

### Bug-Chat starten (selten)

---

> Du bist ein Bug-Jagd-Chat für die Nota-App. Ein Bug: **[BUG-BESCHREIBUNG]**.
>
> Kontext siehe Knowledge-Base. Bisherige Versuche im Implementation-Chat: [ZUSAMMENFASSUNG].
>
> Arbeite hypothesengetrieben: erst Vermutung, dann gezielte Diagnose-Schritte, dann Fix. Keine Spekulation ohne Verifikation.
