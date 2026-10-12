# Nota

Setlist-Manager für Musiker, gebaut für die Bühne. Flutter, Tablet.

![Nota Live-Modus mit Setlisten-Sidebar und Chord Chart](docs/screenshots/live-mode.png)

## Warum

Papier-Setlisten und PDF-Reader taugen auf der Bühne nicht. Nota zeigt Setliste, Songinfos und handschriftliche Notizen gleichzeitig, mit festen Positionen für Tonart und Solo-Markierung, damit das Auge beim Songwechsel nicht suchen muss.

## Features

- Bands, Songs, Setlisten, Gigs
- Handschriftliche Notizen pro Song (S Pen oder Finger), Chord Charts als PDF-Hintergrund
- Live-Modus in drei Varianten (Vollbild, mit Sidebar, nur Setliste), Swipe-Navigation
- Mehrere Sets pro Gig mit Pause-Screen dazwischen
- Übungsliste pro Song
- Backup und Restore über eigenen Nextcloud-Server

## Screenshots

![Nota Gig-Detail mit zwei Setlisten](docs/screenshots/gig.png)

Gig-Detail mit beiden Sets einer Show.

## Stack

- Flutter 3.41.6, Dart 3.11.4
- Provider ^6.1.5+1
- shared_preferences ^2.5.5

## Entwicklung

```bash
flutter pub get
flutter run
```

Zielgerät: Samsung Galaxy Tab S6 Lite, Landscape. Die App ist auf Tablet-Querformat ausgelegt.

## Status

Persönliches Projekt, im Live-Einsatz, kein Release, keine Beiträge gesucht.
