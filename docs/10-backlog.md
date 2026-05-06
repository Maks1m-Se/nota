# Nota – Backlog

**Letzter Stand:** 06.05.2026

## Aktuell in Arbeit

*Nichts. Letztes abgeschlossenes Feature: Set-Übergang im Live-Modus mit Pause-Screen.*

**Nächster Schritt:** Long-Press-Bug in Setlist/Gig fixen, dann weitere Pre-Gig-Items.

**Termine:** Erste echte Live-Nutzung am 09.05.2026 und 10.05.2026.

## Prio HOCH (vor Gigs am 09./10.05.)

- [ ] Long-Press in Setlist/Gig öffnet Canvas statt Edit-Dialog
- [ ] Canvas Vollbild konsistent: aus Setlist/Gig öffnet aktuell mit Sidebar, sollte wie Library Vollbild sein
- [ ] Drag & Drop: Setlists innerhalb Gig + Songs innerhalb Gig-Setlist verschieben
- [ ] Suche in Library
- [ ] Mehrere Songs/Setlists gleichzeitig hinzufügen
- [ ] Duplizieren von Songs/Setlists/Gigs
- [ ] Gig Kartenlayout überarbeiten

## Prio MITTEL

- [ ] Live-Modus-Indikator (Konzept nach erstem Gig)
- [ ] To-Practice-Feature (User-Wunsch hoch, aber nicht Gig-kritisch)
- [ ] Setlist Template System
- [ ] Gig Recap (Sterne, Highlights/Lowlights)
- [ ] Abbreviation-Vorschläge automatisch
- [ ] Gig Live Notes
- [ ] Canvas-Performance: Strich-Cloning O(n²) → mutable Append (verspätete Striche / gerade Linien bei langem Schreiben)

## Prio NIEDRIG

- [ ] Band Logo + Theming aus Logo-Farben
- [ ] Nextcloud Auto-Sync
- [ ] Mehrere Sketch-Seiten pro Song
- [ ] Startscreen (Recently Used, Upcoming Gigs)
- [ ] Canvas-Koordinaten relativ speichern (Sidebar-Scaling fix)
- [ ] Dark/Light Mode App-weit
- [ ] PDF Export Setlist
- [ ] Gerade Linie + Text Tool im Canvas
- [ ] Multilingual DE/EN
- [ ] Rotation für Chord Chart

## Offene Fragen

- Standard-Modus persistent speichern? (User wollte erst Erfahrung sammeln)
- Canvas-Sidebar Refactoring auf relative Koordinaten – tatsächlich nötig im Alltag?
- Auto-Sync Nextcloud: bei jedem Save? Nur beim App-Verlassen?
- Multiple Sketch-Pages: Tabs? Swipe? UI noch unklar
- Band Theming aus Logo: welche Farben extrahieren? Primary, Accent?
- Gig Recap Timing: sofort nach Gig oder optional? Pflichtfelder?
- PDF-Auflösung 2x – reicht das auf der Bühne? Im Alltag noch nicht getestet
- Live-Modus-Indikator: welche Form (am Rand, AppBar-Färbung, kleiner Punkt)?

## Erledigt (chronologisch absteigend)

**2026 (bis Mai):**
- Set-Übergang im Live-Modus: Pause-Screen mit "PAUSE" + nächstem Set + nächstem Song, Swipe weiter, Sidebar-Headers pro Set, Next-Hint zeigt "Pause" am Set-Ende
- PDF im Live-Modus sichtbar (Properties wurden nicht durchgereicht)
- PDF-Lag beim Verschieben/Skalieren behoben (Save erst onScaleEnd statt 60×/s)
- Chord Chart PDF Import als Hintergrund mit Verschieben/Skalieren
- Live-Modus aus Gig spielt korrekt nur Setlist-Songs
- Setting als Freitext (statt isOutdoor Boolean)
- Backwards-Compat-Migration für alte Backups
- Tab-Stop-Layout im Live-Modus
- 3 Live-Modi (Fullscreen / WithSidebar / SetlistOnly)
- Solo/Backing Badges
- Nextcloud WebDAV Backup/Restore (manuell)

**Davor:**
- Vollständiges Songs CRUD inkl. Edit-Dialog (Long Press)
- Gigs CRUD mit Setlist-Zuordnung, Long Press Rename
- Setlists CRUD mit Drag & Drop
- Canvas-System: Polygon-Striche, velocity-basiert, Glättung
- Tools: Pen, Highlighter (saveLayer transparent), Vektor-Eraser
- 8 Hintergründe (Dark/Light × Plain/Lined/Grid/Staff)
- Custom Color Picker, Breiten-Presets + Long-Press Slider
- Zoom mit zwei Fingern, Linie-zwischen-Fingern-Bug behoben
- S Pen Support: Kurz=Undo, Halten=Eraser, Doppelklick=Stift↔Marker
- Swipe-Navigation Live-Modus, Next-Song-Hinweis
- Immersive Mode global, Landscape-Lock

## Termine / Pflege-Notizen

- Vor jedem Gig: Backup auf Nextcloud (manuell)
- Bei Datenformat-Änderung im Modell: 4 Stellen prüfen (Modell, Provider `_load`, Provider `_save`, alle UI-Stellen mit neuem Song-Objekt)