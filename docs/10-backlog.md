# Nota – Backlog

**Letzter Stand:** 05.07.2026

## Aktuell in Arbeit

- [ ] Startscreen (Recently Used, Upcoming Gigs)

## ⚠ Offene Architektur-Entscheidung (BLOCKER für Gig-Setlist-Bearbeitung)

**Gig-Setlisten: Referenz oder Snapshot?**
- Aktueller Ist-Zustand: Setlisten in Gigs teilen die ID mit der Standalone-Setliste → sie sind effektiv **dieselbe** Setliste (Referenz).
- Symptom: „Gig → Setliste → + Song" fügt den Song auch in der Standalone-Version hinzu (gleiche ID, eine Quelle).
- `updateSetlist` wurde erweitert, sodass es Setlisten sowohl in der globalen Liste als auch in Gigs per ID aktualisiert. Funktioniert technisch, aber das Verhalten (shared) ist nicht bewusst entschieden.
- **Zu entscheiden:**
  - **Option 1 (Referenz/shared):** Eine Quelle der Wahrheit. Änderung wirkt überall. Einfacher.
  - **Option 2 (Snapshot/Kopie):** Jeder Gig hat eigene Setlist-Version mit eigener ID. Flexibler für Bühne, mehr Code.
- ⚠ Datenformat-Entscheidung → doppelt nachfragen, Backup vor Umsetzung.

## Prio HOCH

- [ ] Mehrere Songs/Setlists gleichzeitig hinzufügen
- [ ] Gig Kartenlayout überarbeiten
- [ ] Setlists-Screen Sortierung (Parität mit Library)
- [ ] Library Alphabet-Quick-Nav-Leiste (vertikal, bei alphabetischer + Key-Sortierung)
- [ ] Setlist-Copy-Rename defekt: Umbenennen kopierter Setlisten wirkt nicht. War als erledigt geführt → Regression oder nie sauber gefixt. Verdacht: `updateSetlist` trifft die Kopie-Instanz nicht / Rename schreibt auf falsche ID. Nächste Sequenz, hypothesengetrieben.

## Prio MITTEL

- [ ] Live-Modus-Indikator (Konzept nach erstem Gig)
- [ ] Setlist Template System (teilweise durch Duplicate abgedeckt)
- [ ] Gig Recap (Sterne, Highlights/Lowlights)
- [ ] Abbreviation-Vorschläge automatisch
- [ ] Gig Live Notes
- [ ] Canvas-Performance: Strich-Cloning O(n²) → mutable Append (verspätete Striche / gerade Linien bei langem Schreiben)
- [ ] Canvas Rest-Lag: periodische Save-Spikes — jeder Debounce-Save encodet den vollen Blob (base64-Charts dominieren) synchron. Fix: Chart-Base64 cachen / Encode off-isolate. Null Daten-Risiko.
- [ ] `quickStrokes`-Feld (Song-Model): ungenutzt. Entscheidung nutzen/entfernen offen.
- [ ] Cross-Band Practice-Startscreen: `allPracticeItems`-Getter liegt bereit, UI ausstehend.
- [ ] Practice-Screen cross-band: Sidebar-Badge zählt seit 06.07. alle Bands (`openPracticeCountAll`), der Screen dahinter (`PracticeScreen(bandId)`) ist aber weiter band-scoped → Badge N kann > angezeigte Items sein. Konsistenz-Fix: Screen ebenfalls cross-band (braucht Band-Zuordnung/-Label pro Item in der Liste). Eigener Scope.
- [ ] Backlog HOCH verifizieren: „Mehrere Songs/Setlists hinzufügen" + „Gig-Kartenlayout" gegen App-Stand prüfen.

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
- Auto-Sync Nextcloud: bei jedem Save? Nur beim App-Verlassen?
- Multiple Sketch-Pages: Tabs? Swipe? UI noch unklar
- Band Theming aus Logo: welche Farben extrahieren?
- Gig Recap Timing: sofort nach Gig oder optional?
- PDF-Auflösung 2x – reicht das auf der Bühne? Noch nicht im Bühnenlicht getestet
- Live-Modus-Indikator: welche Form?

## Erledigt (chronologisch absteigend)

**2026 (Juli):**
- Canvas-Save-Debounce: Stroke-Save aus dem Hot-Path (800ms + Lifecycle-Flush) → Zeichen-Lag massiv reduziert. Diagnose: `_save()` auskommentiert → Lag weg = Save als Täter bestätigt.
- Pre-Gig-Sprint: Library-Suche, Duplizieren (Songs/Setlists/Gigs), Drag&Drop (echt — war vorher fälschlich als erledigt geführt), Edit-Dialog, Vollbild-Fix, Live-Empty-Guard
- To-Practice Feature (via Claude Code, 4 Phasen): PracticeItem-Model, band-scoped Provider-Layer (backwards-compatible Load + inneres try-catch), Capture-Dialog (2 Entry-Points), Practice-Screen (Prio-Sort, Prio-Cycle, Erledigt-Sektion, Filter, Swipe-Delete), Amber-Badges (Library + Nav), Orphan-Delete (Items sterben mit dem Song).
- Startscreen-Dashboard (via Claude Code, 3 Phasen): Gig-Tag-Bug gefixt (tages-genauer Vergleich, HEUTE als dritter Zustand in Primary), zentrale Datums-Getter im Provider, `BandScaffold.initialIndex/initialGig`, Gig- + Practice-Widget (cross-band, Practice direkt abhakbar), Band-Grid 3-spaltig.

**2026 (Mai, Pre-Gig-Sprint):**
- Library-Suche (Filter title + artist, Live, mit Counter X/Y und Clear-Button)
- Setlist Duplicate (Setlists-Screen, Long-Press → „(Copy)")
- Rename-Bug-Fix (Provider vor await/pop, disposed-Context vermieden)
- Long-Press in Setlist/Gig öffnet Edit-Dialog statt Canvas
- Canvas-Vollbild konsistent aus Setlist/Gig (rootNavigator)
- Drag & Drop: Songs innerhalb Setlist + Setlists innerhalb Gig (Drag-Handle, Reihenfolge Key→Remove→Drag)
- Live-Modus Empty-State-Guard (kein Crash mehr bei leerer Setliste)
- updateSetlist erweitert: aktualisiert Setlisten auch in Gigs per ID
- Set-Übergang im Live-Modus: Pause-Screen, Swipe weiter, Sidebar-Headers, Next-Hint zeigt „Pause"
- PDF im Live-Modus sichtbar
- PDF-Lag beim Verschieben/Skalieren behoben (Save onScaleEnd statt 60×/s)

**Davor:**
- Chord Chart PDF Import als Hintergrund mit Verschieben/Skalieren
- Live-Modus aus Gig spielt korrekt nur Setlist-Songs
- Setting als Freitext, Backwards-Compat-Migration
- Tab-Stop-Layout, 3 Live-Modi, Solo/Backing Badges
- Nextcloud WebDAV Backup/Restore (manuell)
- Songs/Gigs/Setlists CRUD, Canvas-System, S Pen Support

## Termine / Pflege-Notizen

- Vor jedem Gig: Backup auf Nextcloud (manuell)
- Bei Datenformat-Änderung: 4 Stellen prüfen (Modell, `_load`, `_save`, alle UI-Stellen)